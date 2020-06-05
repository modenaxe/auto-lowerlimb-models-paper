%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('msk-STAPLE/STAPLE'));

% SETTINGS
%---------------------------
results_folder = 'results/JCS_variability';
bone_geometry_folder = 'bone_geometries';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
bone_set = { 'pelvis_no_sacrum'};
reference_algorithm = 'STAPLE';
in_mm = 1;
results_plots = 0;
%---------------------------

% headers used in table
table_head = {'PelvisGroundJointCentre_v_mm', 'Dist_norm_mm' 'PelvisGroundJointAxis_femur', 'Ang_diff_deg'};
methods_list = {'Kai2014','STAPLE'};

% create folder if required
if ~isfolder(results_folder); mkdir(results_folder); end

% inform reader about reference algorithm
disp(['Reference algorithm for pelvis variation analysis is: ', reference_algorithm])

nf = 1;
for nb = 1:numel(bone_set)
    
    % current bone name
    cur_bone = bone_set{nb};
    
    for n_d = 1:numel(dataset_set)
        
        % setup folders
        cur_dataset = dataset_set{n_d};
        main_ds_folder =  fullfile(bone_geometry_folder,cur_dataset);
        
        % read bone triangulation
        cur_geom_file = fullfile(main_ds_folder,'tri', cur_bone);
        
        % load the pelves
        Pelvis = load_mesh(cur_geom_file);
        
        % run the algorithms
        [CS1, JCS1] = STAPLE_pelvis(Pelvis, results_plots, 0);
        [CS2, JCS2] = Kai2014_pelvis(Pelvis, results_plots, 0);
        
        % store the origins
        joint_centres = [JCS1.ground_pelvis.Origin, JCS2.ground_pelvis.Origin]';
        
        % reference algorithm
        switch reference_algorithm
            case 'STAPLE'
                ref_JCS = JCS1;
            case 'Kai2014'
                ref_JCS = JCS2;
        end
        
        % compute distance between origins (expressed in reference JCS)
        orig_diff = (joint_centres - ref_JCS.ground_pelvis.Origin')*ref_JCS.ground_pelvis.V;
        orig_dist = sqrt(sum(orig_diff.^2, 2));
        
        % loop through the axis and compute the angular differences
        for naxis = 1:3
            joint_axis = [JCS1.ground_pelvis.V(:,naxis)'; JCS2.ground_pelvis.V(:,naxis)'];
            ang_diff(:,naxis) = acosd(joint_axis*ref_JCS.ground_pelvis.V(:,naxis));
        end
        
        % equivalent better way to avoid loop
%         ang_offset_child = acosd(diag(JCS1.ground_pelvis.V'*JCS2.ground_pelvis.V));
        
        % second option
        row_ind = n_d:numel(dataset_set):numel(methods_list)*numel(dataset_set);
        orig_diff_opt2(row_ind,:) = orig_diff;
        orig_dist_opt2(row_ind,:) = orig_dist;
        ang_diff_opt2(row_ind,:) = ang_diff;
        
        % table with results (one per method)
        res_table = table(orig_diff, orig_dist, joint_axis, ang_diff, 'VariableNames',table_head);
        res_table.Properties.RowNames = methods_list;
        
        % write one table per dataset if required
        % writetable(res_table,fullfile(results_folder, [cur_bone,'_', cur_dataset,'.xlsx']));
        
        % clear all
        clear JCS1 JCS2 JCS3 JCS4 JCS5
    end
    
    % store cumulative results
    res_table2 = table(orig_diff_opt2, orig_dist_opt2, ang_diff_opt2, 'VariableNames',table_head([1,2,4]));
    writetable(res_table2,fullfile(results_folder, [cur_bone,'_comparing_methods.xlsx']));
    
    clear orig_diff_opt2 orig_dist_opt2 ang_diff_opt2
end

