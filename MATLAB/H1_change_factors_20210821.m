%% association model between motor and sensory scores %% 
% created: 20.08.2021
% metrics to start with: PM and AROM 

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

A = table2array(T(:,[3 5 92 114 160 127 122 ])); 

%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,8) = timeSinceStroke; 

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
S3(23,8) = S1(23,8) + 19; 

%% means 

meanPM = [mean(S1(:,7)) mean(S2(:,7)) mean(S3(:,7))]; 
stdPM = [std(S1(:,7)) std(S2(:,7)) std(S3(:,7))]; 

meanDSS = [mean(S1(1:27,8)) mean(S2(1:27,8)) mean(S3(1:27,8))]; 
stdDSS = [std(S1(1:27,8)) std(S2(1:27,8)) std(S3(1:27,8))]; 

meanWSS = [mean(S1(1:27,8)./7) mean(S2(1:27,8)./7) mean(S3(1:27,8)./7)]; 
stdWSS = [std(S1(1:27,8)./7) std(S2(1:27,8)./7) std(S3(1:27,8)./7)]; 

%% change 

nbins = 15; 
SRD = 9.12; 
change(:,1) = S1(:,1); 
change(:,2) = (S1(:,7)-S3(:,7))./SRD; 
change(:,3) = (S1(:,7)-S2(:,7))./SRD; 
change(:,4) = (S2(:,7)-S3(:,7))./SRD; 

%% histograms 

figure; 
histogram(change(:,2))
xlabel('Change T3-T1 / SRD'); 
ylabel('Frequency')
title('Histogram of change'); 
print('Plots/Histograms/210824_PM_ChangeT13_v1','-dpng')

figure; 
histogram(change(:,2),nbins)
xlabel('Change T3-T1 / SRD'); 
ylabel('Frequency')
title('Histogram of change'); 
print('Plots/Histograms/210824_PM_ChangeT13_v2','-dpng')

% S1 S2
figure; 
histogram(change(:,3))
xlabel('Change T2-T1 / SRD'); 
ylabel('Frequency')
title('Histogram of change'); 
print('Plots/Histograms/210824_PM_ChangeT12_v1','-dpng')

% S2 S3
figure; 
histogram(change(:,4))
xlabel('Change T3-T2 / SRD'); 
ylabel('Frequency')
title('Histogram of change'); 
print('Plots/Histograms/210824_PM_ChangeT23_v1','-dpng')

%% change and factors

factors(:,1) = change(:,1); 
factors(:,2) = change(:,2);
factors(:,3) = S1(:,7);
factors(:,4) = S1(:,8)./7;
factors(:,5) = S3(:,8)-S1(:,8); 
factors(:,6) = S3(:,7);

%% scatter plots

figure; 
scatter(factors(:,3),factors(:,2),'filled')

figure; 
scatter(factors(:,4),factors(:,2),'filled')

figure; 
scatter(factors(:,5),factors(:,2),'filled')

%% statistics 

[RHO1,PVAL1] = corr(factors(:,3),factors(:,2),'Type','Spearman');
[RHO2,PVAL2] = corr(factors(1:27,4),factors(1:27,2),'Type','Spearman');
[RHO3,PVAL3] = corr(factors(1:27,5),factors(1:27,2),'Type','Spearman');



