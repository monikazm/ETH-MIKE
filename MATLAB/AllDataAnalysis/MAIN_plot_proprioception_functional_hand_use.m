%% FIGURE 4 - proprioception vs functional hand use (BBT) %% 
% created: 22.03.2022

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
S3(32,8) = S1(32,8); 
S3(32,9) = S1(32,9); 
S3(32,10) = S1(32,10); 

%% Force vs BBT @ T3

figure; 
scatter(S3(:,5),S3(:,8),'filled','k');
%yline(10.93, '--k'); 
xlabel('Box & Block Test @ T3')
ylabel('Maximum Force Flexion (N) @ T3') 
print('plots/ScatterPlots/211013_F_BBT_T3','-dpng')

% correlations
[rho.FBBT_T3_s,pval.FBBT_T3_s] = corr(S3(:,5),S3(:,8), 'Type', 'Spearman'); % strong correlation 

%% PM vs BBT

% BBT @ T3 and PM @ T3
figure; 
scatter(S3(:,7),S3(:,5),'filled','k');
%xlim([-0.5 14.5]) 
%ylim([0 70])
%yline(30, '--k'); 
%xline(10.63,'--k'); 
ylabel('Box & Block Test @ T3')
xlabel('Position Matching Absolute Error (deg) @ T3') 
print('plots/ScatterPlots/211028_PM_BBT_T3','-dpng')

% BBT @ T1 and delta PM 
figure; 
scatter(S1(:,5),S1(:,7)-S3(:,7),'filled','k');
ylim([-9 12]) 
xlim([-2 60])
% xticks([0 1 2 3])
%xline(30, '--k'); 
% xline(10.63,'--k'); 
xlabel('Box & Block Test @ T1')
ylabel('Delta Position Matching Absolute Error (deg)') 
print('plots/ScatterPlots/211206_PMChange_BBT_T1','-dpng')

% PM @ T1 and delta BBT
figure; 
scatter(S1(:,7),S3(:,5)-S1(:,5),'filled','k');
xlim([2 26]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Delta Box & Block Test')
xlabel('Position Matching Absolute Error (deg) @ T1') 
set(gca,'XDir','reverse')
set(gca,'FontSize',12)
print('plots/Paper/220322_Figure4C','-dpng')

[rho.PMBBT3_s,pval.PMBBT3_s] = corr(S3(:,7),S3(:,5), 'Type', 'Spearman');
[rho.PM1DBBT_s,pval.PM1DBBT_s] = corr(S1(:,7),S3(:,5)-S1(:,5), 'Type', 'Spearman');
[rho.PM1DBBT_p,pval.PM1DBBT_p] = corr(S1(:,7),S3(:,5)-S1(:,5), 'Type', 'Pearson');

%% Some motor function needed for proprioceptive improvement 
% with trend line and separation of data points

n = 1;
m = 1; 
tmp1 = []; 
tmp2 = []; 
temp1 = []; 
temp2 = []; 
sz = 50; 
figure; 
for i = 1:length(S1(:,1))
    if S1(i,7) <= 10.63
    tmp1(m,:) = S1(i,:); 
    tmp2(m,:) = S3(i,:);
    m = m +1; 
    c1 = scatter(S1(i,5),S1(i,7)-S3(i,7),'MarkerEdgeColor','k');
    hold on 
    else
    temp1(n,:) = S1(i,:); 
    temp2(n,:) = S3(i,:); 
    n = n +1; 
    c2 = scatter(S1(i,5),S1(i,7)-S3(i,7),'filled','k');
    hold on 
    end
end
ylim([-9 12]) 
xlim([-2 60])
xlabel('Box & Block Test @ T1')
ylabel('Delta Position Matching Absolute Error (deg)') 
% line of best fit - green points
p1 = polyfit(tmp1(:,5),tmp1(:,7)-tmp2(:,7),1);
px1 = [min(tmp1(:,5)) max(tmp1(:,5))];
py1 = polyval(p1, px1);
%plot(px1, py1,'--g', 'LineWidth', 0.5);
% line of best fit - black points
p2 = polyfit(temp1(:,5),temp1(:,7)-temp2(:,7),1);
px2 = [min(temp1(:,5)) max(temp1(:,5))];
py2 = polyval(p2, px2);
c3 = plot(px2, py2,'--k', 'LineWidth', 0.5);
legend([c1(1), c2(1)], 'PM non-impaired @ T1', 'PM impaired @ T1','Location','best')
set(gca,'FontSize',12)
print('plots/Paper/220322_Figure4D','-dpng')

[rho.DPMBBT1_1,pval.DPMBBT1_1] = corr(S1(:,5),S1(:,7)-S3(:,7), 'Type', 'Pearson');
[rho.DPMBBT1_3,pval.DPMBBT1_3] = corr(tmp1(:,5),tmp1(:,7)-tmp2(:,7), 'Type', 'Spearman');
[rho.DPMBBT1_2_s,pval.DPMBBT1_2_s] = corr(temp1(:,5),temp1(:,7)-temp2(:,7), 'Type', 'Spearman');
[rho.DPMBBT1_2_p,pval.DPMBBT1_2_p] = corr(temp1(:,5),temp1(:,7)-temp2(:,7), 'Type', 'Pearson');

%% Both motor function and proprioception needed for functional hand use at discharge

% BBT @ T3 and PM @ T3
figure; 
scatter(S3(:,7),S3(:,5),'filled','k');
p3 = polyfit(S3(:,7),S3(:,5),1);
px3 = [min(S3(:,7)) max(S3(:,7))];
py3 = polyval(p3, px3);
hold on 
plot(px3, py3,'--k', 'LineWidth', 0.5);
xlim([3 25])
ylim([-2 70])
set(gca,'FontSize',12)
set(gca,'XDir','reverse')
ylabel('Box & Block Test @ T2')
xlabel('Position Matching Absolute Error (deg) @ T2') 
print('plots/Paper/220322_Figure4B','-dpng')

% BBT @ T3 vs Force @ T3
figure; 
scatter(S3(:,8),S3(:,5),'filled','k');
xlim([-1 43])
ylim([-2 70])
p4 = polyfit(S3(:,8),S3(:,5),1);
px4 = [min(S3(:,8)) max(S3(:,8))];
py4 = polyval(p4, px4);
hold on 
plot(px4, py4,'--k', 'LineWidth', 0.5);
ylabel('Box & Block Test @ T2')
xlabel('Maximum Force Flexion (N) @ T2') 
set(gca,'FontSize',12)
print('plots/Paper/220322_Figure4A','-dpng')

% correlations
[rho.PMBBT3_p,pval.PMBBT3_p] = corr(S3(:,7),S3(:,5), 'Type', 'Pearson');
[rho.FBBT_T3_p,pval.FBBT_T3_p] = corr(S3(:,5),S3(:,8), 'Type', 'Pearson'); % strong correlation 


%% OLD

% % mark those that were good at T1 already and those that recovered 
% % complicated 
% % BBT @ T3 and PM @ T3
% figure; 
% for i=1:length(S3(:,1))
%     if S3(i,1) == 8 || S3(i,1) == 13 || S3(i,1) == 14 || S3(i,1) == 26 || S3(i,1) == 31 || S3(i,1) == 36 || S3(i,1) == 41 || S3(i,1) == 47
%         scatter(S3(i,7),S3(i,5),'filled','g'); % recovered both. 
%         hold on
%     elseif S3(i,1) == 3 || S3(i,1) == 4 || S3(i,1) == 5 || S3(i,1) == 17 || S3(i,1) == 22 || S3(i,1) == 25 || S3(i,1) == 27 || S3(i,1) == 28 || S3(i,1) == 29 || S3(i,1) == 32 || S3(i,1) == 35 || S3(i,1) == 42 || S3(i,1) == 43 || S3(i,1) == 44 || S3(i,1) == 46 || S3(i,1) == 48 || S3(i,1) == 50
%         scatter(S3(i,7),S3(i,5),'filled','r'); % recovered motor only. 
%     elseif S3(i,1) == 21 || S3(i,1) == 34 
%         scatter(S3(i,7),S3(i,5),'filled','r'); % recovered prop. 
%         hold on
%     else
%         scatter(S3(i,7),S3(i,5),'filled','k');
%         hold on
%     end
% end
% p3 = polyfit(S3(:,7),S3(:,5),1);
% px3 = [min(S3(:,7)) max(S3(:,7))];
% py3 = polyval(p3, px3);
% plot(px3, py3,'--k', 'LineWidth', 0.5);
% xlim([3 25])
% ylim([-2 70])
% set(gca,'FontSize',12)
% set(gca,'XDir','reverse')
% ylabel('Box & Block Test @ T3')
% xlabel('Position Matching Absolute Error (deg) @ T3') 
% print('plots/ScatterPlots/211028_PM_BBT_T3','-dpng')
% 
% 
% figure; 
% for i=1:length(S3(:,1))
%     if S3(i,1) == 8 || S3(i,1) == 13 || S3(i,1) == 14 || S3(i,1) == 26 || S3(i,1) == 31 || S3(i,1) == 36 || S3(i,1) == 41 || S3(i,1) == 47
%         scatter(S3(i,8),S3(i,5),'filled','g'); % recovered both. 
%         hold on
%     elseif S3(i,1) == 3 || S3(i,1) == 4 || S3(i,1) == 5 || S3(i,1) == 17 || S3(i,1) == 22 || S3(i,1) == 25 || S3(i,1) == 27 || S3(i,1) == 28 || S3(i,1) == 29 || S3(i,1) == 32 || S3(i,1) == 35 || S3(i,1) == 42 || S3(i,1) == 43 || S3(i,1) == 44 || S3(i,1) == 46 || S3(i,1) == 48 || S3(i,1) == 50
%         scatter(S3(i,8),S3(i,5),'filled','r'); % recovered motor only. 
%     elseif S3(i,1) == 21 || S3(i,1) == 34 
%         scatter(S3(i,7),S3(i,5),'filled','r'); % recovered prop. 
%         hold on
%     else
%         scatter(S3(i,8),S3(i,5),'filled','k');
%     end
% end
% xlim([-1 43])
% ylim([-2 70])
% p4 = polyfit(S3(:,8),S3(:,5),1);
% px4 = [min(S3(:,8)) max(S3(:,8))];
% py4 = polyval(p4, px4);
% plot(px4, py4,'--k', 'LineWidth', 0.5);
% ylabel('Box & Block Test @ T3')
% xlabel('Maximum Force Flexion (N) @ T3') 
% set(gca,'FontSize',12)
% print('plots/ScatterPlots/211013_F_BBT_T3','-dpng')


