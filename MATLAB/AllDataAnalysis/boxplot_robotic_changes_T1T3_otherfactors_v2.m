%% change motor / sensory - how do they relate?  %% 
% 3 groups
% created: 24.11.2021

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
% 8 - age

A = table2array(T(:,[3 5 47 41 48 61 122 114 92 160 8])); 
% subject session kUDT FMA BBT MoCA PM Force ROM Vel Age TSS

%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,12) = timeSinceStroke; 

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
withREDCap2(:,11) = withREDCap(:,11);
withREDCap2(:,12) = withREDCap(:,12);

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
        elseif C(i,2) == 3 || (C(i,2) == 2 && C(i+1,2) ~= 3) 
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

S3(1,7) = 14.5926361100000; 


%% Grouping 

n = 1; 
m = 1; 
k = 1; 
o = 1; 
p = 1; 
for i = 1:length(S1(:,1))
    if (S1(i,7)-S3(i,7) > 9.12 || (S1(i,7) > 10.64 && S3(i,7) <= 10.64)) && (((S3(i,8)-S1(i,8) > 4.88 || (S1(i,8) < 10.93 && S3(i,8) >= 10.93))) || ((S3(i,9)-S1(i,9) > 15.58 || (S1(i,9) < 63.20 && S3(i,9) >= 63.20))) || ((S3(i,10)-S1(i,10) > 60.68 || (S1(i,10) < 230 && S3(i,10) >= 230)))) 
       both.S1(n,:) = S1(i,:); 
       both.S3(n,:) = S3(i,:); 
       n = n+1; 
    elseif (S1(i,7)-S3(i,7) < 9.12) && (((S3(i,8)-S1(i,8) > 4.88 || (S1(i,8) < 10.93 && S3(i,8) >= 10.93))) || ((S3(i,9)-S1(i,9) > 15.58 || (S1(i,9) < 63.20 && S3(i,9) >= 63.20))) || ((S3(i,10)-S1(i,10) > 60.68 || (S1(i,10) < 230 && S3(i,10) >= 230)))) 
       motor.S1(m,:) = S1(i,:); 
       motor.S3(m,:) = S3(i,:);  
       m = m+1; 
    elseif (S1(i,7)-S3(i,7) > 9.12 || (S1(i,7) > 10.64 && S3(i,7) <= 10.64)) && (((S3(i,8)-S1(i,8) < 4.88) && (S3(i,9)-S1(i,9) < 15.58)) && (S3(i,10)-S1(i,10) < 60.68)) 
       sensory.S1(p,:) = S1(i,:); 
       sensory.S3(p,:) = S3(i,:);  
       p = p+1; 
    elseif  (S1(i,7)-S3(i,7) < 9.12 && (S1(i,7) < 10.64)) && (((S3(i,8)-S1(i,8) < 4.88 && (S1(i,8) > 10.93)) && (S3(i,9)-S1(i,9) < 15.58 && (S1(i,9) > 63.20))) || ((S3(i,8)-S1(i,8) < 4.88 && (S1(i,8) > 10.93)) && (S3(i,10)-S1(i,10) < 60.68 && (S1(i,10) > 230))) || ((S3(i,9)-S1(i,9) < 15.58 && (S1(i,9) > 63.20)) && (S3(i,10)-S1(i,10) < 60.68 && (S1(i,10) > 230)))) 
       good.S1(k,:) = S1(i,:); 
       good.S3(k,:) = S3(i,:); 
       k = k+1; 
    else
       neither.S1(o,:) = S1(i,:); 
       neither.S3(o,:) = S3(i,:); 
       o = o+1; 
    end
end

%% scatterplot time since stroke

figure; 
scatter(S1(:,12), S1(:,7)-S3(:,7), 'filled'); 
xlabel('Time since stroke (days)')
ylabel('Delta Position Matching Absolute Error (deg)')

figure; 
scatter(S1(:,12), S3(:,8)-S1(:,8), 'filled', 'k'); 
xlabel('Time since stroke (days) @ T1')
ylabel('Delta Maximum Force Flexion (N)')
print('plots/ScatterPlots/211126_Force_timeSinceStroke','-dpng')

%% scatter plot age

figure; 
scatter(S1(:,11), S3(:,8)-S1(:,8), 'filled', 'k'); 
xlabel('Age (years) @ T1')
ylabel('Delta Maximum Force Flexion (N)')
print('plots/ScatterPlots/211126_Force_age','-dpng')


%% grouping

change.S1 = [both.S1; sensory.S1; motor.S1]; 
nochange.S1 = [neither.S1]; 

%% time since stroke

g1 = repmat({'Change (N=27)'},length(change.S1(:,1)),1);
g2 = repmat({'No change (N=15)'},length(nochange.S1(:,1)),1);
g = [g1;g2]; 

figure; 
boxplot([change.S1(:,12); nochange.S1(:,12)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(change.S1(:,12))
    scatter(1,change.S1(i,12),'filled','k'); 
end
for i=1:length(nochange.S1(:,12))
    scatter(2,nochange.S1(i,12),'filled','k');
end
xlabel('Groups') 
ylabel('Time since stroke @ T1') 
print('plots/BoxPlots/211126_ChangeGroups_TSS','-dpng')

m_tss(1,1) = nanmean(change.S1(:,12)); 
m_tss(2,1) = nanstd(change.S1(:,12)); 
m_tss(1,2) = nanmean(nochange.S1(:,12)); 
m_tss(2,2) = nanstd(nochange.S1(:,12)); 

% statistical difference  
p_tss = kruskalwallis([change.S1(:,12); nochange.S1(:,12)],g); 

%% age

figure; 
boxplot([change.S1(:,11); nochange.S1(:,11)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(change.S1(:,11))
    scatter(1,change.S1(i,11),'filled','k'); 
end
for i=1:length(nochange.S1(:,11))
    scatter(2,nochange.S1(i,11),'filled','k');
end
xlabel('Groups') 
ylabel('Age @ T1') 
print('plots/BoxPlots/211126_ChangeGroups_Age','-dpng')

% statistical difference  
p_age = kruskalwallis([change.S1(:,11); nochange.S1(:,11)],g); 

%% MoCA

figure; 
boxplot([change.S1(:,6); nochange.S1(:,6)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(change.S1(:,6))
    scatter(1,change.S1(i,6),'filled','k'); 
end
for i=1:length(nochange.S1(:,6))
    scatter(2,nochange.S1(i,6),'filled','k');
end
yline(17,'--k')
xlabel('Groups') 
ylabel('MoCA @ T1') 
print('plots/BoxPlots/211126_ChangeGroups_MoCA','-dpng')

% statistical difference  
p_moca = kruskalwallis([change.S1(:,6); nochange.S1(:,6)],g); 





