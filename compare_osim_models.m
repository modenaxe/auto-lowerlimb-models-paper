%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% computes the differences in mm between origin (models in m)
clearvars;  close all
addpath('support_funcs');

% SETTINGS
%---------------------------
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
modelling_method = 'Modenese2018';
osim_model_folder = 'opensim_models';
results_folder = 'results\JCS_validation';
%---------------------------

% create folder if required
if ~isfolder(results_folder); mkdir(results_folder);end

N_datasets = numel(dataset_set);
for n_d = 1:N_datasets
    
    cur_dataset = dataset_set{n_d};
    
    % identify appropriate models
    manual_model_name = ['manual_',cur_dataset,'.osim'];
    auto_model_name = ['auto',modelling_method,'_',dataset_set{n_d},'.osim'];
    
    % create joint structures for each model for easy comparison
    auto_model = createJointParamsMatStructFromOsimModel(fullfile(osim_model_folder,manual_model_name));
    manual_model = createJointParamsMatStructFromOsimModel(fullfile(osim_model_folder,auto_model_name));
    
    % check if ground ref syst is identical(
    % essential for comparison (model built in same reference frame)
    assert(isequal(auto_model.ground_pelvis.parent-manual_model.ground_pelvis.parent, zeros(4)))
    
    % cheking the origins of the models
    joint_list = fields(auto_model);
    N_joint = numel(joint_list);
    
    % going through the joints
    for n = 1:N_joint
        cur_joint_name = joint_list{n};
        
        % compute joint centre offsets in mm (identical for child and parent)
        jc_offset(n, :) = (auto_model.(cur_joint_name).child(1:3,4) - manual_model.(cur_joint_name).child(1:3,4))*1000;
        jc_offset_norm(n,1) = norm(jc_offset(n, :));
        
        % compute angular offsets for child reference systems
        ang_offset_child(n,:) = acosd(diag(auto_model.(cur_joint_name).child(1:3,1:3)'*manual_model.(cur_joint_name).child(1:3,1:3)));
        
        % compute angular offsets for parent reference systems
        ang_offset_parent(n,:) = acosd(diag(auto_model.(cur_joint_name).parent(1:3,1:3)'*manual_model.(cur_joint_name).parent(1:3,1:3)));
        
    end
    
    %------------- COMPLETE EVALUATION ------------------------------------
    % build a table to visualise all differences in all joint parameters
    cur_res_table = table(jc_offset, jc_offset_norm, ang_offset_parent, ang_offset_child,...
                          'VariableNames',{'JC-Offset_mm', 'JC-Offset-Norm_mm', ...
                                           'Angular_offset_parent_JCS (XYZ)',...
                                           'Angular_offset_child_JCS (XYZ)'});
    cur_res_table.Properties.RowNames = {'pelvis_ground' 'hip_r' 'knee_r' 'ankle_r' 'subtalar_r'};
    cur_res_table.Properties.Description = cur_dataset;
    cur_res_table.Properties.VariableUnits = {'mm', 'mm','deg', 'deg'};
    
    % store structure of results
    validation_tables(n_d) = {cur_res_table};
    
    % write results on xlsx file
    writetable(cur_res_table, [results_folder,filesep,'JCS_differences_',cur_dataset,'.xlsx']);
    
    % clear variables
    clear jc_offset ang_offset_child ang_offset_parent cur_res_table jc_offset_norm
end

clc
% display all tables of results
for nt = 1:N_datasets
    cur_dataset = dataset_set{nt};
    disp( '--------------------')
    disp([' DATASET: ', cur_dataset])
    disp( '--------------------')
    disp(validation_tables{nt})
end

rmpath('support_funcs');