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

C(1:4,:) = []; 
C(48,7) = 20;  

%% PM vs time since stroke vs session nr.

Outcome = C(:,7); 
TimeSinceStroke = C(:,9);
Session = C(:,2); 
Subject = C(:,1); 
initialkUDT = 

tbl = table(Subject,Session,TimeSinceStroke,Outcome);

lme_PM = fitlme(tbl,'Outcome ~ 1 + TimeSinceStroke + Session + (1|Subject)')

figure
for i=unique(C(:,1))'
    F = plot(C(find(C(:,1)==i),9),C(find(C(:,1)==i),7),'o-'); 
    F.MarkerFaceColor = 'k';
    F.Color = 'k'; 
    F.MarkerSize = 3; 
    hold on 
end
set(gca,'YDir','reverse')
set(gca,'FontSize',12)
xlabel('Days Since Stroke') 
ylabel('Position Matching Error (deg)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/210917_PM_Long_timeSinceStrokeAll','-dpng')


%% AROM vs time since stroke vs session nr.

y = C(:,3); 
TimeSinceStroke = C(:,9);
Session = C(:,2); 
Subject = C(:,1); 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme_AROM = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

figure
for i=unique(C(:,1))'
    F = plot(C(find(C(:,1)==i),9),C(find(C(:,1)==i),3),'o-'); 
    F.MarkerFaceColor = 'k';
    F.Color = 'k'; 
    F.MarkerSize = 3; 
    hold on 
end
set(gca,'FontSize',12)
xlabel('Days Since Stroke') 
ylabel('Active Range of Motion (deg)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/210917_AROM_Long_timeSinceStrokeAll','-dpng')


%% Force Flex vs time since stroke vs session nr.

y = C(:,4); 
TimeSinceStroke = C(:,9);
Session = C(:,2); 
Subject = C(:,1); 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme_Force = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

figure
for i=unique(C(:,1))'
    F = plot(C(find(C(:,1)==i),9),C(find(C(:,1)==i),4),'o-'); 
    F.MarkerFaceColor = 'k';
    F.Color = 'k'; 
    F.MarkerSize = 3; 
    hold on 
end
set(gca,'FontSize',12)
xlabel('Days Since Stroke') 
ylabel('Maximum Force Flexion (N)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/210917_Force_Long_timeSinceStrokeAll','-dpng')


%% Max Vel vs time since stroke vs session nr.

y = C(:,5); 
TimeSinceStroke = C(:,9);
Session = C(:,2); 
Subject = C(:,1); 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme_Vel = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

figure
for i=unique(C(:,1))'
    F = plot(C(find(C(:,1)==i),9),C(find(C(:,1)==i),5),'o-'); 
    F.MarkerFaceColor = 'k';
    F.Color = 'k'; 
    F.MarkerSize = 3; 
    hold on 
end
set(gca,'FontSize',12)
xlabel('Days Since Stroke') 
ylabel('Maximum Velocity Extension (deg/s)') 
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/robotic/210917_Vel_Long_timeSinceStrokeAll','-dpng')

