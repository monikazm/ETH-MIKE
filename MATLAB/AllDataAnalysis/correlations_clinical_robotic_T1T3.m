%% ttests to define if change is significant %% 
% created: 13.10.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 47 - kUDT
% 41 - FM M UL
% 48 - BB imp 
% 49 - BB nonimp
% 50 - barther index tot
% 44 - FMA Hand 
% 61 - MoCA
% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR

A = table2array(T(:,[3 5 47 41 48 44 122 114 92 127 50])); 

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
withREDCap2(:,9) = withREDCap(:,9);
withREDCap2(:,10) = withREDCap(:,10);
withREDCap2(:,11) = withREDCap(:,11);

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

%% Divide into S1 and S3

n = 1;  
k = 1; 
m = 1; 
for i = 1:length(C(:,1))
        if C(i,2) == 1
            S1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 2 && isnan(C(i,3))==0
            S3(m,:) = C(i,:);
            m = m+1;
        elseif C(i,2) == 3 && isnan(C(i,3))==0
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

S3(1,7) = 14.5926361100000; 

% remove subjects that only have 2 measurements
S1(find(S1(:,1)==3),:) = []; 
S3(find(S3(:,1)==3),:) = []; 

S1(find(S1(:,1)==33),:) = []; 
S3(find(S3(:,1)==33),:) = []; 

S1(find(S1(:,1)==37),:) = []; 
S3(find(S3(:,1)==37),:) = []; 

S1(find(S1(:,1)==38),:) = []; 
S3(find(S3(:,1)==38),:) = []; 

S1(find(S1(:,1)==48),:) = []; 
S3(find(S3(:,1)==48),:) = []; 

%% kUDT vs Position Matching

figure; 
scatter(S1(:,3),S1(:,7),'filled','k');
xlim([-0.5 3.5]) 
xticks([0 1 2 3])
yline(10.63, '--k'); 
xlabel('kUDT')
ylabel('Position Matching Absolute Error (deg)') 
title('T1')
print('plots/ScatterPlots/211013_PM_kUDT_T1','-dpng')

figure; 
scatter(S3(:,3),S3(:,7),'filled','k');
xlim([-0.5 3.5]) 
xticks([0 1 2 3])
yline(10.63, '--k'); 
xlabel('kUDT')
ylabel('Position Matching Absolute Error (deg)') 
title('T3')
print('plots/ScatterPlots/211013_PM_kUDT_T3','-dpng')

figure; 
scatter(S3(:,3)-S1(:,3),S1(:,7)-S3(:,7),'filled','k');
xlim([-0.5 3.5]) 
xticks([0 1 2 3])
xlabel('Delta kUDT')
ylabel('Delta Position Matching Absolute Error (deg)') 
title('Change T1-T3')
print('plots/ScatterPlots/211013_PM_kUDT_change','-dpng')

n = 1; 
for i = 1:length(S3(:,3))
    if isnan(S3(i,3))
    else
        kUDT_S3(n,1) = S3(i,3); 
        PM_S3(n,1) = S3(i,7); 
        kUDT_S1(n,1) = S1(i,3); 
        PM_S1(n,1) = S1(i,7); 
        n = n +1; 
    end
end

% correlations
[rho.PMkUDT_T1,pval.PMkUDT_T1] = corr(S1(:,3),S1(:,7), 'Type', 'Spearman');
[rho.PMkUDT_T3,pval.PMkUDT_T3] = corr(kUDT_S3,PM_S3, 'Type', 'Spearman');
[rho.PMkUDT_delta,pval.PMkUDT_delta] = corr(kUDT_S3-kUDT_S1,PM_S1-PM_S3, 'Type', 'Spearman');

%% Force vs FMA Motor (Hand)

figure; 
scatter(S1(:,6),S1(:,8),'filled','k');
xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
yline(10.93, '--k'); 
xlabel('FMA Hand')
ylabel('Maximum Force Flexion (N)') 
title('T1')
print('plots/ScatterPlots/211013_F_FMAH_T1','-dpng')

figure; 
scatter(S3(:,6),S3(:,8),'filled','k');
xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
yline(10.93, '--k'); 
xlabel('FMA Hand')
ylabel('Maximum Force Flexion (N)') 
title('T3')
print('plots/ScatterPlots/211013_F_FMAH_T3','-dpng')

figure; 
scatter(S3(:,6)-S1(:,6),S3(:,8)-S1(:,8),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(10.93, '--k'); 
xlabel('Delta FMA Hand')
ylabel('Delta Maximum Force Flexion (N)') 
title('T3-T1')
print('plots/ScatterPlots/211013_F_FMAH_Delta','-dpng')

% correlations
[rho.FFMAH_T1,pval.FFMAH_T1] = corr(S1(:,6),S1(:,8), 'Type', 'Spearman');
[rho.FFMAH_T3,pval.FFMAH_T3] = corr(S3(:,6),S3(:,8), 'Type', 'Spearman');
[rho.FFMAH_delta,pval.FFMAH_delta] = corr(S3(:,6)-S1(:,6),S3(:,8)-S1(:,8), 'Type', 'Spearman');

%% Force vs BBT

figure; 
scatter(S1(:,5),S1(:,8),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
yline(10.93, '--k'); 
xlabel('Box & Block Test')
ylabel('Maximum Force Flexion (N)') 
title('T1')
print('plots/ScatterPlots/211013_F_BBT_T1','-dpng')

figure; 
scatter(S3(:,5),S3(:,8),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
yline(10.93, '--k'); 
xlabel('Box & Block Test')
ylabel('Maximum Force Flexion (N)') 
title('T3')
print('plots/ScatterPlots/211013_F_BBT_T3','-dpng')

figure; 
scatter(S3(:,5)-S1(:,5),S3(:,8)-S1(:,8),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(10.93, '--k'); 
xlabel('Delta BBT')
ylabel('Delta Maximum Force Flexion (N)') 
title('T3-T1')
print('plots/ScatterPlots/211013_F_BBT_Delta','-dpng')

% correlations
[rho.FBBT_T1,pval.FBBT_T1] = corr(S1(:,5),S1(:,8), 'Type', 'Spearman');
[rho.FBBT_T3,pval.FBBT_T3] = corr(S3(:,5),S3(:,8), 'Type', 'Spearman');
[rho.FBBT_delta,pval.FBBT_delta] = corr(S3(:,5)-S1(:,5),S3(:,8)-S1(:,8), 'Type', 'Spearman');

%% PM vs BBT

figure; 
scatter(S1(:,7),S1(:,5),'filled','k');
labelpoints(S1(:,7),S1(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
ylim([0 70])
yline(30, '--k'); 
ylabel('Box & Block Test @ T1')
xlabel('Position Matching Absolute Error (deg) @ T1') 
print('plots/ScatterPlots/211027_PM_BBT_T1','-dpng')


figure; 
scatter(S3(:,7),S3(:,5),'filled','k');
labelpoints(S3(:,7),S3(:,5), string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
ylim([0 70])
yline(30, '--k'); 
xline(10.63,'--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Position Matching Absolute Error (deg) @ T3') 
print('plots/ScatterPlots/211028_PM_BBT_T3','-dpng')

figure; 
scatter(S1(:,7)-S3(:,7),S3(:,5),'filled','k');
labelpoints(S1(:,7)-S3(:,7),S3(:,5), string(S1(:,1))); 
xlim([-9 12]) 
% xticks([0 1 2 3])
yline(30, '--k'); 
% xline(10.63,'--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Delta Position Matching Absolute Error (deg)') 
print('plots/ScatterPlots/211028_PMChange_BBT_T3','-dpng')

figure; 
scatter(S1(:,5),S1(:,7)-S3(:,7),'filled','k');
%labelpoints(S1(:,7)-S3(:,7),S3(:,5), string(S1(:,1))); 
ylim([-9 12]) 
xlim([-2 60])
% xticks([0 1 2 3])
%xline(30, '--k'); 
% xline(10.63,'--k'); 
xlabel('Box & Block Test @ T1')
ylabel('Delta Position Matching Absolute Error (deg)') 
print('plots/ScatterPlots/211206_PMChange_BBT_T1','-dpng')

figure; 
scatter(S1(:,5),S1(:,7)-S3(:,7),'filled','k');
labelpoints(S1(:,5),S1(:,7)-S3(:,7),string(S1(:,1))); 
ylim([-9 12]) 
xlim([-2 60])
% xticks([0 1 2 3])
%xline(30, '--k'); 
% xline(10.63,'--k'); 
xlabel('Box & Block Test @ T1')
ylabel('Delta Position Matching Absolute Error (deg)') 
print('plots/ScatterPlots/211206_PMChange_BBT_T1_v2','-dpng')

% figure; 
% scatter(S1(:,7),S3(:,5),'filled','k');
% labelpoints(S3(:,7),S3(:,5), string(S1(:,1))); 
% %xlim([-0.5 14.5]) 
% % xticks([0 1 2 3])
% yline(30, '--k'); 
% xline(10.63,'--k'); 
% ylabel('Box & Block Test @ T3')
% xlabel('Position Matching Absolute Error (deg) @ T1') 
% print('plots/ScatterPlots/211028_PM_BBT_T1T3','-dpng')

figure; 
scatter(S1(:,7)-S3(:,7),S3(:,5)-S1(:,5),'filled','k');
labelpoints(S1(:,7)-S3(:,7),S3(:,5)-S1(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Delta Box & Block Test')
xlabel('Delta Position Matching Absolute Error (deg)') 
print('plots/ScatterPlots/211026_PM_BBT_Delta','-dpng')

figure; 
scatter(S1(:,7),S3(:,5)-S1(:,5),'filled','k');
%labelpoints(S1(:,7)-S3(:,7),S3(:,5)-S1(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Delta Box & Block Test')
xlabel('Position Matching Absolute Error (deg) @ T1') 
print('plots/ScatterPlots/220114_PMT1_BBTDelta','-dpng')

[rho_bbtpm0,pval_bbtpm0] = corr(S1(:,7),S3(:,5)-S1(:,5), 'Type', 'Spearman');

figure; 
scatter(S3(:,7),S3(:,5),'filled','k');
%labelpoints(S1(:,7)-S3(:,7),S3(:,5)-S1(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Position Matching Absolute Error (deg) @ T3') 
print('plots/ScatterPlots/220114_PM_BBT_T3','-dpng')

[rho_bbtpm1,pval_bbtpm1] = corr(S3(:,7),S3(:,5), 'Type', 'Spearman');

% only consider values above 30
n = 1; 
temp = []; 
for i = 1:length(S3(:,5))
    if S3(i,5) >=30
        temp(n,1) = S3(i,5); 
        temp(n,2) = S3(i,7);
        n = n +1; 
    end
end

figure;
scatter(temp(:,2),temp(:,1), 'filled', 'k'); 
ylabel('Box & Block Test @ T3')
xlabel('Position Matching Absolute Error (deg) @ T3') 
print('plots/ScatterPlots/220114_PM_BBT_T3_above30','-dpng')

[rho_bbtpm,pval_bbtpm] = corr(temp(:,1),temp(:,2), 'Type', 'Spearman');


%% BBT vs motor

figure; 
scatter(S3(:,9)-S1(:,9),S3(:,5)-S1(:,5),'filled','k');
labelpoints(S3(:,9)-S1(:,9),S3(:,5)-S1(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Delta Box & Block Test')
xlabel('Delta Active ROM (deg)') 
print('plots/ScatterPlots/211125_ROM_BBT_Delta','-dpng')

figure; 
scatter(S3(:,9),S3(:,5),'filled','k');
labelpoints(S3(:,9),S3(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Active ROM (deg) @ T3') 
print('plots/ScatterPlots/211125_ROM_BBT_T3','-dpng')

figure; 
scatter(S3(:,8),S3(:,5),'filled','k');
labelpoints(S3(:,8),S3(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Force Flexion @ T3') 
print('plots/ScatterPlots/211125_Force_BBT_T3','-dpng')




%%

figure; 
scatter((S1(:,7)-S3(:,7))./S3(:,7),S3(:,5),'filled','k');
labelpoints((S1(:,7)-S3(:,7))./S3(:,7),S3(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('(T1-T3)/T3 Position Matching Absolute Error') 
print('plots/ScatterPlots/211111_PM_BBT_DeltaNormalized_T3','-dpng')

figure; 
scatter((S1(:,7)-S3(:,7))./S3(:,7),(S3(:,5)-S1(:,5))./S1(:,5),'filled','k');
labelpoints((S1(:,7)-S3(:,7))./S3(:,7),(S3(:,5)-S1(:,5))./S1(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('(T3-T1)/T1 Box & Block Test')
xlabel('(T1-T3)/T3 Position Matching Absolute Error') 
print('plots/ScatterPlots/211111_PM_BBT_DeltaNormalized','-dpng')

figure; 
scatter(S1(:,7)-S3(:,7),S3(:,5),'filled','k');
labelpoints(S1(:,7)-S3(:,7),S3(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Delta Position Matching Absolute Error (deg)') 
print('plots/ScatterPlots/211026_PMDelta_BBTT3','-dpng')


figure; 
scatter(S1(:,7),S3(:,5),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Position Matching Absolute Error @ T1') 
title('T1 vs T3')
print('plots/ScatterPlots/211019_PM_BBT_T1T3','-dpng')


figure; 
scatter(S1(:,7)-S3(:,7),S1(:,5),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T1')
xlabel('Delta Position Matching Absolute Error (deg)') 
title('Delta PM vs BBT @ T1')
print('plots/ScatterPlots/211026_PMDelta_BBTT1','-dpng')
[rho_1,pval_1] = corr(S1(:,7)-S3(:,7),S1(:,5), 'Type', 'Spearman');

figure; 
scatter(S1(:,5),S1(:,7)-S3(:,7),'filled','k');
labelpoints(S1(:,5),S1(:,7)-S3(:,7),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylim([-9 12]) 
xlim([-5 60]) 
xlabel('Box & Block Test at baseline')
ylabel('Change in Position Matching Absolute Error (deg)') 
title('Delta PM vs BBT @ T1')
print('plots/ScatterPlots/211026_PMDelta_BBTT3_v2','-dpng')

figure; 
scatter(S1(:,7),S3(:,5)-S1(:,5),'filled','k');
%labelpoints(S1(:,7),S3(:,5)-S1(:,5),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
xline(10.63, '--k') 
ylabel('Change in Box & Block Test')
xlabel('Position Matching Absolute Error (deg) at baseline') 
% title('Delta BBT vs PM @ T1')
print('plots/ScatterPlots/211028_PMT1_BBTChange_v3','-dpng')
[rho_2,pval_2] = corr(S1(:,7),S3(:,5)-S1(:,5), 'Type', 'Spearman');

% remove subjects that are 0 at baseline in BBT

temp = []; 
n = 1; 
figure; 
for i=1:length(S1(:,1))
    if S1(i,5) == 0 
    else
        temp(n,1) = S1(i,7); 
        temp(n,2) = S3(i,5)-S1(i,5); 
        n = n +1; 
        scatter(S1(i,7),S3(i,5)-S1(i,5),'filled','k');
        labelpoints(S1(i,7),S3(i,5)-S1(i,5),string(S1(i,1))); 
        hold on 
    end
end
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%xline(30, '--k'); 
%ylim([-9 12]) 
ylabel('Change in Box & Block Test')
xlabel('Position Matching Absolute Error (deg) at baseline') 
title('Delta BBT vs PM @ T1')
print('plots/ScatterPlots/211026_PMT1_BBTChange_v3','-dpng')
[rho_3,pval_3] = corr(temp(:,1), temp(:,2), 'Type', 'Spearman');


temp = []; 
n = 1; 
figure; 
for i=1:length(S1(:,1))
    if S1(i,5) == 0 
    else
        temp(n,1) = S1(i,7)-S3(i,7); 
        temp(n,2) = S3(i,5)-S1(i,5); 
        n = n +1; 
        scatter(S1(i,7)-S3(i,7),S3(i,5)-S1(i,5),'filled','k');
        labelpoints(S1(i,7)-S3(i,7),S3(i,5)-S1(i,5),string(S1(i,1))); 
        hold on 
    end
end
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
%ylim([-9 12]) 
ylabel('Change in Box & Block Test')
xlabel('Change in Position Matching Absolute Error (deg)') 
title('Delta BBT vs Delta PM')
print('plots/ScatterPlots/211026_PMChange_BBTChange_v3','-dpng')
[rho_4,pval_4] = corr(temp(:,1), temp(:,2), 'Type', 'Spearman');

temp = []; 
n = 1; 
figure; 
for i=1:length(S1(:,1))
    if S1(i,5) == 0 
    else
        temp(n,1) = S1(i,5); 
        temp(n,2) = S1(i,7)-S3(i,7); 
        n = n +1; 
        scatter(S1(i,5),S1(i,7)-S3(i,7),'filled','k');
        labelpoints(S1(i,5),S1(i,7)-S3(i,7),string(S1(i,1))); 
        hold on 
    end
end
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
%xlim([-2 60]) 
xlabel('Box & Block Test at baseline')
ylabel('Change in Position Matching Absolute Error (deg)') 
title('BBT at T1 vs Delta PM')
print('plots/ScatterPlots/211026_PMChange_BBTT1_v4','-dpng')
[rho_5,pval_5] = corr(temp(:,1), temp(:,2), 'Type', 'Spearman');

figure; 
scatter(S1(:,8),S1(:,7)-S3(:,7),'filled','k');
labelpoints(S1(:,8),S1(:,7)-S3(:,7),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
xlim([-3 50])
ylim([-9 12])
xlabel('Maximum Force at baseline')
ylabel('Change in Position Matching Absolute Error') 
title('Change in PM vs Max Force at T1')
print('plots/ScatterPlots/211026_ChangePM_ForceT1','-dpng')
[rho_6,pval_6] = corr(S1(:,8),S1(:,7)-S3(:,7), 'Type', 'Spearman');

figure; 
scatter(S1(:,9),S1(:,7)-S3(:,7),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
xlabel('ROM at baseline')
ylabel('Change in Position Matching Absolute Error') 
title('Change in PM vs ROM at T1')
print('plots/ScatterPlots/211026_ChangePM_ROMT1','-dpng')
[rho_7,pval_7] = corr(S1(:,9),S1(:,7)-S3(:,7), 'Type', 'Spearman');

figure; 
scatter(S1(:,10),S1(:,7)-S3(:,7),'filled','k');
labelpoints(S1(:,10),S1(:,7)-S3(:,7),string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
xlim([0.1 1.1])
ylim([-9 12])
xlabel('Smoothness MAPR at baseline')
ylabel('Change in Position Matching Absolute Error') 
title('Change in PM vs Smoothness at T1')
set(gca,'XDir','reverse')
print('plots/ScatterPlots/211026_ChangePM_SmoothnessT1','-dpng')
[rho_8,pval_8] = corr(S1(:,10),S1(:,7)-S3(:,7), 'Type', 'Spearman');

%% towards H3

figure; 
scatter(S1(:,7)-S3(:,7),S3(:,5),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Change in Position Matching (deg)') 
title('Delta')
print('plots/ScatterPlots/211013_deltaPM_BBTT3','-dpng')

figure; 
scatter(S3(:,8)-S1(:,8),S3(:,5),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Change in Force Flex (N)') 
title('Delta')
print('plots/ScatterPlots/211013_deltaForce_BBTT3','-dpng')

figure; 
scatter(S3(:,9)-S1(:,9),S3(:,5),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Change in AROM (deg)') 
title('Delta')
print('plots/ScatterPlots/211013_deltaAROM_BBTT3','-dpng')

figure; 
scatter(S3(:,4)-S1(:,4),S3(:,5),'filled','k');
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Change in FMA') 
title('Delta')
print('plots/ScatterPlots/211013_deltaFMA_BBTT3','-dpng')

[rho.PMBBT,pval.PMBBT] = corr(S1(:,7)-S3(:,7),S3(:,5), 'Type', 'Spearman');
[rho.FBBT,pval.FBBT] = corr(S3(:,8)-S1(:,8),S3(:,5), 'Type', 'Spearman');
[rho.ABBT,pval.ABBT] = corr(S3(:,9)-S1(:,9),S3(:,5), 'Type', 'Spearman');

%% Barthel index

figure; 
scatter(S1(:,7),S1(:,11),'filled','k');
labelpoints(S1(:,7),S1(:,11), string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Barthel Index')
xlabel('Position Matching Error (deg)') 
[rho_9,pval_9] = corr(S1(:,7),S1(:,11), 'Type', 'Spearman');

figure; 
scatter(S3(:,7),S3(:,11),'filled','k');
labelpoints(S3(:,7),S3(:,11), string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Barthel Index @ T3')
xlabel('Position Matching Error (deg) @ T3') 
[rho_10,pval_10] = corr(S3(:,7),S3(:,11), 'Type', 'Spearman');
print('plots/ScatterPlots/211027_PM_BathelT3','-dpng')

figure; 
scatter(S3(:,7),S3(:,11),'filled','k');
labelpoints(S3(:,7),S3(:,11), string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Barthel Index @ T3')
xlabel('Position Matching Error (deg) @ T3') 
[rho_10,pval_10] = corr(S3(:,7),S3(:,11), 'Type', 'Spearman');
print('plots/ScatterPlots/211027_PM_BathelT3','-dpng')


figure; 
scatter(S1(:,7)-S3(:,7),S3(:,11)-S1(:,11),'filled','k');
labelpoints(S1(:,7)-S3(:,7),S3(:,11)-S1(:,11), string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Change in Barthel Index')
xlabel('Change in Position Matching Error (deg)') 
%[rho_11,pval_11] = corr(S3(:,7),S3(:,11), 'Type', 'Spearman');
%print('plots/ScatterPlots/211013_deltaPM_BBTT3','-dpng ')

figure; 
scatter(S1(:,7),S3(:,11)-S1(:,11),'filled','k');
labelpoints(S1(:,7),S3(:,11)-S1(:,11), string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Change in Barthel Index')
xlabel('Position Matching Error (deg) at T1') 
%[rho_11,pval_11] = corr(S3(:,7),S3(:,11), 'Type', 'Spearman');
%print('plots/ScatterPlots/211013_deltaPM_BBTT3','-dpng')

figure; 
scatter(S1(:,7)-S3(:,7),S3(:,11),'filled','k');
labelpoints(S1(:,7)-S3(:,7),S3(:,11), string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Barthel Index at T3')
xlabel('Change in Position Matching Error (deg)') 
%[rho_11,pval_11] = corr(S3(:,7),S3(:,11), 'Type', 'Spearman');
%print('plots/ScatterPlots/211013_deltaPM_BBTT3','-dpng')

%% FMA Hand

figure; 
scatter(S3(:,7),S3(:,6),'filled','k');
labelpoints(S3(:,7),S3(:,6), string(S1(:,1))); 
%xlim([-0.5 14.5]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Fugl-Meyer Hand @ T3')
xlabel('Position Matching Error (deg) @ T3') 
[rho_10,pval_10] = corr(S3(:,7),S3(:,11), 'Type', 'Spearman');
print('plots/ScatterPlots/211027_PM_FMAHT3','-dpng')
[rho_12,pval_12] = corr(S3(:,7),S3(:,6), 'Type', 'Spearman');

figure; 
scatter(S1(:,7)-S3(:,7),S3(:,5)-S1(:,5),'filled','k');

