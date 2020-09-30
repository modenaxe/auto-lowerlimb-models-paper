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
% Hardcoded adjustments for plotting kinematics results.

function adjustFigureKinematics(figure_handle)

% CAREFUL: index of children is the opposite of the order of plotting, when
% called as children
ax = findobj(figure_handle,'type','axes');
N_axes = length(ax);

for n = 1:N_axes
    cur_axis = ax(n);
    curr_Ylim = get(cur_axis,'Ylim');
%     if curr_Ylim(2)>=10; curr_Ylim(2) = 9; end
    set(cur_axis, ...
                        'XGrid', 'off',...
                        'YGrid', 'off',...
                        'TickLength',[0.01 0],...
                        'Box','off');
end


% THIS IS FOR SUBTALAR IF INCLUDED
set(ax(7:9), 'Ylim', [-15 20]);
curr_Ylim = get(ax(3),'Ylim');
set(ax(3), 'Ylim', [-10 curr_Ylim(2)])
% hip
set(ax(6), 'Ylim', [-20 60]);
set(ax(4:5), 'Ylim', [-20 20]);
% knee
set(ax(4), 'Ylim', [-20 80]);
% ankle/subtalar
set(ax(1:2), 'Ylim', [-25 20])