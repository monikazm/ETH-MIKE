%% Plot proprioception (PM) at baseline vs change in BBT %% 
% created: 04.05.2021

% H3: sensorimotor recovery & proprioception 

clear 
clc
close all

% 41 - FM
% 44 - FM hand
% 46 - FM sensory 
% 47 - kUDT

%% read from CSV

filename1 = 'data/20210517_DataImpaired.csv'; 
PM = 122; % Position Matching
Smooth = 127; % Trajectory following smoothness 

T1 = readtable(filename1); 
A = table2array(T1(:,[3 5 PM]));
B = table2array(T1(:,[3 5 Smooth]));

%% Position matching at baseline 

% remove subjects that don't have redcap
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

C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: what I want to plot as y-axis

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

% take only the first session (to plot baseline scores) 
PMImp = C(find(C(:,2)==1),:); 
PMImp(:,2) = []; 

%% Smoothness

% remove subjects that don't have redcap
n = 1; 
withREDCap = []; 
for i = 1:1:length(B(:,1))
    if isnan(B(i,2))
        
    else
        withREDCap(n,:) = B(i,:); 
        n=n+1; 
    end

end

withREDCap2(:,1) = withREDCap(:,2); 
withREDCap2(:,2) = withREDCap(:,1); 
withREDCap2(:,3) = withREDCap(:,3); 
C = []; 
C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: what I want to plot as y-axis

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

% remove 2nd measurement (non existant for BBT) 
C(find(C(:,2)==2),:) = [];  
C(find(C(:,2)>3),:) = [];  
C(isnan(C(:,3)),:) = []; 

% divide into S1 and S2
SM1 = C(find(C(:,2)==1),:); 
SM2 = C(find(C(:,2)==3),:); 


%% scatter 

figure; 
scatter(PMImp(:,2), SM1(:,3), 'filled'); 
xlabel('Position Matching Absolute Error @ baseline') 
ylabel('Tracking Smoothness MAPR @ inclusion') 
print('Plots/ScatterPlots/210521_PMbase_SmoothnessInclusion','-dpng')

% spearman correlation 
[rho1,pval1] = corr(PMImp(:,2), SM1(:,3), 'Type', 'Spearman');

% merge into one 
Lia = double(ismember(PMImp(:,1),SM2(:,1))); 
PMImp(:,1) = Lia.*PMImp(:,1); 
PMImp(PMImp(:,1)==0,:)= [];

figure; 
scatter(PMImp(:,2), SM2(:,3), 'filled'); 
xlabel('Position Matching Absolute Error @ baseline') 
ylabel('Tracking Smoothness MAPR @ discharge') 
print('Plots/ScatterPlots/210521_PMbase_SmoothnessDischarge','-dpng')

% spearman correlation 
[rho2,pval2] = corr(PMImp(:,2), SM2(:,3), 'Type', 'Spearman');

% merge into one 
Lia = double(ismember(SM1(:,1),SM2(:,1))); 
SM1(:,1) = Lia.*SM1(:,1); 
SM1(SM1(:,1)==0,:)= [];

figure; 
scatter(PMImp(:,2), SM1(:,3) - SM2(:,3), 'filled'); 
xlabel('Position Matching Absolute Error @ baseline') 
ylabel('Change in Tracking Smoothness MAPR') 
print('Plots/ScatterPlots/210521_PMbase_SmoothnessChange','-dpng')

% spearman correlation 
[rho3,pval3] = corr(PMImp(:,2), SM1(:,3) - SM2(:,3), 'Type', 'Spearman');







