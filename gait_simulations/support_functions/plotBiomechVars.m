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
% attempt of generic, high-level function to plot a biomechanical variable
% quickly on a standard (3 column) subplot. Allows control on basic options
% such as labels, font size, etc.
function [OUTPUT, figure_handle, axis_handle]  = plotBiomechVars(myStruct, figure_handle, what_to_plot, xlabel_set, ylabel_set, subplot_titles, line_color) 

N_var = length(myStruct.colheaders);

row = round(N_var/3);
col = 3; % by default

for n_var = 1:N_var
    axis_handle(n_var) = subplot(row, col, n_var);
    % set what to plot
    curr_var = myStruct.colheaders{n_var};
    % plot and extract info (OUTPUT variable is left empty here, we just
    % want to plot)
    [OUTPUT(n_var), axis_handle(n_var)]  = analyzeVariable(myStruct, curr_var ,['plot=',what_to_plot],axis_handle(n_var),['Colour=',line_color], 'reverse=n');
end

% adjust axes
% makeSubplotRowYAxisConsistent(figure_handle)
makeSubplotYAxisConsistent(figure_handle)

% add labels
addSubplotXYLabels(figure_handle, xlabel_set, ylabel_set, 12)

% add titles
addSubplotTitles(figure_handle, strrep(subplot_titles,'_',' '))

% setting appropriately the figure for saving the file
set(figure_handle,'PaperPositionMode','Auto');

end