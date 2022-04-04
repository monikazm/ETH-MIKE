%% zscore calculation %%  
% created: 22.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

%T = readtable('data/20210914_DataImpaired.csv'); 
T = readtable('data/20211013_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR

A = table2array(T(:,[3 5 92 114 160 127 122 47 41])); 

% Read the estimates from control analysis
F = load('P:\RELab\Research_Projects\ETH MIKE\Monika Zbytniewska\MATLAB\Control Study\Force\Results\Final Results\LME\ForceTask_Estimates_AllTrials.mat'); 
PM = load('P:\RELab\Research_Projects\ETH MIKE\Monika Zbytniewska\MATLAB\Control Study\Position Matching\Results\LME\Estimates_and_NewOM.mat'); 


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

S3(1,7) = S2(1,7); 
S2(13,7) = 20;  

%% change to zscore 

Prop.S1 = (PM.zscoremean.AE-S1(:,7))./PM.zscorestd.AE; 
temp1 = min(Prop.S1); 
Prop.S1 = Prop.S1 - temp1; 
Prop.S3 = (PM.zscoremean.AE-S3(:,7))./PM.zscorestd.AE; 
temp2 = min(Prop.S3); 
Prop.S3 = Prop.S3 - temp1; 
temp3 = min([temp1;temp2]); 
Prop.Change = Prop.S3 - Prop.S1; 
Prop.Recovery = (Prop.S3./((max(Prop.S3))-Prop.S1))*10; 

Prop.Recovery2 = (S3(:,7)./(S1(:,7)))*100; 

Prop.Recovery3 = ((S1(:,7)-S3(:,7))./S3(:,7))*100; 

Prop.Recovery4 = ((S1(:,7)-S3(:,7))./S1(:,7)); 

Force.S1 = (S1(:,4)-F.zscoremean.flex)./F.zscorestd.flex; 
Force.S3 = (S3(:,4)-F.zscoremean.flex)./F.zscorestd.flex; 
Force.Change = Force.S3 - Force.S1; 
Force.Recovery = (Force.S3./(1.8-Force.S1))*100; 

Force.Recovery2 = (S3(:,4)./(54-S1(:,4)))*100; 

Force.Recovery3 = ((S3(:,4)-S1(:,4))./S3(:,4))*100; 

Force.Recovery4 = ((S3(:,4)-S1(:,4))./S1(:,4)); 

figure; 
scatter(Prop.Recovery4,Force.Recovery4, 'filled')

