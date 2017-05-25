function input_struct = plugin_get_parcelwise_statistic_images(parcel_obj, input_struct)
% output_struct = plugin_get_parcelwise_statistic_images(input_struct)
%
%parcel_obj = PARCELS.Shen.parcel_obj;
% input_struct = y_helper_function_get_parcelwise_statistic_images(parcel_obj, input_struct );

% Create placeholder statistic image

parcel_obj = replace_empty(parcel_obj);    
placeholder_vec = ones(parcel_obj.volInfo.n_inmask, 1);
all_parcel_idx = double(parcel_obj.dat);
u = unique(all_parcel_idx); u(u == 0) = [];

dfe = size(input_struct.dat{1}, 1) - 1; % placeholder - replace

placeholder_t_obj = statistic_image('dat', single(0 * placeholder_vec), ...
    'p', placeholder_vec, ...
    'sig', logical(placeholder_vec), ...
    'type', 'T', ...
    'dfe', dfe, ...
    'volInfo', parcel_obj.volInfo);

% number of conditions
k = length(input_struct.group_t);
    
input_struct.t_statistic_obj = {};

% For each condition
% ----------------------------------------------------
t_obj = placeholder_t_obj;
    
t_obj.dat = zeros(size(placeholder_vec, 1), k); % voxels x conditions

for i = 1:k
    
    % Get parcel-by-parcel stats for this condition
    t = input_struct.group_t{i}';
    p = input_struct.group_p{i}';
    sig = input_struct.fdr_sig{i}';
    dfe = size(input_struct.dat{i}, 1) - 1;

    if length(t) ~= length(u)
        error('Parcel indices in parcel_obj and extracted parcel-wise t-values do not match. Check code.')
    end
    
    for j = 1:length(u)
        % For each parcel, fill in statistic_image object
        % ----------------------------------------------------
        parcelidx = u(j);
        
        wh_vox = all_parcel_idx == parcelidx;
        
        % map parcels to voxels
        t_obj.dat(wh_vox, i) = t(j);
        t_obj.p(wh_vox, i) = p(j);
        t_obj.sig(wh_vox, i) = sig(j);
                
    end
    
    t_obj.dfe(i) = dfe;
       
end % conditions
    
t_obj = enforce_variable_types(t_obj);  % space-saving: 5/24/17

input_struct.t_statistic_obj = t_obj;

end % function
