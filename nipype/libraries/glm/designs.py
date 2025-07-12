def trial_events(subject_id, task, direction):
    # subject_id: e.g. 100307
    # task: e.g. EMOTION. Must match one of the task conditions below
    # directoin: LR|RL. determines which eprime and HCP block deisgn data to use for constructing the design
    # 
    # this function returns single trials for all events in chronological order. Unlike the version in
    # the traditional single trial analysis, there are no confound regressors. These need to be configured
    # in subjecteventinfo if you want them

    import pandas as pd
    import numpy as np
    from glob import glob
    
    print("Subject ID: %s\n" % str(subject_id))
    output = []

    data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
    eprime_path = glob(data_dir + \
                       '/%s/MNINonLinear/Results/tfMRI_%s_%s/%s_run*_TAB.txt' % \
                       (subject_id, task, direction, task))
    assert(len(eprime_path) == 1,
        '%d eprime files found for subject %s' % (len(eprime_path), subject_id))
    df = pd.read_csv(eprime_path[0], delimiter='\t', na_values=[''])


    # trial specific variables
    if task == 'EMOTION':
        # get trial onsets and durations
        onsets = df['StimSlide.OnsetTime'] - df['SyncSlide.OnsetTime'][0]
        onsets = [onset for onset in onsets.tolist() if not np.isnan(onset)]

        # includes ITI per Barch 2013 definition of a 'trial'
        #dur = [3 for i in range(0,len(onsets))]

        # no ITI
        dur = [2.0 for i in range(0,len(onsets))]
    elif task == 'GAMBLING':
        onsets = df['QuestionMark.OnsetTime'] - df['SyncSlide.OnsetTime'][0]
        onsets = [onset for onset in onsets.tolist() if not np.isnan(onset)]

        # incorporates ?, reveal, and ITI per the definition of a 'trial' from Barch 2013
        #dur = [3.5 for i in range(0,len(onsets))]

        # incorporates ? and reveal, but not ITI
        dur = [2.5 for i in range(0,len(onsets))]
    elif task == 'SOCIAL':
        time0 = df['CountDownSlide.OnsetTime'][0]
        onsets = np.array(df['MovieSlide.OnsetTime'] - time0)


        onset_ind = np.where(np.isfinite(onsets))[0]

        # this includes response periods, matching Barch 2013 block design
        #fix_onsets = np.array(df['FixationBlock.OnsetTime'] - time0)
        #dur = fix_onsets[onset_ind + 1] - onsets[onset_ind]
        #dur = [d/1000 for d in dur]

        # this version separates out response periods
        resp_onsets = np.array(df['ResponseSlide.OnsetTime'] - time0)
        dur = resp_onsets[onset_ind] - onsets[onset_ind]
        dur = [d/1000 for d in dur]

        onsets = onsets[np.isfinite(onsets)].tolist()
    elif task == 'LANGUAGE':
        # we haven't updated these to be single trials
        
        onsets = np.nanmax([df['PresentStoryFile.OnsetTime'],
                            df['PresentMathFile.OnsetTime']], axis=0) - df['GetReady.FinishTime'][0]

        offsets = np.nanmax([df['PresentStoryFile.OffsetTime'],
                             df['PresentMathFile.OffsetTime']], axis=0) - df['GetReady.FinishTime'][0]

        # this includes response periods and ratings, matching Barch 2013 block designs
        #resp_offsets = np.array(df['ResponsePeriod.OffsetTime'] - df['GetReady.FinishTime'][0])
        #resp_offsets = resp_offsets[np.isfinite(resp_offsets)].tolist()
        #dur = (resp_offsets - onsets[np.isfinite(onsets)])/1000

        # this does not include response periods or questions
        dur = (offsets[np.isfinite(onsets)] - onsets[np.isfinite(onsets)])/1000
        dur = dur.tolist()

        onsets = onsets[np.isfinite(onsets)].tolist()
        # drop final onsets since they are not not part of the scan and blow up VIFs
        onsets = onsets[:12]
        dur = dur[:12]

    elif task == 'RELATIONAL':
        # durations differ for relational and control trials, so we need to be able to
        # disambiguate them
        blocktype = np.array(df['BlockType'])

        onsets = np.nanmax([df['RelationalSlide.OnsetTime'],
                              df['ControlSlide.OnsetTime']], axis=0) - df['SyncSlide.OnsetTime'][0]

        blocktype = blocktype[np.isfinite(onsets)].tolist()
        onsets = onsets[np.isfinite(onsets)].tolist()

        # counting ITIs like in Barch 2013
        #dur = [4.0 if block == 'Relational' else 3.2 for block in blocktype]

        # this does not count ITIs
        dur = [3.5 if block == 'Relational' else 2.8 for block in blocktype]
    elif task == 'MOTOR':
        # each onset corresponds to a single motor sequence. 
        # A single finger tap, a single toe squeeze, etc. The VIFs for this are huge and likely unusable
        if 'SyncSlide.OnsetTime' in df.keys():
            time0 = df['SyncSlide.OnsetTime'][0]
        elif 'CountDownSlide.OnsetTime' in df.keys():
            time0 = df['CountDownSlide.OnsetTime'][0]
        else:
            raise ValueError('No scan onset time could be found for subject %s %s_%s' % (subject_id, task, direction))

        onsets = np.nanmax([df['CrossLeft.OnsetTime'],
                              df['CrossRight.OnsetTime'],
                              df['CrossCenter.OnsetTime']], axis=0) - time0

        onsets = onsets[np.isfinite(onsets)].tolist()
        dur = [1.2 for i in range(0,len(onsets))]
    elif task == 'WM':
        onsets = df['Stim.OnsetTime'] - df['SyncSlide.OnsetTime'][0]
        onsets = [onset for onset in onsets.tolist() if not np.isnan(onset)]

        # includes ITI per Barch 2013 definition of a 'trial'
        #dur = [2.5 for i in range(0,len(onsets))]

        # incorporates image but not ITI
        dur = [2.0 for i in range(0,len(onsets))]
    else:
        raise ValueError('{0} is not a supported task'.format(task))

    assert(len(onsets) < 100, 
        '%d single trials found, which is not supported by our indexing scheme.' % len(onsets))

    # we need a list of lists, with one list per task
    # in order for subsequent code to work correctly, we must have trials first
    onsets = [[onset/1000] for onset in onsets]
    dur = [[d] for d in dur]
    names = ['Task-%02d' % i for i in range(0,len(onsets))]
    
    return names, onsets, dur
    
    
    
def block_events(subject_id, task, direction):
    import pandas as pd
    import numpy as np
    from glob import glob
    
    from nipype.interfaces.base import Bunch
    from copy import deepcopy
    print("Subject ID: %s\n" % str(subject_id))
    output = []

    data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
    eprime_path = glob(data_dir + \
                       '/%s/MNINonLinear/Results/tfMRI_%s_%s/%s_run*_TAB.txt' % \
                       (subject_id, task, direction, task))
    assert(len(eprime_path) == 1,
        '%d eprime files found for subject %s' % (len(eprime_path), subject_id))
    df = pd.read_csv(eprime_path[0], delimiter='\t', na_values=[''])

    # these variables will store task irrelevant events like cues or response periods
    # as needed
    confound_names = []
    confound_onsets = []
    confound_dur = []

    # task specific variables
    if task == 'EMOTION':
        onsets = df['StimSlide.OnsetTime'] - df['SyncSlide.OnsetTime'][0]
        onsets = [onset for onset in onsets.tolist() if not np.isnan(onset)]
        onsets = onsets[::6]

        offsets = np.nanmax([df['face.OnsetTime'],
                             df['shape.OnsetTime']], axis=0) - df['SyncSlide.OnsetTime'][0]
        offsets = [offset for offset in offsets.tolist() if not np.isnan(offset)]
        offsets = offsets + [df['ExpInstrucFeelFreeToRest.StartTime'][0] - df['SyncSlide.OnsetTime'][0]]

        # includes ITI per Barch 2013 definition of a 'trial'
        dur = [(off - on)/1000. for on,off in zip(onsets, offsets[1:])]
    elif task == 'GAMBLING':
        onsets = df['QuestionMark.OnsetTime'] - df['SyncSlide.OnsetTime'][0]
        onsets = [onset for onset in onsets.tolist() if not np.isnan(onset)]
        onsets = onsets[::8]

        offsets = df['FifteenSecFixation.OnsetTime'] - df['SyncSlide.OnsetTime'][0]
        offsets = [offset for offset in offsets.tolist() if not np.isnan(offset)]

        # incorporates ?, reveal, and ITI per the definition of a 'trial' from Barch 2013
        dur = [(off - on)/1000. for on,off in zip(onsets,offsets)]
    elif task == 'SOCIAL':
        time0 = df['CountDownSlide.OnsetTime'][0]
        onsets = np.array(df['MovieSlide.OnsetTime'] - time0)

        resp_onsets = np.array(df['ResponseSlide.OnsetTime'] - time0)
        fix_onsets = np.array(df['FixationBlock.OnsetTime'] - time0)

        onset_ind = np.where(np.isfinite(onsets))[0]

        # this includes response periods, matching Barch 2013 block design
        #dur = fix_onsets[onset_ind + 1] - onsets[onset_ind]
        #dur = [d/1000 for d in dur]

        # this version separates out response periods
        dur = resp_onsets[onset_ind] - onsets[onset_ind]
        dur = [d/1000 for d in dur]

        confound_names.append('Task-Response')
        confound_onsets.append(resp_onsets[onset_ind].tolist())
        resp_dur = fix_onsets[onset_ind + 1] - resp_onsets[onset_ind]
        resp_dur = resp_dur/1000.
        confound_dur.append(resp_dur.tolist())

        onsets = onsets[np.isfinite(onsets)].tolist()
    elif task == 'LANGUAGE':
        onsets = np.nanmax([df['PresentStoryFile.OnsetTime'],
                            df['PresentMathFile.OnsetTime']], axis=0) - df['GetReady.FinishTime'][0]

        offsets = np.nanmax([df['PresentStoryFile.OffsetTime'],
                             df['PresentMathFile.OffsetTime']], axis=0) - df['GetReady.FinishTime'][0]

        math_q_onsets = np.array(df['PresentMathOptions.OnsetTime'] - df['GetReady.FinishTime'][0])
        math_q_offsets = np.array(df['PresentMathOptions.OffsetTime'] - df['GetReady.FinishTime'][0])
        math_q_dur = (math_q_offsets - math_q_onsets)/1000
        math_q_dur = math_q_dur[np.isfinite(math_q_onsets)].tolist()
        math_q_onsets = math_q_onsets[np.isfinite(math_q_onsets)].tolist()

        story_q_onsets = np.array(df['ThatWasAbout.OnsetTime'] - df['GetReady.FinishTime'][0])
        story_q_offsets = np.array(df['ThatWasAbout.OffsetTime'] - df['GetReady.FinishTime'][0])
        story_q_dur = (story_q_offsets - story_q_onsets)/1000
        story_q_dur = story_q_dur[np.isfinite(story_q_onsets)].tolist()
        story_q_onsets = story_q_onsets[np.isfinite(story_q_onsets)].tolist()

        resp_onsets = np.array(df['ResponsePeriod.OnsetTime'] - df['GetReady.FinishTime'][0])
        resp_offsets = np.array(df['ResponsePeriod.OffsetTime'] - df['GetReady.FinishTime'][0])
        resp_dur = (resp_offsets - resp_onsets)/1000
        resp_dur = resp_dur[np.isfinite(resp_onsets)].tolist()
        resp_offsets = resp_offsets[np.isfinite(resp_onsets)].tolist()
        resp_onsets = resp_onsets[np.isfinite(resp_onsets)].tolist()

        # this includes response periods and ratings, matching Barch 2013 block designs
        # dur = (resp_offsets - onsets[np.isfinite(onsets)])/1000

        # this does not include response periods or questions
        dur = (offsets[np.isfinite(onsets)] - onsets[np.isfinite(onsets)])/1000
        dur = dur.tolist()

        # additional confounds. when excluding response periods or questions from single trials
        confound_names.append('Task-Math-Question')
        confound_onsets.append(math_q_onsets)
        confound_dur.append(math_q_dur)

        confound_names.append('Task-Story-Question')
        confound_onsets.append(story_q_onsets)
        confound_dur.append(story_q_dur)

        confound_names.append('Task-Response')
        confound_onsets.append(resp_onsets)
        confound_dur.append(resp_dur)

        onsets = onsets[np.isfinite(onsets)].tolist()
        # drop final onsets since they are not not part of the scan and blow up VIFs
        onsets = onsets[:12]
        dur = dur[:12]

    elif task == 'RELATIONAL':
        # durations differ for relational and control trials, so we need to be able to
        # disambiguate them
        blocktype = np.array(df['BlockType'])

        onsets0 = np.nanmax([df['RelationalSlide.OnsetTime'],
                             df['ControlSlide.OnsetTime']], axis=0) - df['SyncSlide.OnsetTime'][0]

        blocktype = blocktype[np.isfinite(onsets0)].tolist()
        onsets0 = onsets0[np.isfinite(onsets0)].tolist()

        i = 0
        onsets = []
        while i < len(onsets0):
            if blocktype[i] == 'Relational':
                onsets.append(onsets0[i])
                i = i+4
            elif blocktype[i] == 'Control':
                onsets.append(onsets0[i])
                i = i+5
            else:
                raise ValueError('Unexpected blocktype for %s %s %s' % (subject_id, task, direction))

        # counting ITIs like in Barch 2013
        dur = [18. for onset in onsets]
    elif task == 'MOTOR':
        # each onset corresponds to a single motor sequence. 
        # A single finger tap, a single toe squeeze, etc. The VIFs for this are huge and likely unusable
        if 'SyncSlide.OnsetTime' in df.keys():
            time0 = df['SyncSlide.OnsetTime'][0]
        elif 'CountDownSlide.OnsetTime' in df.keys():
            time0 = df['CountDownSlide.OnsetTime'][0]
        else:
            raise ValueError('No scan onset time could be found for subject %s %s_%s' % (subject_id, task, direction))

        onsets = np.nanmax([df['RightHandCue.OnsetTime'],
                            df['LeftHandCue.OnsetTime'],
                            df['RightFootCue.OnsetTime'], 
                            df['LeftFootCue.OnsetTime'],
                            df['TongueCue.OnsetTime']],axis=0) - time0 + 3000

        onsets = onsets[np.isfinite(onsets)].tolist()
        dur = [12. for i in range(0,len(onsets))]
    elif task == 'WM':
        onsets = df['Stim.OnsetTime'] - df['SyncSlide.OnsetTime'][0]
        onsets = [onset for onset in onsets.tolist() if not np.isnan(onset)]
        onsets = onsets[::10]
        
        offsets = np.nanmax([df['Cue2Back.OnsetTime'],
                             df['CueTarget.OnsetTime']], axis=0) - df['SyncSlide.OnsetTime'][0]
        offsets = [offset for offset in offsets.tolist() if not np.isnan(offset)]
        offsets = offsets + [df['ExpInstrucFeelFreeToRest.StartTime'][0] - df['SyncSlide.OnsetTime'][0]]

        # every second block is followed by 15s of fixation, so we need to overwrite some offsets accordingly
        offsets2 = df['Fix15sec.OnsetTime'] - df['SyncSlide.OnsetTime'][0]
        offsets2 = [offset for offset in offsets2.tolist() if not np.isnan(offset)]
        offsets[2::2] = offsets2


        # includes ITI per Barch 2013 definition of a 'trial'
        dur = [(off - on)/1000. for on,off in zip(onsets, offsets[1:])]
        assert(max(dur) < 30, 'Could not retrieve sensible directions for %s %s task!' % (direction,task))
    else:
        raise ValueError('{0} is not a supported task'.format(task))

    assert(len(onsets) < 100, 
        '%d single trials found, which is not supported by our indexing scheme.' % len(onsets))

    # we need a list of lists, with one list per task
    onsets = [[onset/1000.] for onset in onsets]
    dur = [[d] for d in dur]
    names = ['Task-%02d' % i for i in range(0,len(onsets))]

    if confound_names:
        names += confound_names
        onsets += [[onset/1000 for onset in these_onsets]
                   for these_onsets in confound_onsets]
        dur += confound_dur

    return names, onsets, dur
    
    
def hcp_events(subject_id, task, direction):
    import pandas as pd
    
    print("Subject ID: %s\n" % str(subject_id))
    output = []
    
    data_dir = '/dartfs/rc/lab/D/DBIC/DBIC/archive/HCP/HCP1200/'
    
    # task specific variables
    if task == 'EMOTION':
        names = ['Task-Faces', 'Task-Shapes']

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

    return names, onsets, dur
    
    

def select_trials(contrast_names):
    import re

    contrasts = []
    for name in contrast_names:
        if bool(re.match(r'^Task-\d+$',name)):
            this_cont = [name,'T',[name],[1]]
            contrasts.append(this_cont)

    return contrasts

