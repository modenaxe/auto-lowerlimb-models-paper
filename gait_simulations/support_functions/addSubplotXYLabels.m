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
% script that updates X and Y labels of subplots across an entire figure.
function addSubplotXYLabels(figure_handle, xlabel_set, ylabel_set, varargin)

% default
FontWeightX = 'normal';
FontWeightY = 'normal';
font_sizeX = 10;
font_sizeY = 10;

% control on font size
if ~isempty(varargin)
    font_sizeX = varargin{1};
    font_sizeY = varargin{1};
    if size(varargin, 2)==2
        FontWeightX = varargin{2};
        FontWeightY = varargin{2};
    end
end

% CAREFUL: index of children is the opposite of the order of plotting, when
% called as children

% clever way of finding the number of axes in a figure from
% http://stackoverflow.com/questions/15749620/matlab-get-subplot-rows-and-columns
% works well if the figure was created for say 2x3 subplot, but then one
% row or one column was not printed
ax = findobj(figure_handle,'type','axes');
pos = cell2mat(get(ax,'position'));
if isempty(ax)
    display('addXYLabels.m : Figure handle does not have children. Returning to invoking function...')
    return
end
N_cols = numel(unique(pos(:,1))); % same X positions
N_rows = numel(unique(pos(:,2))); % same Y positions
% N = N_rows * N_cols;
N = size(ax,1);

h = get(figure_handle, 'children');

% easy improvement
% % if less labels than col than user wants just to put a title on the first
% % row
% % if same number user wants to give a title to each plot
% if size(title_set,2)<length(ax)
%     N_iter = N_cols;
% elseif size(title_set,2)==length(ax)
%     N_iter = length(ax);
% end

% X labels
for n = 1:N_cols
    if (iscell(xlabel_set) == 0) || size(xlabel_set,2)==1
        cur_xlabel = xlabel_set;
    else
        cur_xlabel = xlabel_set{n};
    end
    xlabel(h(n), cur_xlabel,'FontWeight',FontWeightX,'FontSize',font_sizeX,'FontName','Arial')
end

if iscell(ylabel_set) == 0 || size(ylabel_set,2)==1
    for n = 1:N_rows
        % this if allows to have ylabels of type cell also if they are
        % 1-component.
        if iscell(ylabel_set) == 1
            cur_ylabel = ylabel_set{1};
        else
            cur_ylabel = ylabel_set;
        end
        ylabel(h(N-(n-1)*N_cols), cur_ylabel,'FontWeight',FontWeightY,'FontSize',font_sizeY,'FontName','Arial')
    end
end

if size(ylabel_set,2)==N_rows
    for n = 1:N_rows
        cur_ylabel = ylabel_set{n};
        
        ylabel(h(N-(n-1)*N_cols), cur_ylabel,'FontWeight',FontWeightY,'FontSize',font_sizeY,'FontName','Arial')
    end
end

if size(ylabel_set,2)==N
    N_cols = 1;
     for n = 1:N
        cur_ylabel = ylabel_set{n};
        ylabel(h(N-(n-1)*N_cols), cur_ylabel,'FontWeight',FontWeightY,'FontSize',font_sizeY,'FontName','Arial')
     end
end

end