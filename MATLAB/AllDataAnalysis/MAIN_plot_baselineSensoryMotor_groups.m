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

A = table2array(T(:,[3 5 122 114 92 160 8])); 
% subject session PM Force ROM Vel Age TSS

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

S3(1,3) = 14.5926361100000; 
S3(33,4) = S1(33,4); 
S3(33,5) = S1(33,5); 
S3(33,6) = S1(33,6); 


%% Grouping 

n = 1; 
m = 1; 
k = 1; 
o = 1; 
p = 1; 
for i = 1:length(S1(:,1))
    if (S1(i,3)-S3(i,3) > 9.12 || (S1(i,3) > 10.64 && S3(i,3) <= 10.64)) && (((S3(i,4)-S1(i,4) > 4.88 || (S1(i,4) < 10.93 && S3(i,4) >= 10.93))) || ((S3(i,5)-S1(i,5) > 15.58 || (S1(i,5) < 63.20 && S3(i,5) >= 63.20))) || ((S3(i,6)-S1(i,6) > 60.68 || (S1(i,6) < 230 && S3(i,6) >= 230)))) 
       both.S1(n,:) = S1(i,:); 
       both.S3(n,:) = S3(i,:); 
       n = n+1; 
    elseif (S1(i,3)-S3(i,3) < 9.12) && (((S3(i,4)-S1(i,4) > 4.88 || (S1(i,4) < 10.93 && S3(i,4) >= 10.93))) || ((S3(i,5)-S1(i,5) > 15.58 || (S1(i,5) < 63.20 && S3(i,5) >= 63.20))) || ((S3(i,6)-S1(i,6) > 60.68 || (S1(i,6) < 230 && S3(i,6) >= 230)))) 
       motor.S1(m,:) = S1(i,:); 
       motor.S3(m,:) = S3(i,:);  
       m = m+1; 
    elseif (S1(i,3)-S3(i,3) > 9.12 || (S1(i,3) > 10.64 && S3(i,3) <= 10.64)) && (((S3(i,4)-S1(i,4) < 4.88) && (S3(i,5)-S1(i,5) < 15.58)) && (S3(i,6)-S1(i,6) < 60.68)) 
       sensory.S1(p,:) = S1(i,:); 
       sensory.S3(p,:) = S3(i,:);  
       p = p+1; 
    elseif  (S1(i,3)-S3(i,3) < 9.12 && (S1(i,3) < 10.64)) && (((S3(i,4)-S1(i,4) < 4.88 && (S1(i,4) > 10.93)) && (S3(i,5)-S1(i,5) < 15.58 && (S1(i,5) > 63.20))) || ((S3(i,4)-S1(i,4) < 4.88 && (S1(i,4) > 10.93)) && (S3(i,6)-S1(i,6) < 60.68 && (S1(i,6) > 230))) || ((S3(i,5)-S1(i,5) < 15.58 && (S1(i,5) > 63.20)) && (S3(i,6)-S1(i,6) < 60.68 && (S1(i,6) > 230)))) 
       good.S1(k,:) = S1(i,:); 
       good.S3(k,:) = S3(i,:); 
       k = k+1; 
    else
       neither.S1(o,:) = S1(i,:); 
       neither.S3(o,:) = S3(i,:); 
       o = o+1; 
    end
end


%% mean baseline scores 

changeM.S1 = [both.S1; motor.S1]; 
nochangeM.S1 = [neither.S1]; 

changeS.S1 = [both.S1; sensory.S1]; 
nochangeS.S1 = [neither.S1];

% mean baseline score - change group
changeM.meanF = mean(changeM.S1(:,4)); 
changeM.stdF = std(changeM.S1(:,4)); 
changeM.meanR = mean(changeM.S1(:,5)); 
changeM.stdR = std(changeM.S1(:,5)); 
changeM.meanV = mean(changeM.S1(:,6)); 
changeM.stdV = std(changeM.S1(:,6)); 

changeS.meanPM = mean(changeS.S1(:,3)); 
changeS.stdPM = std(changeS.S1(:,3)); 

% mean baseline score - no change group
nochangeM.meanF = mean(nochangeM.S1(:,4)); 
nochangeM.stdF = std(nochangeM.S1(:,4)); 
nochangeM.meanR = mean(nochangeM.S1(:,5)); 
nochangeM.stdR = std(nochangeM.S1(:,5)); 
nochangeM.meanV = mean(nochangeM.S1(:,6)); 
nochangeM.stdV = std(nochangeM.S1(:,6)); 

nochangeS.meanPM = mean(nochangeS.S1(:,3)); 
nochangeS.stdPM = std(nochangeS.S1(:,3)); 

%% plot - motor 

% baseline Force
g1 = repmat({'Change (N=25)'},length(changeM.S1(:,1)),1);
g2 = repmat({'No change (N=15)'},length(nochangeM.S1(:,1)),1);
g = [g1;g2]; 
figure; 
hold on
yline(10.93,'k--');
boxplot([changeM.S1(:,4); nochangeM.S1(:,4)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(changeM.S1(:,4))
    scatter(1,changeM.S1(i,4),'filled','k'); 
end
for i=1:length(nochangeM.S1(:,4))
    scatter(2,nochangeM.S1(i,4),'filled','k');
end
set(gca,'FontSize',12)
xlabel('Groups') 
ylabel('Flexion Force FF (N) at T1') 
title('Motor function')
ylim([-3 48])
print('plots/Paper/20220522_FigureSM2A','-dpng')

% baseline Velocity 
figure; 
boxplot([changeM.S1(:,5); nochangeM.S1(:,5)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(changeM.S1(:,5))
    scatter(1,changeM.S1(i,5),'filled','k'); 
end
for i=1:length(nochangeM.S1(:,5))
    scatter(2,nochangeM.S1(i,5),'filled','k');
end
xlabel('Groups') 
ylabel('Active Range of Motion AROM (deg) at T1') 
print('plots/Paper/20220522_FigureROM','-dpng')

% baseline Velocity 
figure; 
boxplot([changeM.S1(:,6); nochangeM.S1(:,6)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(changeM.S1(:,6))
    scatter(1,changeM.S1(i,6),'filled','k'); 
end
for i=1:length(nochangeM.S1(:,6))
    scatter(2,nochangeM.S1(i,6),'filled','k');
end
xlabel('Groups') 
ylabel('Extension Velocity EV (deg/s) at T1') 
print('plots/Paper/20220522_FigureVel','-dpng')

% statistics - motor change groups
p_groupsM_F = kruskalwallis([changeM.S1(:,4); nochangeM.S1(:,4)],g); 
p_groupsM_V = kruskalwallis([changeM.S1(:,5); nochangeM.S1(:,5)],g); 
p_groupsM_ROM = kruskalwallis([changeM.S1(:,6); nochangeM.S1(:,6)],g); 


%% boxplot - sensory change 

% sensory function at baseline
g1 = repmat({'Change (N=10)'},length(changeS.S1(:,1)),1);
g2 = repmat({'No change (N=15)'},length(nochangeS.S1(:,1)),1);
g = [g1;g2]; 
figure; 
boxplot([changeS.S1(:,3); nochangeS.S1(:,3)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(changeS.S1(:,3))
    scatter(1,changeS.S1(i,3),'filled','k'); 
end
for i=1:length(nochangeS.S1(:,3))
    scatter(2,nochangeS.S1(i,3),'filled','k');
end
hold on
set(gca,'FontSize',12)
yline(10.63,'k--');
set(gca,'YDir','reverse')
xlabel('Groups') 
ylabel('Absolute Error AE (deg) at T1') 
title('Proprioception')
print('plots/Paper/20220522_FigureSM2B','-dpng')

% sensory change groups 
p_groupsS_PM = kruskalwallis([changeS.S1(:,3); nochangeS.S1(:,3)],g); 

