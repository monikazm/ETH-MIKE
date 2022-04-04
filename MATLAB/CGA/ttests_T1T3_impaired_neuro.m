%% ttests to define if change is significant %% neurophysiology
% created: 18.09.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20210914_DataImpaired.csv'); 

% 70 SEP N20 amplitude left
% 71 SEP N20 latency left 
% 73 SEP N20 ampl right
% 74 SEP N20 lat right
% 79 MEP N20 amp left
% 80 MEP N20 lat left
% 84 MEP N20 amp right
% 85 MEP N20 lat right
% 11 left impaired? 

columnNrs = [70 71 73 74 79 80 84 85]; 

A = table2array(T(:,columnNrs)); 
A2 = str2double(strrep(A,',','.'));

A3 = table2array(T(:,[5 3 2])); 
A3(:,4:length(A2(1,:))+3) = A2; 

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
        elseif C(i,2) == 3
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

S1(1,:) = []; 
S3(1,:) = []; 

S1(34:end,:) = []; 
S3(34:end,:) = []; 

%% SSEP

n = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 1
        ssep_lat_aff(n,1) = S1(i,5); 
        ssep_lat_aff(n,2) = S3(i,5); 
        ssep_lat_aff(n,3) = S1(i,1);
        ssep_ampl_aff(n,1) = S1(i,4); 
        ssep_ampl_aff(n,2) = S3(i,4); 
        ssep_ampl_aff(n,3) = S1(i,1);
        n = n+1; 
    elseif S1(i,3) == 0
        ssep_lat_aff(n,1) = S1(i,7); 
        ssep_lat_aff(n,2) = S3(i,7); 
        ssep_lat_aff(n,3) = S1(i,1); 
        ssep_ampl_aff(n,1) = S1(i,6); 
        ssep_ampl_aff(n,2) = S3(i,6);
        ssep_ampl_aff(n,3) = S1(i,1); 
        n = n+1; 
    end
end

% delete where nan on one 
k = 1; 
for i = 1:length(ssep_lat_aff(:,1))
    if isnan(ssep_lat_aff(i,1)) || isnan(ssep_lat_aff(i,2)) 
        
    else
        ssep.lat_aff(k,1) = ssep_lat_aff(i,1); 
        ssep.lat_aff(k,2) = ssep_lat_aff(i,2); 
        ssep.amp_aff(k,1) = ssep_ampl_aff(i,1); 
        ssep.amp_aff(k,2) = ssep_ampl_aff(i,2); 
        k = k + 1; 
    end
end

ssep.lat_mean_aff(1) = mean(ssep.lat_aff(:,1)); 
ssep.lat_mean_aff(2) = mean(ssep.lat_aff(:,2)); 
ssep.lat_std_aff(1) = std(ssep.lat_aff(:,1)); 
ssep.lat_std_aff(2) = std(ssep.lat_aff(:,2)); 
ssep.amp_mean_aff(1) = mean(ssep.amp_aff(:,1)); 
ssep.amp_mean_aff(2) = mean(ssep.amp_aff(:,2)); 
ssep.amp_std_aff(1) = std(ssep.amp_aff(:,1)); 
ssep.amp_std_aff(2) = std(ssep.amp_aff(:,2)); 


[h1_SSEP_AMP,p1_SSEP_AMP] = ttest(ssep.amp_aff(:,1),ssep.amp_aff(:,2)); 
[h1_SSEP_LAT,p1_SSEP_LAT] = ttest(ssep.lat_aff(:,1),ssep.lat_aff(:,2)); 

%% MEP

n = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 1
        mep_lat_aff(n,1) = S1(i,9); 
        mep_lat_aff(n,2) = S3(i,9); 
        mep_ampl_aff(n,1) = S1(i,8); 
        mep_ampl_aff(n,2) = S3(i,8); 
        n = n+1; 
    elseif S1(i,3) == 0
        mep_lat_aff(n,1) = S1(i,11); 
        mep_lat_aff(n,2) = S3(i,11); 
        mep_ampl_aff(n,1) = S1(i,10); 
        mep_ampl_aff(n,2) = S3(i,10);         
        n = n+1; 
    end
end

% delete where nan on one 
k = 1; 
for i = 1:length(mep_lat_aff(:,1))
    if isnan(mep_lat_aff(i,1)) || isnan(mep_lat_aff(i,2)) 
        
    else
        mep.lat_aff(k,1) = mep_lat_aff(i,1); 
        mep.lat_aff(k,2) = mep_lat_aff(i,2); 
        mep.amp_aff(k,1) = mep_ampl_aff(i,1); 
        mep.amp_aff(k,2) = mep_ampl_aff(i,2); 
        k = k + 1; 
    end
end

mep.lat_mean_aff(1) = mean(mep.lat_aff(:,1)); 
mep.lat_mean_aff(2) = mean(mep.lat_aff(:,2)); 
mep.lat_std_aff(1) = std(mep.lat_aff(:,1)); 
mep.lat_std_aff(2) = std(mep.lat_aff(:,2)); 
mep.amp_mean_aff(1) = mean(mep.amp_aff(:,1)); 
mep.amp_mean_aff(2) = mean(mep.amp_aff(:,2)); 
mep.amp_std_aff(1) = std(mep.amp_aff(:,1)); 
mep.amp_std_aff(2) = std(mep.amp_aff(:,2)); 


[h1_mep_AMP,p1_mep_AMP] = ttest(mep.amp_aff(:,1),mep.amp_aff(:,2)); 
[h1_mep_LAT,p1_mep_LAT] = ttest(mep.lat_aff(:,1),mep.lat_aff(:,2)); 

%% SSEP less affected

n = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 0
        ssep_lat_lessaff(n,1) = S1(i,5); 
        ssep_lat_lessaff(n,2) = S3(i,5); 
        ssep_ampl_lessaff(n,1) = S1(i,4); 
        ssep_ampl_lessaff(n,2) = S3(i,4); 
        n = n+1; 
    elseif S1(i,3) == 1
        ssep_lat_lessaff(n,1) = S1(i,7); 
        ssep_lat_lessaff(n,2) = S3(i,7); 
        ssep_ampl_lessaff(n,1) = S1(i,6); 
        ssep_ampl_lessaff(n,2) = S3(i,6);         
        n = n+1; 
    end
end

% delete where nan on one 
k = 1; 
for i = 1:length(ssep_lat_lessaff(:,1))
    if isnan(ssep_lat_lessaff(i,1)) || isnan(ssep_lat_lessaff(i,2)) 
        
    else
        ssep.lat_lessaff(k,1) = ssep_lat_lessaff(i,1); 
        ssep.lat_lessaff(k,2) = ssep_lat_lessaff(i,2); 
        ssep.amp_lessaff(k,1) = ssep_ampl_lessaff(i,1); 
        ssep.amp_lessaff(k,2) = ssep_ampl_lessaff(i,2); 
        k = k + 1; 
    end
end

ssep.lat_mean_lessaff(1) = mean(ssep.lat_lessaff(:,1)); 
ssep.lat_mean_lessaff(2) = mean(ssep.lat_lessaff(:,2)); 
ssep.lat_std_lessaff(1) = std(ssep.lat_lessaff(:,1)); 
ssep.lat_std_lessaff(2) = std(ssep.lat_lessaff(:,2)); 
ssep.amp_mean_lessaff(1) = mean(ssep.amp_lessaff(:,1)); 
ssep.amp_mean_lessaff(2) = mean(ssep.amp_lessaff(:,2)); 
ssep.amp_std_lessaff(1) = std(ssep.amp_lessaff(:,1)); 
ssep.amp_std_lessaff(2) = std(ssep.amp_lessaff(:,2)); 


[h1_SSEP_AMP_LA,p1_SSEP_AMP_LA] = ttest(ssep.amp_lessaff(:,1),ssep.amp_lessaff(:,2)); 
[h1_SSEP_LAT_LA,p1_SSEP_LAT_LA] = ttest(ssep.lat_lessaff(:,1),ssep.lat_lessaff(:,2)); 

%% MEP less affected

n = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 0
        mep_lat_lessaff(n,1) = S1(i,9); 
        mep_lat_lessaff(n,2) = S3(i,9); 
        mep_ampl_lessaff(n,1) = S1(i,8); 
        mep_ampl_lessaff(n,2) = S3(i,8); 
        n = n+1; 
    elseif S1(i,3) == 1
        mep_lat_lessaff(n,1) = S1(i,11); 
        mep_lat_lessaff(n,2) = S3(i,11); 
        mep_ampl_lessaff(n,1) = S1(i,10); 
        mep_ampl_lessaff(n,2) = S3(i,10);         
        n = n+1; 
    end
end

% delete where nan on one 
k = 1; 
for i = 1:length(mep_lat_lessaff(:,1))
    if isnan(mep_lat_lessaff(i,1)) || isnan(mep_lat_lessaff(i,2)) 
        
    else
        mep.lat_lessaff(k,1) = mep_lat_lessaff(i,1); 
        mep.lat_lessaff(k,2) = mep_lat_lessaff(i,2); 
        mep.amp_lessaff(k,1) = mep_ampl_lessaff(i,1); 
        mep.amp_lessaff(k,2) = mep_ampl_lessaff(i,2); 
        k = k + 1; 
    end
end

mep.lat_mean_lessaff(1) = mean(mep.lat_lessaff(:,1)); 
mep.lat_mean_lessaff(2) = mean(mep.lat_lessaff(:,2)); 
mep.lat_std_lessaff(1) = std(mep.lat_lessaff(:,1)); 
mep.lat_std_lessaff(2) = std(mep.lat_lessaff(:,2)); 
mep.amp_mean_lessaff(1) = mean(mep.amp_lessaff(:,1)); 
mep.amp_mean_lessaff(2) = mean(mep.amp_lessaff(:,2)); 
mep.amp_std_lessaff(1) = std(mep.amp_lessaff(:,1)); 
mep.amp_std_lessaff(2) = std(mep.amp_lessaff(:,2)); 


[h1_mep_AMP_LA,p1_mep_AMP_LA] = ttest(mep.amp_lessaff(:,1),mep.amp_lessaff(:,2)); 
[h1_mep_LAT_LA,p1_mep_LAT_LA] = ttest(mep.lat_lessaff(:,1),mep.lat_lessaff(:,2)); 
