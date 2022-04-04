%% association model: session & time since stroke, also add initial impairment as a variable %% 
% created: 17.09.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20210914_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR
% 46 - FM Sensory 
% 47 - kUDT 
% 61 - MoCA

A = table2array(T(:,[3 5 92 114 160 127 122 47])); 

%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,9) = timeSinceStroke; 

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

%% PM vs time since stroke vs session nr.

y = [S1(:,7);S2(:,7);S3(:,7)]; 
TimeSinceStroke = [S1(:,9); S2(:,9); S3(:,9)];
Session = [S1(:,2);S2(:,2);S3(:,2)]; 
Subject = [S1(:,1);S2(:,1);S3(:,1)]; 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme_PM = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

figure
for i=1:length(S1(:,1))
    F = plot([S1(i,9) S2(i,9) S3(i,9)], [S1(i,7) S2(i,7) S3(i,7)],'o-'); 
    F.MarkerFaceColor = 'k';
    F.Color = 'k'; 
    F.MarkerSize = 4; 
    hold on 
end
set(gca,'YDir','reverse')
set(gca,'FontSize',12)
xlabel('Days Since Stroke') 
ylabel('Position Matching Error (deg)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/210917_PM_Long_timeSinceStroke','-dpng')

figure
for i=1:length(S1(:,1))
    F = scatter(S3(i,9), S1(i,7)-S3(i,7),'filled','k'); 
    hold on 
end
set(gca,'FontSize',12)
xlabel('Days Since Stroke @ T1') 
ylabel('Delta Position Matching Error (deg)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210917_PM_change_timeSinceStroke','-dpng')

change = [S1(:,9),(S1(:,7)-S3(:,7))]; 
change(33,:) = [];

[rho,pval] = corr(change(:,1), change(:,2), 'Type', 'Spearman'); 

%% AROM vs time since stroke vs session nr.

y = [S1(:,3);S2(:,3);S3(:,3)]; 
TimeSinceStroke = [S1(:,9); S2(:,9); S3(:,9)];
Session = [S1(:,2);S2(:,2);S3(:,2)]; 
Subject = [S1(:,1);S2(:,1);S3(:,1)]; 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme_AROM = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

figure
for i=1:length(S1(:,1))
    F = plot([S1(i,9) S2(i,9) S3(i,9)], [S1(i,3) S2(i,3) S3(i,3)],'o-'); 
    F.MarkerFaceColor = 'k';
    F.Color = 'k'; 
    F.MarkerSize = 4; 
    hold on 
end
set(gca,'FontSize',12)
xlabel('Days Since Stroke') 
ylabel('Active Range of Motion (deg)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/210917_AROM_Long_timeSinceStroke','-dpng')

%% Force Flex vs time since stroke vs session nr.

y = [S1(:,4);S2(:,4);S3(:,4)]; 
TimeSinceStroke = [S1(:,9); S2(:,9); S3(:,9)];
Session = [S1(:,2);S2(:,2);S3(:,2)]; 
Subject = [S1(:,1);S2(:,1);S3(:,1)]; 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme_Force = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

figure
for i=1:length(S1(:,1))
    F = plot([S1(i,9) S2(i,9) S3(i,9)], [S1(i,4) S2(i,4) S3(i,4)],'o-'); 
    F.MarkerFaceColor = 'k';
    F.Color = 'k'; 
    F.MarkerSize = 4; 
    hold on 
end
set(gca,'FontSize',12)
xlabel('Days Since Stroke') 
ylabel('Maximum Force Flexion (N)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/210917_Force_Long_timeSinceStroke','-dpng')

change = [S1(:,9),(S3(:,4)-S1(:,4))]; 
change(33,:) = [];

[rho,pval] = corr(change(:,1), change(:,2), 'Type', 'Spearman'); 

%% Vel Ext vs time since stroke vs session nr.

y = [S1(:,5);S2(:,5);S3(:,5)]; 
TimeSinceStroke = [S1(:,9); S2(:,9); S3(:,9)];
Session = [S1(:,2);S2(:,2);S3(:,2)]; 
Subject = [S1(:,1);S2(:,1);S3(:,1)]; 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme_Vel = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

figure
for i=1:length(S1(:,1))
    F = plot([S1(i,9) S2(i,9) S3(i,9)], [S1(i,5) S2(i,5) S3(i,5)],'o-'); 
    F.MarkerFaceColor = 'k';
    F.Color = 'k'; 
    F.MarkerSize = 4; 
    hold on 
end
set(gca,'FontSize',12)
xlabel('Days Since Stroke') 
ylabel('Maximum Velocity Extension (deg/s)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/210917_Vel_Long_timeSinceStroke','-dpng')


%% change vs initial score 


% PM 
Delta = S1(:,7)-S3(:,7); 
TimeSinceStroke = S1(:,9);
InitialImpairment = S1(:,7); 
Subject = S1(:,1); 

tbl = table(Subject,InitialImpairment,Delta);

lme_PM_delta = fitlme(tbl,'Delta ~ 1 + InitialImpairment + (1|Subject)');

figure; 
scatter(InitialImpairment,Delta,'filled')
xlabel('Initial Impairment') 
ylabel('Delta') 
title('Position Matching Error') 
[rho1,pval1] = corr(InitialImpairment,Delta, 'Type', 'Spearman'); 


% AROM
Delta = S3(:,3)-S1(:,3); 
TimeSinceStroke = S1(:,9);
InitialImpairment = S1(:,3); 
Subject = S1(:,1); 

tbl = table(Subject,InitialImpairment,Delta);

lme_AROM_delta = fitlme(tbl,'Delta ~ 1 + InitialImpairment + (1|Subject)')

figure; 
scatter(InitialImpairment,Delta,'filled')
xlabel('Initial Impairment') 
ylabel('Delta') 
title('Active Range of Motion') 
[rho2,pval2] = corr(InitialImpairment,Delta, 'Type', 'Spearman'); 

% Force
Delta = S3(:,4)-S1(:,4); 
TimeSinceStroke = S1(:,9);
InitialImpairment = S1(:,4); 
Subject = S1(:,1); 

tbl = table(Subject,TimeSinceStroke,InitialImpairment,Delta);

lme_Force_delta = fitlme(tbl,'Delta ~ 1 + TimeSinceStroke + InitialImpairment + (1|Subject)')

figure; 
scatter(InitialImpairment,Delta,'filled')
xlabel('Initial Impairment') 
ylabel('Delta') 
title('Maximum Force Flexion') 
[rho3,pval3] = corr(InitialImpairment,Delta, 'Type', 'Spearman'); 

% Velocity
Delta = S3(:,5)-S1(:,5); 
TimeSinceStroke = S1(:,9);
InitialImpairment = S1(:,5); 
Subject = S1(:,1); 

tbl = table(Subject,TimeSinceStroke,InitialImpairment,Delta);

lme_Vel_delta = fitlme(tbl,'Delta ~ 1 + TimeSinceStroke + InitialImpairment + (1|Subject)')




