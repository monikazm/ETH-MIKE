%% create groups - neurophysiology - SSEP %% 
% created: 01.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211101_Neurophysiology.csv'); 

A = table2array(T(:,:)); 

%% plot - amplitude ratio 

% ampl ratio : T1 
figure; 
scatter(A(:,2),A(:,4),'filled')
hold on 
labelpoints(A(:,2),A(:,4),string(A(:,1))); 
xlim([-0.5 2.5]) 
xline(0.5, '--k'); 
ylabel('Position Matching Absolute Error (deg) @ T1') 
xlabel('SSEP amplitude ratio @ T1') 
print('plots/ScatterPlots/211103_PM_SSEP_amplRatio_T1','-dpng')

% ampl ratio: T3
figure; 
scatter(A(:,5),A(:,7),'filled')
hold on 
labelpoints(A(:,5),A(:,7),string(A(:,1))); 
xlim([-0.2 1.5]) 
xline(0.5, '--k'); 
ylabel('Position Matching Absolute Error (deg) @ T3') 
xlabel('SSEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211103_PM_SSEP_amplRatio_T3','-dpng')

% correlation 
A(26,:) = []; 
[rho,pval] = corr(A(:,2),A(:,4), 'Type', 'Spearman');

n = 1; 
for i = 1:length(A(:,5))
    if isnan(A(i,5))== 1
        
    else
        T3(n,1) = A(i,1); 
        T3(n,2) = A(i,5); 
        T3(n,3) = A(i,7); 
        n = n+1; 
    end
end
T3(13,:) = []; 

[rho2,pval2] = corr(T3(:,2),T3(:,3), 'Type', 'Spearman');

%% plot- amplitude ratio & kUDT 

% ampl ratio: T3
figure; 
scatter(A(:,5),A(:,7),'filled')
hold on 
labelpoints(A(:,5),A(:,7),string(A(:,1))); 
xlim([-0.2 1.5]) 
xline(0.5, '--k'); 
ylabel('Position Matching Absolute Error (deg) @ T3') 
xlabel('SSEP amplitude ratio @ T3') 
print('plots/ScatterPlots/211103_PM_SSEP_amplRatio_T3','-dpng')



%% plot - latency difference

m = 1; 
figure; 
for i=1:length(A(:,3))
    if A(i,3) < 10 && A(i,3) > -8
        M(m,1) = A(i,1); 
        M(m,2) = A(i,3); 
        M(m,3) = A(i,4); 
        m = m+1; 
        scatter(A(i,3),A(i,4),'filled','k')
        hold on 
    end
end   
hold on 
xline(1.1, '--k'); 
ylabel('Position Matching Absolute Error (deg) @ T1') 
xlabel('SSEP latency difference @ T1') 
print('plots/ScatterPlots/211103_PM_SSEP_latdiff_T1','-dpng')

[rho3,pval3] = corr(M(:,2),M(:,3), 'Type', 'Spearman');


