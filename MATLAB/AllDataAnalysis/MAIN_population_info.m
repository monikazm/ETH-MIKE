%% description of the population %% 
% created: 04.06.2022
clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 47 - kUDT
% 41 - FM M UL
% 48 - BB imp 
% 49 - BB nonimp
% 50 - barther index tot
% 44 - FMA Hand 
% 61 - MoCA
% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR
% 8 - age

A = table2array(T(:,[3 5 8 9 10 11 17])); 
% subject Age Gender Handedness LeftImpaired TypeOfStroke TSS 

%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,8) = timeSinceStroke; 

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

C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr

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
        elseif C(i,2) == 3 || (C(i,2) == 2 && C(i+1,2) ~= 3) 
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];


%% descriptive statistics

age(1) = nanmean(S1(:,3)); 
age(2) = nanstd(S1(:,3)); 

females = length(S1(:,4))-sum(S1(:,4));
males = length(S1(:,1))-females; 

rightHanded = sum(S1(:,5)==1); 

RHS = sum(S1(:,6));
LHS = length(S1(:,1))-RHS; 

IschemicStroke = sum(S1(:,7)==1); 
HemStroke = length(S1(:,7))-sum(S1(:,7)==1); 

TSS1(1) = nanmean(S1(:,8)); 
TSS1(2) = nanstd(S1(:,8)); 

TSS2(1) = nanmean(S3(:,8)); 
TSS2(2) = nanstd(S3(:,8)); 
