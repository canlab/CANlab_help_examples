# code adapted from
# https://nipype.readthedocs.io/en/latest/users/examples/fmri_fsl.html
#
# This is supposed to simulate a FEAT run, but it doesn't actually use
# FEAT, it uses direct calls to all the constituent functions FEAT otherwise
# calls. Constructing this requires careful comparison with feat output
# logs to make sure everything matches. In order to ensure this I began
# by replicating the results of the HCP provided *fsf files. They can now be
# modified as needed to obtain additional functionality (e.g. single
# trial designs, motion correction, spike detection, or whatever you like).
#
# This version redoes the HCP GLMs so that I could get LR and RL GLMs maps,
# not just the mean GLM maps for RSA analysis. HCP shares the second level 
# results that average over the different acquisition directions, but not
# the first level contrasts. You could also obtain those by rerunning the 
# HCPPipeline scripts, and those were used as a comparator to ensure equivalence
# with these scripts. The HCPPipelines don't actually use pipeline objects
# though and are unlikely to be as robust when modified as this nipype version.
#
# Second level analysis with nipype introduces a technical problem because
# I need to iterate my firstlevel GLM models over subjects, tasks and
# directions, while my second level (but still subject level) FLAMEO
# instances need to be iterated over subjects and tasks. This requires
# nested iterables which is not supported by nipype. Instead I've implemented
# two pipelines, l1pipeline and l2pipeline. These are run in sequence and
# one serves as the input for the other. It's a bit messy at that point.
# Apparenlty Nipype 2 will introduce better handling of iterables to allow
# linking two pipelines of this kind. In the meantime though, this works.
#
# The second level tstats can be compared against the 
# ${SID}_tfMRI_${TASK}_level2_hp200_s2_MSMAll.dscalar.nii files in 
# /dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/ on discovery (which points
# to the local copy of the AWS files). For example,
# /dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/100307/MNINonLinear/Results/tfMRI_EMOTION/tfMRI_EMOTION_hp200_s2_level2_MSMAll.feat/100307_tfMRI_EMOTION_level2_hp200_s2_MSMAll.dscalar.nii

from __future__ import print_function
from __future__ import division
from builtins import str
from builtins import range

import os  # system functions
import sys
import argparse
import numpy as np

import nipype.interfaces.io as nio  # Data i/o
import nipype.interfaces.fsl as fsl  # fsl
import nipype.pipeline.engine as pe  # pypeline engine
import nipype.interfaces.utility as util  # utility
import nipype.algorithms.modelgen as model  # model generation

# the following libraries are needed for confound correction
from nipype.interfaces.freesurfer import Binarize
import nipype.algorithms.rapidart as ra

package_directory = '../libraries/'

if package_directory not in sys.path:
    sys.path.insert(0, package_directory)

import nipype_ext.workbench as wb
import nipype_ext.vifs as vifs

#from glm.preproc import preproc_surf_motion_csf
from glm.preproc import preproc_surf_hcp
from glm.designs import select_trials
#from glm.utils import assemble_csf_motion_confounds_mat, merge_trial_vifs
from glm.utils import merge_trial_vifs

fsl.FSLCommand.set_default_output_type('NIFTI_GZ')

data_dir = os.path.abspath('/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/')

hpcutoff = 200
TR = 0.72

# ########################## #
# Run specific configuration #
# ########################## #


infosource = pe.Node(
    interface=util.IdentityInterface(fields=['subject_id','task','direction']), name="infosource")

datasource = pe.Node(
    interface=nio.DataGrabber(
        infields=['subject_id', 'task', 'direction'], 
        outfields=['func_vol', 'func_surf', 
                   'surf_left', 'shape_left', 
                   'surf_right', 'shape_right', 
                   'seg', 'motion']),
    name='datasource')
datasource.inputs.base_directory = data_dir
datasource.inputs.template='*'
datasource.inputs.field_template={'func_vol': '%s/MNINonLinear/Results/tfMRI_%s_%s/tfMRI_%s_%s.nii.gz', # this isn't actually used but is useful if you modify this script to correct for confounds
                            'func_surf': '%s/MNINonLinear/Results/tfMRI_%s_%s/tfMRI_%s_%s_Atlas_MSMAll.dtseries.nii',
                            'surf_left': '%s/MNINonLinear/fsaverage_LR32k/%s.L.midthickness.32k_fs_LR.surf.gii',
                            'shape_left': '%s/MNINonLinear/fsaverage_LR32k/%s.L.atlasroi.32k_fs_LR.shape.gii',
                            'surf_right': '%s/MNINonLinear/fsaverage_LR32k/%s.R.midthickness.32k_fs_LR.surf.gii',
                            'shape_right': '%s/MNINonLinear/fsaverage_LR32k/%s.R.atlasroi.32k_fs_LR.shape.gii',
                            'seg': '%s/MNINonLinear/aparc+aseg.nii.gz',
                            'motion': '%s/MNINonLinear/Results/tfMRI_%s_%s/Movement_Regressors.txt'}
datasource.inputs.template_args = {'func_vol': [['subject_id','task','direction',
                                                 'task','direction']],
                                   'func_surf': [['subject_id','task','direction',
                                                  'task','direction']],
                                   'surf_left': [['subject_id','subject_id']],
                                   'shape_left': [['subject_id','subject_id']],
                                   'surf_right': [['subject_id','subject_id']],
                                   'shape_right': [['subject_id','subject_id']],
                                   'seg': [['subject_id']],
                                   'motion': [['subject_id','task','direction']]}
datasource.inputs.sort_filelist = True


datasink = pe.Node(
    interface=nio.DataSink(),
    name="datasink")

datasink.inputs.regexp_substitutions = [
    # this assumes that you prefix your datasink outputs with a results folder in every case
    # if you change results.X to anything else other than results, modify this accordingly
    (r'results/([\w\/]+)\/_direction_(LR|RL)_subject_id_(\d+)_task_(\w+)', r'results/\4/\3/\2/\1'),  # Creates directories like 'subj/task/direction'
    (r'_direction_(LR|RL)_subject_id_(\d+)_task_(\w+)', r'\3/\2/\1'),  # Creates directories like 'subj/task/direction'
    (r'tfMRI_.*_[LR][LR]_dtype_thresh.nii.gz', r'nifti_mask.nii.gz'),
]


# ###################### #
# Preprocessing Workflow #
# ###################### #
preproc = preproc_surf_hcp(hpcutoff, TR)

# ########################## #
# firstlvl modeling workflow #
# ########################## #

# task specific event configuration

def subjectinfo(subject_id, task, direction):
    from glm.designs import hcp_events
    from nipype.interfaces.base import Bunch
    from copy import deepcopy

    names, onsets, dur = hcp_events(subject_id, task, direction)

    output = [Bunch(conditions=names,
                    onsets=deepcopy(onsets),
                    durations=deepcopy(dur),
                    amplitudes=None,
                    tmod=None,
                    pmod=None,
                    regressor_names=None,
                    regressors=None)]

    return output, names

subjectinfo_node = pe.Node(util.Function(input_names=['subject_id', 'task', 'direction'],
                                 output_names=['subject_info','contrast_names'],
                                 function=subjectinfo),
                        name='subjectinfo_node')

# task specific contrast configuration

def select_contrasts(contrast_names):
    import re

    contrasts = []
    for name in contrast_names:
        if bool(re.match(r'^Task-.*$',name)):
            this_cont = [name,'T',[name],[1]]
            contrasts.append(this_cont)

    return contrasts

contrastselect_node = pe.Node(util.Function(input_names=['contrast_names'],
                                            output_names=['contrasts'],
                                            function=select_contrasts),
                        name='contrastselect_node')


modelfit = pe.Workflow(name='modelfit')

inputnode_modelfit = pe.Node(
    interface=util.IdentityInterface(fields=[
        'subject_id','task','direction',
        'func',
        'surf_left','shape_left',
        'surf_right','shape_right']),
    name='inputspec')

designspec = pe.Node(interface=model.SpecifyModel(), 
    name="designspec")
level1design = pe.Node(interface=fsl.Level1Design(), 
    iterfield=['session_info','contrasts'],
    name="level1design")
vifestimate = pe.Node(
    vifs.VIFCalculation(), 
    name='vifestimate')
modelgen = pe.Node(
    interface=fsl.FEATModel(),
    name='modelgen')
splitcifti = pe.Node(
    interface=wb.CiftiSeparate(
        volume_all = True,
        metric = ['CORTEX_LEFT', 'CORTEX_RIGHT']),
    name='splitcifti')
lsurfdilate = pe.Node(
    interface=wb.MetricDilate(
        distance=50,
        nearest=True),
    name='lsurfdilate')
rsurfdilate = pe.Node(
    interface=wb.MetricDilate(
        distance=50,
        nearest=True),
    name='rsurfdilate')


# the parameters for the next couple interfaces are taken from lines 573-585 of 
# https://github.com/Washington-University/HCPpipelines/blob/master/TaskfMRIAnalysis/scripts/TaskfMRILevel1.sh
vol_modelestimate = pe.Node(
    interface=fsl.FILMGLS(smooth_autocorr=True, mask_size=5, threshold=1),
    name='volmodelestimate')
LSurf_modelestimate = pe.Node(
    interface=fsl.FILMGLS(smooth_autocorr=True, mode='surface', mask_size=15, brightness_threshold=5),
    name='lsurfmodelestimate')
RSurf_modelestimate = pe.Node(
    interface=fsl.FILMGLS(smooth_autocorr=True, mode='surface', mask_size=15, brightness_threshold=5),
    name='rsurfmodelestimate')

cifticreatedensecope = pe.MapNode(
    interface=wb.CiftiCreateDenseTimeseries(),
    iterfield=['left_metric', 'right_metric', 'volume'],
    name='cifticreatedensecope')

cifticreatedensevarcope = pe.MapNode(
    interface=wb.CiftiCreateDenseTimeseries(),
    iterfield=['left_metric', 'right_metric', 'volume'],
    name='cifticreatedensevarcope')

cifticreatedenseres4 = pe.Node(
    interface=wb.CiftiCreateDenseTimeseries(),
    name='cifticreatedenseres4')

cifticreatedensetstats = pe.MapNode(
    interface=wb.CiftiCreateDenseTimeseries(),
    iterfield=['left_metric', 'right_metric', 'volume'],
    name='cifticreatedenseres4')

cifticreatedensetstat = pe.MapNode(
    interface=wb.CiftiCreateDenseTimeseries(),
    iterfield=['left_metric', 'right_metric', 'volume'],
    name='cifticreatedensetstat')

cifticreatedensezstat = pe.MapNode(
    interface=wb.CiftiCreateDenseTimeseries(),
    iterfield=['left_metric', 'right_metric', 'volume'],
    name='cifticreatedensezstat')

# code to merge copes after running model fitting
# function provied by ChatGPT
def natural_sort(files):
    import re

    def atoi(text):
        return int(text) if text.isdigit() else text

    def natural_keys(text):
        return [atoi(c) for c in re.split('(\d+)', text)]

    sorted_files = sorted(files, key=natural_keys)
    return sorted_files

sortcopes_node = pe.Node(util.Function(input_names=['files'],
                                 output_names=['files'],
                                 function=natural_sort),
                        name='sortcopes_node')

# these merge all copes within a run across conditions
copemerge = pe.Node(
    interface=wb.CiftiMerge(),
    name="copemerge")

varcopemerge = pe.Node(
    interface=wb.CiftiMerge(),
    name="varcopemerge")

tstatmerge = pe.Node(
    interface=wb.CiftiMerge(),
    name="tstatmerge")

zstatmerge = pe.Node(
    interface=wb.CiftiMerge(),
    name="zstatmerge")

modelfit.connect([
    (inputnode_modelfit, subjectinfo_node, [('subject_id', 'subject_id'),
                                                 ('task','task'),
                                                 ('direction','direction')]),

    (subjectinfo_node, contrastselect_node, [('contrast_names','contrast_names')]),

    (inputnode_modelfit, splitcifti, [('func','in_file')]),
    (splitcifti, designspec, [('volume_all_out', 'functional_runs')]),

    (subjectinfo_node, designspec, [('subject_info','subject_info')]),

    (designspec, level1design, [('session_info', 'session_info')]),
    (contrastselect_node, level1design, [('contrasts', 'contrasts')]),

    (level1design, modelgen, [('fsf_files', 'fsf_file'), 
                              ('ev_files', 'ev_files')]),

    (splitcifti, vol_modelestimate, [('volume_all_out', 'in_file')]),
    (modelgen, vol_modelestimate, [('design_file', 'design_file'),
                                   ('con_file', 'tcon_file')]),


    (inputnode_modelfit, lsurfdilate, [('surf_left', 'surface')]),
    (splitcifti, lsurfdilate, [('CORTEX_LEFT_out', 'metric')]),

    (inputnode_modelfit, LSurf_modelestimate, [('surf_left', 'surface')]),
    (lsurfdilate, LSurf_modelestimate, [('out_file', 'in_file')]),
    (modelgen, LSurf_modelestimate, [('design_file', 'design_file'),
                                     ('con_file', 'tcon_file')]),


    (inputnode_modelfit, rsurfdilate, [('surf_right', 'surface')]),
    (splitcifti, rsurfdilate, [('CORTEX_RIGHT_out', 'metric')]),

    (inputnode_modelfit, RSurf_modelestimate, [('surf_right', 'surface')]),
    (rsurfdilate, RSurf_modelestimate, [('out_file', 'in_file')]),
    (modelgen, RSurf_modelestimate, [('design_file', 'design_file'),
                                     ('con_file', 'tcon_file')]),

    # reassemble and merge copes
    (vol_modelestimate, cifticreatedensecope, [('copes', 'volume')]),
    (splitcifti, cifticreatedensecope, [('volume_all_label_out', 'volume_label')]),
    (inputnode_modelfit, cifticreatedensecope, [('shape_left', 'left_roi'),
                                                ('shape_right', 'right_roi')]),
    (LSurf_modelestimate, cifticreatedensecope, [('copes', 'left_metric')]),
    (RSurf_modelestimate, cifticreatedensecope, [('copes', 'right_metric')]),

    (cifticreatedensecope, copemerge, [('out_file', 'cifti')]),

    # reassemble and merge varcopes
    (vol_modelestimate, cifticreatedensevarcope, [('varcopes', 'volume')]),
    (splitcifti, cifticreatedensevarcope, [('volume_all_label_out', 'volume_label')]),
    (inputnode_modelfit, cifticreatedensevarcope, [('shape_left', 'left_roi'),
                                                   ('shape_right', 'right_roi')]),
    (LSurf_modelestimate, cifticreatedensevarcope, [('varcopes', 'left_metric')]),
    (RSurf_modelestimate, cifticreatedensevarcope, [('varcopes', 'right_metric')]),

    (cifticreatedensevarcope, varcopemerge, [('out_file', 'cifti')]),

    # reassemble and merge zstat
    (vol_modelestimate, cifticreatedensezstat, [('zstats', 'volume')]),
    (splitcifti, cifticreatedensezstat, [('volume_all_label_out', 'volume_label')]),
    (inputnode_modelfit, cifticreatedensezstat, [('shape_left', 'left_roi'),
                                                   ('shape_right', 'right_roi')]),
    (LSurf_modelestimate, cifticreatedensezstat, [('zstats', 'left_metric')]),
    (RSurf_modelestimate, cifticreatedensezstat, [('zstats', 'right_metric')]),

    (cifticreatedensezstat, zstatmerge, [('out_file', 'cifti')]),

    # reassemble and merge tstat
    (vol_modelestimate, cifticreatedensetstat, [('tstats', 'volume')]),
    (splitcifti, cifticreatedensetstat, [('volume_all_label_out', 'volume_label')]),
    (inputnode_modelfit, cifticreatedensetstat, [('shape_left', 'left_roi'),
                                                   ('shape_right', 'right_roi')]),
    (LSurf_modelestimate, cifticreatedensetstat, [('tstats', 'left_metric')]),
    (RSurf_modelestimate, cifticreatedensetstat, [('tstats', 'right_metric')]),

    (cifticreatedensetstat, tstatmerge, [('out_file', 'cifti')]),

    # reassemble res4
    (vol_modelestimate, cifticreatedenseres4, [('residual4d', 'volume')]),
    (splitcifti, cifticreatedenseres4, [('volume_all_label_out', 'volume_label')]),
    (inputnode_modelfit, cifticreatedenseres4, [('shape_left', 'left_roi'),
                                               ('shape_right', 'right_roi')]),
    (LSurf_modelestimate, cifticreatedenseres4, [('residual4d', 'left_metric')]),
    (RSurf_modelestimate, cifticreatedenseres4, [('residual4d', 'right_metric')]),


    (subjectinfo_node, vifestimate, [('contrast_names','contrast_names')]),
    (modelgen, vifestimate, [('design_file','design_matrix')]),
])


# actually running the first level scripts
firstlevel = pe.Workflow(name='firstlevel')
firstlevel.connect(
    [(preproc, modelfit, [('nii2cifti.out_file', 'inputspec.func'),
                         ]),
])




firstlevel.inputs.modelfit.designspec.input_units = 'secs'
firstlevel.inputs.modelfit.designspec.time_repetition = TR
firstlevel.inputs.modelfit.designspec.high_pass_filter_cutoff = hpcutoff

firstlevel.inputs.modelfit.level1design.interscan_interval = TR
firstlevel.inputs.modelfit.level1design.bases = {'dgamma': {'derivs': True}}
firstlevel.inputs.modelfit.level1design.model_serial_correlations = True

############################
### second level scripts ###
############################

infosource2 = pe.Node(
    interface=util.IdentityInterface(fields=['subject_id','task']), name="infosource")

datasource2a = pe.Node(
    interface=nio.DataGrabber(
        infields=['subject_id', 'task'],
        outfields=['surf_left', 'shape_left',
                   'surf_right', 'shape_right']),
    name='datasource2a')
datasource2a.inputs.base_directory = data_dir
datasource2a.inputs.template='*'
datasource2a.inputs.field_template={'surf_left': '%s/MNINonLinear/fsaverage_LR32k/%s.L.midthickness.32k_fs_LR.surf.gii',
                            'shape_left': '%s/MNINonLinear/fsaverage_LR32k/%s.L.atlasroi.32k_fs_LR.shape.gii',
                            'surf_right': '%s/MNINonLinear/fsaverage_LR32k/%s.R.midthickness.32k_fs_LR.surf.gii',
                            'shape_right': '%s/MNINonLinear/fsaverage_LR32k/%s.R.atlasroi.32k_fs_LR.shape.gii'}
datasource2a.inputs.template_args = {'surf_left': [['subject_id','subject_id']],
                                   'shape_left': [['subject_id','subject_id']],
                                   'surf_right': [['subject_id','subject_id']],
                                   'shape_right': [['subject_id','subject_id']]}
datasource2a.inputs.sort_filelist = True

datasource2b = pe.Node(
    interface=nio.DataGrabber(
        infields=['subject_id', 'task', 'direction'],
        outfields=['cope', 'varcope', 'mask', 'res', 'dof']),
    iterables=('direction', ['LR', 'RL']),
    name='datasource2b')
datasource2b.inputs.template='*'
datasource2b.inputs.field_template={'cope': '%s/%s/%s/firstlevel/copes/merged_cifti.dscalar.nii',
                                    'varcope': '%s/%s/%s/firstlevel/varcopes/merged_cifti.dscalar.nii',
                                    'mask': '%s/%s/%s/firstlevel/nifti_mask.nii.gz',
                                    'res': '%s/%s/%s/firstlevel/res4/dense_cifti.dtseries.nii',
                                    'dof': '%s/%s/%s/firstlevel/dof'}
datasource2b.inputs.template_args = {'cope': [['task','subject_id','direction']],
                                     'varcope': [['task','subject_id','direction']],
                                     'mask': [['task','subject_id','direction']],
                                     'res': [['task','subject_id','direction']],
                                     'dof': [['task','subject_id','direction']]}

datasource2b.inputs.sort_filelist = True

join_datasource2b = pe.JoinNode(
    interface=util.IdentityInterface(fields=['copes','varcopes','masks','res','dof']),
    joinsource="datasource2b",
    joinfield=['copes','varcopes','masks','res','dof'],
    name='joindatasource2b')

datasink2 = pe.Node(
    interface=nio.DataSink(),
    name="datasink")

datasink2.inputs.regexp_substitutions = [
    # this assumes that you prefix your datasink outputs with a results folder in every case
    # if you change results.X to anything else other than results, modify this accordingly
    (r'results/([\w\/]+)\/_subject_id_(\d+)_task_(\w+)', r'results/\3/\2/\1'),  # Creates directories like 'subj/task/direction'
    (r'_subject_id_(\d+)_task_(\w+)', r'\2/\1'),  # Creates directories like 'subj/task/direction'
]

secondlevel = pe.Workflow(name='secondlevel')

level2model = pe.Node(interface=fsl.L2Model(), name='l2model')

inputnode_secondlevel = pe.Node(
    interface=util.IdentityInterface(fields=[
        'copes', 'varcopes', 
        'masks', 'res', 'dof',
        'surf_left','shape_left',
        'surf_right','shape_right']),
    name='inputspec')

# utility function for dealing with MapNode outputs
def pickfirst(files):
    if isinstance(files, list):
        return files[0]
    else:
        return files

def num_copes(files):
    return len(files)

level2model = pe.Node(interface=fsl.L2Model(), name='l2model')

# these merge a condition across runs
copemerge2 = pe.MapNode(
    interface=fsl.Merge(dimension='t'),
    iterfield='in_files',
    name="copemerge2")

varcopemerge2 = pe.MapNode(
    interface=fsl.Merge(dimension='t'),
    iterfield='in_files',
    name="varcopemerge2")

mergemasks = pe.Node(
   interface=fsl.ImageMaths(out_data_type='int', op_string='-Tmean'),
   name='mergemasks')

cope2nifti = pe.MapNode(
    interface=wb.CiftiConvertNifti(
        smaller_dims=True),
    iterfield='cifti_in',
    name='cope2nii')

splitcopes = pe.MapNode(
    interface=fsl.utils.Split(dimension='t'),
    iterfield='in_file',
    name="splitcopes")

def matchfiles(filelist):
    '''
    Takes a list and resorts it by the orthogonal dimension. For instance,
    matchfiles([['a', 'b'], ['1', '2'], ['A', 'B']]) -> [['a', '1', 'A'], ['b', '2', 'B']]
    '''
    return [list(elem) for elem in zip(*filelist)]

matchfiles1_node = pe.Node(
    interface=util.Function(
        input_names='filelist',
        output_names='copes',
        function=matchfiles),
    name='matchfiles1_node')

varcope2nifti = pe.MapNode(
    interface=wb.CiftiConvertNifti(
        smaller_dims=True),
    iterfield='cifti_in',
    name='varcope2nii')

splitvarcopes = pe.MapNode(
    interface=fsl.utils.Split(dimension='t'),
    iterfield='in_file',
    name="splitvarcopes")

matchfiles2_node = pe.Node(
    interface=util.Function(
        input_names='filelist',
        output_names='varcopes',
        function=matchfiles),
    name='matchfiles2_node')

mkmask = pe.Node(
    interface=fsl.ImageMaths(op_string='-abs -bin -fillh'),
    name='mkmask')

def mkdofbrain_opstring(dof):
    these_dof = []
    for d in dof:
        with open(d, 'r') as file:
           these_dof.append(file.readline().strip())
    return ['-Tstd -bin -mul %d' % int(d) for d in these_dof]

mkdofbrain = pe.MapNode(
    interface=fsl.ImageMaths(),
    iterfield=['in_file','op_string'],
    name="mkdofbrain")

dof2nifti = pe.MapNode(
    interface=wb.CiftiConvertNifti(smaller_dims=True),
    iterfield='cifti_in',
    name="dof2nifti")

dofmerge = pe.MapNode(
    interface=fsl.Merge(dimension='t'),
    iterfield='in_files',
    name="dofmerge")

doffloor = pe.Node(
    interface=fsl.ImageMaths(op_string='-Tmin -bin'),
    iterfield='in_file',
    name="doffloor")

flameo = pe.MapNode(
    interface=fsl.FLAMEO(run_mode='fe'),
    name="flameo",
    iterfield=['cope_file', 'var_cope_file'])

def selectFirstVol(x):
    if isinstance(x, list):
        return [('vol1', f'{x[0]} -select 1 1')]
    else:
        return [('vol1', f'{x} -select 1 1')]

ciftisplit = pe.MapNode(
    interface=wb.CiftiMath(expression='vol1'),
    iterfield='in_vars',
    name='ciftisplit')

cope2cifti = pe.MapNode(
    interface=wb.NiftiConvertCifti(),
    iterfield='nifti_in',
    name='cope2cifti')

tstat2cifti = pe.MapNode(
    interface=wb.NiftiConvertCifti(),
    iterfield='nifti_in',
    name='tstat2cifti')

zstat2cifti = pe.MapNode(
    interface=wb.NiftiConvertCifti(),
    iterfield='nifti_in',
    name='zstat2cifti')

varcope2cifti = pe.MapNode(
    interface=wb.NiftiConvertCifti(),
    iterfield='nifti_in',
    name='varcope2cifti')

secondlevel.connect([
    # each acquisition direction has multiple contrasts. We need
    # to merge corresponding contrasts with one contrast per file, but
    # with both acquisition directions in each file. We do this for copes
    # here
    (inputnode_secondlevel, cope2nifti, [('copes', 'cifti_in')]),
    (cope2nifti, splitcopes, [('out_file', 'in_file')]),
    (splitcopes, matchfiles1_node, [('out_files', 'filelist')]),
    (matchfiles1_node, copemerge2, [('copes', 'in_files')]),

    # now let's do it for varcopes
    (inputnode_secondlevel, varcope2nifti, [('varcopes', 'cifti_in')]),
    (varcope2nifti, splitvarcopes, [('out_file', 'in_file')]),
    (splitvarcopes, matchfiles2_node, [('out_files', 'filelist')]),
    (matchfiles2_node, varcopemerge2, [('varcopes', 'in_files')]),

    # prepare dof files
    (inputnode_secondlevel, mkdofbrain, [(('dof', mkdofbrain_opstring), 'op_string')]),
    (inputnode_secondlevel, dof2nifti, [('res', 'cifti_in')]),
    (dof2nifti, mkdofbrain, [('out_file', 'in_file')]),
    (mkdofbrain, dofmerge, [('out_file', 'in_files')]),
    (dofmerge, doffloor, [(('merged_file', pickfirst), 'in_file')]),

    # connect nodes for second level modeling
    (inputnode_secondlevel, level2model, [(('copes', num_copes), 'num_copes')]),

    (copemerge2, flameo, [('merged_file','cope_file')]),
    (varcopemerge2, flameo, [('merged_file', 'var_cope_file')]),
    (dofmerge, flameo, [(('merged_file', pickfirst), 'dof_var_cope_file')]),
    (level2model, flameo, [('design_mat', 'design_file'),
                           ('design_con', 't_con_file'),
                           ('design_grp', 'cov_split_file')]),
    (doffloor, flameo, [('out_file', 'mask_file')]),

    # convert model outputs to cifti
    (inputnode_secondlevel, ciftisplit, [(('copes', selectFirstVol), 'in_vars')]),
    (flameo, cope2cifti, [('copes', 'nifti_in')]),
    (ciftisplit, cope2cifti, [(('out_file', pickfirst), 'cifti_template')]),
    (flameo, tstat2cifti, [('tstats', 'nifti_in')]),
    (ciftisplit, tstat2cifti, [(('out_file', pickfirst), 'cifti_template')]),
    (flameo, zstat2cifti, [('zstats', 'nifti_in')]),
    (ciftisplit, zstat2cifti, [(('out_file', pickfirst), 'cifti_template')]),
    (flameo, varcope2cifti, [('var_copes', 'nifti_in')]),
    (ciftisplit, varcope2cifti, [(('out_file', pickfirst), 'cifti_template')])
])

#################################
# Combine preproc and first lvl #
#################################

l1pipeline = pe.Workflow(name="subjectlevel1")

l1pipeline.connect([
    (infosource, datasource, [('subject_id', 'subject_id'),
                             ('task','task'),
                             ('direction','direction')]),
    (infosource, firstlevel, [('subject_id', 'modelfit.inputspec.subject_id'),
                             ('task','modelfit.inputspec.task'),
                             ('direction','modelfit.inputspec.direction')]),
    (datasource, firstlevel, [
        ('func_vol', 'preproc.inputspec.func_vol'),
        ('func_surf', 'preproc.inputspec.func_surf'),
        ('surf_left', 'preproc.inputspec.surf_left'),
        ('surf_right', 'preproc.inputspec.surf_right'),
        ('motion', 'preproc.inputspec.motion'),
        ('seg', 'preproc.inputspec.seg'),
        ('surf_left', 'modelfit.inputspec.surf_left'),
        ('shape_left', 'modelfit.inputspec.shape_left'),
        ('surf_right', 'modelfit.inputspec.surf_right'),
        ('shape_right', 'modelfit.inputspec.shape_right')]),
    (firstlevel, datasink, [
        ('preproc.threshold.out_file', 'results.firstlevel.@mask'),
        ('modelfit.copemerge.out_file', 'results.firstlevel.copes'),
        ('modelfit.zstatmerge.out_file', 'results.firstlevel.zstat'),
        ('modelfit.tstatmerge.out_file', 'results.firstlevel.tstat'),
        ('modelfit.varcopemerge.out_file', 'results.firstlevel.varcopes'),
        ('modelfit.cifticreatedenseres4.out_file', 'results.firstlevel.res4'),
        ('modelfit.volmodelestimate.dof_file', 'results.firstlevel.@dof'),
        ('modelfit.vifestimate.vif_file', 'results.firstlevel.@vif'),
        ('modelfit.level1design.fsf_files', 'results.firstlevel.@fsf_files'),
        ('modelfit.level1design.ev_files', 'results.firstlevel.@ev_files'),
        ('modelfit.modelgen.design_file', 'results.firstlevel.@design'),
        ('modelfit.modelgen.con_file', 'results.firstlevel.@con')])
])


l2pipeline = pe.Workflow(name="subjectlevel2")

l2pipeline.connect([
    (infosource2, datasource2a, [
        ('subject_id', 'subject_id'),
        ('task', 'task')]),
    (infosource2, datasource2b, [
        ('subject_id', 'subject_id'),
        ('task', 'task')]),
    (datasource2b, join_datasource2b, [
        ('cope', 'copes'),
        ('varcope', 'varcopes'),
        ('mask', 'masks'),
        ('res', 'res'),
        ('dof', 'dof')]),
    (datasource2a, secondlevel, [
        ('surf_left', 'inputspec.surf_left'),
        ('shape_left', 'inputspec.shape_left'),
        ('surf_right', 'inputspec.surf_right'),
        ('shape_right', 'inputspec.shape_right')]),
    (join_datasource2b, secondlevel, [
        ('copes', 'inputspec.copes'),
        ('varcopes', 'inputspec.varcopes'),
        ('masks', 'inputspec.masks'),
        ('res', 'inputspec.res'),
        ('dof', 'inputspec.dof')]),
    (secondlevel, datasink2, [
        ('cope2cifti.out_file', 'results.secondlevel.@copes'),
        ('varcope2cifti.out_file', 'results.secondlevel.@varcopes'), 
        ('tstat2cifti.out_file', 'results.secondlevel.@tstat'), 
        ('zstat2cifti.out_file', 'results.secondlevel.@zstat')])

])


# run

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="HCP single trials GLM estimation")
    parser.add_argument('--subject_ids', nargs='*', help="Subject ID. Must match HCP directory name")
    parser.add_argument('--tasks', nargs='*', 
                        default=['EMOTION', 'GAMBLING', 'SOCIAL', 'LANGUAGE', 'RELATIONAL', 'MOTOR', 'WM'],
                        help='Must match HCP task labels which are all capitalized. See default for options.')
    parser.add_argument('--directions', nargs='*', default=['LR','RL'],
                        help='Phase encoding direction')
    parser.add_argument('--out', type=str, required=True, help='Output path basename. \
                        Outputs will be in subfolders labed by subject_id, task and direction.')
    parser.add_argument('--scratch', type=str, required=True,
                        help='scratch directory where temporary files should be stored')
    parser.add_argument('--n_cpus', type=int, default=int(os.getenv('SLURM_CPUS_PER_TASK',default='1')),
                        help='Number of CPUs available for computation')

    args = parser.parse_args()

    infosource.iterables = [('subject_id', args.subject_ids),
                            ('task', args.tasks),
                            ('direction', args.directions)]

    SCRATCH_DIR = args.scratch
    l1pipeline.base_dir = os.path.abspath(SCRATCH_DIR + '/workingdir')
    l1pipeline.config = {
        "execution": {
            "crashdump_dir": os.path.abspath(SCRATCH_DIR + '/crashdumps')
        }
    }

    datasink.inputs.base_directory = os.path.abspath(args.out)

    l1pipeline.write_graph()

    if args.n_cpus and args.n_cpus > 1:
        outgraph = l1pipeline.run(plugin='MultiProc', plugin_args={'n_procs':args.n_cpus})
    else:
        outgraph = l1pipeline.run()


    infosource2.iterables = [('subject_id', args.subject_ids),
                            ('task', args.tasks)]

    l2pipeline.base_dir = os.path.abspath(SCRATCH_DIR + '/workingdir')
    l2pipeline.config = {
        "execution": {
            "crashdump_dir": os.path.abspath(SCRATCH_DIR + '/crashdumps')
        }
    }

    # the joining with 'results' here has to match the first argument of the datasink used
    # by l1pipeline
    datasource2b.inputs.base_directory = os.path.join(os.path.abspath(args.out),'results')
    datasink2.inputs.base_directory = os.path.abspath(args.out)

    l2pipeline.write_graph()

    if args.n_cpus and args.n_cpus > 1:
        outgraph2 = l2pipeline.run(plugin='MultiProc', plugin_args={'n_procs':args.n_cpus})
    else:
        outgraph2 = l2pipeline.run()


