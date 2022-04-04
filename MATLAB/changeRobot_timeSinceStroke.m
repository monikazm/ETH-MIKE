%% Change in Robotic task vs Time Since Stroke %% 
% created: 04.05.2021

% divide by SRD 

clear 
close all
clc

%% read table %% 

T = readtable('data/20210702_DataImpaired.csv'); 
M = readtable('data/20210121_metricInfo.csv'); 
ID = 36; 
SRD_sensory = table2array(M(ID,7)); 
% 28 - force flex
% 6 - AROM
% 74 - max vel ext
ID = 74; 
SRD_motor = table2array(M(ID,7)); 
healthyAvrg = table2array(M(ID,6));

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end

A = table2array(T(:,[3 5 160])); 
A(:,4) = timeSinceStroke; 

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

%% Calculate if above SRD

n = 1;  
k = 1; 
for i = 1:length(C(:,1))
    if C(i,1) == 3
        if C(i,2) == 1
            Sesh1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 2
            Sesh3(k,:) = C(i,:);
            k = k+1; 
        end
    else
        if C(i,2) == 1
            Sesh1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 3
            Sesh3(k,:) = C(i,:);
            k = k+1; 
        end
    end
end

change(:,1) = Sesh1(1:17,1); 
change(:,2) = Sesh3(1:17,3) - Sesh1(1:17,3); % change
change(:,3) = Sesh1(1:17,4);

%% divide the change by SRD

change_bySRD(:,1) = change(:,1); 
change_bySRD(:,2) = change(:,2)./SRD_motor; 
change_bySRD(:,3) = change(:,3); % time since stroke 

% exclude the outlier (strange result on S3)
change_bySRD(1,:) = []; 

%% plot longitudinal data - individual subjects 

figure; 
scatter(change_bySRD(:,3),change_bySRD(:,2), 'filled'); 
%legend show
set(gca,'FontSize',12)
%xlim([-10 15])
%ylim([-10 15])
xlabel('Time since stroke at baseline (days)') 
ylabel('Change in Velocity Extension / SRD') 
% xlim([-1.5 1.5])
% ylim([-1.5 3.5])
% yline(0,'k-.')
% xline(0,'k-.')
%print('Plots/ScatterPlots/210504_ChangeVelExt_DaysSinceStroke','-dpng')




