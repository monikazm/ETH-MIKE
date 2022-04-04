%% Compare PM and kUDT 
% created: 11.08.2021

clear
close all
clc

%% read table %% 

filename1 = 'data/20210811_DataImpaired.csv'; 
columnNrs = 122; % Position Matching
kUDT = 47; 

T1 = readtable(filename1); 
A = table2array(T1(:,[3 5 kUDT columnNrs]));

M = readtable('data/20210121_metricInfo.csv'); 
ID = 36; 
SRD_sensory = table2array(M(ID,7));

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

C2 = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: left hand? 
% rest: what I want to plot as y-axis - both left and right

% remove those rows where there is only one data point
n = 1; 
remove = []; 
temp = []; 
for i=1:max(C2(:,1))
    temp = find(C2(:,1)==i); 
    if length(temp) == 1
        remove(n) = temp; 
        n = n+1; 
    end
end
C2(remove,:) = []; 

% remove all rows for which clinical data doesn't exist 
n = 1; 
t = []; 
for i = 1:length(C2(:,4))
    if isnan(C2(i,4)) && isnan(C2(i,5))
        t(n) = i; 
        n = n+1; 
    end
end
C2(t,:) = []; 

%% Take only first and third measurement

% remove 2nd measurement (non existant for BBT) 
C2(find(C2(:,2)==2),:) = [];  
C2(find(C2(:,2)>3),:) = [];  
%C2(isnan(C(:,4)),:) = []; 

%% split into two days

% divide into S1 and S2
PM1 = C2(find(C2(:,2)==1),:); 
PM2 = C2(find(C2(:,2)==3),:); 

%% clean up and merge

Lia = double(ismember(PM1(:,1),PM2(:,1))); 
PM1(:,1) = Lia.*PM1(:,1); 
PM1(PM1(:,1)==0,:)= [];

% remove S2 (strange result on discharge) 
PM1(1,:) = []; 
PM2(1,:) = []; 

%% calculate change

change(:,1) = PM1(:,1); 
change(:,2) = PM2(:,3)-PM1(:,3); 
change(:,3) = PM1(:,4)-PM2(:,4); 

change_bySRD(:,1) = change(:,1); 
change_bySRD(:,2) = change(:,2); 
change_bySRD(:,3) = change(:,3)./SRD_sensory; 

%% remove NaNs for correlations

PM2_new = []; 
for i = 1:length(PM2)
    if isnan(PM2(i,:)) == 0 
       PM2_new(i,:) = PM2(i,:); 
    end
end
% Remove zero rows
PM2_new( all(~PM2_new,2), : ) = [];

Lia = double(ismember(PM1(:,1),PM2_new(:,1))); 
PM1(:,1) = Lia.*PM1(:,1); 
PM1(PM1(:,1)==0,:)= [];

Lia = double(ismember(change_bySRD(:,1),PM2_new(:,1))); 
change_bySRD(:,1) = Lia.*change_bySRD(:,1); 
change_bySRD(change_bySRD(:,1)==0,:)= [];

%% plot inclusion
txt = string(PM1(:,1)');

figure; 
scatter(PM1(:,3), PM1(:,4), 'filled');
hold on 
labelpoints(PM1(:,3), PM1(:,4), txt)
xlim([-0.5 3.5])
xticks([0 1 2 3])
ylim([0 27])
xlabel('kUDT @ inclusion')
ylabel('Position matching error @ inclusion') 
title('PM vs kUDT @ T1') 
print('Plots/ScatterPlots/210811_PM_kUDT_inclusion','-dpng')

%% plot discharge

txt = string(PM2_new(:,1)');

figure; 
scatter(PM2_new(:,3), PM2_new(:,4), 'filled', 'r');
hold on 
labelpoints(PM2_new(:,3), PM2_new(:,4), txt)
xlim([-0.5 3.5])
xticks([0 1 2 3])
ylim([0 27])
xlabel('kUDT @ discharge')
ylabel('Position matching error @ discharge') 
title('PM vs kUDT @ T3') 
print('Plots/ScatterPlots/210811_PM_kUDT_discharge','-dpng')

%% plot change

txt = string(change_bySRD(:,1)');

figure; 
scatter(change_bySRD(:,2), change_bySRD(:,3), 'filled', 'k');
hold on 
labelpoints(change_bySRD(:,2), change_bySRD(:,3), txt)
xlim([-0.5 2.5])
% xticks([0 1 2 3])
% ylim([5 27])
xlabel('Delta kUDT')
ylabel('Delta by SRD Position matching error') 
title('Delta PM by SRD vs delta kUDT') 
print('Plots/ScatterPlots/210811_PM_kUDT_changebySRD','-dpng')



%% Correlations

[rho1,pval1] = corr(PM1(:,4), PM1(:,3), 'Type', 'Spearman');
[rho2,pval2] = corr(PM2_new(:,4), PM2_new(:,3), 'Type', 'Spearman');
[rho3,pval3] = corr(change_bySRD(:,3), change_bySRD(:,2), 'Type', 'Spearman');
