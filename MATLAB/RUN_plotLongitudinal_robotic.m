%% extract from CSV and plot longitudinal data %% 
% created: 20.01.2021

% improved script which contains functions

clear 
close all
clc

%% pre-processing

filename = '20210119_dbExport_impaired.csv'; 
metricInfo = '20210121_metricInfo.csv'; 
columnNrs = [92 109 114 122 127 144 160 170 142 123 148 146]; 
namesPlots = [{'AROM'},{'Force Ext'},{'Force Flex (N)'},{'Position Matching AE (deg)'},{'MAPR Slow (deg)'},{'Smoothness MAPR'},{'Max Velocity Extension'},{'MaxVel Flex'},{'Tracking Error RMSE (deg)'},{'Position Matching VE'},{'TrajFollow ROM'},{'TrajFollow minROM'}]; 
% ROM ForceE ForceF PM MAPRS MAPRF MaxVelE MaxVelF
axisDir = [0 0 0 1 1 1 0 0 1 1 0 1]; 
ID = [6 23 28 36 41 58 74 84 56 37 62 60];   

% run functions 
C = extractLongitudinal_robotic(filename,columnNrs); 

%plotLongitudinal_robotic(C,namesPlots,axisDir)

plotSRD_robotic(metricInfo,ID,C,namesPlots,axisDir)

