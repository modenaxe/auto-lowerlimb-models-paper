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
function     attachPatellaGeom(osimModel, tri_folder, geometry_folder_path, geometry_folder_name, vis_geom_format)
% OpenSim libraries
dim_fact = 0.001;
import org.opensim.modeling.*
mesh_file = ['patella_r.',vis_geom_format];
vis_mesh_file = fullfile(geometry_folder_path, mesh_file);
cur_tri_geom = load_mesh(fullfile(tri_folder, 'patella_r'));
writeOBJfile(cur_tri_geom, vis_mesh_file);
osim_body = osimModel.getBodySet().get('tibia_r');
vis_geom = Mesh(fullfile(geometry_folder_name,mesh_file));
vis_geom.set_scale_factors(Vec3(dim_fact));
osim_body.attachGeometry(vis_geom);
end