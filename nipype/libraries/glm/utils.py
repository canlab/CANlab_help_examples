def assemble_csf_motion_confounds_mat(motion, csf):
    import pandas as pd
    import os

    motion_df = pd.read_csv(motion, sep='\s+', header=None)
    csf_df = pd.read_csv(csf, sep='\s+', header=None)

    # regress 24 motion parameters and csf (but not white matter)
    confounds = pd.concat([motion_df, motion_df**2, csf_df], axis=1)

    # get node specific working directory
    cwd = os.getcwd()

    filename = os.path.join(cwd, "confounds.csv")

    confounds.to_csv(filename, sep='\t', index=False, header=False)

    return filename


# combine VIFs across trials in the order recieved. Select trials of interest
# based on name matching to 'Task-(\d+)' regular expression.
def merge_trial_vifs(files):
    import pandas as pd
    import os
    import re

    labels = []
    vifs = []
    for filename in files:
        these_vifs_df=pd.read_csv(filename, sep=',', header=None)

        these_labels = these_vifs_df[0].tolist()
        these_vifs = these_vifs_df[1].tolist()

        # find trial contrast
        is_single_trial = [True if re.search('^Task-(\d+)$', label) else False
                                for label in these_labels]

        these_labels = [label for label,good in zip(these_labels,is_single_trial) if good]
        labels = labels + these_labels

        these_vifs = [vif for vif,good in zip(these_vifs,is_single_trial) if good]
        vifs = vifs + these_vifs

    vifs_df = pd.DataFrame({'trial': labels, 'VIF': vifs})

    # get node specific working directory
    cwd = os.getcwd()


    filename = os.path.join(cwd, "vifs.csv")

    vifs_df.to_csv(filename, sep=',', index=False, header=False)

    return filename

