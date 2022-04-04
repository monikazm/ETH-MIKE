%% ttests to define if change is significant %% 
% created: 14.10.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 70 SEP N20 amplitude left
% 71 SEP N20 latency left 
% 73 SEP N20 ampl right
% 74 SEP N20 lat right
% 79 MEP N20 amp left
% 80 MEP N20 lat left
% 84 MEP N20 amp right
% 85 MEP N20 lat right
% 11 left impaired? 
% 77 MEP base left
% 78 MEP stim left
% 82 MEP base right
% 83 MEP stim right

columnNrs = [70 71 73 74 79 80 84 85]; 

A = table2array(T(:,columnNrs)); 
A2 = str2double(strrep(A,',','.'));

A3 = table2array(T(:,[5 3 2])); 
A3(:,4:length(A2(1,:))+3) = A2; 

stimuli = table2array(T(:,[78 83]));  
A3 = [A3 stimuli]; 

%% clean-up the table 

% remove subjects that don't have redcap yet

n = 1; 
withREDCap = []; 
for i = 1:1:length(A3(:,1))
    if isnan(A3(i,2))
        
    else
        withREDCap(n,:) = A3(i,:); 
        n=n+1; 
    end

end

C = sortrows(withREDCap,'ascend'); 

% remove those rows where there is only one data point
% n = 1; 
% remove = []; 
% for i=1:max(C(:,1))
%     temp = find(C(:,1)==i); 
%     if length(temp) == 1
%         remove(n) = temp; 
%         n = n+1; 
%     end
% end
% C(remove,:) = []; 

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

% clean up and merge 
% Lia = double(ismember(S1(:,1),S3(:,1))); 
% S1(:,1) = Lia.*S1(:,1); 
% S1(S1(:,1)==0,:)= [];

% S1(1,:) = []; 
% S3(1,:) = []; 

% S1(34:end,:) = []; 
% S3(34:end,:) = []; 

%% SSEP 

% affected
n = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 1
        ssep_lat_aff(n,1) = S1(i,1);
        ssep_lat_aff(n,2) = S1(i,5); 
        ssep_lat_aff(n,3) = S3(i,5); 
        ssep_ampl_aff(n,1) = S1(i,1);
        ssep_ampl_aff(n,2) = S1(i,4); 
        ssep_ampl_aff(n,3) = S3(i,4); 
        n = n+1; 
    elseif S1(i,3) == 0
        ssep_lat_aff(n,1) = S1(i,1);         
        ssep_lat_aff(n,2) = S1(i,7); 
        ssep_lat_aff(n,3) = S3(i,7); 
        ssep_ampl_aff(n,1) = S1(i,1); 
        ssep_ampl_aff(n,2) = S1(i,6); 
        ssep_ampl_aff(n,3) = S3(i,6);
        n = n+1; 
    end
end

% less affected
n = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 0
        ssep_lat_lessaff(n,1) = S1(i,1);
        ssep_lat_lessaff(n,2) = S1(i,5); 
        ssep_lat_lessaff(n,3) = S3(i,5); 
        ssep_ampl_lessaff(n,1) = S1(i,1);
        ssep_ampl_lessaff(n,2) = S1(i,4); 
        ssep_ampl_lessaff(n,3) = S3(i,4); 
        n = n+1; 
    elseif S1(i,3) == 1
        ssep_lat_lessaff(n,1) = S1(i,1); 
        ssep_lat_lessaff(n,2) = S1(i,7); 
        ssep_lat_lessaff(n,3) = S3(i,7);
        ssep_ampl_lessaff(n,1) = S1(i,1); 
        ssep_ampl_lessaff(n,2) = S1(i,6); 
        ssep_ampl_lessaff(n,3) = S3(i,6);         
        n = n+1; 
    end
end


%% MEP

n = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 1
        mep_lat_aff(n,1) = S1(i,1); 
        mep_lat_aff(n,2) = S1(i,9); 
        mep_lat_aff(n,3) = S3(i,9); 
        mep_ampl_aff(n,1) = S1(i,1); 
        mep_ampl_aff(n,2) = S1(i,8); 
        mep_ampl_aff(n,3) = S3(i,8); 
        mep_stim_aff(n,1) = S1(i,1); 
        mep_stim_aff(n,2) = S1(i,12); 
        mep_stim_aff(n,3) = S3(i,12); 
        n = n+1; 
    elseif S1(i,3) == 0
        mep_lat_aff(n,1) = S1(i,1); 
        mep_lat_aff(n,2) = S1(i,11); 
        mep_lat_aff(n,3) = S3(i,11); 
        mep_ampl_aff(n,1) = S1(i,1);
        mep_ampl_aff(n,2) = S1(i,10); 
        mep_ampl_aff(n,3) = S3(i,10);  
        mep_stim_aff(n,1) = S1(i,1); 
        mep_stim_aff(n,2) = S1(i,13); 
        mep_stim_aff(n,3) = S3(i,13); 
        n = n+1; 
    end
end

n = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 0
        mep_lat_lessaff(n,1) = S1(i,1);
        mep_lat_lessaff(n,2) = S1(i,9); 
        mep_lat_lessaff(n,3) = S3(i,9); 
        mep_ampl_lessaff(n,1) = S1(i,1); 
        mep_ampl_lessaff(n,2) = S1(i,8); 
        mep_ampl_lessaff(n,3) = S3(i,8); 
        mep_stim_lessaff(n,1) = S1(i,1); 
        mep_stim_lessaff(n,2) = S1(i,12); 
        mep_stim_lessaff(n,3) = S3(i,12); 
        n = n+1; 
    elseif S1(i,3) == 1
        mep_lat_lessaff(n,1) = S1(i,1);
        mep_lat_lessaff(n,2) = S1(i,11); 
        mep_lat_lessaff(n,3) = S3(i,11); 
        mep_ampl_lessaff(n,1) = S1(i,1);
        mep_ampl_lessaff(n,2) = S1(i,10); 
        mep_ampl_lessaff(n,3) = S3(i,10);   
        mep_stim_lessaff(n,1) = S1(i,1); 
        mep_stim_lessaff(n,2) = S1(i,13); 
        mep_stim_lessaff(n,3) = S3(i,13);
        n = n+1; 
    end
end
