%% ttests to define if change is significant %% 
% created: 24.08.2021

clear 
close all
clc

%% read table

T = readtable('data/20210811_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR

A = table2array(T(:,[3 5 92 114 160 127 122 47 41])); 

%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,10) = timeSinceStroke; 

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

%% Divide into S1 S2 and S3

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
        elseif C(i,2) == 3
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];
  
Lia = double(ismember(S2(:,1),S3(:,1))); 
S2(:,1) = Lia.*S2(:,1); 
S2(S2(:,1)==0,:)= [];

S1(1,:) = []; 
S2(1,:) = []; 
S3(1,:) = []; 
S2(13,7) = 20;  

%% ttests Position Matching

[h1_PM,p1_PM] = ttest(S1(:,7),S2(:,7)); 
[h2_PM,p2_PM] = ttest(S1(:,7),S3(:,7)); 
[h3_PM,p3_PM] = ttest(S2(:,7),S3(:,7)); 

[h4,p4] = ttest(S2(:,7)-S1(:,7)); % sanity check - same as h1&p1 - yay

%% ttests AROM

[h1_AROM,p1_AROM] = ttest(S1(:,3),S2(:,3)); 
[h2_AROM,p2_AROM] = ttest(S1(:,3),S3(:,3)); 
[h3_AROM,p3_AROM] = ttest(S2(:,3),S3(:,3)); 

%% ttests Force Flex

[h1_Force,p1_Force] = ttest(S1(:,4),S2(:,4)); 
[h2_Force,p2_Force] = ttest(S1(:,4),S3(:,4)); 
[h3_Force,p3_Force] = ttest(S2(:,4),S3(:,4)); 

%% ttests Vel Ext

[h1_Vel,p1_Vel] = ttest(S1(:,5),S2(:,5)); 
[h2_Vel,p2_Vel] = ttest(S1(:,5),S3(:,5)); 
[h3_Vel,p3_Vel] = ttest(S2(:,5),S3(:,5)); 

%% ttests kUDT & fMA
 
[h1_kUDT,p1_kUDT] = ttest(S1(:,8),S3(:,8)); 
[h1_FMA,p1_FMA] = ttest(S1(:,9),S3(:,9)); 




%% Correlation time since stroke vs change
S3(23,10) = S1(23,10) + 19; 

[RHO1,PVAL1] = corr(S2(1:27,7)-S1(1:27,7), S2(1:27,10),'Type','Spearman');
[RHO2,PVAL2] = corr(S3(1:27,7)-S1(1:27,7), S3(1:27,10),'Type','Spearman');

[RHO3,PVAL3] = corr(S2(1:27,7)-S1(1:27,7), S2(1:27,10)-S1(1:27,10),'Type','Spearman');
[RHO4,PVAL4] = corr(S3(1:27,7)-S1(1:27,7), S3(1:27,10)-S1(1:27,10),'Type','Spearman');

[RHO5,PVAL5] = corr([S1(1:27,7); S2(1:27,7); S3(1:27,7)], [S1(1:27,10); S2(1:27,10); S3(1:27,10)],'Type','Spearman');




