%% check correlations SSEP vs proprioception %% 
% created: 05.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211102_SSEP.csv'); 

A = table2array(T(:,:)); 

%% calculate amplitude ratio

ampl_ratio.T1 = A(:,2)./A(:,4); 
ampl_ratio.T1(31,1) = 1; 
ampl_ratio.T3 = A(:,3)./A(:,5); 
lat_diff.T1 = A(:,6) - A(:,8); 
lat_diff.T3 = A(:,7) - A(:,9);
PM.T1 = A(:,10); 
PM.T3 = A(:,11);
kUDT.T1 = A(:,12); 
kUDT.T3 = A(:,13); 

% change
ampl_ratio.Delta = ampl_ratio.T3-ampl_ratio.T1;
lat_diff.Delta = lat_diff.T3-lat_diff.T1; 
PM.Delta = PM.T1-PM.T3; 

%% plot - amplitude SSEP vs PM - Delta 

% ampl ratio: T1
figure; 
scatter(ampl_ratio.Delta,PM.Delta,'filled')
hold on 
labelpoints(ampl_ratio.Delta,PM.Delta,string(A(:,1))); 
% xlim([-0.2 2.5]) 
% xline(0.5, '--k'); 
ylabel('Delta Position Matching AE') 
xlabel('Delta SSEP amplitude ratio') 
print('plots/ScatterPlots/211105_PM_SSEP_amplRatio_Delta','-dpng')

%% plot - latency SSEP vs PM - Delta 

figure; 
scatter(lat_diff.Delta,PM.Delta,'filled')
hold on 
labelpoints(lat_diff.Delta,PM.Delta,string(A(:,1))); 
xlim([-3 3]) 
% xline(0.5, '--k'); 
ylabel('Delta Position Matching AE') 
xlabel('Delta SSEP latency difference') 
print('plots/ScatterPlots/211105_PM_SSEP_LatDiff_Delta','-dpng')

%% Delta position matching vs initial SSEP ampl ratio

% ampl ratio: T1
figure; 
scatter(ampl_ratio.T1,PM.Delta,'filled')
hold on 
labelpoints(ampl_ratio.T1,PM.Delta,string(A(:,1))); 
xlim([0 1.1]) 
% xline(0.5, '--k'); 
ylabel('Delta Position Matching AE') 
xlabel('SSEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211105_PMDelta_SSEP_amplRatio_T1','-dpng')

%% correlations

n = 1; 
for i=1:length(ampl_ratio.Delta)
    if isnan(ampl_ratio.Delta(i,1)) || isnan(PM.Delta(i,1))
    else
        ampl_ratio.Delta_nonan(n,1) = ampl_ratio.Delta(i,1); 
        lat_diff.Delta_nonan(n,1) = lat_diff.Delta(i,1);
        PM.Delta_nonan(n,1) = PM.Delta(i,1);
        n = n+1; 
    end
end


n = 1; 
for i=1:length(ampl_ratio.T1)
    if isnan(ampl_ratio.T1(i,1)) || isnan(PM.Delta(i,1))
    else
        ampl_ratio.T1_nonan(n,1) = ampl_ratio.T1(i,1); 
        PM.Delta_nonan2(n,1) = PM.Delta(i,1);
        n = n+1; 
    end
end



[rho1,pval1] = corr(ampl_ratio.Delta_nonan,PM.Delta_nonan, 'Type', 'Spearman');
[rho2,pval2] = corr(lat_diff.Delta_nonan,PM.Delta_nonan, 'Type', 'Spearman');
[rho3,pval3] = corr(ampl_ratio.T1_nonan,PM.Delta_nonan2, 'Type', 'Spearman');



