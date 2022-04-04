%% Categorize longitudinal data into absent / impaired / normal
% created: 26.05.2021

% SEP amplitude and latency 

% 70 SEP N20 amplitude left
% 71 SEP N20 latency left 
% 73 SEP N20 ampl right
% 74 SEP N20 lat right
% 79 MEP N20 amp left
% 80 MEP N20 lat left
% 84 MEP N20 amp right
% 85 MEP N20 lat right

% need to extract which side is impaired : field 11 leftImpaired 

% for SEP amplitude - if NaN - absent, if more affected side <50% of less
% affected --> impaired 

clear
close all
clc

%% read table %% 

filename = 'data/20210517_DataImpaired.csv';  
T = readtable(filename); 
% convert a string into a double array 
% take both left and right hand: MEP N20 ampl
A = table2array(T(:,[79 84])); 
A2 = str2double(strrep(A,',','.'));

A3 = table2array(T(:,[5 3 2 11])); 
A3(:,5:length(A2(1,:))+4) = A2; 

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

% first column: subject ID
% second column: session nr
% third column: left hand? 
% rest: what I want to plot as y-axis - both left and right

% remove those rows where there is only one data point
n = 1; 
remove = []; 
temp = []; 
for i=1:max(C(:,1))
    temp = find(C(:,1)==i); 
    if length(temp) == 1
        remove(n) = temp; 
        n = n+1; 
    end
end
C(remove,:) = []; 

% remove all rows for which neurophysiology data doesn't exist 
n = 1; 
t = []; 
for i = 1:length(C(:,5))
    if isnan(C(i,5)) && isnan(C(i,6))
        t(n) = i; 
        n = n+1; 
    end
end
C(t,:) = []; 

% change all 3rd into second session 
temp2 = find(C(:,2) == 3); 
C(temp2,2) = 2; 

%% Split into left and right hand

MEP_Amp_Imp = []; 
MEP_Amp_NonImp = []; 
n = 1; 
for i = 1:length(C(:,5))
    if C(i,4) == 0 % right hand impaired 
        MEP_Amp_Imp(n,1) = C(i,1); 
        MEP_Amp_Imp(n,2) = C(i,2);
        MEP_Amp_Imp(n,3) = C(i,6); 
        MEP_Amp_NonImp(n,1) = C(i,1); 
        MEP_Amp_NonImp(n,2) = C(i,2);
        MEP_Amp_NonImp(n,3) = C(i,5); 
        n = n+1; 
    elseif C(i,4) == 1 % left hand impaired 
        MEP_Amp_Imp(n,1) = C(i,1); 
        MEP_Amp_Imp(n,2) = C(i,2);
        MEP_Amp_Imp(n,3) = C(i,5); 
        MEP_Amp_NonImp(n,1) = C(i,1); 
        MEP_Amp_NonImp(n,2) = C(i,2);
        MEP_Amp_NonImp(n,3) = C(i,6); 
        n = n+1; 
    end
end

%% split into two days

% divide into S1 and S2
MEP_Amp_Imp_S1 = MEP_Amp_Imp(find(MEP_Amp_Imp(:,2)==1),:); 
MEP_Amp_Imp_S2 = MEP_Amp_Imp(find(MEP_Amp_Imp(:,2)==2),:);

MEP_Amp_NonImp_S1 = MEP_Amp_NonImp(find(MEP_Amp_NonImp(:,2)==1),:); 
MEP_Amp_NonImp_S2 = MEP_Amp_NonImp(find(MEP_Amp_NonImp(:,2)==2),:);




