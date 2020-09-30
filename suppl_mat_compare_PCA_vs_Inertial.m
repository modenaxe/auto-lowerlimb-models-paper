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

%----------
% SETTINGS
%---------------------------
results_folder = 'results/PCA_vs_PIAs';
bone_geometry_folder = 'bone_geometries';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
cur_bone_set = {'femur_r','tibia_r'};
in_mm = 1;
results_plots = 1;
%---------------------------

if ~isfolder(results_folder); mkdir(results_folder); end
nf = 1;
for nb = 1:numel(cur_bone_set)
    cur_bone = cur_bone_set{nb};
    for n_d = 1:numel(dataset_set)
        
        % setup folders
        cur_dataset = dataset_set{n_d};
        main_ds_folder =  fullfile(bone_geometry_folder,cur_dataset);
        cur_geom_file = fullfile(main_ds_folder,'tri', cur_bone);
        cur_bone_name = strrep(cur_bone,'_',' ');
        
        % load the femur and split it on prox and dist
        cur_triGeom = load_mesh(cur_geom_file);
        [ProxBone, DistBone] = cutLongBoneMesh(cur_triGeom);
        unitedTibia = TriUnite(DistBone, ProxBone);
        
        % full geometry
        V_all_PCA              = pca(cur_triGeom.Points);
        V_all_Inertia          = TriInertiaPpties( cur_triGeom );
        angle_PCA_Inertia(n_d) = acosd(dot(V_all_PCA(:,3), V_all_Inertia(:,3)));
        
        % partial geometry of interest (distal femur and proximal tibia)
        if strcmp(cur_bone,'tibia_r')
            part_bone = ProxBone;
            kwd = 'proximal';
        elseif strcmp(cur_bone,'femur_r')
            part_bone = DistBone;
            kwd = 'distal';
        end
        
        figure('Name',['comparison of options-',cur_dataset])
        subplot(1,3,1);     quickPlotTriang(cur_triGeom); title(['full ',cur_bone_name])
        subplot(1,3,2);     quickPlotTriang(part_bone); title([kwd,' ',cur_bone_name])
        subplot(1,3,3);     quickPlotTriang(unitedTibia); title(['epiphyses ',cur_bone_name])
        
        % only epiphysis
        V_all_PCA = pca(part_bone.Points);
        V_all_Inertia_ProxTibia = TriInertiaPpties(part_bone);
        angle_PCA_Inertia_partial(n_d)     = acosd(dot(V_all_PCA(:,3), V_all_Inertia_ProxTibia(:,3)));
        
        % united geometry
        V_all_PCA = pca(unitedTibia.Points);
        V_all_Inertia_unitedTibia = TriInertiaPpties( unitedTibia );
        angle_PCA_Inertia_united(n_d)     = acosd(dot(V_all_PCA(:,3), V_all_Inertia_unitedTibia(:,3)));
    end
    
    % adjusting angles > 90 (axes not pointing in the same direction)
    angle_PCA_Inertia(:, angle_PCA_Inertia>90) = 180 - angle_PCA_Inertia(:, angle_PCA_Inertia>90);
    angle_PCA_Inertia_partial(:, angle_PCA_Inertia_partial>90) = 180 - angle_PCA_Inertia_partial(:, angle_PCA_Inertia_partial>90);
    angle_PCA_Inertia_united(:, angle_PCA_Inertia_united>90) = 180 - angle_PCA_Inertia_united(:, angle_PCA_Inertia_united>90);
    
    % table of results: angular difference between PCA and Inertial long axes
    PCA_vs_Inertia_table(nb) = {table(angle_PCA_Inertia', angle_PCA_Inertia_partial', angle_PCA_Inertia_united',...
        'VariableNames',{['full ',cur_bone_name], [kwd,' ',cur_bone_name], ['epiphysis ',cur_bone_name]},...
        'RowNames', {'LHDL-CT', 'TLEM-CT', 'ICL-MRI', 'JIA-MRI'})};
    
%     writetable(PCA_vs_Inertia_table{nb},fullfile(results_folder, [cur_bone,'_PCA_PIAs.xlsx']));
    
    clear angle_PCA_Inertia angle_PCA_Inertia_partial angle_PCA_Inertia_united
    
end

% display tables on clean command window
clc
disp(PCA_vs_Inertia_table{1})
disp(PCA_vs_Inertia_table{2})