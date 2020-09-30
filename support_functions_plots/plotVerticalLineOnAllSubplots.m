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
% Plots a vertical line on all subplots presents in the figure identified
% by the handle. Shades mean and std if V_value is a vector.
function plotVerticalLineOnAllSubplots(figure_handle, V_value, varargin)

if isempty(varargin)
    color = 'k';
else
    color = varargin{1};
end



% CAREFUL: index of children is the opposite of the order of plotting, when
% called as children
% clever way of finding the number of axes in a figure from
% http://stackoverflow.com/questions/15749620/matlab-get-subplot-rows-and-columns
% works well if the figure was created for say 2x3 subplot, but then one
% row or one column was not printed
ax = findobj(figure_handle,'type','axes');
N_axes = length(ax);

for n = 1:N_axes
    cur_axis = ax(n);
    % plots all curves
    if length(V_value)>1
        % if you want to plot all lines
        %         for n_line = 1:length(V_value)
        % %             plotVerticalLine(cur_axis, V_value(n_line), color);
        %         end
        
        %------------ MEAN AND SD BANDS ------------------------
        set(figure_handle,'CurrentAxes', cur_axis)
        %  plotting the mean line
        plotVerticalLine(cur_axis, mean(V_value), color);
        
        % plot SD band
        lb = mean(V_value)+std(V_value);
        ub = mean(V_value)-std(V_value);
        yup = get(cur_axis,'YLim')*100;
        jbfill(ub:lb,ones(length(ub:lb),1)'*yup(1), ones(length(ub:lb),1)'*yup(2) ,color,color, 1, 0.075)
        
    else
        % plots one line if given 1 value
        plotVerticalLine(cur_axis, V_value, color);
    end
end

end