%% check correlations MEP vs motor tasks %% 
% created: 04.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211104_MEP.csv'); 

A = table2array(T(:,:)); 

%% calculate amplitude ratio

ampl_ratio.T1 = A(:,2)./A(:,4); 
ampl_ratio.T3 = A(:,3)./A(:,5); 
lat_diff.T1 = A(:,6) - A(:,8); 
lat_diff.T3 = A(:,7) - A(:,9);
Force.T1 = A(:,10); 
Force.T3 = A(:,11);
ROM.T1 = A(:,14); 
ROM.T3 = A(:,15); 
Vel.T1 = A(:,16); 
Vel.T3 = A(:,17); 

% change
ampl_ratio.Delta = ampl_ratio.T3-ampl_ratio.T1;
lat_diff.Delta = lat_diff.T3-lat_diff.T1; 
Force.Delta = Force.T3-Force.T1; 
ROM.Delta = ROM.T3-ROM.T1; 
Vel.Delta = Vel.T3-Vel.T1; 

%% plot - Force 

figure; 
scatter(ampl_ratio.Delta,Force.Delta,'filled','k')
hold on 
labelpoints(ampl_ratio.Delta,Force.Delta,string(A(:,1))); 
xlim([-1.5 1]) 
ylabel('Delta Maximum Force') 
xlabel('Delta MEP amplitude ratio') 
print('plots/ScatterPlots/211105_Force_MEP_amplRatio_Delta','-dpng')

figure; 
scatter(lat_diff.Delta,Force.Delta,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
xlim([-4 6]) 
ylabel('Delta Maximum Force') 
xlabel('Delta MEP latency differecne') 
print('plots/ScatterPlots/211105_Force_MEP_latDiff_Delta','-dpng')

%% plot - ROM

figure; 
scatter(ampl_ratio.Delta,ROM.Delta,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
xlim([-1.5 1]) 
ylabel('Delta ROM') 
xlabel('Delta MEP amplitude ratio') 
print('plots/ScatterPlots/211105_ROM_MEP_amplRatio_Delta','-dpng')

figure; 
scatter(lat_diff.Delta,ROM.Delta,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
xlim([-4 6]) 
ylabel('Delta ROM') 
xlabel('Delta MEP latency differecne') 
print('plots/ScatterPlots/211105_ROM_MEP_latDiff_Delta','-dpng')

%% plot - Vel

figure; 
scatter(ampl_ratio.Delta,Vel.Delta,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
xlim([-1.5 1]) 
ylabel('Delta Max Vel') 
xlabel('Delta MEP amplitude ratio') 
print('plots/ScatterPlots/211105_Vel_MEP_amplRatio_Delta','-dpng')

figure; 
scatter(lat_diff.Delta,Vel.Delta,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
xlim([-4 6]) 
ylabel('Delta Max Vel') 
xlabel('Delta MEP latency differecne') 
print('plots/ScatterPlots/211105_Vel_MEP_latDiff_Delta','-dpng')

%% correlation - lat diff

n = 1; 
for i=1:length(lat_diff.Delta)
    if isnan(lat_diff.Delta(i,1)) || isnan(Force.Delta(i,1))
    else
        lat_diff.Delta_nonan(n,1) = lat_diff.Delta(i,1); 
        Force.Delta_nonan(n,1) = Force.Delta(i,1); 
        ROM.Delta_nonan(n,1) = ROM.Delta(i,1);
        Vel.Delta_nonan(n,1) = Vel.Delta(i,1);
        n = n+1; 
    end
end

[rho.Delta.F1,pval.Delta.F1] = corr(lat_diff.Delta_nonan,Force.Delta_nonan, 'Type', 'Spearman');
[rho.Delta.ROM1,pval.Delta.ROM1] = corr(lat_diff.Delta_nonan,ROM.Delta_nonan, 'Type', 'Spearman');
[rho.Delta.Vel1,pval.Delta.Vel1] = corr(lat_diff.Delta_nonan,Vel.Delta_nonan, 'Type', 'Spearman');


%% correlation - amplitude 

n = 1; 
for i=1:length(ampl_ratio.Delta)
    if isnan(ampl_ratio.Delta(i,1)) || isnan(Force.Delta(i,1))
    else
        ampl_ratio.Delta_nonan(n,1) = ampl_ratio.Delta(i,1); 
        Force.Delta_nonan(n,1) = Force.Delta(i,1); 
        ROM.Delta_nonan(n,1) = ROM.Delta(i,1);
        Vel.Delta_nonan(n,1) = Vel.Delta(i,1);
        n = n+1; 
    end
end

[rho.Delta.F2,pval.Delta.F2] = corr(ampl_ratio.Delta_nonan,Force.Delta_nonan, 'Type', 'Spearman');
[rho.Delta.ROM2,pval.Delta.ROM2] = corr(ampl_ratio.Delta_nonan,ROM.Delta_nonan, 'Type', 'Spearman');
[rho.Delta.Vel2,pval.Delta.Vel2] = corr(ampl_ratio.Delta_nonan,Vel.Delta_nonan, 'Type', 'Spearman');


