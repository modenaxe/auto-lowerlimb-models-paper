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
% this script plots the joint angle and joint moment from the automatic and
% manual model simulations.
% ----------------------------------------------------------------------- %
clear;clc;fclose all;close all;
addpath(genpath('./support_functions_plots'));

%---------------------------------------------------------------------------
% folder where results are stored
mat_summary_folder = './gait_simulations/Dataset_Mat_Summaries';
% folder where to save the Figures
figure_folder = 'results/Figures_4-5';

% Inspection of the manual JIA-MRI model revealed that the model had 
% 4.234 degrees offset at the ankle joint (so that the reference position 
% was set at that value instead of 0 degrees), so we considered that in the
% automatic model as well, as the model was modified after creating it.
% Offset in the joint angles present in the manual model (visible from the
% OpenSim GUI for example).
manual_model_ankle_offset = 4.234;
%---------------------------------------------------------------------------

% create figure folder
if ~isfolder(figure_folder); mkdir(figure_folder);  end

% read results from manual and automatic model
m = load([mat_summary_folder,'\','Summary_P3m6_R_manual.mat']);
a = load([mat_summary_folder,'\','Summary_P3m6_R_automatic.mat']);

% remove ankle offset
a.SummaryBiomech.KINEMATICS.data(:,strcmp(a.SummaryBiomech.KINEMATICS.colheaders, 'ankle_angle'),:) = ...
    a.SummaryBiomech.KINEMATICS.data(:,strcmp(a.SummaryBiomech.KINEMATICS.colheaders, 'ankle_angle'),:)-manual_model_ankle_offset;

% vector of toe offs from the simulated trials
ToeOffV = m.SummaryBiomech.ToeOffV_R;

what_to_plot = 'mean';
line_color = 'k';
%% ================ PLOTTING =========================
% ToeOffV = [ToeOffV_R, ToeOffV_L];
H_Kin = figure('position', [0 0 1440 900]);

        xlabel_set = {'Gait cycle [%]'};
        ylabel_set = {  'posterior(-)       anterior(+)',...
                        'down(-)      up(+)',...
                        'external(-)      internal(+)',...
                        'extension(-)     flexion(+)',...
                        'abduction(-)   adduction(+)',...
                        'external(-)      internal(+)',...
                        'extension(-)    flexion(+)',...
                        'plantarflexion(-)  dorsiflexion(+)',...
                        'eversion(-)     inversion(+)'};
         title_set = {  'Pelvic tilt [deg]','Pelvic rotation [deg]','Pelvic list [deg]','Hip Flex/Extension [deg]','Hip Ad/Abduction [deg]',...
                        'Hip Int/External rotation [deg]', 'Knee Flex/Extension [deg]','Ankle Dorsi/Plantarflexion [deg]', 'Subtalar Ev/Inversion [deg]'};
subplot_titles = {};
[~, H_Kin, ~]  = plotBiomechVars(m.SummaryBiomech.KINEMATICS, H_Kin, what_to_plot, xlabel_set, ylabel_set, subplot_titles,'k');hold on
[~, H_Kin, ~]  = plotBiomechVars(a.SummaryBiomech.KINEMATICS, H_Kin, what_to_plot, xlabel_set, ylabel_set, subplot_titles, 'r');
plotHorizontalLineOnAllSubplots(H_Kin,0,'k')
plotVerticalLineOnAllSubplots(H_Kin, ToeOffV,'b'); hold on

% add titles
addSubplotTitles(H_Kin, title_set,14)

adjustFigureKinematics(H_Kin)

set(H_Kin,'PaperPositionMode','Auto');
saveas(H_Kin, fullfile(figure_folder,'Figure4_kinematics_comparison.fig'));
% saveas(H_Kin, fullfile(figure_folder,'Figure4_kinematics_comparison.png'));

%% ================ PLOTTING =========================

% H_JMom= figure('Position', [300 311 1374 589]);
H_JMom = figure('position', [0 0 1440 600]);

        % plot labels for kinetics
        xlabel_set = {'Gait cycle [%]'};
        ylabel_set = {'flexion(-)     extension(+)',... 
                      'adduction(-)    abduction(+)',...
                      'internal(-)     external(+)',...
                      'flexion(-)     extension(+)',...
                      'dorsiflexion(-)    plantarflexion(+)',...
                      'inversion(-)  eversion(+)'};
        title_set = {'Hip Flex/Extension [Nm/kg]','Hip Ad/Abduction [Nm/kg]',...
                     'Hip Int/External Rotation [Nm/kg]','Knee Flex/Extension [Nm/kg]',...
                     'Ankle Dorsi/Plantarflexion [Nm/kg]', 'Subtalar Ev/Inversion [Nm/kg]'};
subplot_titles = {};%GRF.colheaders ;KINETICS.colheaders;
[~, H_JMom, ~]  = plotBiomechVars(m.SummaryBiomech.KINETICS, H_JMom, what_to_plot, xlabel_set, ylabel_set, subplot_titles, 'k');
[~, H_JMom, ~]  = plotBiomechVars(a.SummaryBiomech.KINETICS, H_JMom, what_to_plot, xlabel_set, ylabel_set, subplot_titles, 'r');
plotHorizontalLineOnAllSubplots(H_JMom,0,'k')
plotVerticalLineOnAllSubplots(H_JMom, ToeOffV,'b'); hold on
% add titles
addSubplotTitles(H_JMom, title_set,14)

adjustFigureKinetics(H_JMom)
set(H_JMom,'PaperPositionMode','Auto');
saveas(H_JMom, fullfile(figure_folder,'Figure5_kinetics_comparison.fig'));
% saveas(H_JMom, fullfile(figure_folder,'Figure5_kinetics_comparison.png'));

% free the memory
delete(H_Kin); delete(H_JMom);
clear H_Kin H_JMom

rmpath(genpath('./support_functions_plots'));