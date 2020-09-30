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
% Function aimed to implement standard analysis for a generic
% biomechanical variable. Here used for plotting purposes by 
% plotBiomechVars.m....redundant!
% ----------------------------------------------------------------------- %
function  [out, axes_handle] = analyzeVariable(resultStruct, var_name, varargin)

% this will lead to a matrix 100 x n_trials
var_mat = squeeze(getValueColumnForHeader(resultStruct, var_name));


% check if variable is included in structure
 if isempty(var_mat)
     disp(['Variable ',var_name, ' is not included in the result structure. Skipping.'])
     out = [];
     axes_handle = []; % added on 16/10/2017 
     return
 else
     % initializing structure
    out = struct;
   % storing the name of the variable
    out.analised_variable = var_name;
 end
 
 % check if to be reversed
 if length(varargin)>=4 && strcmp(varargin{4},'reverse=y')
        var_mat = var_mat * -1;
 end 
 
%=================== OPERATIONS ==================
% ...REMOVED  

%=================== METRICS ======================
%....REMOVED


% =============== TO BE REMOVED ==================
% plotting all curves and max and min for checking/verifying
if ~isempty(varargin)
    opt = varargin{1};
    
    switch opt
        
        case 'plot=no'
            axes_handle = [];
            return
            
        case 'plot=trials'
            % order of options: plot - axes handles - colors
            if isempty(varargin{2})
                figure('Name',var_name);
                h = axes;
            else
                h = varargin{2};
            end
            
            if size(varargin,2)>=3
                col = varargin{3}(end);
            else
                col = 'k';
            end
            plot(h, 0:length(var_mat)-1, var_mat, col); hold on

        case 'plot=mean'
            
            if isempty(varargin{2})
                figure('Name',var_name);
                h = axes;
            else
                h = varargin{2};
            end
            % 02/09/2016
            % I have chosen to abandon this option and preferred to include
            % the plot handle as second option
            % colour of the plot
            if size(varargin,2)>=3
                col = varargin{3}(end);
            else
                col = 'k';
            end
%====================================
            h = plotMeanSDBand(var_mat,col,h); hold on
            
        otherwise
            error('analizeVariable.m has quick visualizing options: ''plot=trials'' or ''plot=mean''. Option not recognized.')
    end
    axes_handle = h;

end

end