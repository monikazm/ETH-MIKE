%% extract datat from CSV (cheater) %% 
% created: 08.04.2021

clear 
close all
clc

%% read table %% 

T = readtable('20210408_DataFull.csv'); 

% force flexion 115 
A = table2array(T(:,[1 3 6 115])); 

%% clean-up the table 

% remove subjects that don't have redcap yet (study_id = NaN) 

n = 1; 
withREDCap = []; 
for i = 1:1:length(A(:,3))
    if isnan(A(i,3))
        
    else
        withREDCap(n,:) = A(i,:); 
        n=n+1; 
    end
end

