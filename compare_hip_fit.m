%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
%

% ----------------------------------------------------------------------- %
% NB: I know that all femurs have Z pointing cranially. In a completely
% generic case I should have used femur_guess_CS.m.
% ----------------------------------------------------------------------- %

clear; clc; close all
addpath('support_funcs');

% SETTINGS
%---------------------------
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
in_mm = 1;
% if visualization is desired
fitting_plots = 0;
%---------------------------

for n_d = 1:numel(dataset_set)
    
    % setup folders
    main_ds_folder =  ['bone_geometries',filesep,dataset_set{n_d}];
    tri_folder = fullfile(main_ds_folder,'tri');
    cur_geom_file = fullfile(tri_folder, 'femur_r');
    
    % load the femur and split it on prox and dist
    Femur = load_mesh(cur_geom_file);
    [ProxFem, DistFem] = cutLongBoneMesh(Femur);
    
    % Get eigen vectors V_all of the Femur 3D geometry and volumetric center
    [ CS.V_all, CS.CenterVol ] = TriInertiaPpties(Femur);
    
    % assign longitudinal axis
    CS.Z0 = CS.V_all(:,1);

    % morphological coeff used by GIBOC
    CoeffMorpho = computeTriCoeffMorpho(Femur);
    
    % algorithms
    [CSKai, MostProxPoint] = Kai2014_femur_fitSphere2FemHead(ProxFem, CS, fitting_plots);
    [CSRenault, FemHead] = GIBOC_femur_fitSphere2FemHead(ProxFem, CS, CoeffMorpho, fitting_plots);
    
    % save estimations
    estimations(n_d,:) = [  CSKai.CenterFH_Kai,...
                            CSKai.RadiusFH_Kai, ...
                            CSRenault.CenterFH_Renault,...
                            CSRenault.RadiusFH_Renault]; %#ok<SAGROW>
end

% results table
res_table = table(estimations(:,1:3), estimations(:,4), estimations(:,5:7),estimations(:,8),...
            'VariableNames',{'HJC_coords_Kai2014', 'Radius_Kai2014', 'HJC_coords_Renault2018','Radius_Renault2018'});
res_table.Properties.RowNames = dataset_set;
      
% metrics table
diff_centre_comp = estimations(:,1:3)-estimations(:,5:7);
abs_distance = sqrt(sum(diff_centre_comp.^2 , 2));
diff_radii = abs(estimations(:,4)-estimations(:,8));
metric_table = table(diff_centre_comp, abs_distance, diff_radii,...
    'VariableNames',{'Diff_Vector', 'Diff_Vec_Magnitude', 'Radius_Diff'});
metric_table.Properties.RowNames = dataset_set;

% display results on clean console
clc
disp(res_table);
disp(metric_table)
