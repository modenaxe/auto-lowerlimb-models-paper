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
% Hardcoded adjustments for plotting kinetics results

function adjustFigureKinetics(figure_handle)

% CAREFUL: index of children is the opposite of the order of plotting, when
% called as children
% clever way of finding the number of axes in a figure from
% http://stackoverflow.com/questions/15749620/matlab-get-subplot-rows-and-columns
ax = findobj(figure_handle,'type','axes');
N_axes = length(ax);

for n = 1:N_axes
    cur_axis = ax(n);

    set(cur_axis, ...
                        'XGrid', 'off',...
                        'YGrid', 'off',...
                        'TickLength',[0.01 0],...
                        'Box','off');
end

% THIS IS FOR SUBTALAR IF INCLUDED
% set(ax(6), 'Ylim', [-0.75 1])
set(ax(5), 'Ylim', [-0.5 1])
set(ax([1,4]), 'Ylim', [-0.5 0.5])
set(ax(2), 'Ylim', [-0.5 1.5])
set(ax(3), 'Ylim', [-0.5 1.0])


