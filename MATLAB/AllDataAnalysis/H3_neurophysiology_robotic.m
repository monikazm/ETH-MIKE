%% check correlations MEP vs SSEP vs robotic (H2) %% 
% created: 05.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T1 = readtable('data/20211104_MEP.csv'); 
T2 = readtable('data/20211102_SSEP.csv');

A1 = table2array(T1(:,:)); 
A2 = table2array(T2(:,:)); 

%% calculate amplitude ratio

MEP.ampl_ratio.T1 = A1(:,2)./A1(:,4); 
SSEP.ampl_ratio.T1 = A2(:,2)./A2(:,4); 
MEP.ampl_ratio.T3 = A1(:,3)./A1(:,5); 
SSEP.ampl_ratio.T3 = A2(:,3)./A2(:,5); 
MEP.lat_diff.T1 = A1(:,6) - A1(:,8); 
SSEP.lat_diff.T1 = A2(:,6) - A2(:,8);
MEP.lat_diff.T3 = A1(:,7) - A1(:,9);
SSEP.lat_diff.T3 = A2(:,7) - A2(:,9);
Force.T1 = A1(:,10); 
Force.T3 = A1(:,11);
ROM.T1 = A1(:,14); 
ROM.T3 = A1(:,15); 
Vel.T1 = A1(:,16); 
Vel.T3 = A1(:,17); 
PM.T1 = A2(:,10); 
PM.T3 = A2(:,11); 

% change
MEP.ampl_ratio.Delta = MEP.ampl_ratio.T3-MEP.ampl_ratio.T1;
SSEP.ampl_ratio.Delta = SSEP.ampl_ratio.T3-SSEP.ampl_ratio.T1;
MEP.lat_diff.Delta = MEP.lat_diff.T3-MEP.lat_diff.T1; 
SSEP.lat_diff.Delta = SSEP.lat_diff.T3-SSEP.lat_diff.T1; 
Force.Delta = Force.T3-Force.T1; 
ROM.Delta = ROM.T3-ROM.T1; 
Vel.Delta = Vel.T3-Vel.T1; 
PM.Delta = PM.T1-PM.T3; 

%% MEP at T3 vs PM at T3

% MEP amplitude
figure; 
scatter(PM.T3,MEP.ampl_ratio.T3,'filled','k')
hold on 
labelpoints(PM.T3,MEP.ampl_ratio.T3,string(A1(:,1))); 
% xlim([-0.5 0.5]) 
ylim([-0.2 1.5]) 
ylabel('MEP amplitude ratio @ T3') 
xlabel('Position Matching Error @ T3') 
print('plots/ScatterPlots/211105_MEPampl_PM_T3','-dpng')

