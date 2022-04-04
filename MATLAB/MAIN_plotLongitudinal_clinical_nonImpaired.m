%% extract from CSV and plot longitudinal data %% 
% created: 20.01.2021

% improved script which contains functions

clear 
close all
clc

%% pre-processing

filename = '20210408_DataNonImpaired.csv'; 
columnNrs = 49; 
namesPlots = {'BoxBlock NonImp'}; 
% ROM ForceE ForceF PM MAPRS MAPRF MaxVelE MaxVelF
axisDir = 0; 
C = extractLongitudinal_clinical(filename,columnNrs); 

plotLongitudinal_clinical(C,namesPlots,axisDir)
