function C = extractLongitudinal_robotic(filename,columnNrs)
% INFO: extract data from the CSV and save so that it can be used in the plotting

%% read table %% 

%T = readtable('20210119_dbExport_impaired.csv'); 
T = readtable(filename); 
A = table2array(T(:,[3 5 columnNrs])); 

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
withREDCap2(:,3:length(columnNrs)+2) = withREDCap(:,3:length(columnNrs)+2); 

C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: what I want to plot as y-axis

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


end

