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

A = table2array(T(:,[3 5 47 41 48 61 122 114 92 160 8])); 
% subject session kUDT FMA BBT MoCA PM Force ROM Vel Age TSS

%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,12) = timeSinceStroke; 

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
withREDCap2(:,10) = withREDCap(:,10);
withREDCap2(:,11) = withREDCap(:,11);
withREDCap2(:,12) = withREDCap(:,12);

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

%% Divide into S1 and S3

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
        elseif C(i,2) == 3 || (C(i,2) == 2 && C(i+1,2) ~= 3) 
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
% Lia = double(ismember(S1(:,1),S3(:,1))); 
% S1(:,1) = Lia.*S1(:,1); 
% S1(S1(:,1)==0,:)= [];
% 
% S3(1,7) = 14.5926361100000; 
% S3(33,4) = S1(33,4); 
% S3(33,5) = S1(33,5); 
% S3(33,6) = S1(33,6); 

%% count how many sessions for each subject
% out = []; 
% n = 1; 
% %for j = 1:length(C(:,1))
%     for i = unique(C(:,1))'
%         out(n,1) = max(C(find(C(:,1) == i),2)); 
%         n = n+1; 
%     end
% %end
% 
% stay(1) = length(find(out == 2)); 
% stay(2) = length(find(out == 3)); 
% stay(3) = length(find(out == 4)); 
% stay(4) = length(find(out == 5)); 
% stay(5) = length(find(out == 6)); 
% stay(6) = length(find(out == 7)); 
% stay(7) = length(find(out == 8)); 

%% descriptive statistics

age(1) = nanmean(S1(:,11)); 
age(2) = nanstd(S1(:,11)); 

females = length(S1(:,4))-sum(S1(:,4));
males = length(S1(:,1))-females; 

rightHanded = sum(S1(:,5)==1); 

RHS = sum(S1(:,6));
LHS = length(S1(:,1))-RHS; 

IschemicStroke = sum(S1(:,7)==1); 
HemStroke = length(S1(:,7))-sum(S1(:,7)==1); 

TimeSinceStrokeMean(1) = nanmean(S1(:,8)); 
TimeSinceStrokeMean(2) = nanstd(S1(:,8)); 

%% consider only 38 subjects 

% clean up and merge 
% Lia = double(ismember(S1(:,1),S3(:,1))); 
% S1(:,1) = Lia.*S1(:,1); 
% S1(S1(:,1)==0,:)= [];

% TimeSinceStrokeMean(3) = nanmean(S1(:,8)); 
% TimeSinceStrokeMean(4) = nanstd(S1(:,8)); 
% 
% TimeSinceStrokeMean(5) = min(S1(:,8)); 
% TimeSinceStrokeMean(6) = max(S1(:,8)); 

