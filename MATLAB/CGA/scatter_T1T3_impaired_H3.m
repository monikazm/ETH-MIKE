%% scatter plots to analyse H3: proprioception at baseline vs sensorimotor recovery %% 
% created: 18.09.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20210914_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR
% 47 - kUDT
% 41 - FM M UL
% 48 - BB imp 
% 49 - BB nonimp
% 50 - barthel index tot
% 44 - FMA Hand 

A = table2array(T(:,[3 5 122 48 50 127 41 44])); 

%% clean-up the table 

% remove subjects that don't have redcap yet

n = 1; 
withREDCap = []; 
for i = 1:1:length(A(:,1))
    if isnan(A(i,2))
        
    else
        withREDCap(n,:) = A(i,:); 
        n=n+1; 
    end

end

withREDCap2(:,1) = withREDCap(:,2); 
withREDCap2(:,2) = withREDCap(:,1); 
withREDCap2(:,3) = withREDCap(:,3); 
withREDCap2(:,4) = withREDCap(:,4); 
withREDCap2(:,5) = withREDCap(:,5);
withREDCap2(:,6) = withREDCap(:,6);
withREDCap2(:,7) = withREDCap(:,7);
withREDCap2(:,8) = withREDCap(:,8);


C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: max force flexion 

% remove those rows where there is only one data point
n = 1; 
remove = []; 
for i=1:max(C(:,1))
    temp = find(C(:,1)==i); 
    if length(temp) == 1
        remove(n) = temp; 
        n = n+1; 
    end
end
C(remove,:) = []; 

%% Divide into S1 S2 and S3

n = 1;  
k = 1; 
m = 1; 
for i = 1:length(C(:,1))
        if C(i,2) == 1
            S1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 3
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

S1(1,:) = []; 
S3(1,:) = [];  

%% scatter Position Matching baseline vs discharge BBT 

figure; 
scatter(S1(:,3),S3(:,4),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Position Matching @ T1') 
ylabel('Box & Block Test @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMincl_BBTdisch','-dpng')

n = 1; 
out = []; 
figure;
for i=1:length(S1(:,3))
    if S3(i,4) > 30
        out(n,1) = S3(i,4); 
        out(n,2) = S1(i,3); 
        n = n+1; 
        scatter(S1(i,3),S3(i,4),'filled','k');
        hold on 
    end
end
xlabel('Position Matching @ T1') 
ylabel('Box & Block Test @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMincl_BBTdisch_above30','-dpng')

[rho1,pval1] = corr(out(:,1), out(:,2), 'Type', 'Spearman'); 

% Baseline proprioception vs change in BBT? 
figure; 
scatter(S1(:,3),S3(:,4)-S1(:,4),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Position Matching @ T1') 
ylabel('Change in Box & Block Test') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMincl_BBTchange','-dpng')

figure;
for i=1:length(S1(:,3))
    if S3(i,4) > 30
        scatter(S1(i,3),S3(i,4)-S1(i,4),'filled','k');
        hold on 
    end
end
xlabel('Position Matching @ T1') 
ylabel('Change in Box & Block Test') 
title('Subjects with BBT > 30 @ T1') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMincl_BBTchange_above30','-dpng')

figure; 
scatter(S1(:,3)-S3(:,3),S3(:,4)-S1(:,4),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Change in Position Matching') 
ylabel('Change in Box & Block Test') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMchange_BBTchange','-dpng') 

figure;
for i=1:length(S1(:,3))
    if S3(i,4) > 30
        scatter(S1(i,3)-S3(i,3),S3(i,4)-S1(i,4),'filled','k');
        hold on 
    end
end
xlabel('Change in Position Matching') 
ylabel('Change in Box & Block Test') 
title('Subjects with BBT > 30 @ T1') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMchange_BBTchange_above30','-dpng')


%% scatter Position Matching baseline vs discharge Barthel

figure; 
scatter(S1(:,3),S3(:,5),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Position Matching @ T1') 
ylabel('Barthel Index @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMincl_Bartheldisch','-dpng')

figure; 
scatter(S1(:,3),S3(:,5)-S1(:,5),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Position Matching @ T1') 
ylabel('Change in Barthel Index') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMincl_BarthelChange','-dpng')


%% scatter Position Matching baseline vs Fugl-Meyer

figure; 
scatter(S1(:,3),S3(:,7),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Position Matching @ T1') 
ylabel('Fugl-Meyer @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMincl_FMdisch','-dpng')

figure; 
scatter(S1(:,3),S3(:,7)-S1(:,7),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Position Matching @ T1') 
ylabel('Change in Fugl-Meyer') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMincl_FMchange','-dpng')

figure; 
scatter(S1(:,3)-S3(:,3),S3(:,7)-S1(:,7),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Change in Position Matching') 
ylabel('Change in Fugl-Meyer') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210918_PMchange_FMchange','-dpng')


%% scatter Position Matching T3 bs BBT T3 

figure; 
scatter(S3(:,3),S3(:,4),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Position Matching @ T3') 
ylabel('Box & Block Test @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210919_PMdisch_BBTdisch','-dpng')


n = 1; 
out = []; 
figure;
for i=1:length(S1(:,3))
    if S3(i,4) > 30
        out(n,1) = S3(i,4); 
        out(n,2) = S3(i,3); 
        n = n+1; 
        scatter(S3(i,3),S3(i,4),'filled','k');
        hold on 
    end
end
xlabel('Position Matching @ T3') 
ylabel('Box & Block Test @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210919_PMdisch_BBTdisch_above30','-dpng')

[rho2,pval2] = corr(out(:,1), out(:,2), 'Type', 'Spearman'); 

%% change in PM vs BBT at T3

figure; 
scatter(S1(:,3)-S3(:,3),S3(:,4),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Change in Position Matching (deg)') 
ylabel('Box & Block Test @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210919_PMchange_BBTdisch','-dpng') 

[rho3,pval3] = corr(S1(:,3)-S3(:,3),S3(:,4), 'Type', 'Spearman'); 


output = []; 
m = 1; 
for i = 1:length(S3(:,4))
    if isnan(S3(i,4))
    else
        output(m,1) = S3(i,4); 
        output(m,2) = S3(i,4)-S1(i,4);
        output(m,3) = S1(i,3)-S3(i,3);
        m = m+1; 
    end
end

% corrs
[rho3,pval3] = corr(output(:,2), output(:,3), 'Type', 'Spearman'); 
[rho4,pval4] = corr(output(:,1), output(:,3), 'Type', 'Spearman'); 


%% change in PM vs FM at T3

figure; 
scatter(S1(:,3)-S3(:,3),S3(:,7),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Change in Position Matching (deg)') 
ylabel('Fugl-Meyer Upper Limb Motor @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210919_PMchange_FMdisch','-dpng')

output2 = []; 
n = 1; 
for i = 1:length(S3(:,7))
    if isnan(S3(i,7))
    else
        output2(n,1) = S3(i,7); 
        output2(n,2) = S3(i,7)-S1(i,7);
        output2(n,3) = S1(i,3)-S3(i,3);
        n = n+1; 
    end
end

% corrs
[rho5,pval5] = corr(output2(:,1), output2(:,3), 'Type', 'Spearman'); 

%% change in PM vs FM Hand at T3

figure; 
scatter(S1(:,3)-S3(:,3),S3(:,8),'filled','k');
% xlim([0 26])
% ylim([0 26])
xlabel('Change in Position Matching (deg)') 
ylabel('Fugl-Meyer Hand @ T3') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210919_PMchange_FMHanddisch','-dpng')

output3 = []; 
n = 1; 
for i = 1:length(S3(:,8))
    if isnan(S3(i,8))
    else
        output3(n,1) = S3(i,8); 
        output3(n,2) = S3(i,8)-S1(i,8);
        output3(n,3) = S1(i,3)-S3(i,3);
        n = n+1; 
    end
end

% corrs
[rho6,pval6] = corr(output3(:,1), output3(:,3), 'Type', 'Spearman'); 







