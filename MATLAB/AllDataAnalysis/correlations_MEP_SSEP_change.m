%% check correlations SSEP vs proprioception %% 
% created: 05.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

M = readtable('data/20211104_MEP.csv'); 
MEP = table2array(M(:,:)); 

S = readtable('data/20211102_SSEP.csv'); 
SEP = table2array(S(:,:)); 

%% calculate amplitude ratio

%% % clean up and merge 

ampl_ratio(:,1) = MEP(:,1); 
ampl_ratio(:,2) = MEP(:,2)./MEP(:,4); 
ampl_ratio(:,3) = MEP(:,3)./MEP(:,5); 
ampl_ratio(:,4) = SEP(:,2)./SEP(:,4); 
ampl_ratio(31,4) = 1; 
ampl_ratio(:,5) = SEP(:,3)./SEP(:,5); 

% change
ampl_ratio(:,6) = ampl_ratio(:,3)-ampl_ratio(:,2);
ampl_ratio(:,7) = ampl_ratio(:,5)-ampl_ratio(:,4);

%% plot - amplitude ratio SSEP vs MEP - Delta 

% ampl ratio: T1
figure; 
scatter(ampl_ratio(:,7),ampl_ratio(:,6),'filled')
hold on 
labelpoints(ampl_ratio(:,7),ampl_ratio(:,6),string(ampl_ratio(:,1))); 
% xlim([-0.2 2.5]) 
% xline(0.5, '--k'); 
xlabel('Delta SSEP amplitude ratio') 
ylabel('Delta MEP amplitude ratio') 
print('plots/ScatterPlots/211108_MEP_SSEP_amplRatio_Delta','-dpng')

