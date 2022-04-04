%% Compare AROM and FMA at different time points 
% created: 11.08.2021

clear
close all
clc

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR
% FMA = 41; 
% FMAH = 44; 

% ID
% 28 - force flex
% 6 - AROM
% 74 - max vel ext


%% read table %% 

filename1 = 'data/20210811_DataImpaired.csv'; 
columnNrs = 92; % AROM
FMAH = 44; 

T1 = readtable(filename1); 
A = table2array(T1(:,[3 5 FMAH columnNrs]));

M = readtable('data/20210121_metricInfo.csv'); 
ID = 6; 
SRD_motor = table2array(M(ID,7));
MDC = 1; 

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
for i = 1:length(C2(:,3))
    if isnan(C2(i,3))
        t(n) = i; 
        n = n+1; 
    end
end
C2(t,:) = []; 

% change all 3rd into second session 
temp2 = find(C2(:,2) == 3); 
C2(temp2,2) = 2; 


%% Take only first and third measurement

% % remove 2nd measurement (non existant for BBT) 
% C2(find(C2(:,2)==2),:) = [];  
% C2(find(C2(:,2)>3),:) = [];  
% %C2(isnan(C(:,4)),:) = []; 

%% split into two days

% divide into S1 and S2
MOT1 = C2(find(C2(:,2)==1),:); 
MOT2 = C2(find(C2(:,2)==2),:); 

%% clean up and merge

Lia = double(ismember(MOT1(:,1),MOT2(:,1))); 
MOT1(:,1) = Lia.*MOT1(:,1); 
MOT1(MOT1(:,1)==0,:)= [];

% remove S2 (strange result on discharge) 
MOT1(1,:) = []; 
MOT2(1,:) = []; 

%% calculate change

change(:,1) = MOT1(:,1); 
change(:,2) = MOT2(:,3)-MOT1(:,3); 
change(:,3) = MOT2(:,4)-MOT1(:,4); 

change_bySRD(:,1) = change(:,1); 
change_bySRD(:,2) = change(:,2)./MDC; 
change_bySRD(:,3) = change(:,3)./SRD_motor; 

%% plot inclusion
txt = string(MOT1(:,1)');

figure; 
scatter(MOT1(:,3), MOT1(:,4), 'filled');
hold on 
labelpoints(MOT1(:,3), MOT1(:,4), txt)
xlim([-1 15])
% xticks([0 1 2 3])
% ylim([0 27])
xlabel('Fugl-Meyer Hand @ inclusion')
ylabel('Active Range of Motion @ inclusion') 
title('AROM vs FMAH @ T1') 
print('Plots/ScatterPlots/210811_AROM_FMAH_inclusion','-dpng')

%% plot discharge

txt = string(MOT2(:,1)');

figure; 
scatter(MOT2(:,3), MOT2(:,4), 'filled', 'r');
hold on 
labelpoints(MOT2(:,3), MOT2(:,4), txt)
xlim([-1 15])
% xticks([0 1 2 3])
% ylim([0 27])
xlabel('Fugl-Meyer Hand @ discharge')
ylabel('Active Range of Motion @ discharge') 
title('AROM vs FMAH @ T3') 
print('Plots/ScatterPlots/210811_AROM_FMAH_discharge','-dpng')

%% plot change

txt = string(change_bySRD(:,1)');

figure; 
scatter(change_bySRD(:,2), change_bySRD(:,3), 'filled', 'k');
hold on 
labelpoints(change_bySRD(:,2), change_bySRD(:,3), txt)
% xlim([-0.5 2.5])
% xticks([0 1 2 3])
% ylim([5 27])
xlabel('Delta FMAH')
ylabel('Delta by SRD AROM') 
title('Delta AROM by SRD vs delta FMAH') 
print('Plots/ScatterPlots/210811_AROM_FMAH_changebySRD','-dpng')

%% Correlations

[rho1,pval1] = corr(MOT1(:,4), MOT1(:,3), 'Type', 'Spearman');
[rho2,pval2] = corr(MOT2(:,4), MOT2(:,3), 'Type', 'Spearman');
[rho3,pval3] = corr(change_bySRD(:,3), change_bySRD(:,2), 'Type', 'Spearman');
