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

%% plot - amplitude MEP vs Force

% ampl ratio: T1
figure; 
scatter(ampl_ratio.T1,Force.T1,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
%xlim([-0.2 1.5]) 
xline(0.5, '--k'); 
ylabel('Maximum Force @ T1') 
xlabel('MEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211104_Force_MEP_amplRatio_T1','-dpng')

% get rid of outliers - T1
figure; 
for i=1:length(ampl_ratio.T1)
    if ampl_ratio.T1(i,1) < 3
        scatter(ampl_ratio.T1(i,1),Force.T1(i,1),'filled','k')
        hold on
        labelpoints(ampl_ratio.T1(i,1),Force.T1(i,1),string(A(i,1))); 
    end
end
xlim([-0.2 1.9])
ylim([-0.5 51]) 
xline(0.5, '--k'); 
ylabel('Maximum Force @ T1') 
xlabel('MEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211104_Force_MEP_amplRatio_T1_v2','-dpng')

% ampl ratio: T3
figure; 
scatter(ampl_ratio.T3,Force.T3,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
%xlim([-0.2 1.5]) 
xline(0.5, '--k'); 
ylabel('Maximum Force @ T3') 
xlabel('MEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211104_Force_MEP_amplRatio_T3','-dpng')

% get rid of outliers - T3
figure; 
for i=1:length(ampl_ratio.T3)
    if ampl_ratio.T3(i,1) < 3
        scatter(ampl_ratio.T3(i,1),Force.T3(i,1),'filled','k')
        hold on
        labelpoints(ampl_ratio.T3(i,1),Force.T3(i,1),string(A(i,1))); 
    end
end
xlim([-0.2 1.4])
ylim([-0.5 51]) 
xline(0.5, '--k'); 
ylabel('Maximum Force @ T3') 
xlabel('MEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211104_Force_MEP_amplRatio_T3_v2','-dpng')

%% MEP amplitude vs ROM

% ampl ratio: T1
figure; 
scatter(ampl_ratio.T1,ROM.T1,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
%xlim([-0.2 1.5]) 
xline(0.5, '--k'); 
ylabel('ROM @ T1') 
xlabel('MEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211104_ROM_MEP_amplRatio_T1','-dpng')

% get rid of outliers - T1
figure; 
for i=1:length(ampl_ratio.T1)
    if ampl_ratio.T1(i,1) < 3
        scatter(ampl_ratio.T1(i,1),ROM.T1(i,1),'filled','k')
        hold on
        labelpoints(ampl_ratio.T1(i,1),ROM.T1(i,1),string(A(i,1))); 
    end
end
xlim([-0.2 1.8])
ylim([-2 90])  
xline(0.5, '--k'); 
ylabel('ROM @ T1') 
xlabel('MEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211104_ROM_MEP_amplRatio_T1_v2','-dpng')

% get rid of outliers - T3
figure; 
for i=1:length(ampl_ratio.T3)
    if ampl_ratio.T3(i,1) < 3
        scatter(ampl_ratio.T3(i,1),ROM.T3(i,1),'filled','k')
        hold on
        labelpoints(ampl_ratio.T3(i,1),ROM.T3(i,1),string(A(i,1))); 
    end
end
xlim([-0.2 1.4])
ylim([-2 110])  
xline(0.5, '--k'); 
ylabel('ROM @ T3') 
xlabel('MEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211104_ROM_MEP_amplRatio_T3_v2','-dpng')

%% MEP amplitude vs Vel

% ampl ratio: T1
figure; 
scatter(ampl_ratio.T1,Vel.T1,'filled')
% hold on 
% labelpoints(A(:,5),A(:,7),string(A(:,1))); 
%xlim([-0.2 1.5]) 
xline(0.5, '--k'); 
ylabel('Maximum Velocity @ T1') 
xlabel('MEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211104_Vel_MEP_amplRatio_T1','-dpng')

% get rid of outliers - T1
figure; 
for i=1:length(ampl_ratio.T1)
    if ampl_ratio.T1(i,1) < 3
        scatter(ampl_ratio.T1(i,1),Vel.T1(i,1),'filled','k')
        hold on
        labelpoints(ampl_ratio.T1(i,1),Vel.T1(i,1),string(A(i,1))); 
    end
end
xlim([-0.2 1.8])
ylim([-10 600])  
xline(0.5, '--k'); 
ylabel('Maximum Velocity @ T1') 
xlabel('MEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211104_Vel_MEP_amplRatio_T1_v2','-dpng')

% get rid of outliers - T3
figure; 
for i=1:length(ampl_ratio.T3)
    if ampl_ratio.T3(i,1) < 3
        scatter(ampl_ratio.T3(i,1),Vel.T3(i,1),'filled','k')
        hold on
        labelpoints(ampl_ratio.T3(i,1),Vel.T3(i,1),string(A(i,1))); 
    end
end
xlim([-0.2 1.4])
ylim([-10 600])  
xline(0.5, '--k'); 
ylabel('Maximum Velocity @ T3') 
xlabel('MEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211104_Vel_MEP_amplRatio_T3_v2','-dpng')

%% MEP latency diff vs Force

% lat diff: T1
figure; 
scatter(lat_diff.T1,Force.T1,'filled')
hold on 
labelpoints(lat_diff.T1,Force.T1,string(A(:,1))); 
xlim([-4 16]) 
ylim([-2 51]) 
xline(0.5, '--k'); 
ylabel('Maximum Force @ T1') 
xlabel('MEP latency difference @ T1') 
print('plots/ScatterPlots/211105_Force_MEP_latdiff_T1','-dpng')

% lat diff: T3
figure; 
scatter(lat_diff.T3,Force.T3,'filled')
hold on 
labelpoints(lat_diff.T3,Force.T3,string(A(:,1))); 
xlim([-4 16]) 
ylim([-2 51]) 
xline(0.5, '--k'); 
ylabel('Maximum Force @ T3') 
xlabel('MEP latency difference @ T3') 
print('plots/ScatterPlots/211105_Force_MEP_latdiff_T3','-dpng')

%% MEP latency diff vs ROM

% lat diff: T1
figure; 
scatter(lat_diff.T1,ROM.T1,'filled')
hold on 
labelpoints(lat_diff.T1,ROM.T1,string(A(:,1))); 
xlim([-4 16])
ylim([-1 90]) 
xline(0.5, '--k'); 
ylabel('ROM @ T1') 
xlabel('MEP latency difference @ T1') 
print('plots/ScatterPlots/211105_ROM_MEP_latdiff_T1','-dpng')

% lat diff: T3
figure; 
scatter(lat_diff.T3,ROM.T3,'filled')
hold on 
labelpoints(lat_diff.T3,ROM.T3,string(A(:,1))); 
ylim([-1 90]) 
xlim([-4 16])
xline(0.5, '--k'); 
ylabel('ROM @ T3') 
xlabel('MEP latency difference @ T3') 
print('plots/ScatterPlots/211105_ROM_MEP_latdiff_T3','-dpng')

%% MEP latency diff vs Max Vel

% lat diff: T1
figure; 
scatter(lat_diff.T1,Vel.T1,'filled')
hold on 
labelpoints(lat_diff.T1,Vel.T1,string(A(:,1))); 
xlim([-4 16])
%ylim([-1 90]) 
xline(0.5, '--k'); 
ylabel('Maximum Velocity @ T1') 
xlabel('MEP latency difference @ T1') 
print('plots/ScatterPlots/211105_Vel_MEP_latdiff_T1','-dpng')

% lat diff: T3
figure; 
scatter(lat_diff.T3,Vel.T3,'filled')
hold on 
labelpoints(lat_diff.T3,Vel.T3,string(A(:,1))); 
xlim([-4 16])
%ylim([-1 90]) 
xline(0.5, '--k'); 
ylabel('Maximum Velocity @ T3') 
xlabel('MEP latency difference @ T3') 
print('plots/ScatterPlots/211105_Vel_MEP_latdiff_T3','-dpng')

%% correlation T1 - amplitude

n = 1; 
for i=1:length(ampl_ratio.T1)
    if isnan(ampl_ratio.T1(i,1))
    else
        ampl_ratio.T1_nonan(n,1) = ampl_ratio.T1(i,1); 
        Force.T1_nonan(n,1) = Force.T1(i,1); 
        ROM.T1_nonan(n,1) = ROM.T1(i,1);
        Vel.T1_nonan(n,1) = Vel.T1(i,1);
        n = n+1; 
    end
end

[rho.T1.F,pval.T1.F] = corr(ampl_ratio.T1_nonan,Force.T1_nonan, 'Type', 'Spearman');
[rho.T1.ROM,pval.T1.ROM] = corr(ampl_ratio.T1_nonan,ROM.T1_nonan, 'Type', 'Spearman');
[rho.T1.Vel,pval.T1.Vel] = corr(ampl_ratio.T1_nonan,Vel.T1_nonan, 'Type', 'Spearman');

%% correlation T1 - lat diff

n = 1; 
for i=1:length(lat_diff.T1)
    if isnan(lat_diff.T1(i,1))
    else
        lat_diff.T1_nonan(n,1) = lat_diff.T1(i,1); 
        Force.T1_nonan(n,1) = Force.T1(i,1); 
        ROM.T1_nonan(n,1) = ROM.T1(i,1);
        Vel.T1_nonan(n,1) = Vel.T1(i,1);
        n = n+1; 
    end
end

[rho.T1.F2,pval.T1.F2] = corr(lat_diff.T1_nonan,Force.T1_nonan, 'Type', 'Spearman');
[rho.T1.ROM2,pval.T1.ROM2] = corr(lat_diff.T1_nonan,ROM.T1_nonan, 'Type', 'Spearman');
[rho.T1.Vel2,pval.T1.Vel2] = corr(lat_diff.T1_nonan,Vel.T1_nonan, 'Type', 'Spearman');


%% correlation T3 - lat diff

n = 1; 
for i=1:length(lat_diff.T3)
    if isnan(lat_diff.T3(i,1)) || isnan(Force.T3(i,1))
    else
        lat_diff.T3_nonan(n,1) = lat_diff.T3(i,1); 
        Force.T3_nonan(n,1) = Force.T3(i,1); 
        ROM.T3_nonan(n,1) = ROM.T3(i,1);
        Vel.T3_nonan(n,1) = Vel.T3(i,1);
        n = n+1; 
    end
end

[rho.T3.F2,pval.T3.F2] = corr(lat_diff.T3_nonan,Force.T3_nonan, 'Type', 'Spearman');
[rho.T3.ROM2,pval.T3.ROM2] = corr(lat_diff.T3_nonan,ROM.T3_nonan, 'Type', 'Spearman');
[rho.T3.Vel2,pval.T3.Vel2] = corr(lat_diff.T3_nonan,Vel.T3_nonan, 'Type', 'Spearman');


