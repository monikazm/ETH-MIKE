%% Compare PM and kUDT 
% created: 11.08.2021

clear
close all
clc

%% read table %% 

filename1 = 'data/20210811_DataImpaired.csv'; 
columnNrs = 122; % Position Matching
BBT = 48; % Box&Block Test

T1 = readtable(filename1); 
A = table2array(T1(:,[3 5 BBT columnNrs]));

M = readtable('data/20210121_metricInfo.csv'); 
ID = 36; 
SRD_sensory = table2array(M(ID,7));
MDC = 5.5; 

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
change_bySRD(:,2) = change(:,2)./MDC; 
change_bySRD(:,3) = change(:,3)./SRD_sensory; 

change_byinitial(:,1) = PM1(:,1); 
change_byinitial(:,2) = change(:,2)./PM1(:,3); 
change_byinitial(:,3) = change(:,3)./PM1(:,4); 

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

Lia = double(ismember(change_byinitial(:,1),PM2_new(:,1))); 
change_byinitial(:,1) = Lia.*change_byinitial(:,1); 
change_byinitial(change_byinitial(:,1)==0,:)= [];

%% remove subjects with BBT < 10

PM1_2 = []; 
for i = 1:length(PM1)
    if PM1(i,3) >= 10 
       PM1_2(i,:) = PM1(i,:); 
    end
end
% Remove zero rows
PM1_2( all(~PM1_2,2), : ) = [];

PM2_2 = []; 
for i = 1:length(PM2_new)
    if PM2_new(i,3) >= 10 
       PM2_2(i,:) = PM2_new(i,:); 
    end
end
% Remove zero rows
PM2_2( all(~PM2_2,2), : ) = [];

change2 = []; 
for i = 1:length(change_byinitial)
    if PM2_new(i,3) >= 10 
       change2(i,:) = change_byinitial(i,:); 
    end
end
% Remove zero rows
change2( all(~change2,2), : ) = [];


%% plot inclusion
txt = string(PM1_2(:,1)');

figure; 
scatter(PM1_2(:,3), PM1_2(:,4), 'filled');
hold on 
labelpoints(PM1_2(:,3), PM1_2(:,4), txt)
%xlim([-5 60])
% xticks([0 1 2 3])
% ylim([0 27])
xlabel('BBT @ inclusion')
ylabel('Position matching error @ inclusion') 
title('PM vs BBT @ T1 - good subjects only') 
print('Plots/ScatterPlots/210811_PM_BBT_inclusion_goodSubjects','-dpng')

%% plot discharge

txt = string(PM2_2(:,1)');

figure; 
scatter(PM2_2(:,3), PM2_2(:,4), 'filled', 'r');
hold on 
labelpoints(PM2_2(:,3), PM2_2(:,4), txt)
%xlim([-5 70])
% xticks([0 1 2 3])
% ylim([0 27])
xlabel('BBT @ discharge')
ylabel('Position matching error @ discharge') 
title('PM vs BBT @ T3 - good subjects only') 
print('Plots/ScatterPlots/210811_PM_BBT_discharge_goodSubjects','-dpng')

%% plot T1 T3

txt = string(PM2_2(:,1)');

figure; 
scatter(PM2_2(:,3), PM1_2(:,4), 'filled', 'k');
hold on 
labelpoints(PM2_2(:,3), PM1_2(:,4), txt)
%xlim([-5 70])
% xticks([0 1 2 3])
% ylim([0 27])
xlabel('BBT @ discharge')
ylabel('Position matching error @ inclusion') 
title('PM @ T1 vs BBT @ T3 - good subjects only') 
print('Plots/ScatterPlots/210811_PM_BBT_T1T3_goodSubjects','-dpng')


%% plot T1 vs change by initial 

txt = string(change2(:,1)');

figure; 
scatter(change2(:,2), PM1_2(:,4), 'filled', 'k');
hold on 
labelpoints(change2(:,2), PM1_2(:,4), txt)
%xlim([-5 70])
% xticks([0 1 2 3])
% ylim([0 27])
xlabel('delta BBT by initial BBT')
ylabel('Position matching error @ inclusion') 
title('PM @ T1 vs delata BBT by initial value - good subjects only') 
print('Plots/ScatterPlots/210817_PM_BBT_T1vschange_goodSubjects','-dpng')


%% plot change by initial 

txt = string(change2(:,1)');

figure; 
scatter(change2(:,2), change2(:,3), 'filled', 'k');
hold on 
labelpoints(change2(:,2), change2(:,3), txt)
%xlim([-5 70])
% xticks([0 1 2 3])
% ylim([0 27])
xlabel('delta BBT by initial BBT')
ylabel('delta Position matching error by initial') 
title('PM vs BBT delta by initial value - good subjects only') 
print('Plots/ScatterPlots/210817_PM_BBT_changebyinitial_goodSubjects','-dpng')

%% Correlations

[rho1,pval1] = corr(PM1_2(:,4), PM1_2(:,3), 'Type', 'Spearman');
[rho2,pval2] = corr(PM2_2(:,4), PM2_2(:,3), 'Type', 'Spearman');
[rho3,pval3] = corr(PM1_2(:,4), PM2_2(:,3), 'Type', 'Spearman');
[rho4,pval4] = corr(change2(:,2), PM1_2(:,4), 'Type', 'Spearman');
[rho5,pval5] = corr(change2(:,2), change2(:,3), 'Type', 'Spearman');
