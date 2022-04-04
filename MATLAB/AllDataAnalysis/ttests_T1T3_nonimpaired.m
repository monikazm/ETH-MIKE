%% ttests to define if change is significant %% 
% also calculate mean & std for each metric 
% nonimpaired side robotic tests
% created: 12.10.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataNonImpaired.csv'); 

Imp = open('SubjectsT1T3Analysis.mat'); 

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

%% Divide into S1 and S3

n = 1;  
k = 1; 
m = 1; 
for i = 1:length(C(:,1))
        if C(i,2) == 1
            S1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 2
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

%% Remove some subjects 
  
% clean up and merge 
Lia = double(ismember(S1(:,1),Imp.S1(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

Lia = double(ismember(S3(:,1),Imp.S1(:,1))); 
S3(:,1) = Lia.*S3(:,1); 
S3(S3(:,1)==0,:)= [];


%% ttests Position Matching

[h_PM,p_PM] = ttest(S1(:,7),S3(:,7)); 

%% ttests AROM

[h_AROM,p_AROM] = ttest(S1(:,3),S3(:,3)); 

%% ttests Force Flex

[h_Force,p_Force] = ttest(S1(:,4),S3(:,4)); 

%% ttests Vel Ext

[h_Vel,p_Vel] = ttest(S1(:,5),S3(:,5)); 

%% Mean and std

mean_PM_t1 = nanmean(S1(:,7)); 
mean_PM_t3 = nanmean(S3(:,7)); 
std_PM_t1 = nanstd(S1(:,7)); 
std_PM_t3 = nanstd(S3(:,7)); 

mean_AROM_t1 = nanmean(S1(:,3)); 
mean_AROM_t3 = nanmean(S3(:,3)); 
std_AROM_t1 = nanstd(S1(:,3)); 
std_AROM_t3 = nanstd(S3(:,3)); 

mean_Force_t1 = nanmean(S1(:,4)); 
mean_Force_t3 = nanmean(S3(:,4)); 
std_Force_t1 = nanstd(S1(:,4)); 
std_Force_t3 = nanstd(S3(:,4)); 

mean_Vel_t1 = nanmean(S1(:,5)); 
mean_Vel_t3 = nanmean(S3(:,5)); 
std_Vel_t1 = nanstd(S1(:,5)); 
std_Vel_t3 = nanstd(S3(:,5)); 


%% Plot

% k = 1; 
% figure; 
% for i = 1:length(S1(:,3))
%     if isnan(S3(i,3))
%     else
%     temp1(k,:) = [S1(i,7) S3(i,7)]; 
%     F = plot(1:2, [S1(i,7) S3(i,7)],'-o'); 
%     F.Color = 'k'; 
%     F.MarkerFaceColor = 'k'; 
%     hold on 
%     k = k+1; 
%     end
% end
% ylabel('Position Matching Absolute Error (deg)') 
% hold on 
% yline(10.63, '--k'); 
% xlim([0.75 2.25]) 
% ylim([2 27]) 
% xticks([1 2])
% xticklabels({'T1','T3'})
% xlabel('Measurement Session Nr') 
% set(gca,'FontSize',12)
% set(gca,'YDir','reverse')
% print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/211011_PM','-dpng')
% 
% 
% 
