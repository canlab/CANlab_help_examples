canlab_help_set_up_pain_prediction_walkthrough;

[mask_obj, networknames, imagenames] = load_image_set('bucknerlab');
mycolors={[120 18 134]/255 [70 130 180]/255  [0 118 14]/255  [196 58 250]/255  [220 248 164]/255  [230 148 34]/255  [205 62 78]/255 };
[fitresult, gof] = evaluate_spatial_scale(image_obj,mask_obj,'cv_lassopcr', 'nfolds',[rem(subject_id,2)+1],'verbose',0,'labels',networknames,'colors',mycolors);
