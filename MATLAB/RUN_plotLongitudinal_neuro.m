%% extract from CSV and plot longitudinal data %% 
% created: 21.01.2021

% improved script which contains functions

clear 
close all
clc

% 70 SEP N20 amplitude left
% 71 SEP N20 latency left 
% 73 SEP N20 ampl right
% 74 SEP N20 lat right
% 79 MEP N20 amp left
% 80 MEP N20 lat left
% 84 MEP N20 amp right
% 85 MEP N20 lat right

%% pre-processing

filename = '20210119_dbExport_impaired.csv'; 
columnNrs = [70 73 71 74 79 84 80 85]; 
namesPlots = [{'SEP ampl'},{'SEP lat'},{'MEP ampl'},{'MEP lat'}]; 
axisDir = [0 1 0 1]; 
C = extractLongitudinal_neuro(filename,columnNrs); 

plotLongitudinal_neuro(C,columnNrs,namesPlots,axisDir)
