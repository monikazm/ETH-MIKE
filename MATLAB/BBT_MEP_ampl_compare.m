%% Compare PM and neurophysiology categorized 
% created: 05.05.2021

clear
close all
clc

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 48 - Box&Block Test

%% read table %% 

filename1 = 'data/20210517_DataImpaired.csv'; 
BBT = 48; 

T1 = readtable(filename1); 
A = table2array(T1(:,[3 5 BBT]));

load('results/MEP_ampl'); 

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
%withREDCap2(:,4) = withREDCap(:,4); 

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
BBT1 = C2(find(C2(:,2)==1),:); 
BBT2 = C2(find(C2(:,2)==2),:); 

MEP1 = C(find(C(:,2)==1),:); 
MEP2 = C(find(C(:,2)==2),:); 


%% clean up and merge - inclusion 
MEP1(:,2) = []; 
BBT1(:,2) = []; 
Lia = double(ismember(BBT1(:,1),MEP1(:,1))); 
BBT1(:,1) = Lia.*BBT1(:,1); 
BBT1(BBT1(:,1)==0,:)= [];

S1 = [BBT1(:,1) BBT1(:,2) MEP1(:,5)]; 

% change all 3rd into second session 
% temp3 = find(S1(:,5) == 3); 
% S1(temp3,5) = 2; 

%% clean up and merge - discharge

MEP2(:,2) = []; 
BBT2(:,2) = []; 
Lia = double(ismember(MEP2(:,1),BBT2(:,1))); 
MEP2(:,1) = Lia.*MEP2(:,1); 
MEP2(MEP2(:,1)==0,:)= [];

Lia = double(ismember(BBT2(:,1),MEP2(:,1))); 
BBT2(:,1) = Lia.*BBT2(:,1); 
BBT2(BBT2(:,1)==0,:)= [];

S2 = [BBT2(:,1) BBT2(:,2) MEP2(:,5)];

%% plot inclusion

txt = string(S1(:,1)');

figure; 
scatter(S1(:,3), S1(:,2), 'filled');
hold on 
labelpoints(S1(:,3), S1(:,2), txt)
xlim([-0.5 2.5])
xticks([0 1 2])
xticklabels({'absent', 'impaired', 'normal'})
xlabel('MEP amplitude @ inclusion') 
ylabel('BBT @ inclusion') 
print('Plots/ScatterPlots/210518_MEPampl_BBT_inclusion','-dpng')

% spearman correlation 
[rho,pval] = corr(S1(:,3), S1(:,2), 'Type', 'Spearman');

%% plot discharge

figure; 
scatter(S2(:,3), S2(:,2), 'filled');
xlim([-0.5 2.5])
xticks([0 1 2])
xticklabels({'absent', 'impaired', 'normal'})
xlabel('MEP amplitude @ discharge') 
ylabel('BBT @ discharge') 
print('Plots/ScatterPlots/210518_MEPampl_BBT_discharge','-dpng')
[rho2,pval2] = corr(S2(1:13,3), S2(1:13,2), 'Type', 'Spearman');
