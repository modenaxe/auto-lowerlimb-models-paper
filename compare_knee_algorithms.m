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
%----------
results_folder = 'results/JCS_variability';
bone_geometry_folder = 'bone_geometries';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
bone_set = { 'femur_r', 'tibia_r'};
in_mm = 1;
results_plots = 0;
reference_algorithm_femur = 'GIBOC-Cylinder';
reference_algorithm_tibia = 'Kai2014';
%----------

if ~isfolder(results_folder); mkdir(results_folder); end
nf = 1;
for nb = 1:numel(bone_set)
    % cur bone
    cur_bone = bone_set{nb};
    
    for n_d = 1:numel(dataset_set)    
        
        % setup folders
        cur_dataset = dataset_set{n_d};
        main_ds_folder =  fullfile(bone_geometry_folder,cur_dataset);
        
        % read bone triangulation
        cur_geom_file = fullfile(main_ds_folder,'tri', cur_bone);
        
        % load the femur/tibia and split it in prox and dist
        bone_triang = load_mesh(cur_geom_file);
        
        % Get eigen vectors V_all of the Femur 3D geometry and volumetric center
        [ CS.V_all, CS.CenterVol ] = TriInertiaPpties(bone_triang);
        
        % take the long direction for femur
        CS.Z0 = CS.V_all(:,1);
        CoeffMorpho = computeTriCoeffMorpho(bone_triang);
        
        switch cur_bone
            case 'femur_r'
                try
                    [CS1, JCS1] = Miranda2010_buildfACS(bone_triang);
                catch
                    JCS1.knee_r.Origin = nan(1,3); 
                    JCS1.knee_r.V = nan(3,3);
                end
                [CS2, JCS2] = Kai2014_femur(bone_triang, [], results_plots);
                [CS3, JCS3] = GIBOC_femur(bone_triang, [], 'spheres', results_plots);
                [CS4, JCS4] = GIBOC_femur(bone_triang, [], 'ellipsoids', results_plots);
                [CS5, JCS5] = GIBOC_femur(bone_triang, [], 'cylinder', results_plots);
                % cylinder fit chosen as reference - easy to change
                if strcmp(reference_algorithm_femur, 'GIBOC-Cylinder')
                    ref_JCS = JCS5;
                else
                    error('Please modify script manually to change femoral reference JCS.')
                end
                % table headers
                table_head = {'KneeJointCentre_femur_dist_v_mm', 'Dist_norm_mm' 'KneeJointAxis_femur', 'Ang_diff_deg'};
                methods_list = {'Miranda2010','Kai2014','GIBOK-Sphere','GIBOK-Ellipsoids','GIBOK-Cylinder'};
            case 'tibia_r'
                try
                    [CS1, JCS1] = Miranda2010_buildtACS(bone_triang);
                catch
                    JCS1.knee_r.Origin = nan(1,3);
                    JCS1.knee_r.V = nan(3,3);
                end
                [CS2, JCS2] = Kai2014_tibia(bone_triang, [], results_plots);
                [CS3, JCS3] = GIBOC_tibia(bone_triang, [], 'plateau', results_plots);
                [CS4, JCS4] = GIBOC_tibia(bone_triang, [], 'ellipse', results_plots);
                [CS5, JCS5] = GIBOC_tibia(bone_triang, [], 'centroids', results_plots);
                
                % Kai2014 chosen as reference - easy to change
                if strcmp(reference_algorithm_tibia, 'Kai2014')
                    ref_JCS = JCS2;
                else 
                    error('Please modify script manually to change tibial reference JCS.')
                end
                %  [CS, ref_JCS] = STAPLE_tibia(bone_triang, [], results_plots);
                
                % table headers
                table_head = {'KneeJointCentre_tibia_v_mm', 'Dist_norm_mm' 'KneeJointAxis_tibia', 'Ang_diff_deg'};
                methods_list = {'Miranda2010','Kai2014','GIBOK-Plateau','GIBOK-Ellipse','GIBOK-Centroids'};
            otherwise
        end
        joint_centres = [  JCS1.knee_r.Origin;
                           JCS2.knee_r.Origin;
                           JCS3.knee_r.Origin;
                           JCS4.knee_r.Origin;
                           JCS5.knee_r.Origin];
        
        % compute distance vectors in ref femur/tibia coord frame for JCSs
        % origins.
        % This are results for this bone and this algorithm (table not
        % printed by default).
        orig_diff = (joint_centres - ref_JCS.knee_r.Origin)*ref_JCS.knee_r.V;
        orig_dist = sqrt(sum(orig_diff.^2, 2));
        
        % compute angular differences as well
        for naxis = 1:3
                    joint_axis =[JCS1.knee_r.V(:,naxis)';
                                JCS2.knee_r.V(:,naxis)';
                                JCS3.knee_r.V(:,naxis)';
                                JCS4.knee_r.V(:,naxis)';
                                JCS5.knee_r.V(:,naxis)'];
            ang_diff(:,naxis) = acosd(joint_axis*ref_JCS.knee_r.V(:,naxis));
        end
        
        % second option for reporting results (cumulative variables)
        row_ind = n_d:numel(dataset_set):numel(methods_list)*numel(dataset_set);
        orig_diff_opt2(row_ind,:) = orig_diff; %#ok<*SAGROW>
        orig_dist_opt2(row_ind,:) = orig_dist;
        ang_diff_opt2(row_ind,:) = ang_diff;
        
        % table with results (one per method)
        % res_table = table(orig_diff, orig_dist, joint_axis, ang_diff, 'VariableNames',table_head);
        % res_table.Properties.RowNames = methods_list;
        % writetable(res_table,fullfile(results_folder, [cur_bone,'_', cur_dataset,'.xlsx']));
        
        % clear partial results
        clear JCS1 JCS2 JCS3 JCS4 JCS5 ref_JCS ang_diff orig_dist orig_diff bone_triang
        
    end
        % cumulative table of results for all methods
        res_table2 = table(orig_diff_opt2, orig_dist_opt2, ang_diff_opt2, ...
                          'VariableNames',table_head([1,2,4]));
        
        % write on results folder, where pelvis results also              
        writetable(res_table2,fullfile(results_folder, [cur_bone,'_comparing_algorithms.xlsx']));
        
        % clear before analyzing next bone
        clear orig_diff_opt2 orig_dist_opt2 ang_diff_opt2
end

