# code adapted from
# https://nipype.readthedocs.io/en/latest/users/examples/fmri_fsl.html
#
# This is supposed to simulate a FEAT run, but it doesn't actually use
# FEAT, it uses direct calls to all the constituent functions FEAT otherwise
# calls. Constructing this requires careful comparison with feat output
# logs to make sure everything matches. In order to ensure this I began
# by replicating the results of the HCP provided *fsf files and then 
# modified them as needed to obtain additional functionality (e.g. single
# trial designs, motion correction, spike detection, or whatever I may have
# wanted).

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

from glm.preproc import preproc_surf_motion_csf
from glm.designs import select_trials
from glm.utils import assemble_csf_motion_confounds_mat, merge_trial_vifs

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
datasource.inputs.field_template={'func_vol': '%s/MNINonLinear/Results/tfMRI_%s_%s/tfMRI_%s_%s.nii.gz',
                            'func_surf': '%s/MNINonLinear/Results/tfMRI_%s_%s/tfMRI_%s_%s_Atlas.dtseries.nii',
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
    (r'_direction_(LR|RL)_subject_id_(\d+)_task_(\w+)', r'\3/\2/\1'),  # Creates directories like 'subj/task/direction'
]


# ###################### #
# Preprocessing Workflow #
# ###################### #
preproc = preproc_surf_motion_csf(hpcutoff, TR)

# ########################## #
# firstlvl modeling workflow #
# ########################## #

# task specific event configuration

def subjectinfo(subject_id, task, direction):
    from glm.designs import block_events
    from nipype.interfaces.base import Bunch
    from copy import deepcopy
    
    names, onsets, dur = block_events(subject_id, task, direction)
    
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
        if bool(re.match(r'^Task-\d+$',name)):
            this_cont = [name,'T',[name],[1]]
            contrasts.append(this_cont)

    return contrasts

contrastselect_node = pe.Node(util.Function(input_names=['contrast_names'],
                                            output_names=['contrasts'],
                                            function=select_contrasts),
                        name='contrastselect_node')
                        
    
assembleconfounds_node = pe.MapNode(util.Function(input_names=['motion','csf'],
                                                  output_names=['confounds'],
                                                  function=assemble_csf_motion_confounds_mat),
                                       iterfield=['motion','csf'],
                                       name='assembleconfounds_node')
    

modelfit = pe.Workflow(name='modelfit')

inputnode_modelfit = pe.Node(
    interface=util.IdentityInterface(fields=[
        'subject_id','task','direction',
        'func',
        'surf_left','shape_left',
        'surf_right','shape_right',
        'outliers','csf','motion']),
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
    
cifticreatedensets = pe.MapNode(
    interface=wb.CiftiCreateDenseTimeseries(),
    iterfield=['left_metric', 'right_metric', 'volume'],
    name='cifticreatedensets')


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

copemerge = pe.Node(
    interface=wb.CiftiMerge(),
    name="copemerge")
    

modelfit.connect([
    (inputnode_modelfit, subjectinfo_node, [('subject_id', 'subject_id'),
                                                 ('task','task'),
                                                 ('direction','direction')]),
    
    (subjectinfo_node, contrastselect_node, [('contrast_names','contrast_names')]),
    
    (inputnode_modelfit, splitcifti, [('func','in_file')]),
    (splitcifti, designspec, [('volume_all_out', 'functional_runs')]),
       
    (inputnode_modelfit, designspec, [('outliers','outlier_files')]),
    (subjectinfo_node, designspec, [('subject_info','subject_info')]),
    (inputnode_modelfit, assembleconfounds_node, [('csf','csf'),
                                                 ('motion','motion')]),
    (assembleconfounds_node, designspec, [('confounds', 'realignment_parameters')]),
    
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
                                     
                                     
    (vol_modelestimate, cifticreatedensets, [('copes', 'volume')]),
    (splitcifti, cifticreatedensets, [('volume_all_label_out', 'volume_label')]),
    (inputnode_modelfit, cifticreatedensets, [('shape_left', 'left_roi')]),
    (LSurf_modelestimate, cifticreatedensets, [('copes', 'left_metric')]),
    (inputnode_modelfit, cifticreatedensets, [('shape_right', 'right_roi')]),
    (RSurf_modelestimate, cifticreatedensets, [('copes', 'right_metric')]),

    (cifticreatedensets, copemerge, [('out_file', 'cifti')]),
    
    (subjectinfo_node, vifestimate, [('contrast_names','contrast_names')]),
    (modelgen, vifestimate, [('design_file','design_matrix')]),
])


# actually running the first level scripts
firstlevel = pe.Workflow(name='firstlevel')
firstlevel.connect(
    [(preproc, modelfit, [('nii2cifti.out_file', 'inputspec.func'),
                          ('spikedetection.outlier_files', 'inputspec.outliers'),
                          ('compute_csf_ts.out_file', 'inputspec.csf'),
                          ('inputspec.motion', 'inputspec.motion')]),
])




firstlevel.inputs.modelfit.designspec.input_units = 'secs'
firstlevel.inputs.modelfit.designspec.time_repetition = TR
firstlevel.inputs.modelfit.designspec.high_pass_filter_cutoff = hpcutoff

firstlevel.inputs.modelfit.level1design.interscan_interval = TR
firstlevel.inputs.modelfit.level1design.bases = {'dgamma': {'derivs': False}}
firstlevel.inputs.modelfit.level1design.model_serial_correlations = True

# ############################# #
# Combine preproc and first lvl #
#################################

l1pipeline = pe.Workflow(name="level1")

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
        ('motion', 'preproc.inputspec.motion'),
        ('seg', 'preproc.inputspec.seg'),
        ('surf_left', 'modelfit.inputspec.surf_left'),
        ('shape_left', 'modelfit.inputspec.shape_left'),
        ('surf_right', 'modelfit.inputspec.surf_right'),
        ('shape_right', 'modelfit.inputspec.shape_right')]),
    (firstlevel, datasink, [
        ('modelfit.copemerge.out_file', 'results.@copes'),
        ('modelfit.vifestimate.vif_file', 'results.@vif'),
        ('modelfit.level1design.fsf_files', 'results.@fsf_files'),
        ('modelfit.level1design.ev_files', 'results.@ev_files'),
        ('modelfit.modelgen.design_file', 'results.@design'),
        ('modelfit.modelgen.con_file', 'results.@con')])
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
