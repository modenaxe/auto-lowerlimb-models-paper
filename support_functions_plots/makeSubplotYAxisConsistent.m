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
% Adjusts the Y axis of subplots in a figure so that they all have the same
% min and max limits.
function [figure_handle, axes_min, axes_max] = makeSubplotYAxisConsistent(figure_handle)

% differs from makeSubplotRowYAxisConsistent as all rows have same y axis

% adjust axes
subaxes = figure_handle.Children;

% clever way of finding the number of axes in a figure from
% http://stackoverflow.com/questions/15749620/matlab-get-subplot-rows-and-columns
% works well if the figure was created for say 2x3 subplot, but then one
% row or one column was not printed
ax = findobj(figure_handle,'type','axes');
if isempty(ax)
    disp('makeSubplotRowYAxisConsistent.m : Figure handle does not have children. Returning to invoking function...')
    return
end
pos = cell2mat(get(ax,'position'));
N_cols = numel(unique(pos(:,1))); % same X positions
N_rows = numel(unique(pos(:,2))); % same Y positions

%normalize_Yaxis
% N_rows = rows;
% N_cols = cols;
% changed to deal with incomplete rows
T_tot = size(ax,1);%T_tot = N_rows*N_cols;
count = 0;
count2 = 0;
axes_max = -Inf;
axes_min = Inf;
for n_rows = 1:N_rows
    for n_col = 1:N_cols
        % NEW TO HANDLE INCOMPLETE ROWS
        if count == T_tot
            break
        end
        %--------------------------------
        curr_Ylim = get(subaxes(T_tot-count),'Ylim');
        if curr_Ylim(2)>axes_max
            axes_max = curr_Ylim(2);
        end
        if curr_Ylim(1)<axes_min
            axes_min = curr_Ylim(1);
        end
        count = count+1;
    end
end
    
    for n = 1:T_tot
        set(subaxes(T_tot-count2),'Ylim',[axes_min axes_max]);
        count2 = count2+1;
        % NEW TO HANDLE INCOMPLETE ROWS
        if count2 == T_tot
            break
        end
        %--------------------------------
    end
end

