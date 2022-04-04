%% ttests to define if change is significant %% 
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


%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,11) = timeSinceStroke; 


%% clean up 
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
withREDCap2(:,11) = withREDCap(:,11);

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
        elseif C(i,2) == 2 && isnan(C(i,3))==0
            S3(m,:) = C(i,:);
            m = m+1;
        elseif C(i,2) == 3 && isnan(C(i,3))==0
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

S3(1,7) = 14.5926361100000; 

% remove subjects that only have 2 measurements
S1(find(S1(:,1)==3),:) = []; 
S3(find(S3(:,1)==3),:) = []; 

S1(find(S1(:,1)==33),:) = []; 
S3(find(S3(:,1)==33),:) = []; 

S1(find(S1(:,1)==37),:) = []; 
S3(find(S3(:,1)==37),:) = []; 

S1(find(S1(:,1)==38),:) = []; 
S3(find(S3(:,1)==38),:) = []; 

S1(find(S1(:,1)==48),:) = []; 
S3(find(S3(:,1)==48),:) = []; 

%% scatter

figure; 
scatter(S1(:,3), S1(:,7)-S3(:,7),'filled')


%% Two groups according to kUDT at T1

group1 = []; 
group2 = []; 
n = 1; 
m = 1; 
for i = 1:length(S1(:,1))
    if S1(i,3) == 3
        group1(n,1) = S1(i,1); 
        group1(n,2) = S1(i,7); 
        group1(n,3) = S3(i,7); 
        group1(n,4) = S1(i,7) - S3(i,7); 
        n = n+1; 
    else
        group2(m,1) = S1(i,1); 
        group2(m,2) = S1(i,7); 
        group2(m,3) = S3(i,7);
        group2(m,4) = S1(i,7) - S3(i,7); 
        m = m + 1; 
    end
end


g1 = repmat({'Impaired'},length(group2(:,1)),1);
g2 = repmat({'Normal'},length(group1(:,1)),1);
g = [g1;g2]; 

figure; 
boxplot([group2(:,4); group1(:,4)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(group2(:,4))
    if group2(i,4) >= 9.12
       scatter(1,group2(i,4),'filled','g'); 
    elseif group2(i,3) <= 10.63 && group2(i,2) > 10.63
       scatter(1,group2(i,4),'filled','b'); 
    else
       scatter(1,group2(i,4),'filled','k');
    end
end
hold on
for i=1:length(group1(:,4))
    if group1(i,4) >= 9.12
       scatter(2,group1(i,4),'filled','g'); 
    elseif group1(i,3) <= 10.63 && group1(i,2) > 10.63
       scatter(2,group1(i,4),'filled','b'); 
    else
       scatter(2,group1(i,4),'filled','k'); 
    end
end
xlabel('kUDT @ T1') 
ylabel('Delta Position Matching Absolute Error (deg)') 
print('plots/BoxPlots/211115_kUDT_PM_Delta','-dpng')


% is the difference significant between the groups? 
% Kruskal Wallis
p_PMDelta_kUDTT1 = kruskalwallis([group2(:,4); group1(:,4)],[g1;g2]); 

