%% FIGURE 4 - proprioception vs functional hand use (BBT) %% 
% remove subjects that are in the Floor effect of BBT 
% created: 05.04.2022

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
    if S1(i,7) <= 10.63 && S1(i,5)>0
    tmp1(m,:) = S1(i,:); 
    tmp2(m,:) = S3(i,:);
    m = m +1; 
    c1 = scatter(S1(i,5),S1(i,7)-S3(i,7),'MarkerEdgeColor','k');
    hold on 
    elseif S1(i,5)>0
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
print('plots/Paper/220405_FigureSM8D','-dpng')

[rho.DPMBBT1_1,pval.DPMBBT1_1] = corr(tmp1(:,5),tmp1(:,7)-tmp2(:,7), 'Type', 'Spearman');
[rho.DPMBBT1_2,pval.DPMBBT1_2] = corr(temp1(:,5),temp1(:,7)-temp2(:,7), 'Type', 'Spearman');

%% Both motor function and proprioception needed for functional hand use at discharge

% BBT @ T3 and PM @ T3
tmp = []; 
tmp2 = []; 
n = 1; 
figure; 
for i = 1:length(S3(:,1))
    if S3(i,5)>0
    tmp(n,1)=S3(i,5); 
    tmp(n,2)=S3(i,7); 
    scatter(S3(i,7),S3(i,5),'filled','k');
    n = n +1; 
    hold on
    end
end
hold on 
p3 = polyfit(tmp(:,2),tmp(:,1),1);
px3 = [min(tmp(:,2)) max(tmp(:,2))];
py3 = polyval(p3, px3);
hold on 
plot(px3, py3,'--k', 'LineWidth', 0.5);
xlim([3 25])
ylim([-2 70])
set(gca,'FontSize',12)
set(gca,'XDir','reverse')
ylabel('Box & Block Test @ T2')
xlabel('Position Matching Absolute Error (deg) @ T2') 
print('plots/Paper/220405_FigureSM8B','-dpng')

% BBT @ T3 vs Force @ T3
n = 1; 
figure; 
for i = 1:length(S3(:,1))
    if S3(i,5)>0
    tmp2(n,1)=S3(i,5); 
    tmp2(n,2)=S3(i,8); 
    scatter(S3(i,8),S3(i,5),'filled','k');
    n = n +1; 
    hold on
    end
end
hold on 
p3 = polyfit(tmp2(:,2),tmp2(:,1),1);
px3 = [min(tmp2(:,2)) max(tmp2(:,2))];
py3 = polyval(p3, px3);
plot(px3, py3,'--k', 'LineWidth', 0.5);
xlim([-1 43])
ylim([-2 70])
ylabel('Box & Block Test @ T2')
xlabel('Maximum Force Flexion (N) @ T2') 
set(gca,'FontSize',12)
print('plots/Paper/220405_FigureSM8A','-dpng')

% correlations
[rho.PMBBT3_p,pval.PMBBT3_p] = corr(tmp(:,1),tmp(:,2), 'Type', 'Spearman');
[rho.FBBT_T3_p,pval.FBBT_T3_p] = corr(tmp2(:,1),tmp2(:,2), 'Type', 'Spearman'); % strong correlation 


