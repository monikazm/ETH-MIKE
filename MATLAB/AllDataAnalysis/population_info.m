%% description of the population %% 
% created: 12.10.2021
clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 8 - age
% 9 - gender(0-female, 1-male) 
% Handedness - 10 (1-right, 0-left, 2-ambidexterous)  
% Left impaired? - 11 (0-no, 1-yes)
% type of stroke - 17 (1-ischemic, 2-hemorrhagic)

A = table2array(T(:,[3 5 8 9 10 11 17])); 

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

%% count how many sessions for each subject
out = []; 
n = 1; 
%for j = 1:length(C(:,1))
    for i = unique(C(:,1))'
        out(n,1) = max(C(find(C(:,1) == i),2)); 
        n = n+1; 
    end
%end

stay(1) = length(find(out == 2)); 
stay(2) = length(find(out == 3)); 
stay(3) = length(find(out == 4)); 
stay(4) = length(find(out == 5)); 
stay(5) = length(find(out == 6)); 
stay(6) = length(find(out == 7)); 
stay(7) = length(find(out == 8)); 


%% Divide into S1 and S3

n = 1;  
k = 1; 
m = 1; 
for i = 1:length(C(:,1))
        if C(i,2) == 1
            S1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 3
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% S1(1,:) = []; 
% S3(1,:) = []; 

%% descriptive statistics

age(1) = nanmean(S1(:,3)); 
age(2) = nanstd(S1(:,3)); 

females = length(S1(:,4))-sum(S1(:,4)); 

rightHanded = sum(S1(:,5)==1); 

RHS = sum(S1(:,6));

IschemicStroke = sum(S1(:,7)==1); 
HemStroke = length(S1(:,7))-sum(S1(:,7)==1); 

TimeSinceStrokeMean(1) = nanmean(S1(:,8)); 
TimeSinceStrokeMean(2) = nanstd(S1(:,8)); 

%% consider only 38 subjects 

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

TimeSinceStrokeMean(3) = nanmean(S1(:,8)); 
TimeSinceStrokeMean(4) = nanstd(S1(:,8)); 

TimeSinceStrokeMean(5) = min(S1(:,8)); 
TimeSinceStrokeMean(6) = max(S1(:,8)); 

