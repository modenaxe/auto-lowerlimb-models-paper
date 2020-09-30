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
% Inspection of the manual JIA-MRI model revealed that the model had 
% 4.234 degrees offset at the ankle joint (so that the reference position 
% was set at that value instead of 0 degrees), so we considered that in the
% automatic model as well.
clear;clc;fclose all;close all;
addpath('./support_functions');

%---------------------------------------------------------------------------
% folder where results are stored
mat_summary_folder = './gait_simulations/Dataset_Mat_Summaries';
stats_results_folder = './results/gait_sims_analysis';
% folder where to save the Figures
figure_folder = './results/Figures_S4-S8_SPM_stats';
% axis labels details
AxisFontSize = 12;
AxisFontWeight = 'bold';
% offset in the joint angles present in the manual model (visible from the
% OpenSim GUI for example).
manual_model_ankle_offset = 4.234;
% decide if you want to plot kinematics of kinetics
what_to_plot_set = {'kinematics', 'kinetics'};
%---------------------------------------------------------------------------

% create figure folder
if ~isfolder(figure_folder); mkdir(figure_folder);  end
% create stats results folder
if ~isfolder(stats_results_folder); mkdir(stats_results_folder);  end

for n_plot_type = 1:length(what_to_plot_set)
    what_to_plot = what_to_plot_set{n_plot_type};
    
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
        xlabel_set = {'Gait cycle [%]'};
        ylabel_set = {  'posterior(-)       anterior(+)','SPM \{ t \}',...
                        'down(-)      up(+)','SPM \{ t \}',...
                        'external(-)      internal(+)','SPM \{ t \}',...
                        'extension(-)     flexion(+)','SPM \{ t \}',...
                        'abduction(-) adduction(+)','SPM \{ t \}',...
                        'external(-)      internal(+)','SPM \{ t \}',...
                        'extension(-)    flexion(+)','SPM \{ t \}',...
                        'plantarflexion(-)  dorsiflexion(+)','SPM \{ t \}',...
                        'eversion(-)  inversion(+)','SPM \{ t \}'};
         title_set = {  'Pelvic tilt [deg]','Pelvic rotation [deg]','Pelvic list [deg]','Hip Flex/Extension [deg]','Hip Ad/Abduction [deg]',...
                        'Hip Int/External rotation [deg]', 'Knee Flex/Extension [deg]','Ankle Dorsi/Plantarflexion [deg]', 'Subtalar Eversion/Inversion [deg]'};
    case 'kinetics'
        manualResults = manualSummary.KINETICS;
        autoResults   = autoSummary.KINETICS;
        list_comparisons = manualSummary.KINETICS.colheaders;
        % plot labels for kinetics
        xlabel_set = {'Gait cycle [%]'};
        ylabel_set = {'flexion(-)     extension(+)','SPM \{ t \}',... 
                      'adduction(-)    abduction(+)','SPM \{ t \}',...
                      'internal(-)     external(+)','SPM \{ t \}',...
                      'flexion(-)     extension(+)','SPM \{ t \}',...
                      'dorsiflexion(-)    plantarflexion(+)','SPM \{ t \}',...
                      'inversion(-)  eversion(+)','SPM \{ t \}'};
        title_set = {'Hip Flex/Extension Moment [Nm/kg]','Hip Ad/Abduction Moment [Nm/kg]',...
                     'Hip Int/External Rotation Moment [Nm/kg]','Knee Flex/Extension Moment [Nm/kg]',...
                     'Ankle Dorsi/Plantar Moment [Nm/kg]', 'Subtalar Ev/Inversion Moment [Nm/kg]'};
end

% vector of toe offs from the simulated trials
ToeOffV = manualSummary.ToeOffV_R;

%% -------------- T-TEST -----------------
% initialisations
figure_handle = figure('position', [0 0 1440 900]);
n_fig=1;
n_plot=1;
n_label = 1;
n_label_old = n_label;
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
    % addinG it to the manual model)
    if strcmp(cur_var_name, 'ankle_angle') && strcmp(what_to_plot,'kinematics')
        YB=YB-manual_model_ankle_offset;
    end
    
    %(1) Conduct SPM analysis:
    spm       = spm1d.stats.ttest2(YB, YA);
    spmi      = spm.inference(0.05, 'two_tailed', true, 'interp',true);
%     disp(spmi)
% cluster analysis
%     report_clusters.(cur_var_name).nr = length(spmi.clusters);
    ext_collector = [];
    for nc = 1:length(spmi.clusters)
        ext_collector = [ext_collector, spmi.clusters{nc}.extent];
    end
    report_clusters(n_met,:) = sum(ext_collector);
    
    % correlation coefficient
    for n_trial = 1:size(YB, 1)
        [R(:,:,n_trial), P(:,:,n_trial)]= corrcoef(YB(n_trial,:)', YA(n_trial,:)');
    end
    
    % all values
    report_RMS_v.([cur_var_name,'_rmse']) = sqrt(mean((YB-YA).^2,2));
    report_corrcoeff_v.([cur_var_name,'_roh']) = squeeze(R(2,1,:));
    report_corrcoeff_v.([cur_var_name,'_p_val']) = squeeze(P(2,1,:));
    
    % save table with mean / std / p value
    report_RMSE(n_met,:) = [mean(sqrt(mean((YB-YA).^2,2))), std(sqrt(mean((YB-YA).^2,2)))];
    report_corrcoeff(n_met,:) = [mean(squeeze(R(2,1,:))), std(squeeze(R(2,1,:))), mean(squeeze(P(2,1,:))), std(squeeze(P(2,1,:)))];
    
    %(2) Plot:
    %%% plot mean and SD:
    subplot(3,2,n_plot)
    spm1d.plot.plot_meanSD(YA, 'color','k'); hold on
    spm1d.plot.plot_meanSD(YB, 'color','r'); hold on
    % add title, zero line and toe off line
    title(title_set{n_label}, 'FontSize', 16)
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
        addSubplotXYLabels(figure_handle, xlabel_set, ylabel_set(n_label_old:n_label*2), 13, 'normal')
        % save figure
        set(figure_handle,'PaperPositionMode','Auto');
        saveas(figure_handle, fullfile(figure_folder,['Suppl_',what_to_plot,'_Fig',num2str(n_fig),'.fig']));
%         saveas(figure_handle, fullfile(figure_folder,['Suppl_',what_to_plot,'_Fig',num2str(n_fig),'.png']));
        % modify/reinitialise flow control variables
        n_fig=n_fig+1;
        n_plot = 1;
        n_label_old=n_label*2+1;
        % avoid generating figure if comparisons are over.
        if n_met<Nc
            figure_handle = figure('position', [0 0 1440 900]);
        end
    end
    n_label = n_label+1;
end
% build a table
cur_res_table = table(report_corrcoeff(:,1), report_corrcoeff(:,2),...
    report_corrcoeff(:,3), report_corrcoeff(:,4),...
    report_RMSE(:,1), report_RMSE(:,2), report_clusters,...
    'VariableNames',{'corr_coeff (mean)', 'corr_coeff (std)', ...
    'p val (average)', 'p val (std)',...
    'RMSE (mean)', 'RMSE (std)', 'SPM-Test diff clusters(% gait cycle)'});
cur_res_table.Properties.RowNames = list_comparisons;

% write results on xlsx file
writetable(cur_res_table, [stats_results_folder,filesep,'gait_sims_',what_to_plot,'_stats.xlsx']);
    
% collect the tables with results stats
stats_tables(n_plot_type) = {cur_res_table};

clear report_corrcoeff report_RMSE report_clusters
end

% close all
disp('----------')
disp('Kinematics')
disp('----------')
disp(stats_tables{1})
disp('   ')
disp('----------')
disp('Kinetics')
disp('----------')
disp(stats_tables{1})
