%% scatter plots to look at relationships between sensory & motor metrics %% 
% created: 17.09.2021

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

A = table2array(T(:,[3 5 92 114 160 127 122 47 41])); 

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
        elseif C(i,2) == 2
            S2(k,:) = C(i,:);
            k = k+1; 
        elseif C(i,2) == 3
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];
  
Lia = double(ismember(S2(:,1),S3(:,1))); 
S2(:,1) = Lia.*S2(:,1); 
S2(S2(:,1)==0,:)= [];

S1(1,:) = []; 
S2(1,:) = []; 
S3(1,:) = []; 
S2(13,7) = 20;  

%% scatter Position Matching vs AROM 

deltaPM = (S1(:,7)-S3(:,7))./9.12; 
deltaAROM = (S3(:,3)-S1(:,3))./15.58; 
deltaForce = (S3(:,4)-S1(:,4))./4.88; 
deltaVel = (S3(:,5)-S1(:,5))./60.68; 

figure; 
scatter(deltaPM, deltaAROM,'filled','k')
xlabel('Delta/SRD: Position Matching Error') 
ylabel('Delta/SRD: Active Range of Motion') 
hold on 
xline(1, '--k'); 
yline(1, '--k'); 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210917_PM_AROM_change','-dpng')


%% scatter PM vs Force 

figure; 
scatter(deltaPM, deltaForce,'filled','k')
xlabel('Delta/SRD: Position Matching Error') 
ylabel('Delta/SRD: Maximum Force Flexion') 
hold on 
xline(1, '--k'); 
yline(1, '--k'); 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210917_PM_Force_change','-dpng')

%% correlation deltas

[rho1_delta,pval1_delta] = corr(deltaPM, deltaAROM, 'Type', 'Spearman');
[rho2_delta,pval2_delta] = corr(deltaPM, deltaForce, 'Type', 'Spearman');
[rho3_delta,pval3_delta] = corr(deltaPM, deltaVel, 'Type', 'Spearman');

%% scatter at T1 and at T3 - PM vs AROM 

figure; 
scatter(S1(:,7), S1(:,3),'filled','k')
xlabel('Position Matching Error @ T1') 
ylabel('Active Range of Motion @ T1') 

[rho1_PMAROM,pval1_PMAROM] = corr(S1(:,7), S1(:,3), 'Type', 'Spearman');

figure; 
scatter(S2(:,7), S2(:,3),'filled','k')
xlabel('Position Matching Error @ T2') 
ylabel('Active Range of Motion @ T2') 

[rho2_PMAROM,pval2_PMAROM] = corr(S2(:,7), S2(:,3), 'Type', 'Spearman');

figure; 
scatter(S3(:,7), S3(:,3),'filled','k')
xlabel('Position Matching Error @ T3') 
ylabel('Active Range of Motion @ T3') 

[rho3_PMAROM,pval3_PMAROM] = corr(S3(:,7), S3(:,3), 'Type', 'Spearman');

%% scatter at T1 and at T3 - PM vs Force
figure; 
scatter(S1(:,7), S1(:,4),'filled','k')
xlabel('Position Matching Error @ T1') 
ylabel('Max Force Flex @ T1') 

[rho1_PMF,pval1_PMF] = corr(S1(:,7), S1(:,4), 'Type', 'Spearman');

figure; 
scatter(S2(:,7), S2(:,4),'filled','k')
xlabel('Position Matching Error @ T2') 
ylabel('Max Force Flex @ T2') 

[rho2_PMF,pval2_PMF] = corr(S2(:,7), S2(:,4), 'Type', 'Spearman');

figure; 
scatter(S3(:,7), S3(:,4),'filled','k')
xlabel('Position Matching Error @ T3') 
ylabel('Max Force Flex @ T3') 

[rho3_PMF,pval3_PMF] = corr(S3(:,7), S3(:,4), 'Type', 'Spearman');

%% scatter at T1 and at T3 - PM vs Vel

figure; 
scatter(S1(:,7), S1(:,5),'filled','k')
xlabel('Position Matching Error @ T1') 
ylabel('Max Velocity Extension @ T1') 
ylim([0 700]) 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210917_PM_Vel_T1','-dpng')

[rho1_PMV,pval1_PMV] = corr(S1(:,7), S1(:,5), 'Type', 'Spearman');

figure; 
scatter(S2(:,7), S2(:,5),'filled','k')
xlabel('Position Matching Error @ T2') 
ylabel('Max Velocity Extension @ T2') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210917_PM_Vel_T2','-dpng')

[rho2_PMV,pval2_PMV] = corr(S2(:,7), S2(:,5), 'Type', 'Spearman');

figure; 
scatter(S3(:,7), S3(:,5),'filled','k')
xlabel('Position Matching Error @ T3') 
ylabel('Max Velocity Extension @ T3') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210917_PM_Vel_T3','-dpng')

[rho3_PMV,pval3_PMV] = corr(S3(:,7), S3(:,5), 'Type', 'Spearman');

%% "Recovery" definition

recoveryPM = S1(:,7)./(S3(:,7)-0); 
recoveryAROM = S3(:,3)./(90-S1(:,3)); 

% figure; 
% scatter(recoveryPM, recoveryAROM,'filled','k')
% xlabel('Recovery Position Matching Error') 
% ylabel('Recovery Active Range of Motion') 



