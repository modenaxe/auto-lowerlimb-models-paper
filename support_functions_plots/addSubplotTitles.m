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
% creates titles for the subplots of the figure identified by the
% figure_handle using the title_set.
% ----------------------------------------------------------------------- %
function figure_handle = addSubplotTitles(figure_handle, title_set, varargin)

% control on font size
% default
font_size = 14;
FontWeight = 'bold';
if ~isempty(varargin)
    font_size = varargin{1};
    if size(varargin, 2) ==2
        FontWeight = varargin{2};
    end
end

% CAREFUL: index of children is the opposite of the order of plotting, when
% called as children

if isempty(title_set) || size(title_set,1)==0 || size(title_set,2)==0
    return
end

% clever way of finding the number of axes in a figure from
% http://stackoverflow.com/questions/15749620/matlab-get-subplot-rows-and-columns
% works well if the figure was created for say 2x3 subplot, but then one
% row or one column was not printed
ax = findobj(figure_handle,'type','axes');
if isempty(ax)
    display('makeSubplotRowYAxisConsistent.m : Figure handle does not have children. Returning to invoking function...')
    return
end
pos = cell2mat(get(ax,'position'));
N_cols = numel(unique(pos(:,1))); % same X positions
% N_rows = numel(unique(pos(:,2))); % same Y positions
% N = N_rows * N_cols;

% how many subplots
h = get(figure_handle, 'children');
N = length(h);

% if less labels than col than user wants just to put a title on the first
% row
% if same number user wants to give a title to each plot
if size(title_set,2)<length(ax)
    N_iter = N_cols;
elseif size(title_set,2)==length(ax)
    N_iter = length(ax);
end

for n = 1:N_iter
    if iscell(title_set) == 0
        cur_title = title_set;
    else
        cur_title = title_set{n};
    end
    title(h(N-n+1), cur_title,'FontWeight',FontWeight,'FontSize',font_size,'FontName','Arial')
end


end