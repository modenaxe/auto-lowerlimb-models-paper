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
clear;clc;fclose all;close all;
addpath('./support_functions');

%---------------------------------------------------------------------------
% folder where results are stored
mat_summary_folder = './Mat_Summaries';
% folder where to save the Figures
figure_folder = 'Figures_gait_comparison';
% axis labels details
AxisFontSize = 12;
AxisFontWeight = 'bold';
% offset in the joint angles present in the manual model (visible from the
% OpenSim GUI for example).
manual_model_ankle_offset = 4.234;
% decide if you want to plot kinematics of kinetics
what_to_plot = 'kinetics';
what_to_plot = 'kinematics';
%---------------------------------------------------------------------------

% create figure folder
if ~isfolder(figure_folder); mkdir(figure_folder);  end

% read results from manual and automatic model
m = load([mat_summary_folder,'\','Summary_P3m6_R_manual.mat']);
a = load([mat_summary_folder,'\','Summary_P3m6_R_automatic.mat']);

% extract summaries for both results
manualSummary = m.SummaryBiomech;
autoSummary   = a.SummaryBiomech;

% create variable depending on the quantity desired for plotting
% (kinematics or kinetics)
switch what_to_plot
    case 'kinematics'
        manualResults = manualSummary.KINEMATICS;
        autoResults   = autoSummary.KINEMATICS;
        list_comparisons = manualSummary.KINEMATICS.colheaders;
        % plot labels for kinematics
        xlabel_set = {'Gait cycle [%]'};ylabel_set = {'Joint Angles [deg]','SPM \{ t \}','Joint Angles [deg]','SPM \{ t \}','Joint Angles [deg]','SPM \{ t \}'};
    case 'kinetics'
        manualResults = manualSummary.KINETICS;
        autoResults   = autoSummary.KINETICS;
        list_comparisons = manualSummary.KINETICS.colheaders;
        % plot labels for kinetics
        xlabel_set = {'Gait cycle [%]'};ylabel_set = {'Joint Moments [Nm/kg]','SPM \{ t \}','Joint Moments [Nm/kg]','SPM \{ t \}','Joint Moments [Nm/kg]','SPM \{ t \}'};
end

% vector of toe offs from the simulated trials
ToeOffV = manualSummary.ToeOffV_R;

%% -------------- T-TEST -----------------
% initialisations
figure_handle = figure('position', [0 0 1440 900]);
n_fig=1;
n_plot=1;

% list of variables to be compared
Nc = numel(list_comparisons);

for n_met = 1:Nc
    
    % variable name from the list of stored results from simulations
    cur_var_name = list_comparisons{n_met};
    
    %(0) Load dataset
    YA = squeeze(getValueColumnForHeader(manualResults,cur_var_name))';
    YB = squeeze(getValueColumnForHeader(autoResults,cur_var_name))';
    
    % apply same offset of the manual model to the automated results
    % otherwise the comparison is not fair (even better would have been
    % addinf it to the manual model)
    if strcmp(cur_var_name, 'ankle_angle') && strcmp(what_to_plot,'kinematics')
        YB=YB-manual_model_ankle_offset;
    end
    
    %(1) Conduct SPM analysis:
    spm       = spm1d.stats.ttest2(YB, YA);
    spmi      = spm.inference(0.05, 'two_tailed', false, 'interp',true);
    disp(spmi)
%     spmi.clusters{:}
    
    %(2) Plot:
    %%% plot mean and SD:
    subplot(3,2,n_plot)
    spm1d.plot.plot_meanSD(YA, 'color','k'); hold on
    spm1d.plot.plot_meanSD(YB, 'color','r'); hold on
    % add title, zero line and toe off line
    title(strrep(cur_var_name,'_',' '), 'FontSize', 16)
    plotHorizontalLine(gca, 0, 'k'); hold on
    plotVerticalLine(gca, mean(ToeOffV), 'b');
    box off
    
    %%% plot SPM results:
    subplot(3,2,n_plot+1)
    spmi.plot();
    spmi.plot_threshold_label();
    spmi.plot_p_values();
    title('hypothesis test', 'FontSize', 16)
    n_plot = n_plot+2;
    box off
    
    % finalise and store figure if the subplot is complete
    if n_plot>6
        % add labels
        addSubplotXYLabels(figure_handle, xlabel_set, ylabel_set, 16, 'normal')
        % save figure
        set(figure_handle,'PaperPositionMode','Auto');
        saveas(figure_handle, fullfile(figure_folder,['Suppl_',what_to_plot,'_Fig',num2str(n_fig),'.fig']));
        % modify/reinitialise flow control variables
        n_fig=n_fig+1;
        n_plot = 1;
        % avoid generating figure if comparisons are over.
        if n_met<Nc
            figure_handle = figure('position', [0 0 1440 900]);
        end
    end
end
