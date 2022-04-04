%% check mean & ttest SSEP  %% 
% created: 08.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211102_SSEP.csv'); 

A = table2array(T(:,:)); 

%% report amplitude, amp ratio, latency, lat diff

ampl_aff.T1 = A(:,2); 
ampl_lessaff.T1 = A(:,4); 
ampl_aff.T3 = A(:,3); 
ampl_lessaff.T3 = A(:,5); 

lat_aff.T1 = A(:,6); 
lat_lessaff.T1 = A(:,8); 
lat_aff.T3 = A(:,7); 
lat_lessaff.T3 = A(:,9); 


ampl_ratio.T1 = A(:,2)./A(:,4);  
ampl_ratio.T1(31,1) = 1; 
ampl_ratio.T3 = A(:,3)./A(:,5); 
lat_diff.T1 = A(:,6) - A(:,8); 
lat_diff.T3 = A(:,7) - A(:,9);

%% mean & std

% mean
mean_amplaff.T1 = nanmean(ampl_aff.T1); 
mean_amplaff.T3 = nanmean(ampl_aff.T3); 
mean_ampllessaff.T1 = nanmean(ampl_lessaff.T1); 
mean_ampllessaff.T3 = nanmean(ampl_lessaff.T3); 

mean_lataff.T1 = nanmean(lat_aff.T1); 
mean_lataff.T3 = nanmean(lat_aff.T3); 
mean_latlessaff.T1 = nanmean(lat_lessaff.T1); 
mean_latlessaff.T3 = nanmean(lat_lessaff.T3); 

mean_amplratio.T1 = nanmean(ampl_ratio.T1); 
mean_amplratio.T3 = nanmean(ampl_ratio.T3); 
mean_latdiff.T1 = nanmean(lat_diff.T1); 
mean_latdiff.T3 = nanmean(lat_diff.T3); 

% std
std_amplaff.T1 = nanstd(ampl_aff.T1); 
std_amplaff.T3 = nanstd(ampl_aff.T3); 
std_ampllessaff.T1 = nanstd(ampl_lessaff.T1); 
std_ampllessaff.T3 = nanstd(ampl_lessaff.T3); 

std_lataff.T1 = nanstd(lat_aff.T1); 
std_lataff.T3 = nanstd(lat_aff.T3); 
std_latlessaff.T1 = nanstd(lat_lessaff.T1); 
std_latlessaff.T3 = nanstd(lat_lessaff.T3); 

std_amplratio.T1 = nanstd(ampl_ratio.T1); 
std_amplratio.T3 = nanstd(ampl_ratio.T3); 
std_latdiff.T1 = nanstd(lat_diff.T1); 
std_latdiff.T3 = nanstd(lat_diff.T3); 

%% ttest

[h_amplaff,p_amplaff] = ttest(ampl_aff.T1,ampl_aff.T3); 
[h_ampllessaff,p_ampllessaff] = ttest(ampl_lessaff.T1,ampl_lessaff.T3); 
[h_amplratio,p_amplratio] = ttest(ampl_ratio.T1,ampl_ratio.T3); 

[h_lataff,p_lataff] = ttest(lat_aff.T1,lat_aff.T3); 
[h_latlessaff,p_latlessaff] = ttest(lat_lessaff.T1,lat_lessaff.T3); 
[h_latdiff,p_latdiff] = ttest(lat_diff.T1,lat_diff.T3); 

%% how many subjects do we actually have

n = 1; 
for i=1:length(ampl_ratio.T3)
    if isnan(ampl_ratio.T3(i,1))
    else
        ampl_ratio.T1_nonan(n,1) = ampl_ratio.T1(i,1); 
        ampl_ratio.T3_nonan(n,1) = ampl_ratio.T3(i,1);
        ampl_aff.T1_nonan(n,1) = ampl_aff.T1(i,1); 
        ampl_aff.T3_nonan(n,1) = ampl_aff.T3(i,1);
        n = n+1; 
    end
end


%% plot amplitude ratio

figure; 
for i = 1:length(ampl_aff.T1_nonan)
    m = plot([1 2], [ampl_aff.T1_nonan(i,1) ampl_aff.T3_nonan(i,1)],'--ok'); 
    m.Color = 'k'; 
    m.MarkerFaceColor = 'k'; 
    hold on 
end
xlim([0.5 2.5])
ylim([-0.5 9]) 
xticks([1 2]) 
xticklabels({'Inclusion', 'Discharge'}) 
ylabel('SSEP amplitude (uV)') 
print('plots/LongitudinalPlots/211108_SSEP_amplT1T3','-dpng')

