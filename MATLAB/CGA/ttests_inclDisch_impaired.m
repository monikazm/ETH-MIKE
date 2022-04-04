%% ttests to define if change is significant %% 
% created: 14.09.2021

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

%% Divide into S1 and S2

n = 1;  
k = 1; 
m = 1; 


for j = unique(C(:,1))'
    temp = find(C(:,1)==j); 
    S1(n,:) = C(min(temp),:); 
    S2(n,:) = C(max(temp),:);
    n = n + 1; 
end

S1(1,:) = []; 
S2(1,:) = []; 

% S1(32,:) = []; 
% S2(32,:) = []; 

%% ttests Position Matching

[h1_PM,p1_PM] = ttest(S1(:,7),S2(:,7)); 

%% ttests AROM

[h1_AROM,p1_AROM] = ttest(S1(:,3),S2(:,3));  

%% ttests Force Flex

[h1_Force,p1_Force] = ttest(S1(:,4),S2(:,4));  

%% ttests Vel Ext

[h1_Vel,p1_Vel] = ttest(S1(:,5),S2(:,5)); 

%% ttests kUDT & fMA
 
% [h1_kUDT,p1_kUDT] = ttest(S1(:,8),S2(:,8)); 
% [h1_FMA,p1_FMA] = ttest(S1(:,9),S2(:,9)); 

%% Mean and std

mean_PM_t1 = nanmean(S1(:,7)); 
mean_PM_t2 = nanmean(S2(:,7)); 
std_PM_t1 = nanstd(S1(:,7)); 
std_PM_t2 = nanstd(S2(:,7)); 

mean_AROM_t1 = nanmean(S1(:,3)); 
mean_AROM_t2 = nanmean(S2(:,3)); 
std_AROM_t1 = nanstd(S1(:,3)); 
std_AROM_t2 = nanstd(S2(:,3)); 

mean_Force_t1 = nanmean(S1(:,4)); 
mean_Force_t2 = nanmean(S2(:,4)); 
std_Force_t1 = nanstd(S1(:,4)); 
std_Force_t2 = nanstd(S2(:,4)); 

mean_Vel_t1 = nanmean(S1(:,5)); 
mean_Vel_t2 = nanmean(S2(:,5)); 
std_Vel_t1 = nanstd(S1(:,5)); 
std_Vel_t2 = nanstd(S2(:,5)); 





