%% Compare PM and neurophysiology categorized 
% created: 05.05.2021

clear
close all
clc

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext

%% read table %% 

filename1 = 'data/20210517_DataImpaired.csv'; 
columnNrs = 92; % Position Matching
FMA = 41; 
FMAH = 44; 

T1 = readtable(filename1); 
A = table2array(T1(:,[3 5 FMA columnNrs FMAH]));

load('results/MEP_ampl'); 

% 28 - force flex
% 6 - AROM
% 74 - max vel ext

M = readtable('data/20210121_metricInfo.csv'); 
ID = 6; 
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
withREDCap2(:,5) = withREDCap(:,5); 

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

%% make sure C2 matches with C

Lia = double(ismember(C2(:,1),C(:,1))); 
C2(:,1) = Lia.*C2(:,1); 
C2(C2(:,1)==0,:)= [];
% PM1(:,2) = []; 
% PM2(:,2) = []; 

% change all 3rd into second session 
temp2 = find(C2(:,2) == 3); 
C2(temp2,2) = 2; 

%% split into two days

% divide into S1 and S2
PM1 = C2(find(C2(:,2)==1),:); 
PM2 = C2(find(C2(:,2)==2),:); 

MEP1 = C(find(C(:,2)==1),:); 
MEP2 = C(find(C(:,2)==2),:); 


%% clean up and merge - inclusion 
MEP1(:,2) = []; 
PM1(:,2) = []; 
Lia = double(ismember(PM1(:,1),MEP1(:,1))); 
PM1(:,1) = Lia.*PM1(:,1); 
PM1(PM1(:,1)==0,:)= [];

S1 = [MEP1 PM1(:,2) PM1(:,3) PM1(:,4)]; 

% change all 3rd into second session 
temp3 = find(S1(:,5) == 3); 
S1(temp3,5) = 2; 

%% clean up and merge - discharge
MEP2(:,2) = []; 
PM2(:,2) = []; 
Lia2 = double(ismember(PM2(:,1),MEP2(:,1))); 
PM2(:,1) = Lia2.*PM2(:,1); 
PM2(PM2(:,1)==0,:)= [];

Lia3 = double(ismember(MEP2(:,1), PM2(:,1))); 
MEP2(:,1) = Lia3.*MEP2(:,1); 
MEP2(MEP2(:,1)==0,:)= [];

S2 = [MEP2 PM2(:,2) PM2(:,3) PM2(:,4)]; 
S2(1,:) = []; 

% change 3 into 2 in SEP interpretation 
temp4 = find(S2(:,5) == 3); 
S2(temp4,5) = 2; 

%% plot inclusion

txt = string(S1(:,1)');

figure; 
scatter(S1(:,5), S1(:,7), 'filled');
hold on 
labelpoints(S1(:,5), S1(:,7), txt)
xlim([-0.5 2.5])
xticks([0 1 2])
xticklabels({'absent', 'impaired', 'normal'})
xlabel('MEP amplitude @ inclusion') 
ylabel('AROM (deg) @ inclusion') 
print('Plots/ScatterPlots/210518_MEPampl_AROM_inclusion','-dpng')

% spearman correlation 
[rho,pval] = corr(S1(:,5), S1(:,7), 'Type', 'Spearman');

% correlation with FMA
figure; 
scatter(S1(:,5), S1(:,6), 'filled');
xlim([-0.5 2.5])
xticks([0 1 2])
xticklabels({'absent', 'impaired', 'normal'})
xlabel('MEP amplitude @ inclusion') 
ylabel('FMA @ inclusion') 
print('Plots/ScatterPlots/210518_MEPampl_FMA_inclusion','-dpng')

% spearman correlation 
[rho2,pval2] = corr(S1(:,5), S1(:,6), 'Type', 'Spearman');

figure; 
%txt = string(S1(:,1)');
scatter(S1(:,6), S1(:,7), 'filled');
%hold on 
%labelpoints(S1(:,5), S1(:,6), txt)
%xlim([-0.5 3.5])
%xticks([0 1 2 3])
%ylim([0 26])
%xticklabels({'absent', 'impaired', 'normal'})
xlabel('FMA @ inclusion')
ylabel('AROM @ inclusion') 
print('Plots/ScatterPlots/210518_AROM_FMA_inclusion','-dpng')

% spearman correlation 
[rho3,pval3] = corr(S1(:,6), S1(:,7), 'Type', 'Spearman');

%% plot discharge

txt = string(S2(:,1)');

figure; 
scatter(S2(:,5), S2(:,7), 'filled');
hold on 
labelpoints(S2(:,5), S2(:,7), txt)
xlim([-0.5 2.5])
xticks([0 1 2])
xticklabels({'absent', 'impaired', 'normal'})
xlabel('MEP amplitude @ discharge') 
ylabel('AROM (deg) @ discharge') 
print('Plots/ScatterPlots/210518_MEPampl_AROM_discharge','-dpng')

%% quantify the change

% merge s1 and s2
Lia4 = double(ismember(S1(:,1),S2(:,1))); 
S1(:,1) = Lia4.*S1(:,1); 
S1(S1(:,1)==0,:)= [];
% merge s1 and s2
Lia5 = double(ismember(S2(:,1),S1(:,1))); 
S2(:,1) = Lia5.*S2(:,1); 
S2(S2(:,1)==0,:)= [];

change(:,1) = S2(:,5) - S1(:,5); 
change(:,2) = S2(:,7) - S1(:,7); 
change(:,3) = change(:,2)./SRD_motor; 
change(:,4) = S2(:,6) - S1(:,6); 
change(9,1) = 0; 
change(:,5) = S2(:,8) - S1(:,8); 

figure; 
scatter(change(:,1), change(:,3), 'filled');
hold on 
labelpoints(change(:,1), change(:,3), txt)
%xlim([-0.5 2.5])
% xticks([0 1 2])
% xticklabels({'absent', 'impaired', 'normal'})
xlabel('MEP amplitude change') 
ylabel('AROM change / SRD')
xlim([-0.5 1.5])
print('Plots/ScatterPlots/210518_MEPampl_AROM_change','-dpng')

figure; 
scatter(change(:,1), change(:,4), 'filled');
hold on 
labelpoints(change(:,1), change(:,4), txt)
%xlim([-0.5 2.5])
% xticks([0 1 2])
% xticklabels({'absent', 'impaired', 'normal'})
xticks([0 1])
xticklabels({'no change', 'change'})
xlabel('MEP amplitude change') 
ylabel('FMA change')
xlim([-0.5 1.5])
print('Plots/ScatterPlots/210518_MEPampl_FMA_change','-dpng')

figure; 
scatter(change(:,4), change(:,3), 'filled');
hold on 
labelpoints(change(:,4), change(:,3), txt)
%xlim([-0.5 2.5])
% xticks([0 1 2])
% xticklabels({'absent', 'impaired', 'normal'})
%xticks([0 1])
%xticklabels({'no change', 'change'})
xlabel('FMA change') 
ylabel('AROM change / SRD')
xlim([-0.5 12])
print('Plots/ScatterPlots/210518_AROM_FMA_change','-dpng')

figure; 
scatter(change(:,5), change(:,3), 'filled');
hold on 
labelpoints(change(:,5), change(:,3), txt)
%xlim([-0.5 2.5])
% xticks([0 1 2])
% xticklabels({'absent', 'impaired', 'normal'})
%xticks([0 1])
%xticklabels({'no change', 'change'})
xlabel('FMA Hand change') 
ylabel('AROM change / SRD')
xlim([-0.5 9.5])
print('Plots/ScatterPlots/210518_AROM_FMAH_change','-dpng')

