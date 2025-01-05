# code adapted from
# https://nipype.readthedocs.io/en/latest/users/examples/fmri_fsl.html
#
# This is supposed to simulate a FEAT run, but it doesn't actually use
# FEAT, it uses direct calls to all the constituent functions FEAT otherwise
# calls. Constructing this requires careful comparison with feat output
# logs to make sure everything matches. As far as I can tell it does.
#
# This script was used as a starting point from which different designs
# were implemented with additional functionality. It's the most primitive
# of the GLM scripts in other words. It performs FEAT analysis of 
# hcp volumetric data

from __future__ import print_function
from __future__ import division
from builtins import str
from builtins import range

import os  # system functions

import nipype.interfaces.io as nio  # Data i/o
import nipype.interfaces.fsl as fsl  # fsl
import nipype.pipeline.engine as pe  # pypeline engine
import nipype.interfaces.utility as util  # utility


fsl.FSLCommand.set_default_output_type('NIFTI_GZ')

hpcutoff = 200
TR = 0.72


# ###################### #
# Preprocessing Workflow #
# ###################### #
preproc = pe.Workflow(name='preproc')

inputnode = pe.Node(
    interface=util.IdentityInterface(fields=[
        'func',
    ]),
    name='inputspec')

# ensure data is a float
img2float = pe.MapNode(
    interface=fsl.ImageMaths(
        out_data_type='float', op_string='', suffix='_dtype'),
    iterfield=['in_file'],
    name='img2float')
preproc.connect(inputnode, 'func', img2float, 'in_file')

# utility function for dealing with MapNode outputs
def pickfirst(files):
    if isinstance(files, list):
        return files[0]
    else:
        return files

# motion correction would normally happen here if we wanted it, but we don't

# intensity normalization
getthresh = pe.MapNode(
    interface=fsl.ImageStats(op_string='-p 2 -p 98'),
    iterfield=['in_file'],
    name='getthreshold')
preproc.connect(img2float, 'out_file', getthresh, 'in_file')

threshold = pe.Node(
    interface=fsl.ImageMaths(out_data_type='char', suffix='_thresh'),
    name='threshold')
preproc.connect(img2float, ('out_file',	pickfirst), threshold, 'in_file')

def getthreshop(thresh):
    return '-thr %.14f -Tmin -bin' % (0.1 * thresh[0][1])
preproc.connect(getthresh, ('out_stat', getthreshop), threshold, 'op_string')

medianval = pe.MapNode(
    interface=fsl.ImageStats(op_string='-k %s -p 50'),
    iterfield=['in_file'],
    name='medianval')
preproc.connect(img2float, 'out_file', medianval, 'in_file')
preproc.connect(threshold, 'out_file', medianval, 'mask_file')

dilatemask = pe.Node(
    interface=fsl.ImageMaths(suffix='_dil', op_string='-dilF'),
    name='dilatemask')
preproc.connect(threshold, 'out_file', dilatemask, 'in_file')

maskfunc = pe.MapNode(
    interface=fsl.ImageMaths(suffix='_mask', op_string='-mas'),
    iterfield=['in_file'],
    name='maskfunc2')
preproc.connect(img2float, 'out_file', maskfunc, 'in_file')
preproc.connect(dilatemask, 'out_file', maskfunc, 'in_file2')

intnorm = pe.MapNode(
    interface=fsl.ImageMaths(suffix='_intnorm'),
    iterfield=['in_file', 'op_string'],
    name='intnorm')

def getinormscale(medianvals):
    return ['-mul %.14f' % (10000. / val) for val in medianvals]
preproc.connect(maskfunc, 'out_file', intnorm, 'in_file')
preproc.connect(medianval, ('out_stat', getinormscale), intnorm, 'op_string')


# highpass filter

meanfunc = pe.MapNode(
    interface=fsl.ImageMaths(op_string='-Tmean', suffix='_mean'),
    iterfield=['in_file'],
    name='meanfunc')
preproc.connect(intnorm, 'out_file', meanfunc, 'in_file')

# this is a dirty way to add the meanfunc back in. I should pass '-add %s' somehow in a single consolidated command
# so I don't have to just assume where in_file2 will be dropped
highpass = pe.MapNode(
    interface=fsl.ImageMaths(suffix='_hpf', op_string='-bptf %.14f -1 -add ' % (0.5* hpcutoff / TR)),
    iterfield=['in_file','in_file2'],
    name='highpass')
preproc.connect(intnorm, 'out_file', highpass, 'in_file')
preproc.connect(meanfunc, 'out_file', highpass, 'in_file2')


# ########################## #
# firstlvl modeling workflow #
# ########################## #

# design and contrast configurations

import nipype.algorithms.modelgen as model  # model generation

modelfit = pe.Workflow(name='modelfit')
modelspec = pe.Node(interface=model.SpecifyModel(), name="modelspec")
level1design = pe.Node(interface=fsl.Level1Design(), name="level1design")
modelgen = pe.MapNode(
    interface=fsl.FEATModel(),
    name='modelgen',
    iterfield=['fsf_file','ev_files'])
modelestimate = pe.MapNode(
    interface=fsl.FILMGLS(smooth_autocorr=True, mask_size=5, threshold=1000),
    name='modelestimate',
    iterfield=['design_file', 'in_file', 'tcon_file'])

modelfit.connect([
    (modelspec, level1design, [('session_info', 'session_info')]),
    (level1design, modelgen, [('fsf_files', 'fsf_file'), ('ev_files',
                                                          'ev_files')]),
    (modelgen, modelestimate, [('design_file', 'design_file'),
                               ('con_file', 'tcon_file')])
])

# actually running the first level scripts
# augment this later to average across LR and RL at the second level

firstlevel = pe.Workflow(name='firstlevel')
firstlevel.connect(
    [(preproc, modelfit, [('highpass.out_file', 'modelspec.functional_runs'),
                          ('highpass.out_file', 'modelestimate.in_file')])])

# ########################## #
# Run specific configuration #
# ########################## #

data_dir = os.path.abspath('/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/')
subject_list = ['100307']
task_list = ['EMOTION','GAMBLING','SOCIAL','LANGUAGE','RELATIONAL','MOTOR','WM']
direction_list = ['RL','LR']

infosource = pe.Node(
    interface=util.IdentityInterface(fields=['subject_id','task','direction']), name="infosource")

infosource.iterables = [('subject_id', subject_list), ('task', task_list), ('direction', direction_list)]



datasource = pe.Node(
    interface=nio.DataGrabber(
        infields=['subject_id', 'task', 'direction'], outfields=['func']),
    name='datasource')
datasource.inputs.base_directory = data_dir
datasource.inputs.template='%s/MNINonLinear/Results/tfMRI_%s_%s/tfMRI_%s_%s.nii.gz'
datasource.inputs.template_args = dict(func=[['subject_id','task','direction',
                                             'task','direction']])
datasource.inputs.sort_filelist = True


# task specific event configuration

def subjectinfo(subject_id, task, direction):
    import pandas as pd
    
    from nipype.interfaces.base import Bunch
    from copy import deepcopy
    print("Subject ID: %s\n" % str(subject_id))
    output = []
    
    # task specific variables
    if task == 'EMOTION':
        names = ['Task-Faces', 'Task-Shapes']

        data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
        fear_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/fear.txt' % \
                    (subject_id, task, direction)
        neut_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/neut.txt' % \
                    (subject_id, task, direction)

        fear_df = pd.read_csv(fear_path, header=None, delimiter='\t', na_values=[''])
        neut_df = pd.read_csv(neut_path, header=None, delimiter='\t', na_values=[''])
        
        onsets = [fear_df[0].tolist(), neut_df[0].tolist()]
        dur = [fear_df[1].tolist(), neut_df[1].tolist()]
    elif task == 'GAMBLING':
        names = ['Task-Punish', 'Task-Reward']

        data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
        loss_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/loss.txt' % \
                    (subject_id, task, direction)
        win_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/win.txt' % \
                    (subject_id, task, direction)

        loss_df = pd.read_csv(loss_path, header=None, delimiter='\t', na_values=[''])
        win_df = pd.read_csv(win_path, header=None, delimiter='\t', na_values=[''])
        
        onsets = [loss_df[0].tolist(), win_df[0].tolist()]
        dur = [loss_df[1].tolist(), win_df[1].tolist()]
    elif task == 'SOCIAL':
        names = ['Task-Random', 'Task-TOM']

        data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
        rnd_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/rnd.txt' % \
                    (subject_id, task, direction)
        tom_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/mental.txt' % \
                    (subject_id, task, direction)

        rnd_df = pd.read_csv(rnd_path, header=None, delimiter='\t', na_values=[''])
        tom_df = pd.read_csv(tom_path, header=None, delimiter='\t', na_values=[''])
        
        onsets = [rnd_df[0].tolist(), tom_df[0].tolist()]
        dur = [rnd_df[1].tolist(), tom_df[1].tolist()]
    elif task == 'LANGUAGE':
        names = ['Task-Math', 'Task-Story']

        data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
        math_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/math.txt' % \
                    (subject_id, task, direction)
        story_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/story.txt' % \
                    (subject_id, task, direction)

        math_df = pd.read_csv(math_path, header=None, delimiter='\t', na_values=[''])
        story_df = pd.read_csv(story_path, header=None, delimiter='\t', na_values=[''])
        
        onsets = [math_df[0].tolist(), story_df[0].tolist()]
        dur = [math_df[1].tolist(), story_df[1].tolist()]
    elif task == 'RELATIONAL':
        names = ['Task-Match', 'Task-Rel']

        data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
        match_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/match.txt' % \
                    (subject_id, task, direction)
        rel_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/relation.txt' % \
                    (subject_id, task, direction)

        match_df = pd.read_csv(match_path, header=None, delimiter='\t', na_values=[''])
        rel_df = pd.read_csv(rel_path, header=None, delimiter='\t', na_values=[''])
        
        onsets = [match_df[0].tolist(), rel_df[0].tolist()]
        dur = [match_df[1].tolist(), rel_df[1].tolist()]
    elif task == 'MOTOR':
        names = ['Task-Cue', 'Task-LF', 'Task-LH', 'Task-RF', 'Task-RH', 'Task-Tongue']

        data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
        cue_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/cue.txt' % \
                    (subject_id, task, direction)
        lf_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/lf.txt' % \
                    (subject_id, task, direction)
        lh_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/lh.txt' % \
                    (subject_id, task, direction)
        rf_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/rf.txt' % \
                    (subject_id, task, direction)
        rh_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/rh.txt' % \
                    (subject_id, task, direction)
        t_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/t.txt' % \
                    (subject_id, task, direction)

        cue_df = pd.read_csv(cue_path, header=None, delimiter='\t', na_values=[''])
        lf_df = pd.read_csv(lf_path, header=None, delimiter='\t', na_values=[''])
        lh_df = pd.read_csv(lh_path, header=None, delimiter='\t', na_values=[''])
        rf_df = pd.read_csv(rf_path, header=None, delimiter='\t', na_values=[''])
        rh_df = pd.read_csv(rh_path, header=None, delimiter='\t', na_values=[''])
        t_df = pd.read_csv(t_path, header=None, delimiter='\t', na_values=[''])
        
        onsets = [cue_df[0].tolist(), lf_df[0].tolist(), lh_df[0].tolist(), rf_df[0].tolist(), rh_df[0].tolist(), t_df[0].tolist()]
        dur = [cue_df[1].tolist(), lf_df[1].tolist(), lh_df[1].tolist(), rf_df[1].tolist(), rh_df[1].tolist(), t_df[1].tolist()]
    elif task == 'WM':
        names = ['Task-2bk-Body', 'Task-2bk-Face', 'Task-2bk-Place', 'Task-2bk-Tool',
                 'Task-0bk-Body', 'Task-0bk-Face', 'Task-0bk-Place', 'Task-0bk-Tool']

        data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
        bk2_body_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/2bk_body.txt' % \
                    (subject_id, task, direction)
        bk2_faces_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/2bk_faces.txt' % \
                    (subject_id, task, direction)
        bk2_places_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/2bk_places.txt' % \
                    (subject_id, task, direction)
        bk2_tools_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/2bk_tools.txt' % \
                    (subject_id, task, direction)
        bk0_body_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/0bk_body.txt' % \
                    (subject_id, task, direction)
        bk0_faces_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/0bk_faces.txt' % \
                    (subject_id, task, direction)
        bk0_places_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/0bk_places.txt' % \
                    (subject_id, task, direction)
        bk0_tools_path = data_dir + \
                    '/%s/MNINonLinear/Results/tfMRI_%s_%s/EVs/0bk_tools.txt' % \
                    (subject_id, task, direction)

        bk2_body_df = pd.read_csv(bk2_body_path, header=None, delimiter='\t', na_values=[''])
        bk2_faces_df = pd.read_csv(bk2_faces_path, header=None, delimiter='\t', na_values=[''])
        bk2_places_df = pd.read_csv(bk2_places_path, header=None, delimiter='\t', na_values=[''])
        bk2_tools_df = pd.read_csv(bk2_tools_path, header=None, delimiter='\t', na_values=[''])
        bk0_body_df = pd.read_csv(bk0_body_path, header=None, delimiter='\t', na_values=[''])
        bk0_faces_df = pd.read_csv(bk0_faces_path, header=None, delimiter='\t', na_values=[''])
        bk0_places_df = pd.read_csv(bk0_places_path, header=None, delimiter='\t', na_values=[''])
        bk0_tools_df = pd.read_csv(bk0_tools_path, header=None, delimiter='\t', na_values=[''])
        
        onsets = [bk2_body_df[0].tolist(), bk2_faces_df[0].tolist(), bk2_places_df[0].tolist(), bk2_tools_df[0].tolist(), bk0_body_df[0].tolist(), bk0_faces_df[0].tolist(), bk0_places_df[0].tolist(), bk0_tools_df[0].tolist()]
        dur = [bk2_body_df[1].tolist(), bk2_faces_df[1].tolist(), bk2_places_df[1].tolist(), bk2_tools_df[1].tolist(), bk0_body_df[1].tolist(), bk0_faces_df[1].tolist(), bk0_places_df[1].tolist(), bk0_tools_df[1].tolist()]
    else:
        raise ValueError('{0} is not a supported task'.format(task))

    # task general variables
    output.insert(1,
                  Bunch(
                      conditions=names,
                      onsets=deepcopy(onsets),
                      durations=deepcopy(dur),
                      amplitudes=None,
                      tmod=None,
                      pmod=None,
                      regressor_names=None,
                      regressors=None))
    
    return output

subjectinfo_node = pe.Node(util.Function(input_names=['subject_id', 'task', 'direction'],
                                 output_names=['subject_info'],
                                 function=subjectinfo),
                        name='subjectinfo_node')

# task specific contrast configuration

def select_contrasts(task):
    contrasts = {'EMOTION': [], 'GAMBLING': [], 'SOCIAL': [], 'LANGUAGE': [], 'RELATIONAL': [],
                'MOTOR': [], 'WM': []}

    cont1 = ['FACES','T',['Task-Faces'],[1]]
    cont2 = ['SHAPES','T',['Task-Shapes'],[1]]
    cont3 = ['FACES-SHAPES','T',['Task-Faces','Task-Shapes'],[1,-1]]
    cont4 = ['neg_FACES','T',['Task-Faces'],[-1]]
    cont5 = ['neg_SHAPES','T',['Task-Shapes'],[-1]]
    cont6 = ['SHAPES-FACES','T',['Task-Faces','Task-Shapes'],[-1,1]]
    contrasts['EMOTION'] = [cont1, cont2, cont3, cont4, cont5, cont6]

    cont1 = ['PUNISH','T',['Task-Punish'],[1]]
    cont2 = ['REWARD','T',['Task-Reward'],[1]]
    cont3 = ['PUNISH-REWARD','T',['Task-Punish','Task-Reward'],[1,-1]]
    cont4 = ['neg_PUNISH','T',['Task-Punish'],[-1]]
    cont5 = ['neg_REWARD','T',['Task-Reward'],[-1]]
    cont6 = ['REWARD-PUNISH','T',['Task-Punish','Task-Reward'],[-1,1]]
    contrasts['GAMBLING'] = [cont1, cont2, cont3, cont4, cont5, cont6]

    cont1 = ['RANDOM','T',['Task-Random'],[1]]
    cont2 = ['TOM','T',['Task-TOM'],[1]]
    cont3 = ['RANDOM-TOM','T',['Task-Random','Task-TOM'],[1,-1]]
    cont4 = ['neg_RANDOM','T',['Task-Random'],[-1]]
    cont5 = ['neg_TOM','T',['Task-TOM'],[-1]]
    cont6 = ['TOM-RANDOM','T',['Task-RANDOM','Task-TOM'],[-1,1]]
    contrasts['SOCIAL'] = [cont1, cont2, cont3, cont4, cont5, cont6]

    cont1 = ['MATH','T',['Task-Math'],[1]]
    cont2 = ['STORY','T',['Task-Story'],[1]]
    cont3 = ['MATH-STORY','T',['Task-Math','Task-Story'],[1,-1]]
    cont4 = ['STORY-MATH','T',['Task-Math','Task-Story'],[-1,1]]
    cont5 = ['neg_MATH','T',['Task-Math'],[-1]]
    cont6 = ['neg_STORY','T',['Task-Story'],[-1]]
    contrasts['LANGUAGE'] = [cont1, cont2, cont3, cont4, cont5, cont6]

    cont1 = ['MATCH','T',['Task-Match'],[1]]
    cont2 = ['REL','T',['Task-Rel'],[1]]
    cont3 = ['MATCH-REL','T',['Task-Match','Task-Rel'],[1,-1]]
    cont4 = ['REL-MATCH','T',['Task-Match','Task-Rel'],[-1,1]]
    cont5 = ['neg_MATCH','T',['Task-Match'],[-1]]
    cont6 = ['neg_REL','T',['Task-Rel'],[-1]]
    contrasts['RELATIONAL'] = [cont1, cont2, cont3, cont4, cont5, cont6]

    cont1 = ['CUE','T',['Task-Cue'],[1]]
    cont2 = ['LF','T',['Task-LF'],[1]]
    cont3 = ['LH','T',['Task-LH'],[1]]
    cont4 = ['RF','T',['Task-RF'],[1]]
    cont5 = ['RH','T',['Task-RH'],[1]]
    cont6 = ['T','T',['Task-Tongue'],[1]]
    contrasts['MOTOR'] = [cont1, cont2, cont3, cont4, cont5, cont6]

    cont1 = ['2BK_BODY','T',['Task-2bk-Body'],[1]]
    cont2 = ['2BK_FACE','T',['Task-2bk-Face'],[1]]
    cont3 = ['2BK_PLACE','T',['Task-2bk-Place'],[1]]
    cont4 = ['2BK_TOOL','T',['Task-2bk-Tool'],[1]]
    cont5 = ['0BK_BODY','T',['Task-0bk-Body'],[1]]
    cont6 = ['0BK_FACE','T',['Task-0bk-Face'],[1]]
    cont7 = ['0BK_PLACE','T',['Task-0bk-Place'],[1]]
    cont8 = ['0BK_TOOL','T',['Task-0bk-Tool'],[1]]
    contrasts['WM'] = [cont1, cont2, cont3, cont4, cont5, cont6, cont7, cont8]
    
    return contrasts[task]

contrastselect_node = pe.Node(util.Function(input_names=['task'],
                                            output_names=['contrasts'],
                                            function=select_contrasts),
                        name='contrastselect_node')

firstlevel.inputs.modelfit.modelspec.input_units = 'secs'
firstlevel.inputs.modelfit.modelspec.time_repetition = TR
firstlevel.inputs.modelfit.modelspec.high_pass_filter_cutoff = hpcutoff

firstlevel.inputs.modelfit.level1design.interscan_interval = TR
firstlevel.inputs.modelfit.level1design.bases = {'dgamma': {'derivs': True}}
firstlevel.inputs.modelfit.level1design.model_serial_correlations = True

# ############################# #
# Combine preproc and first lvl #
#################################

l1pipeline = pe.Workflow(name="level1")
l1pipeline.base_dir = os.path.abspath('./fsl/workingdir')
l1pipeline.config = {
    "execution": {
        "crashdump_dir": os.path.abspath('./fsl/crashdumps')
    }
}

l1pipeline.connect([
    (infosource, datasource, [('subject_id', 'subject_id'),
                             ('task','task'),
                             ('direction','direction')]),
    (infosource, subjectinfo_node, [('subject_id', 'subject_id'),
                                    ('task','task'),
                                    ('direction','direction')]),
    (infosource, contrastselect_node, [('task','task')]),
    (subjectinfo_node, firstlevel, [
        ('subject_info', 'modelfit.modelspec.subject_info')]),
    (datasource, firstlevel, [
        ('func', 'preproc.inputspec.func')]),
    (contrastselect_node, firstlevel, [
        ('contrasts', 'modelfit.level1design.contrasts')])
])

# run

if __name__ == '__main__':
    l1pipeline.write_graph()
    outgraph = l1pipeline.run()
    # l1pipeline.run(plugin='MultiProc', plugin_args={'n_procs':2})
