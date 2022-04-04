%% check correlations SSEP vs proprioception tasks %% 
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
ampl_ratio.T3 = A(:,3)./A(:,5);
lat_diff.T1 = A(:,6) - A(:,8); 
lat_diff.T3 = A(:,7) - A(:,9);
PM.T1 = A(:,10); 
PM.T3 = A(:,11);
kUDT.T1 = A(:,12); 
kUDT.T3 = A(:,13); 

%% plot - amplitude SSEP vs PM 

% ampl ratio: T1
figure; 
scatter(ampl_ratio.T1,PM.T1,'filled')
hold on 
labelpoints(ampl_ratio.T1,PM.T1,string(A(:,1))); 
xlim([-0.2 2.5]) 
xline(0.5, '--k'); 
ylabel('Position Matching AE @ T1') 
xlabel('SSEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211105_PM_SSEP_amplRatio_T1','-dpng')

% ampl ratio: T3
figure; 
scatter(ampl_ratio.T3,PM.T3,'filled')
hold on 
labelpoints(ampl_ratio.T3,PM.T3,string(A(:,1))); 
xlim([-0.2 1.6]) 
xline(0.5, '--k'); 
ylabel('Position Matching AE @ T3')  
xlabel('SSEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211105_PM_SSEP_amplRatio_T3','-dpng')

%% plot - latency diff SSEP vs PM 

% T1 
% m = 1; 
% figure; 
% for i=1:length(lat_diff.T1(:,1))
%     if lat_diff.T1(i,1) < 10 && lat_diff.T1(i,1) > -8 && isnan(PM.T1(i,1))==0
%         M1(m,1) = A(i,1); 
%         M1(m,2) = lat_diff.T1(i,1); 
%         M1(m,3) = PM.T1(i,1); 
%         m = m+1; 
%         scatter(lat_diff.T1(i,1),PM.T1(i,1),'filled','k')
%         hold on 
%         labelpoints(lat_diff.T1(i,1),PM.T1(i,1),string(A(i,1))); 
%         hold on 
%     end
% end   
% hold on 
% xline(1.1, '--k'); 
% ylabel('Position Matching Absolute Error (deg) @ T1') 
% xlabel('SSEP latency difference @ T1') 
% print('plots/ScatterPlots/211105_PM_SSEP_latdiff_T1','-dpng')
% 
% [rho.T1.latdiff,pval.T1.latdiff] = corr(M1(:,2),M1(:,3), 'Type', 'Spearman');

% T1 
figure; 
scatter(lat_diff.T1(:,1),PM.T1(:,1),'filled','k')
hold on 
labelpoints(lat_diff.T1(:,1),PM.T1(:,1),string(A(:,1)));  
hold on 
xline(1.1, '--k'); 
ylabel('Position Matching Absolute Error (deg) @ T1') 
xlabel('SSEP latency difference @ T1') 
print('plots/ScatterPlots/211105_PM_SSEP_latdiff_T1_v2','-dpng')

% T3 
figure; 
scatter(lat_diff.T3(:,1),PM.T3(:,1),'filled','k')
hold on 
labelpoints(lat_diff.T3(:,1),PM.T3(:,1),string(A(:,1))); 
hold on 
xline(1.1, '--k'); 
ylabel('Position Matching Absolute Error (deg) @ T3') 
xlabel('SSEP latency difference @ T3') 
print('plots/ScatterPlots/211105_PM_SSEP_latdiff_T3','-dpng')

%[rho.T3.latdiff,pval.T3.latdiff] = corr(lat_diff.T3(:,1),PM.T3(:,1), 'Type', 'Spearman');

% considering all the data
figure; 
scatter(lat_diff.T1(:,1),PM.T1(:,1),'filled','k')

%% plot - amplitude SSEP vs kUDT

% ampl ratio: T1
figure; 
scatter(ampl_ratio.T1,kUDT.T1,'filled')
hold on 
labelpoints(ampl_ratio.T1,kUDT.T1,string(A(:,1))); 
xlim([-0.2 2.5]) 
xline(0.5, '--k'); 
ylabel('kUDT @ T1') 
xlabel('SSEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211105_kUDT_SSEP_amplRatio_T1','-dpng')

% ampl ratio: T3
figure; 
scatter(ampl_ratio.T3,kUDT.T3,'filled')
hold on 
labelpoints(ampl_ratio.T3,kUDT.T3,string(A(:,1))); 
xlim([-0.2 1.6]) 
xline(0.5, '--k'); 
ylabel('kUDT @ T3')  
xlabel('SSEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211105_kUDT_SSEP_amplRatio_T3','-dpng')

%% correlation T1

n = 1; 
for i=1:length(ampl_ratio.T1)
    if isnan(ampl_ratio.T1(i,1)) || isnan(PM.T1(i,1))
    else
        ampl_ratio.T1_nonan(n,1) = ampl_ratio.T1(i,1); 
        lat_diff.T1_nonan(n,1) = lat_diff.T1(i,1); 
        PM.T1_nonan(n,1) = PM.T1(i,1); 
        kUDT.T1_nonan(n,1) = kUDT.T1(i,1);
        n = n+1; 
    end
end

[rho.T1.PM,pval.T1.PM] = corr(ampl_ratio.T1_nonan,PM.T1_nonan, 'Type', 'Spearman');
[rho.T1.kUDT,pval.T1.kUDT] = corr(ampl_ratio.T1_nonan,kUDT.T1_nonan, 'Type', 'Spearman');
[rho.T1.latdiff,pval.T1.latdiff] = corr(lat_diff.T1_nonan,PM.T1_nonan, 'Type', 'Spearman');

%% correlation T3

n = 1; 
for i=1:length(ampl_ratio.T3)
    if isnan(ampl_ratio.T3(i,1)) || isnan(PM.T3(i,1))
    else
        ampl_ratio.T3_nonan(n,1) = ampl_ratio.T3(i,1); 
        lat_diff.T3_nonan(n,1) = lat_diff.T3(i,1); 
        PM.T3_nonan(n,1) = PM.T3(i,1); 
        kUDT.T3_nonan(n,1) = kUDT.T3(i,1);
        n = n+1; 
    end
end

[rho.T3.PM,pval.T3.PM] = corr(ampl_ratio.T3_nonan,PM.T3_nonan, 'Type', 'Spearman');
[rho.T3.kUDT,pval.T3.kUDT] = corr(ampl_ratio.T3_nonan,kUDT.T3_nonan, 'Type', 'Spearman');
[rho.T3.latdiff,pval.T3.latdiff] = corr(lat_diff.T3_nonan,PM.T3_nonan, 'Type', 'Spearman');

%% what if I modified values of PM there were at 20 

% ampl ratio: T1

for i=1:length(PM.T1)
    if PM.T1(i,1) > 19 && PM.T1(i,1) < 21
       PM.T1(i,1) = 30; 
    end
end

figure; 
scatter(ampl_ratio.T1,PM.T1,'filled')
hold on 
labelpoints(ampl_ratio.T1,PM.T1,string(A(:,1))); 
xlim([-0.2 2.5]) 
xline(0.5, '--k'); 
ylabel('Position Matching AE @ T1') 
xlabel('SSEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211105_PM_SSEP_amplRatio_T1_v2','-dpng')

n = 1; 
for i=1:length(ampl_ratio.T1)
    if isnan(ampl_ratio.T1(i,1)) || isnan(PM.T1(i,1))
    else
        ampl_ratio.T1_nonan(n,1) = ampl_ratio.T1(i,1); 
        PM.T1_nonan(n,1) = PM.T1(i,1); 
        kUDT.T1_nonan(n,1) = kUDT.T1(i,1);
        n = n+1; 
    end
end

[rho.T1.PM2,pval.T1.PM2] = corr(ampl_ratio.T1_nonan,PM.T1_nonan, 'Type', 'Spearman');

% ampl ratio: T3

for i=1:length(PM.T3)
    if PM.T3(i,1) > 19 && PM.T3(i,1) < 21
       PM.T3(i,1) = 30; 
    end
end


figure; 
scatter(ampl_ratio.T3,PM.T3,'filled')
hold on 
labelpoints(ampl_ratio.T3,PM.T3,string(A(:,1))); 
xlim([-0.2 1.6]) 
xline(0.5, '--k'); 
ylabel('Position Matching AE @ T3') 
xlabel('SSEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211105_PM_SSEP_amplRatio_T3_v2','-dpng')

n = 1; 
for i=1:length(ampl_ratio.T3)
    if isnan(ampl_ratio.T3(i,1)) || isnan(PM.T3(i,1))
    else
        ampl_ratio.T3_nonan(n,1) = ampl_ratio.T3(i,1); 
        PM.T3_nonan(n,1) = PM.T3(i,1); 
        kUDT.T3_nonan(n,1) = kUDT.T3(i,1);
        n = n+1; 
    end
end

[rho.T3.PM2,pval.T3.PM2] = corr(ampl_ratio.T3_nonan,PM.T3_nonan, 'Type', 'Spearman');


% latency difference 

% T1 
figure; 
scatter(lat_diff.T1(:,1),PM.T1(:,1),'filled','k')
hold on 
labelpoints(lat_diff.T1(:,1),PM.T1(:,1),string(A(:,1)));  
hold on 
xline(1.1, '--k'); 
ylabel('Position Matching Absolute Error (deg) @ T1') 
xlabel('SSEP latency difference @ T1') 
print('plots/ScatterPlots/211105_PM_SSEP_latdiff_T1_v3','-dpng')

[rho.T1.latdiff2,pval.T1.latdiff2] = corr(lat_diff.T1_nonan,PM.T1_nonan, 'Type', 'Spearman');

% T3 
figure; 
scatter(lat_diff.T3(:,1),PM.T3(:,1),'filled','k')
hold on 
labelpoints(lat_diff.T3(:,1),PM.T3(:,1),string(A(:,1))); 
hold on 
xline(1.1, '--k'); 
ylabel('Position Matching Absolute Error (deg) @ T3') 
xlabel('SSEP latency difference @ T3') 
print('plots/ScatterPlots/211105_PM_SSEP_latdiff_T3_v2','-dpng')

[rho.T3.latdiff2,pval.T3.latdiff2] = corr(lat_diff.T3_nonan,PM.T3_nonan, 'Type', 'Spearman');

