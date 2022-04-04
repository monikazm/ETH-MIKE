%% Sensory vs Motor at two different time points (inclusion and discharge and change) %% 
% created: 11.08.2021

% are the relationships between the two different at inclusion and
% discharge and well as between delta? 

% inspired from: https://pubmed.ncbi.nlm.nih.gov/28566461/ 

clear 
close all
clc

%% read table %% 

T = readtable('data/20210811_DataImpaired.csv'); 
M = readtable('data/20210121_metricInfo.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR

A = table2array(T(:,[3 5 160 122])); 
% 36 - PM
% 28 - force flex
% 6 - AROM
% 74 - max vel ext
ID = 36; 
SRD_sensory = table2array(M(ID,7)); 
ID = 74; 
SRD_motor = table2array(M(ID,7)); 

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
for i = 1:length(C(:,1))
    if C(i,1) == 3
        if C(i,2) == 1
            Sesh1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 2
            Sesh3(k,:) = C(i,:);
            k = k+1; 
        end
    else
        if C(i,2) == 1
            Sesh1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 3
            Sesh3(k,:) = C(i,:);
            k = k+1; 
        end
    end
end

%% combine 
Lia = double(ismember(Sesh1(:,1),Sesh3(:,1))); 
Sesh1(:,1) = Lia.*Sesh1(:,1); 
Sesh1(Sesh1(:,1)==0,:)= [];

% N = 27 
Sesh1(1,:) = []; 
Sesh3(1,:) = []; %remove the outlier 

Sesh1(26,:) = []; 
Sesh3(26,:) = []; %remove the outlier 

%% calculate change
change(:,1) = Sesh1(:,1); 
change(:,2) = Sesh3(:,3)-Sesh1(:,3); 
change(:,3) = Sesh1(:,4)-Sesh3(:,4); 

change_bySRD(:,1) = change(:,1); 
change_bySRD(:,2) = change(:,2)./SRD_motor; 
change_bySRD(:,3) = change(:,3)./SRD_sensory; 

%% define impairment threshold

PM_thr = 5.21+2*2.71; 
AROM_thr = 76.77+2*6.18; 
Flex_thr = 32.79+2*10.93; 
Ext_thr = 408.00+2*76.20; 

%% plot Motor vs Sensory 
% raw metric for now, eventually do it in z-score  

txt1 = string(Sesh1(:,1)');
txt2 = string(Sesh3(:,1)');
txt3 = string(change(:,1)');

% T1 
figure;
scatter(Sesh1(:,4),Sesh1(:,3), 'filled'); % x-sensory, y-motor
hold on
labelpoints(Sesh1(:,4),Sesh1(:,3), txt1); 
hold on 
xline(PM_thr, '--k'); 
hold on 
yline(Ext_thr, '--k'); 
set(gca,'XDir','reverse')
xlabel('Position Matching Error (deg)') 
ylabel('Max Velocity Extension (deg/s)') 
% xlim([-1.2 0.8])
%ylim([-2 4])
title('PM vs Max Vel Ext @ T1')
print('Plots/ScatterPlots/210810_VelExtvsPM_T1','-dpng')

% T3
figure; 
scatter(Sesh3(:,4),Sesh3(:,3), 'filled','r'); % x-sensory, y-motor
hold on
labelpoints(Sesh3(:,4),Sesh3(:,3), txt2);
hold on 
xline(PM_thr, '--k'); 
hold on 
yline(Ext_thr, '--k'); 
set(gca,'XDir','reverse')
xlabel('Position Matching Error (deg)') 
ylabel('Max Velocity Extension (deg/s)') 
% xlim([-1.2 0.8])
%ylim([-2 4])
title('PM vs Max Vel Ext @ T3')
print('Plots/ScatterPlots/210810_VelExtvsPM_T3','-dpng')


% change
figure; 
scatter(change(:,3),change(:,2), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(change(:,3),change(:,2), txt3);
%set(gca,'XDir','reverse')
xlabel('Delta Position Matching Error (deg)') 
ylabel('Delta Max Velocity Extension (deg/s)') 
% xlim([-1.2 0.8])
%ylim([-2 4])
title('Delta PM vs Max Vel Ext')
print('Plots/ScatterPlots/210810_VelExtvsPM_delta','-dpng')

% change by SRD
figure; 
scatter(change_bySRD(:,3),change_bySRD(:,2), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(change_bySRD(:,3),change_bySRD(:,2), txt3);
xline(1, '--k'); 
hold on 
yline(1, '--k'); 
%set(gca,'XDir','reverse')
xlabel('Delta by SRD Position Matching Error (deg)') 
ylabel('Delta by SRD Max Velocity Extension (deg/s)') 
% xlim([-1.2 0.8])
ylim([-2.5 3.5])
title('Delta by SRD PM vs Max Vel Ext')
print('Plots/ScatterPlots/210810_VelExtvsPM_deltabySRD','-dpng')

% change by SRD vs PM @ T1
figure; 
scatter(Sesh1(:,4),change_bySRD(:,2), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(Sesh1(:,4),change_bySRD(:,2), txt3);
xlabel('Position Matching Error (deg) @ T1') 
ylabel('Delta by SRD Max Velocity Extension (deg/s)') 
% xlim([-1.2 0.8])
ylim([-2.5 3.5])
title('Delta by Max Vel Ext vs PM @ T1')
print('Plots/ScatterPlots/210817_VelExt_deltabySRD_PMT1','-dpng')


%% correlations

[RHO1,PVAL1] = corr(Sesh1(:,4),Sesh1(:,3),'Type','Spearman');
[RHO2,PVAL2] = corr(Sesh3(:,4),Sesh3(:,3),'Type','Spearman');
[RHO3,PVAL3] = corr([Sesh1(:,4);Sesh3(:,4)], [Sesh1(:,3); Sesh3(:,3)],'Type','Spearman');
[RHO4,PVAL4] = corr(change_bySRD(:,3),change_bySRD(:,2),'Type','Spearman');
[RHO5,PVAL5] = corr(Sesh1(:,4),change_bySRD(:,2),'Type','Spearman');




