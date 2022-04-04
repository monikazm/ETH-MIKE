%% Robotic task score vs Time Since Stroke %% 
% created: 04.05.2021

clear 
close all
clc

% start with positon matching 
colors = {  [0.8500, 0.3250, 0.0980]
            [1, 0, 0]    
          	[0.9290, 0.6940, 0.1250]	          	
          	[0.4940, 0.1840, 0.5560]	          	
          	[0.4660, 0.6740, 0.1880]	          	
          	[0.3010, 0.7450, 0.9330]	          	 
          	[0.6350, 0.0780, 0.1840]	
            [0.25, 0.25, 0.25]
            [0.1, 0.7, 0]
            [0, 0.4470, 0.7410] 
            [0.75, 0, 0.75]
            [0.75, 0.75, 0]
            [0, 0, 1]
            [178/255, 255/255, 102/255]
            [0.75, 0.75, 0.75]
            [0.8, 0.4, 0]
            [0.25, 0.75, 0.5]
            [1.0, 0.4, 0.6]
            [0.45, 0.65, 0.87]
            [0.7, 0.6, 0.5]
            [1, 0.6, 0.1]
            [0.65, 0.32, 0.12]
            [0, 0.4470, 0.7410]
            [0.8500, 0.3250, 0.0980]	
            [0.9290, 0.6940, 0.1250]	
            [0.4940, 0.1840, 0.5560]	
            [0.453, 0.587, 0.978]
            [102/255 255/255 102/255]
            [255/255 128/255 0/255]
            [204/255 0/255 204/255]
            [102/255 178/255 255/255]
            };

%% read table %% 

T = readtable('data/20210517_DataImpaired.csv'); 

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
    txt = ['Nr = ',num2str(PM1(i,1))];
    P = plot([PM1(i,3) PM3(i,3)], [PM1(i,2) PM3(i,2)],'o-','DisplayName',txt);    
    P.MarkerFaceColor = colors{PM1(i,1)}; 
    P.MarkerEdgeColor = colors{PM1(i,1)}; 
    P.Color = colors{PM1(i,1)}; 
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
print('Plots/LongitudinalPlots/robotic/210518_PM_timeSinceStroke','-dpng')




