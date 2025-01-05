import os  # system functions
import sys
import numpy as np

import nipype.interfaces.io as nio  # Data i/o
import nipype.interfaces.fsl as fsl  # fsl
import nipype.pipeline.engine as pe  # pypeline engine
import nipype.interfaces.utility as util  # utility
import nipype.algorithms.modelgen as model  # model generation
import nipype.interfaces.workbench.cifti as nipype_wb

# the following libraries are needed for confound correction
from nipype.interfaces.freesurfer import Binarize
import nipype.algorithms.rapidart as ra

package_directory = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/bogdan_hcp_glm/libraries/'

if package_directory not in sys.path:
    sys.path.insert(0, package_directory)

import nipype_ext.workbench as wb


# this function was drafted by ChatGPT and modded by BP
def _hcp2mcflirt_motion_parameters(motion):
    # converts HCP motion regressors to MCFLIRT style for use by ArtifactDetect

    import numpy as np
    import os

    data = np.loadtxt(motion)

    cwd = os.getcwd();
    # Assuming the first six columns are the original parameters
    new_filepath = os.path.join(cwd, 'confounds.csv')

    trans = data[:,:3]
    rot = data[:,3:6]

    # convert from HCP degree convention to MCFLIRT radian convention
    rot = np.pi/180*rot

    data = np.hstack([rot, trans]);

    np.savetxt(new_filepath, data, delimiter='\t', fmt='%.6f')

    return new_filepath



# ensure data is a float
img2float = pe.Node(
    interface=fsl.ImageMaths(
        out_data_type='float', op_string='', suffix='_dtype'),
    name='img2float')


# motion correction would normally happen here if we wanted it, but we don't


# intensity normalization
getthresh = pe.Node(
    interface=fsl.ImageStats(op_string='-p 2 -p 98'),
    name='getthreshold')

threshold = pe.Node(
    interface=fsl.ImageMaths(out_data_type='char', suffix='_thresh'),
    name='threshold')

def getthreshop(thresh):
    return '-thr %.14f -Tmin -bin' % (0.1 * thresh[1])

medianval = pe.Node(
    interface=fsl.ImageStats(op_string='-k %s -p 50'),
    name='medianval')


dilatemask = pe.Node(
    interface=fsl.ImageMaths(suffix='_dil', op_string='-dilF'),
    name='dilatemask')

maskfunc = pe.Node(
    interface=fsl.ImageMaths(suffix='_mask', op_string='-mas'),
    name='maskfunc')

volintnorm = pe.Node(
    interface=fsl.ImageMaths(suffix='_intnorm'),
    name='volintnorm')

surfintnorm = pe.Node(
    interface=fsl.ImageMaths(suffix='_intnorm'),
    name='surfintnorm')

def getinormscale(medianvals):
    return '-mul %.14f' % (10000. / medianvals)


# extract csf timeseries

binarize_csf = pe.Node(Binarize(match=[4, 43]),
                         name="binarize_csf")  # Typical labels for lateral ventricles

erode_csf = pe.Node(fsl.maths.ErodeImage(kernel_shape='box',
                                         kernel_size=3),
                    name="erode_csf")

resample_csf = pe.Node(fsl.preprocess.ApplyWarp(interp='nn'),
                         name='resample_csf')

compute_csf_ts = pe.Node(fsl.utils.ImageMeants(),
    name="compute_csf_ts")

# spike detection
hcp2mcflirt_motion_params = pe.Node(util.Function(input_names=['motion'],
                                              output_names=['motion'],
                                              function=_hcp2mcflirt_motion_parameters),
                             name='hcp2mcflirt_motion_params')

art = pe.Node(
    interface=ra.ArtifactDetect(
        use_differences=[True, False],
        use_norm=True,
        norm_threshold=1,
        zintensity_threshold=3,
        parameter_source='FSL',
        mask_type='file'),
    name="spikedetection")

cifti2nifti = pe.Node(
    interface=wb.CiftiConvertNifti(
        smaller_dims=True),
    name='cifti2nii')

nifti2cifti = pe.Node(
    interface=wb.NiftiConvertCifti(),
    name='nii2cifti')

# highpass filter
meanfunc = pe.Node(
    interface=fsl.ImageMaths(op_string='-Tmean', suffix='_mean'),
    name='meanfunc')


def preproc_vol_motion_csf(hpcutoff, TR):
    preproc = pe.Workflow(name='preproc')

    inputnode = pe.Node(
        interface=util.IdentityInterface(fields=[
            'func','seg','motion']),
        name='inputspec')

    # this is a dirty way to add the meanfunc back in. I should pass '-add %s' somehow in a single consolidated command
    # so I don't have to just assume where in_file2 will be dropped
    highpass = pe.Node(
        interface=fsl.ImageMaths(suffix='_hpf', op_string='-bptf %.14f -1 -add ' % (0.5* hpcutoff / TR)),
        name='highpass')


    preproc.connect([
        (inputnode, img2float, [('func','in_file')]),

        # find intensity normalization parameters
        (img2float, getthresh, [('out_file', 'in_file')]),
        (img2float, threshold, [('out_file', 'in_file')]),
        (getthresh, threshold, [(('out_stat', getthreshop),'op_string')]),

        (img2float, medianval, [('out_file', 'in_file')]),
        (threshold, medianval, [('out_file', 'mask_file')]),

        # intensity norm volume. Probably superfluous but ensures CSF vector is numerically
        # the same in surface analysis as volumetric analysis rather than off by a scaling
        # factor.
        (threshold, dilatemask, [('out_file', 'in_file')]),
        (img2float, maskfunc, [('out_file', 'in_file')]),
        (dilatemask, maskfunc, [('out_file', 'in_file2')]),

        (maskfunc, volintnorm, [('out_file', 'in_file')]),
        (medianval, volintnorm, [(('out_stat', getinormscale), 'op_string')]),

        # get CSF timeseries
        (inputnode, binarize_csf, [('seg', 'in_file')]),
        (binarize_csf,  erode_csf, [('binary_file', 'in_file')]),
        (erode_csf, resample_csf, [('out_file', 'in_file')]),
        (volintnorm, resample_csf, [('out_file', 'ref_file')]),
        (resample_csf, compute_csf_ts, [('out_file', 'mask')]),
        (volintnorm, compute_csf_ts, [('out_file', 'in_file')]),

        # find motion spikes. Hard to know if this works, because this data is low motion
        # so few true positives to detect.
        (inputnode, hcp2mcflirt_motion_params, [('motion', 'motion')]),
        (hcp2mcflirt_motion_params, art, [('motion','realignment_parameters')]),
        (maskfunc, art, [('out_file', 'realigned_files')]),
        (dilatemask, art, [('out_file', 'mask_file')]),

        # highpass filter volume data (save mean, filter then add mean back in)
        (volintnorm, meanfunc, [('out_file', 'in_file')]),
        (volintnorm, highpass, [('out_file', 'in_file')]),
        (meanfunc, highpass, [('out_file', 'in_file2')]),
    ])

    return preproc

def preproc_surf_motion_csf(hpcutoff, TR):
    preproc = pe.Workflow(name='preproc')

    inputnode = pe.Node(
        interface=util.IdentityInterface(fields=[
            'func_vol','func_surf','seg','motion']),
        name='inputspec')

    # this is a dirty way to add the meanfunc back in. I should pass '-add %s' somehow in a single consolidated command
    # so I don't have to just assume where in_file2 will be dropped
    highpass = pe.Node(
        interface=fsl.ImageMaths(suffix='_hpf', op_string='-bptf %.14f -1 -add ' % (0.5* hpcutoff / TR)),
        name='highpass')


    preproc.connect([
        (inputnode, img2float, [('func_vol','in_file')]),

        # find intensity normalization parameters
        (img2float, getthresh, [('out_file', 'in_file')]),
        (img2float, threshold, [('out_file', 'in_file')]),
        (getthresh, threshold, [(('out_stat', getthreshop),'op_string')]),

        (img2float, medianval, [('out_file', 'in_file')]),
        (threshold, medianval, [('out_file', 'mask_file')]),

        # intensity norm volume. Probably superfluous but ensures CSF vector is numerically
        # the same in surface analysis as volumetric analysis rather than off by a scaling
        # factor.
        (threshold, dilatemask, [('out_file', 'in_file')]),
        (img2float, maskfunc, [('out_file', 'in_file')]),
        (dilatemask, maskfunc, [('out_file', 'in_file2')]),

        (maskfunc, volintnorm, [('out_file', 'in_file')]),
        (medianval, volintnorm, [(('out_stat', getinormscale), 'op_string')]),

        # get CSF timeseries
        (inputnode, binarize_csf, [('seg', 'in_file')]),
        (binarize_csf,  erode_csf, [('binary_file', 'in_file')]),
        (erode_csf, resample_csf, [('out_file', 'in_file')]),
        (volintnorm, resample_csf, [('out_file', 'ref_file')]),
        (resample_csf, compute_csf_ts, [('out_file', 'mask')]),
        (volintnorm, compute_csf_ts, [('out_file', 'in_file')]),

        # find motion spikes. Hard to know if this works, because this data is low motion
        # so few true positives to detect.
        (inputnode, hcp2mcflirt_motion_params, [('motion', 'motion')]),
        (hcp2mcflirt_motion_params, art, [('motion','realignment_parameters')]),
        (maskfunc, art, [('out_file', 'realigned_files')]),
        (dilatemask, art, [('out_file', 'mask_file')]),

        # convert surf to nifti for bandpass filtering
        (inputnode, cifti2nifti, [('func_surf','cifti_in')]),

        # intensity normalize surface (already normed to mean, but we need it normed to the
        # median FEAT style)
        (cifti2nifti, surfintnorm, [('out_file','in_file')]),
        (medianval, surfintnorm, [(('out_stat', getinormscale), 'op_string')]),

        # highpass filter surface data (save mean, filter then add mean back in)
        (surfintnorm, meanfunc, [('out_file', 'in_file')]),
        (surfintnorm, highpass, [('out_file', 'in_file')]),
        (meanfunc, highpass, [('out_file', 'in_file2')]),

        # convert nifti back to cifti
        (highpass, nifti2cifti, [('out_file','nifti_in')]),
        (inputnode, nifti2cifti, [('func_surf','cifti_template')])
    ])

    return preproc


def preproc_surf_hcp(hpcutoff, TR, spatialSmoothingSigma=None):
    '''
    spatialSmoothingSigma - it appears minimally preprocessed hcp data has already had surface smoothing performed,
                            meaning you can't just supply a naive sigma here, you have to account for this prior 2mm
                            smoothing. The way to do that is as follows

                            origSm = 2
                            spatialSmoothingSigma = np.sqrt(spatialSmoothingSigma**2 - origSm**2) / (2*sqrt(2*np.log(2)))

                            The math was copied from here:
                            https://github.com/Washington-University/HCPpipelines/blob/master/TaskfMRIAnalysis/scripts/TaskfMRILevel1.sh
    '''
    preproc = pe.Workflow(name='preproc')

    inputnode = pe.Node(
        interface=util.IdentityInterface(fields=[
            'func_vol','func_surf','seg','motion','surf_left','surf_right']),
        name='inputspec')

    # this is a dirty way to add the meanfunc back in. I should pass '-add %s' somehow in a single consolidated command
    # so I don't have to just assume where in_file2 will be dropped
    highpass = pe.Node(
        interface=fsl.ImageMaths(suffix='_hpf', op_string='-bptf %.14f -1 -add ' % (0.5* hpcutoff / TR)),
        name='highpass')


    preproc.connect([
        (inputnode, img2float, [('func_vol','in_file')]),

        # find intensity normalization parameters
        (img2float, getthresh, [('out_file', 'in_file')]),
        (img2float, threshold, [('out_file', 'in_file')]),
        (getthresh, threshold, [(('out_stat', getthreshop),'op_string')]),

        (img2float, medianval, [('out_file', 'in_file')]),
        (threshold, medianval, [('out_file', 'mask_file')]),

        # intensity normalize surface (already normed to mean, but we need it normed to the
        # median FEAT style)
        (cifti2nifti, surfintnorm, [('out_file','in_file')]),
        (medianval, surfintnorm, [(('out_stat', getinormscale), 'op_string')]),

        # highpass filter surface data (save mean, filter then add mean back in)
        (surfintnorm, meanfunc, [('out_file', 'in_file')]),
        (surfintnorm, highpass, [('out_file', 'in_file')]),
        (meanfunc, highpass, [('out_file', 'in_file2')]),

        # convert nifti back to cifti
        (highpass, nifti2cifti, [('out_file','nifti_in')]),
        (inputnode, nifti2cifti, [('func_surf','cifti_template')])
    ])

    if not spatialSmoothingSigma:
        preproc.connect([
            # convert surf to nifti for bandpass filtering
            (inputnode, cifti2nifti, [('func_surf','cifti_in')]),
        ])
    else:
        surfsmooth = pe.Node(
            interface=nipype_wb.CiftiSmooth(
                direction='COLUMN',
                sigma_surf=spatialSmoothingSigma,
                sigma_vol=spatialSmoothingSigma),
            name='surfsmooth')

        preproc.connect([
            # convert surf to nifti for bandpass filtering
            (inputnode, surfsmooth, [('func_surf','in_file')]),
            (inputnode, surfsmooth, [('surf_left', 'left_surf'),
                                     ('surf_right', 'right_surf')]),
            (surfsmooth, cifti2nifti, [('out_file','cifti_in')])
        ])

    return preproc

