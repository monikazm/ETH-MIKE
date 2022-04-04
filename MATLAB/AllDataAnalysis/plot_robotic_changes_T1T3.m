%% change motor / sensory - how do they relate?  %% 
% created: 13.10.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 47 - kUDT
% 41 - FM M UL
% 48 - BB imp 
% 49 - BB nonimp
% 50 - barther index tot
% 44 - FMA Hand 
% 61 - MoCA
% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR

A = table2array(T(:,[3 5 47 41 48 44 122 114 92 127])); 

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

S3(1,7) = 14.5926361100000; 

% % remove subjects that only have 2 measurements
% S1(find(S1(:,1)==3),:) = []; 
% S3(find(S3(:,1)==3),:) = []; 
% 
% S1(find(S1(:,1)==33),:) = []; 
% S3(find(S3(:,1)==33),:) = []; 
% 
% S1(find(S1(:,1)==37),:) = []; 
% S3(find(S3(:,1)==37),:) = []; 
% 
% S1(find(S1(:,1)==38),:) = []; 
% S3(find(S3(:,1)==38),:) = []; 
% 
% S1(find(S1(:,1)==48),:) = []; 
% S3(find(S3(:,1)==48),:) = []; 

%% Position Matching

figure; 
for i=1:length(S1)
    if S1(i,7)-S3(i,7)< 9.12
        p = plot(1:2, [S1(i,7) S3(i,7)],'-o','Linewidth',1);
        p.MarkerFaceColor = [0.7,0.7,0.7];
        p.Color = [0.7,0.7,0.7]; 
        hold on 
    else
        p = plot(1:2, [S1(i,7) S3(i,7)],'-o','Linewidth',1);
        p.MarkerFaceColor = 'k';
        p.Color = 'k'; 
        hold on 
    end
end
set(gca,'YDir','reverse')
xlim([0.5 2.5]) 
xticks([1 2]) 
xticklabels({'Inclusion','Discharge'})
ylabel('Position Matching Absolute Error (deg)')
print('plots/LongitudinalPlots/211026_PM_T1T3','-dpng')

%% Force

figure; 
for i=1:length(S1)
    if S3(i,8)-S1(i,8)< 4.88
        p = plot(1:2, [S1(i,8) S3(i,8)],'-o','Linewidth',1);
        p.MarkerFaceColor = [0.7,0.7,0.7];
        p.Color = [0.7,0.7,0.7]; 
        hold on 
    else
        p = plot(1:2, [S1(i,8) S3(i,8)],'-o','Linewidth',1);
        p.MarkerFaceColor = 'k';
        p.Color = 'k'; 
        hold on 
    end
end
xlim([0.5 2.5]) 
ylim([-2 52])
xticks([1 2]) 
xticklabels({'Inclusion','Discharge'})
ylabel('Maximum Force Flexion (N)')
print('plots/LongitudinalPlots/211026_Force_T1T3','-dpng')



