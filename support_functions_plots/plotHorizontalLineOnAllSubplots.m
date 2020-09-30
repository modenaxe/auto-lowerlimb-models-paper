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
% Plots a horizontal line on all subplots presents in the figure identified
% by the handle.
% ----------------------------------------------------------------------- %
function plotHorizontalLineOnAllSubplots(figure_handle, Hvalue, varargin)


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
    done = plotHorizontalLine(cur_axis, Hvalue, color);
    
end

end