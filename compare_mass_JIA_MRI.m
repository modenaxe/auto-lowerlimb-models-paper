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
% This script compares the mass and centre of mass position (com) of the segment
% of the manually created and automatically created JIA-MRI models.
% We used the differences for discussing the differences in joint moments
% observed when simulating the same gait trials with the two models.
% Our reference publication for interpreting the results was:
% Wesseling, M., et al. (2014). "The effect of perturbing body segment 
% parameters on calculated joint moments and muscle forces during gait." 
% Journal of Biomechanics 47(2): 596-601.
% They found that if the inertia properties of a model were perturbed, the
% largest variations in inverse dynamics analyses were observed at the hip 
% flex/extension moment and were due to shank com and mass alteration.
% Our models differ in terms of shank mass, not com, and be observed
% similar differences in joint moment at the hip joint.
% The moments of inertia and changes in inertia properties of the other 
% segments seem to be less critical, accoding to the publication.
% ----------------------------------------------------------------------- %

import org.opensim.modeling.*
addpath(genpath('msk-STAPLE/STAPLE'));
addpath('support_functions');

% model folders
model_folder = 'opensim_models';

% read models
auto_JIA = Model([model_folder, filesep, 'automatic_JIA_MRI.osim']);
manual_JIA = Model([model_folder, filesep, 'manual_JIA_MRI.osim']);

% number of bodies in automatic model
N_bodies = auto_JIA.getBodySet().getSize();

% tibia has karge % variation and has been linked to variation in hip
% moments before.
for nb = 0:N_bodies-1
    % get current body
    curr_auto_body = auto_JIA.getBodySet().get(nb);
    curr_manu_body = manual_JIA.getBodySet().get(nb);
    disp(['Body: ', char(curr_auto_body.getName())]);
    disp(['mass autom  [kg]: ', num2str(curr_auto_body.getMass())])
    disp(['mass manual [kg]: ', num2str(curr_manu_body.getMass())])
    disp(['diff (aut-man)  : ', num2str(curr_auto_body.getMass()-curr_manu_body.getMass())])
    disp(['diff (%manual)  : ', num2str(100*(curr_auto_body.getMass()-curr_manu_body.getMass())/curr_manu_body.getMass())])
    disp('----------------------')
end

% on tibia vertical diff in com position is around 5.6% variation of the 
% total length (~36 cm, estimated from the bone bounding box in MeshLab).
% x component is medio/lateral
% y component is antero/posterior
% z component is prox/distal
for nb = 0:N_bodies-1
    % get current body
    curr_auto_body = auto_JIA.getBodySet().get(nb);
    curr_manu_body = manual_JIA.getBodySet().get(nb);
    disp(['Body: ', char(curr_auto_body.getName())]);
    disp(['com autom     [m]: ', num2str(osimVec3ToArray(curr_auto_body.get_mass_center()))])
    disp(['com manual    [m]: ', num2str(osimVec3ToArray(curr_manu_body.get_mass_center()))])
    disp(['diff (aut-man) [m]: ', num2str(osimVec3ToArray(curr_auto_body.get_mass_center())-osimVec3ToArray(curr_manu_body.get_mass_center()))])
    disp('----------------------')
end

% remove STAPLE from path
rmpath(genpath('msk-STAPLE/STAPLE'));
rnpath('support_functions');
