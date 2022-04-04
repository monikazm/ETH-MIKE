%% Categorize longitudinal data into absent / impaired / normal
% created: 05.05.2021

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
% take both left and right hand: SEP N20 ampl
A = table2array(T(:,[70 73])); 
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

% remove all rows for which clinical data doesn't exist 
n = 1; 
t = []; 
for i = 1:length(C(:,4))
    if isnan(C(i,4)) && isnan(C(i,5))
        t(n) = i; 
        n = n+1; 
    end
end
C(t,:) = []; 

% change all 3rd into second session 
temp2 = find(C(:,2) == 3); 
C(temp2,2) = 2; 

% remove subjects 21 (missing data) 
%C(find(C(:,1)==21),:) = []; 

%% categorize 
% 0 - absent, 1 - impaired, 2 - normal, 3 - other (the good side is NaN) 

for i = 1:length(C) 
    if C(i,3) == 0 % right impaired
        if C(i,5) < C(i,4)/2
            C(i,6) = 1; 
        elseif isnan(C(i,5)) == 1
            C(i,6) = 0;
        elseif C(i,5) > C(i,4)/2 
            C(i,6) = 2;
        else
            C(i,6) = 3;
        end
    elseif C(i,3) == 1 % left impaired   
        if C(i,4) < C(i,5)/2
            C(i,6) = 1; 
        elseif isnan(C(i,4)) == 1
            C(i,6) = 0;
        elseif C(i,4) > C(i,5)/2 
            C(i,6) = 2;
        else
            C(i,6) = 3;
        end
    end
end

save('results/SEP_ampl','C'); 




