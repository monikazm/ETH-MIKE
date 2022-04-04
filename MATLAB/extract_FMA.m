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
A = table2array(T1(:,[3 5 FMA]));

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

%% Take only first and third measurement

% remove 2nd measurement (non existant for BBT) 
C2(find(C2(:,2)==2),:) = [];  
C2(find(C2(:,2)>3),:) = [];  
%C2(isnan(C(:,4)),:) = []; 

% change all 3rd into second session 
temp2 = find(C2(:,2) == 3); 
C2(temp2,2) = 2; 

%% split into two days

% divide into S1 and S2
FMA1 = C2(find(C2(:,2)==1),:); 
FMA2 = C2(find(C2(:,2)==2),:); 

