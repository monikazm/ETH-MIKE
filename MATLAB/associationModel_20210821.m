%% association model between motor and sensory scores %% 
% created: 20.08.2021
% metrics to start with: PM and AROM 

clear 
close all
clc

%% read table

T = readtable('data/20210811_DataImpaired.csv'); 

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

%% AROM vs PM 

Sensory = [S1(:,7);S2(:,7);S3(:,7)]; 
y = [S1(:,3);S2(:,3);S3(:,3)]; % AROM
Session = [S1(:,2);S2(:,2);S3(:,2)]; 
Subject = [S1(:,1);S2(:,1);S3(:,1)]; 

tbl = table(Subject,Session,Sensory,y); 

lme1 = fitlme(tbl,'y ~ 1 + Sensory + Session + (1|Subject)')

%% Force vs PM 

Sensory = [S1(:,7);S2(:,7);S3(:,7)]; 
y = [S1(:,4);S2(:,4);S3(:,4)]; % Force Flex

tbl = table(Subject,Session,Sensory,y); 

lme2 = fitlme(tbl,'y ~ 1 + Sensory + Session + (1|Subject)')

%% Max Vel Ext vs PM 

Sensory = [S1(:,7);S2(:,7);S3(:,7)]; 
y = [S1(:,5);S2(:,5);S3(:,5)]; % Vel Ext

tbl = table(Subject,Session,Sensory,y); 

lme3 = fitlme(tbl,'y ~ 1 + Sensory + Session + (1|Subject)')

%% PM vs all 3 motor scores

y = [S1(:,7);S2(:,7);S3(:,7)]; 
AROM = [S1(:,3);S2(:,3);S3(:,3)]; % AROM
ForceFlex = [S1(:,4);S2(:,4);S3(:,4)]; % Force
VelExt = [S1(:,5);S2(:,5);S3(:,5)]; % Velocity

tbl = table(Subject,Session,AROM, ForceFlex, VelExt ,y); 

lme4 = fitlme(tbl,'y ~ 1 + AROM + ForceFlex + VelExt + (1|Subject)')

%% PM vs all 3 motor scores + time since stroke 

% replace NaN for S30 with a meaningful value
S3(23,8) = S2(23,8) + 14; 

y = [S1(:,7);S2(:,7);S3(:,7)]; 
AROM = [S1(:,3);S2(:,3);S3(:,3)]; % AROM
ForceFlex = [S1(:,4);S2(:,4);S3(:,4)]; % Force
VelExt = [S1(:,5);S2(:,5);S3(:,5)]; % Velocity
TimeSinceStroke = [S1(:,8);S2(:,8);S3(:,8)];
Session = [S1(:,2);S2(:,2);S3(:,2)]; 

tbl = table(Subject,Session,AROM, ForceFlex, VelExt , TimeSinceStroke, y); 

lme4 = fitlme(tbl,'y ~ 1 + AROM + ForceFlex + VelExt + TimeSinceStroke + (1|Subject)')

%% PM vs time since stroke & initial kUDT

y = [S1(:,7);S2(:,7);S3(:,7)]; 
TimeSinceStroke = [S1(:,9); S2(:,9); S3(:,9)];
Session = [S1(:,2);S2(:,2);S3(:,2)]; 
Subject = [S1(:,1);S2(:,1);S3(:,1)]; 
InitialkUDT = [S1(:,8); S1(:,8); S1(:,8)];

tbl = table(Subject,Session,TimeSinceStroke,InitialkUDT,y);

lme5 = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + InitialkUDT + (1|Subject)')

%lme6 = fitlme(tbl,'y ~ 1 + Session + (1|Subject)')


% figure
% scatter(TimeSinceStroke,y, 'filled')
% xlabel('Time Since Stroke') 
% ylabel('Position Matching Error') 
% 
% figure
% scatter(Session,y)
% xlim([0.5 3.5])
% xlabel('Session nr.') 
% ylabel('Position Matching Error') 

%% Split the time frame into T1 vs T2 vs T3 

% T1 vs T2 

y = [S1(:,7);S2(:,7)]; 
TimeSinceStroke = [S1(:,9);S2(:,9)];
Session = [S1(:,2);S2(:,2)]; 
Subject = [S1(:,1);S2(:,1)]; 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme7 = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

% T1 vs T3 

y = [S1(:,7);S3(:,7)]; 
TimeSinceStroke = [S1(:,9);S3(:,9)];
Session = [S1(:,2);S3(:,2)]; 
Subject = [S1(:,1);S3(:,1)]; 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme8 = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')

% T2 vs T3 

y = [S2(:,7);S3(:,7)]; 
TimeSinceStroke = [S2(:,9);S3(:,9)];
Session = [S2(:,2);S3(:,2)]; 
Subject = [S2(:,1);S3(:,1)]; 

tbl = table(Subject,Session,TimeSinceStroke,y);

lme9 = fitlme(tbl,'y ~ 1 + TimeSinceStroke + Session + (1|Subject)')








