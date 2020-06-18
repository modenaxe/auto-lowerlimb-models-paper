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
clear; clc; close all
addpath(genpath('msk-STAPLE/STAPLE'));
addpath('support_functions')

%----------
% SETTINGS 
%----------
output_models_folder = 'opensim_models';

% datasets that you would like to process
dataset_set  = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};

% mass required for mass estimation
subj_mass_set = [64, 45, 87, 76.5];

% cell array with the bone geometries that you would like to process
bone_geometries_folder = 'bone_geometries';
bones_list = {'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r'};
in_mm = 1;

% visualization geometry format
vis_geom_format = 'obj'; % options: 'stl'/'obj'

% choose the definition of the joint coordinate systems (see documentation)
modelling_method = 'Modenese2018';
%--------------------------------------


% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = 1:numel(dataset_set)
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometries_folder, cur_dataset);
    
    % model and model file naming
    model_name = ['automatic_',dataset_set{n_d}];
    model_file_name = [model_name, '.osim'];
    
    % options to read stl or mat(tri) files
    % tri_folder = fullfile(main_ds_folder,'stl');
    tri_folder = fullfile(main_ds_folder,'tri');
    
    % create geometry set structure for the entire dataset
    geom_set = createTriGeomSet(bones_list, tri_folder);
    
    % create bone geometry folder for visualization
    geometry_folder_name = [model_name, '_Geometries'];
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    writeModelGeometriesFolder(geom_set, geometry_folder_path, vis_geom_format);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, geom_set, geometry_folder_name, vis_geom_format);
    
    % add patella to tibia (this will be replaced by a proper joint and
    % dealt with the other joints in the future).
    attachPatellaGeom(osimModel, tri_folder, geometry_folder_path, geometry_folder_name, vis_geom_format)
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(geom_set);
    
    % create joints
    createLowerLimbJoints(osimModel, JCS, modelling_method);
    
    % update mass properties
    osimModel = assignMassPropsToSegments(osimModel, JCS, subj_mass_set(n_d));
    
    % add markers to the bones
    addBoneLandmarksAsMarkers(osimModel, BL);
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % print
    osimModel.print(fullfile(output_models_folder, model_file_name));
    
    % inform the user about time employed to create the model
    disp(['Model generated in ', num2str(toc)]);
   
    close all
end

% remove paths
rmpath(genpath('msk-STAPLE/STAPLE'));
rmpath('support_functions')