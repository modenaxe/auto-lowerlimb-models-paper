%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear;clc;
fclose all;close all;
addpath(genpath('./support_functions'));

%---------------------------------------------------------------------------
% where the simulations are
database_root_folder = '.\Dataset';
% name of the models used in the simulations
model_set = {'P3m6_R_manual', 'P3m6_R_automatic'};
% where to store the summary
mat_summary_folder = './Dataset_Mat_Summaries';
% mass of the subject represented by the automatic and manual model
bodyMass = 76.5; %kg
%---------------------------------------------------------------------------

% create summary folder
if ~isfolder(mat_summary_folder); mkdir(mat_summary_folder); end

% initializations of all storage variables
pelvis_tilt= []; pelvis_list = []; pelvis_rotation = [];
hip_flexion = []; hip_flexion_moment = [];hip_adduction = []; hip_adduction_moment = [];
hip_rotation = []; hip_rotation_moment = []; knee_angle = []; knee_angle_moment = [];
ankle_angle = []; ankle_angle_moment = []; subtalar_angle = []; subtalar_angle_moment = [];
KINEMATICS = []; KINETICS = []; ToeOffV_R = []; 

% getting data from simulations of each model
for n_subj = 1:length(model_set)
    
    % extract details for the current model
    cur_model_name = model_set{n_subj};
    display(['Processing: ', cur_model_name])
    
    % summary folders in model folder structure
    Mat_summary_folder = fullfile(database_root_folder,cur_model_name,'Mat_summary');
    % summary file
    summary_file = fullfile(Mat_summary_folder, [cur_model_name,'_OS_allTrials.mat'] );
    % load and remove external structure layer
    subj_OS_summary = load(summary_file);
    eval(['subj_OS_summary = subj_OS_summary.',cur_model_name,'_OS_summary;'])

    if ~isempty(subj_OS_summary) 
        
        % PULLING TOE OFF
        ToeOffV_R = [ToeOffV_R, subj_OS_summary.toe_off_vec]; %#ok<AGROW>
        
        % STORING ALL KINEMATICS TOGETHER (with correct signs for plotting)
        pelvis_tilt    = -squeeze(getValueColumnForHeader(subj_OS_summary,  'pelvis_tilt'));
        pelvis_list    = -squeeze(getValueColumnForHeader(subj_OS_summary,  'pelvis_list'));
        pelvis_rotation= squeeze(getValueColumnForHeader(subj_OS_summary,  'pelvis_rotation'));
        hip_flexion    = squeeze(getValueColumnForHeader(subj_OS_summary,  'hip_flexion_r'));
        hip_adduction  = squeeze(getValueColumnForHeader(subj_OS_summary,  'hip_adduction_r'));
        hip_rotation   = squeeze(getValueColumnForHeader(subj_OS_summary,  'hip_rotation_r'));
        knee_angle     =-(squeeze(getValueColumnForHeader(subj_OS_summary, 'knee_angle_r')));
        ankle_angle    = squeeze(getValueColumnForHeader(subj_OS_summary,  'ankle_angle_r'));
        subtalar_angle = squeeze(getValueColumnForHeader(subj_OS_summary,  'subtalar_angle_r'));
        
        % STORING ALL DYNAMICS TOGETHER (with correct signs for plotting)
        hip_flexion_moment   = -squeeze(getValueColumnForHeader(subj_OS_summary, 'hip_flexion_r_moment'))/bodyMass;
        hip_adduction_moment = -squeeze(getValueColumnForHeader(subj_OS_summary, 'hip_adduction_r_moment'))/bodyMass;
        hip_rotation_moment  = squeeze(getValueColumnForHeader(subj_OS_summary, 'hip_rotation_r_moment'))/bodyMass;
        knee_angle_moment    = squeeze(getValueColumnForHeader(subj_OS_summary, 'knee_angle_r_moment'))/bodyMass;
        ankle_angle_moment   = -squeeze(getValueColumnForHeader(subj_OS_summary, 'ankle_angle_r_moment'))/bodyMass;
        subtalar_angle_moment= -squeeze(getValueColumnForHeader(subj_OS_summary, 'subtalar_angle_r_moment'))/bodyMass;
    end

%------------- create summary structures ------------------
% store kinematics
KINEMATICS.colheaders = {'pelvis_tilt', 'pelvis_list','pelvis_rotation',...
                         'hip_flexion','hip_adduction','hip_rotation',...
                         'knee_angle','ankle_angle','subtalar_angle'};
KINEMATICS.data = reshape([pelvis_tilt; pelvis_list; pelvis_rotation;...
                           hip_flexion;  hip_adduction;  hip_rotation;...
                           knee_angle; ankle_angle;subtalar_angle],...
                           101,length(KINEMATICS.colheaders),[]);

% store kinetics
KINETICS.colheaders   = {'hip_flexion_moment','hip_adduction_moment',...
                         'hip_rotation_moment','knee_angle_moment',...
                         'ankle_angle_moment', 'subtalar_angle_moment'};
KINETICS.data = reshape([hip_flexion_moment; hip_adduction_moment;...
                         hip_rotation_moment; knee_angle_moment;...
                         ankle_angle_moment;subtalar_angle_moment],...
                         101,length(KINETICS.colheaders),[]);

% hyper-structure
SummaryBiomech.KINEMATICS = KINEMATICS;
SummaryBiomech.KINETICS = KINETICS;
SummaryBiomech.ToeOffV_R = ToeOffV_R;

% save the summary for this model
save([mat_summary_folder, filesep, ['Summary_',cur_model_name,'.mat']], 'SummaryBiomech')
disp(['Summary files written in folder: ',mat_summary_folder])

clear subj_OS_summary
end
