%% Robotic task score vs Time Since Stroke %% 
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

N = 122; 

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end

A = table2array(T(:,[3 5 N])); 
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

%% Take only first and third measurement

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

% remove one outlier
% exclude the outlier (strange result on S3)
PM1(1,:) = []; 
PM3(1,:) = []; 

% replace NaNs with a meaningful value
for i=19:23
    PM3(i,3) = PM1(i,3) + 28; 
end


%% plot longitudinal data - individual subjects 

figure; 
for i=1:length(PM1)
    P = plot([PM1(i,3) PM3(i,3)], [PM1(i,2) PM3(i,2)],'o-');    
    P.MarkerFaceColor = [0.7 0.7 0.7]; 
    P.MarkerEdgeColor = [0.7 0.7 0.7]; 
    P.Color = [0.7 0.7 0.7]; 
    hold on 
end
%legend show
set(gca,'FontSize',12)
%xlim([-10 15])
%ylim([-10 15])
xlabel('Time since stroke (days)') 
ylabel('Position Matching Error (deg)') 
set(gca,'Ydir','reverse')
% xlim([-1.5 1.5])
% ylim([-1.5 3.5])
% yline(0,'k-.')
% xline(0,'k-.')
print('Plots/LongitudinalPlots/robotic/210817_PM_timeSinceStroke','-dpng')

%% change vs time since stroke

change(:,1) = PM1(:,1); 
change(:,2) = PM1(:,2) - PM3(:,2); 

PM3(24,3) = PM1(24,3) + 19; 

figure; 
scatter(PM1(1:30,3), change(1:30,2), 'filled')
xlabel('Time since stroke (days)') 
ylabel('Delta Position Matching Error (deg)') 
%set(gca,'Ydir','reverse')
% xlim([-1.5 1.5])
% ylim([-1.5 3.5])
% yline(0,'k-.')
% xline(0,'k-.')
print('Plots/ScatterPlots/210823_changePM_timeSinceStroke','-dpng')

figure; 
scatter(PM1(1:30,3), PM1(1:30,2), 'filled')
xlabel('Time since stroke (days)') 
ylabel('Position Matching Error @ T1 (deg)') 
set(gca,'Ydir','reverse')
% xlim([-1.5 1.5])
% ylim([-1.5 3.5])
% yline(0,'k-.')
% xline(0,'k-.')
print('Plots/ScatterPlots/210823_PMT1_timeSinceStroke','-dpng')


[RHO1,PVAL1] = corr(PM1(1:30,3), change(1:30,2),'Type','Spearman');
[RHO2,PVAL2] = corr(PM1(1:30,3), PM1(1:30,2),'Type','Spearman');
[RHO3,PVAL3] = corr(PM3(1:30,3), PM3(1:30,2),'Type','Spearman');
