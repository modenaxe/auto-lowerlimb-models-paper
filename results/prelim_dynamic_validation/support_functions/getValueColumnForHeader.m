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
%    Author:   Luca Modenese,  July 2014                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% Function that allows to retrieve the value of a specified variable whose
% name is specified in var_name
%
% INPUTS
% struct:   is a structure with fields 'colheaders', the headers, and 'data'
%           that is a matrix of data.
% var_name: the name of the variable to extract
%
% OUTPUTS
% var_value: the column of the matrix correspondent to the header specified
%               in input.
%
% modified 29/6/2016
% made changes to ensure that only one variable will be extracted.
% it also ensure extraction of 3D data by taking the 3rd dimension.
% includes modifications implemented in getValueColumnForHeader3D.m
% ----------------------------------------------------------------------- %
function var_value = getValueColumnForHeader(struct, var_name)%, varargin)

% bug scoperto da Giuliano 11/07/2017
if (iscell(var_name)) && isequal(length(var_name),1)
    var_name = var_name{1};
elseif (iscell(var_name)) && length(var_name)>1
    error('getValueColumnForHeader.m Input var_name is a cell array with more than one element. Not supported at the moment. Please give a single label.')
end

% initializing allows better control outside the function
var_value = [];

% gets the index of the desired variable name in the colheaders of the
% structure from where it will be extracted
var_index = strcmp(struct.colheaders, var_name);%june 2016: strcmp instead of strncmp ensures unique correspondance

if sum(var_index) == 0
    % changed from error to warning so the output is the empty set
    warning(['getValueColumnForHeader.m','. No header in structure is matching the name ''',var_name,'''.'])
else
    % check that there is only one column with that label
    if sum(var_index) >1
        display(['getValueColumnForHeader.m',' WARNING: Multiple columns have been identified in summary with label ', var_name]);
        pause
    end
    
    % my choice was to automatically extract the third dimension of a set
    % using the 2D column headers indices
    if ndims(struct.data)==3
        var_value = struct.data(:,var_index,:);
    else
        var_value = struct.data(:,var_index);
    end
    
    % HERE IS AN ALTERNATIVE USING VARARGIN
%     % maybe this could be better handled 
%     if isempty(varargin)
%         var_value = struct.data(:,var_index);
%     elseif strcmp(varargin{1},'3D')==1
%         display('Extracting 3D data.')
%         % uses the index to retrieve the column of values for that variable.
%         var_value = struct.data(:,var_index,:);
%     end
end

end
