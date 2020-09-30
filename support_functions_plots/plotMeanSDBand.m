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
% first version by Luca Modenese, Griffith University, (November 2014)
% ----------------------------------------------------------------------- %
% From a matrix of trials plots mean and std as solid line plus shaded area
% of standard deviations. The matrix is normally [time, trial_1, trial_2, etc.]
% with trials variables being column vectors and first column being time.
% ----------------------------------------------------------------------- %
function [plot_handle, M, STD, LB, UB ]= plotMeanSDBand(MatrixOfTrial,color, varargin)

% if the data comes from a 3D matrix ([time, trial, gait_variables]
% squeeze them to [time, gait_variable]
if ndims(MatrixOfTrial)>2
    MatrixOfTrial = squeeze(MatrixOfTrial);
end

% sampling
N_sampling = size(MatrixOfTrial,1);

% plot mean
if isempty(varargin)
    plot_handle = axes;
else
    plot_handle = varargin{1};
%     axes(plot_handle);
end
% plotting mean
if ischar(color)
    plot(plot_handle, 0:N_sampling-1, mean(MatrixOfTrial,2),color,'Linewidth',2); hold on
elseif isvector(color)
    plot(plot_handle, 0:N_sampling-1, mean(MatrixOfTrial,2),'Color',color,'Linewidth',2); hold on
end

% plot SD band
lb = mean(MatrixOfTrial,2)+std(MatrixOfTrial,0,2);
ub = mean(MatrixOfTrial,2)-std(MatrixOfTrial,0,2);

%outputs
M = mean(MatrixOfTrial,2);
STD = std(MatrixOfTrial,0,2);
LB = lb;
UB = ub;
% alpha transp
alpha = 0.2;
jbfill(0:N_sampling-1,lb',ub',color,color,1,alpha);

end