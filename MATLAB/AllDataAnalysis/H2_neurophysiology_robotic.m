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

%% SSEP vs MEP

% amplitude
figure; 
scatter(SSEP.ampl_ratio.Delta,MEP.ampl_ratio.Delta,'filled','k')
hold on 
labelpoints(SSEP.ampl_ratio.Delta,MEP.ampl_ratio.Delta,string(A1(:,1))); 
% xlim([-0.5 0.5]) 
% ylim([-0.5 0.5]) 
ylabel('Delta MEP amplitude ratio') 
xlabel('Delta SSEP amplitude ratio') 
print('plots/ScatterPlots/211105_MEP_SSEP_amplRatio_Delta','-dpng')

% latency
figure; 
scatter(SSEP.lat_diff.Delta,MEP.lat_diff.Delta,'filled','k')
hold on 
labelpoints(SSEP.lat_diff.Delta,MEP.lat_diff.Delta,string(A1(:,1))); 
% xlim([-0.5 0.5]) 
% ylim([-0.5 0.5]) 
ylabel('Delta MEP latency difference') 
xlabel('Delta SSEP latency difference') 
print('plots/ScatterPlots/211105_MEP_SSEP_latdiff_Delta','-dpng')

%% Delta PM vs Delta MEP

% amplitude
figure; 
scatter(PM.Delta,MEP.ampl_ratio.Delta,'filled','k')
hold on 
labelpoints(PM.Delta,MEP.ampl_ratio.Delta,string(A1(:,1))); 
% xlim([-0.5 0.5]) 
ylim([-1.5 1.5]) 
ylabel('Delta MEP amplitude ratio') 
xlabel('Delta Position Matching Error') 
print('plots/ScatterPlots/211105_MEPamplratio_PM_Delta','-dpng')

%% change PM vs initial MEP

% amplitude
figure; 
scatter(MEP.ampl_ratio.T1,PM.Delta,'filled','k')
hold on 
labelpoints(MEP.ampl_ratio.T1,PM.Delta,string(A1(:,1))); 
hold on 
xline(0.5, '--k'); 
%yline(1, '--k'); 
xlim([-0.5 2]) 
ylim([-9 12]) 
xlabel('MEP amplitude ratio @ T1') 
ylabel('Delta Position Matching Error (deg)') 
print('plots/ScatterPlots/211105_MEPamplT1_PMDelta','-dpng')

% latency
figure; 
scatter(MEP.lat_diff.T1,PM.Delta,'filled','k')
hold on 
labelpoints(MEP.lat_diff.T1,PM.Delta,string(A1(:,1))); 
hold on 
xline(1.1, '--k'); 
% yline(1, '--k'); 
% xlim([-0.5 2]) 
ylim([-9 12]) 
xlabel('MEP latency difference @ T1') 
ylabel('Delta Position Matching Error (deg)') 
print('plots/ScatterPlots/211105_MEPlatdiffT1_PMDelta','-dpng')


%% correlation - lat diff

n = 1; 
for i=1:length(MEP.lat_diff.Delta)
    if isnan(MEP.lat_diff.Delta(i,1)) || isnan(SSEP.lat_diff.Delta(i,1))
    else
        MEP.lat_diff.Delta_nonan(n,1) = MEP.lat_diff.Delta(i,1); 
        SSEP.lat_diff.Delta_nonan(n,1) = SSEP.lat_diff.Delta(i,1); 
        n = n+1; 
    end
end

[rho.Delta.latdiff,pval.Delta.latdiff] = corr(MEP.lat_diff.Delta_nonan,SSEP.lat_diff.Delta_nonan, 'Type', 'Spearman');


%% correlation - amplitude 

n = 1; 
for i=1:length(MEP.ampl_ratio.Delta)
    if isnan(MEP.ampl_ratio.Delta(i,1)) || isnan(SSEP.ampl_ratio.Delta(i,1))
    else
        MEP.ampl_ratio.Delta_nonan(n,1) = MEP.ampl_ratio.Delta(i,1); 
        SSEP.ampl_ratio.Delta_nonan(n,1) = SSEP.ampl_ratio.Delta(i,1); 
        n = n+1; 
    end
end

[rho.Delta.amplratio,pval.Delta.amplratio] = corr(MEP.ampl_ratio.Delta_nonan,SSEP.ampl_ratio.Delta_nonan, 'Type', 'Spearman');

%% correlation - pm vs mep 

n = 1; 
for i=1:length(MEP.ampl_ratio.T1)
    if isnan(MEP.ampl_ratio.T1(i,1)) || isnan(PM.Delta(i,1))
    else
        MEP.ampl_ratio.T1_nonan(n,1) = MEP.ampl_ratio.T1(i,1); 
        MEP.lat_diff.T1_nonan(n,1) = MEP.lat_diff.T1(i,1); 
        PM.Delta_nonan(n,1) = PM.Delta(i,1); 
        n = n+1; 
    end
end

[rho.DeltaPM_MEPT12,pval.DeltaPM_MEPT12] = corr(MEP.lat_diff.T1_nonan,PM.Delta_nonan, 'Type', 'Spearman');



