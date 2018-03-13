% Check conditions:
fmridisplay_is_ok = true;
if ~exist('o2', 'var') || ~isa(o2, 'fmridisplay')
    fmridisplay_is_ok = false;
    
elseif length(o2.montage) < whmontage 
    % wrong fmridisplay object for this plot
    fmridisplay_is_ok = false;
    
elseif ~all(ishandle(o2.montage{whmontage}.axis_handles))
    % Figure was closed or axes deleted
    fmridisplay_is_ok = false;
    
end
    
if ~fmridisplay_is_ok
    
    create_figure('fmridisplay'); axis off
    o2 = canlab_results_fmridisplay([], 'noverbose');

else % Ok, reactivate, clear blobs, and clear name
    
    o2 = removeblobs(o2);
    axes(o2.montage{whmontage}.axis_handles(5));
    title(' ');
end

% Get figure number - to reactivate figure later, even if we are changing its tag
hh = get(o2.montage{whmontage}.axis_handles, 'Parent');  %findobj('Tag', 'fmridisplay');
if iscell(hh), hh = hh{1}; end
fig_number = hh(1).Number;
