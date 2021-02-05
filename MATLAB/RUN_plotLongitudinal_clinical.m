%% extract from CSV and plot longitudinal data %% 
% created: 20.01.2021

% improved script which contains functions

clear 
close all
clc

%% pre-processing

filename = '20210119_dbExport_impaired.csv'; 
columnNrs = [41 44 46 47 48 50 61]; 
namesPlots = [{'FuglMeyer Motor'},{'Fugl-Meyer Hand'},{'FuglMeyer Sensory'},{'kUDT'},{'BoxBlock'},{'Barthel'},{'MoCA'}]; 
% ROM ForceE ForceF PM MAPRS MAPRF MaxVelE MaxVelF
axisDir = [0 0 0 0 0 0 0]; 
C = extractLongitudinal_clinical(filename,columnNrs); 

plotLongitudinal_clinical(C,namesPlots,axisDir)
