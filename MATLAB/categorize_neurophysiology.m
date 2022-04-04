%% Categorize longitudinal data into absent / impaired / normal
% created: 05.05.2021






%% read table %% 

filename = '20210408_DataImpaired.csv';  
T = readtable(filename); 
% convert a string into a double array 
% take both left and right hand: MEP ampl
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

% % remove all rows for which clinical data doesn't exist 
% n = 1; 
% t = []; 
% for i = 1:length(C(:,4))
%     if isnan(C(i,4)) && isnan(C(i,5))
%         t(n) = i; 
%         n = n+1; 
%     end
% end
% C(t,:) = []; 
% 
% % change all 3rd into second session 
% temp2 = find(C(:,2) == 3); 
% C(temp2,2) = 2; 



