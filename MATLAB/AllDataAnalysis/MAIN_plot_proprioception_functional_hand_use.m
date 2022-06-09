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
% 44 - FMA Hand 
% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 127 - extension velocity 

A = table2array(T(:,[3 5 47 41 48 44 122 114 92 160])); 

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

%% add one missing subject entry (#40)

S1(43,1) = 40; 
S1(43,2) = 1; 
S1(43,3) = 2;
S1(43,4) = 51;
S1(43,5) = 31;
S1(43,6) = 12;
S1(43,7) = 14.4014303;
S1(43,8) = 5.891059822;
S1(43,9) = 60.00324717; 
S1(43,10) = 77.13920413; 

S3(43,1) = 40; 
S3(43,2) = 2; 
S3(43,3) = 3;
S3(43,4) = 54;
S3(43,5) = 15;
S3(43,6) = 11;
S3(43,7) = 10.81948228;
S3(43,8) = 7.140993862;
S3(43,9) = 52.25931944; 
S3(43,10) = 53.58038117;

%% PM vs BBT

% PM @ T1 and delta BBT
figure; 
scatter(S1(:,7),S3(:,5)-S1(:,5),'filled','k');
xlim([2 26]) 
% xticks([0 1 2 3])
%yline(30, '--k'); 
ylabel('Delta Box & Block Test (#/min)')
xlabel('Absolute Error AE (deg) at T1') 
set(gca,'XDir','reverse')
set(gca,'FontSize',12)
print('plots/Paper/20220522_Figure4C','-dpng')
figure2pdf('plots/Paper/20220609_Figure4C'); 

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
xlabel('Box & Block Test (#/min) at T1')
ylabel('Delta Absolute Error AE (deg)') 
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
legend([c1(1), c2(1)], 'AE non-impaired at T1', 'AE impaired at T1','Location','best')
set(gca,'FontSize',12)
print('plots/Paper/20220606_Figure4D','-dpng')
figure2pdf('plots/Paper/20220609_Figure4D'); 

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
ylabel('Box & Block Test (#/min) at T2')
xlabel('Absolute Error AE (deg) at T2') 
print('plots/Paper/20220522_Figure4B','-dpng')
figure2pdf('plots/Paper/20220609_Figure4B'); 

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
ylabel('Box & Block Test (#/min) at T2')
xlabel('Flexion Force FF (N) at T2') 
set(gca,'FontSize',12)
print('plots/Paper/20220522_Figure4A','-dpng')
figure2pdf('plots/Paper/20220609_Figure4A'); 

% BBT @ T3 vs AROM @ T3
figure; 
scatter(S3(:,9),S3(:,5),'filled','k');
xlim([-5 110])
ylim([-5 68])
p4 = polyfit(S3(:,9),S3(:,5),1);
px4 = [min(S3(:,9)) max(S3(:,9))];
py4 = polyval(p4, px4);
hold on 
plot(px4, py4,'--k', 'LineWidth', 0.5);
ylabel('Box & Block Test (#/min) at T2')
xlabel('Active Range of Motion AROM (deg) at T2') 
set(gca,'FontSize',12)
print('plots/Paper/20220522_FigureSM7A','-dpng')

% BBT @ T3 vs EV @ T3
figure; 
scatter(S3(:,10),S3(:,5),'filled','k');
% xlim([-1 680])
% ylim([-1 70])
p4 = polyfit(S3(:,10),S3(:,5),1);
px4 = [min(S3(:,10)) max(S3(:,10))];
py4 = polyval(p4, px4);
hold on 
plot(px4, py4,'--k', 'LineWidth', 0.5);
ylabel('Box & Block Test (#/min) at T2')
xlabel('Extension Velocity EV (deg/s) at T2') 
set(gca,'FontSize',12)
print('plots/Paper/20220522_FigureSM7B','-dpng')

% correlations
[rho.PMBBT3_p,pval.PMBBT3_p] = corr(S3(:,7),S3(:,5), 'Type', 'Pearson');
[rho.FBBT_T3_p,pval.FBBT_T3_p] = corr(S3(:,5),S3(:,8), 'Type', 'Pearson'); % strong correlation 
[rho.RBBT_T3_p,pval.RBBT_T3_p] = corr(S3(:,5),S3(:,9), 'Type', 'Pearson');
[rho.VBBT_T3_p,pval.VBBT_T3_p] = corr(S3(:,5),S3(:,10), 'Type', 'Pearson');


