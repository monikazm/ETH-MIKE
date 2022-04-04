%% Initial robotic task score vs length of stay %% 
% created: 17.08.2021

clear 
close all
clc

%% read table %% 

T = readtable('data/20210811_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext

N = 160; 

A = table2array(T(:,[3 5 N])); 


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

C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: metric 

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

%% Processing

% take max stay for each subject 
stay = []; 
for j=1:length(C) 
    for i=1:max(C(:,1))
        if C(j,1) == i
            stay(i,1) = C(j,1); 
            stay(i,2) = C(j,2);  
        end
    end
end
stay(1,:) = []; 


% remove leave only 1st and 2nd or 3rd measurement 
new = [];
out = [];
for i=1:max(C(:,1))
    temp = find(C(:,1)==i); 
    if length(temp) >= 3
        new = C(find(C(:,1)==i),:);
        new(find(new(:,2)==2),:) = [];
        new(find(new(:,2)>3),:) = [];
        if i == 1
            out = new;
        else
            out = [out;new];
        end
    elseif length(temp) == 2
        new = C(find(C(:,1)==i),:);
        if i == 1
            out = new;
        else
            out = [out;new];
        end 
    end
end

% change 2nd into 3rd session
temp2 = find(out(:,2) == 2); 
out(temp2,2) = 3; 

% split into PM1 and PM2
PM1 = out(find(out(:,2) == 1),:);
PM3 = out(find(out(:,2) == 3),:);

% merge into one 
Lia = double(ismember(PM1(:,1),PM3(:,1))); 
PM1(:,1) = Lia.*PM1(:,1); 
PM1(PM1(:,1)==0,:)= [];
PM1(:,2) = []; 
PM3(:,2) = []; 

% merge into one 
Lia = double(ismember(stay(:,1),PM3(:,1))); 
stay(:,1) = Lia.*stay(:,1); 
stay(stay(:,1)==0,:)= [];

%merge into one array
result = [PM1(:,1) PM1(:,2) PM3(:,2) stay(:,2)]; 
result(33,:) = [];

%% plot

figure; 
scatter(result(:,4), result(:,2),'filled') 
xlabel('Number of sessions')
ylabel('Initial Max Vel Ext (deg/s)')
xlim([1.5 8.5])
%ylim([-0.5 90]) 
print('Plots/ScatterPlots/210823_VelExt_lengthStay','-dpng')


%% correlation

[RHO1,PVAL1] = corr(result(:,4), result(:,2),'Type','Spearman');

