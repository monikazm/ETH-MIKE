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


%% mean

MeanTimeSinceStroke(1) = nanmean(PM1(:,3)); 
MeanTimeSinceStroke(2) = nanmean(PM3(:,3)); 

