%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
tic
addpath(genpath('msk-STAPLE/STAPLE'));

%--------------------------------------
auto_models_folder = './opensim_models';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
bone_geometry_folder = 'bone_geometries';
body_list = {'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r'};
in_mm = 1;
method = 'Modenese2018';
method = 'auto2020';
%--------------------------------------

% create model folder if required
if ~isfolder(auto_models_folder); mkdir(auto_models_folder); end

for n_d = 1:numel(dataset_set)
    
    % setup folders
    model_name = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometry_folder, dataset_set{n_d});
    
    % geometry folder (STL)
    % tri_folder = fullfile(main_ds_folder,'stl');
    % geometry folder (mat triangulations)
    tri_folder = fullfile(main_ds_folder,'tri');
    
    vis_geom_folder=fullfile(main_ds_folder,'vtp');
    
    % create geometrySet
    geom_set = createTriGeomSet(body_list, tri_folder);
    disp(['Geometries imported in ', num2str(toc), ' s']);
    
    % create bodies
    osimModel = createBodiesFromTriGeomBoneSet(geom_set, vis_geom_folder);
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(geom_set);
    
    % create joints
    createLowerLimbJoints(osimModel, JCS, method);
    
    % add markers to
    addBoneLandmarksAsMarkers(osimModel, BL);
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % assign name
    osimModel.setName([dataset_set{n_d},'_auto']);
    
    % assign STAPLE credits
    osimModel.set_credits('Luca Modenese, Jean-Baptist Renault - created with STAPLE: Shared Tools for Automatic Personalised Lower Extremity modelling.')
    
    % print odel
    osimModel.print(fullfile(auto_models_folder, [method,'_',model_name, '.osim']));
    
    % disown
    osimModel.disownAllComponents();
    
    % display total time to create the model
    disp(['Model generated in ', num2str(toc)]);
    
end

% remove paths
rmpath('msk-STAPLE/STAPLE');
