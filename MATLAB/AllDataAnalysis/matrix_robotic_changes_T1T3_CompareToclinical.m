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
% 46 - FM Sensory 
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

A = table2array(T(:,[3 5 47 41 48 46 122 114 92 160 8])); 
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
S3(33,8) = S1(33,8); 
S3(33,9) = S1(33,9); 
S3(33,10) = S1(33,10); 


%% Grouping - robotic

for i = 1:length(S1(:,1))
    if (S1(i,7)-S3(i,7) > 9.12 || (S1(i,7) > 10.64 && S3(i,7) <= 10.64)) && (((S3(i,8)-S1(i,8) > 4.88 || (S1(i,8) < 10.93 && S3(i,8) >= 10.93))) || ((S3(i,9)-S1(i,9) > 15.58 || (S1(i,9) < 63.20 && S3(i,9) >= 63.20))) || ((S3(i,10)-S1(i,10) > 60.68 || (S1(i,10) < 230 && S3(i,10) >= 230)))) 
       S1(i,13) = 1; % sensory
       S1(i,14) = 1; % motor
    elseif (S1(i,7)-S3(i,7) < 9.12) && (((S3(i,8)-S1(i,8) > 4.88 || (S1(i,8) < 10.93 && S3(i,8) >= 10.93))) || ((S3(i,9)-S1(i,9) > 15.58 || (S1(i,9) < 63.20 && S3(i,9) >= 63.20))) || ((S3(i,10)-S1(i,10) > 60.68 || (S1(i,10) < 230 && S3(i,10) >= 230)))) 
       S1(i,13) = 0; % sensory
       S1(i,14) = 1; % motor
    elseif (S1(i,7)-S3(i,7) > 9.12 || (S1(i,7) > 10.64 && S3(i,7) <= 10.64)) && (((S3(i,8)-S1(i,8) < 4.88) && (S3(i,9)-S1(i,9) < 15.58)) && (S3(i,10)-S1(i,10) < 60.68)) 
       S1(i,13) = 1; % sensory
       S1(i,14) = 0; % motor
    elseif  (S1(i,7)-S3(i,7) < 9.12 && (S1(i,7) < 10.64)) && (((S3(i,8)-S1(i,8) < 4.88 && (S1(i,8) > 10.93)) && (S3(i,9)-S1(i,9) < 15.58 && (S1(i,9) > 63.20))) || ((S3(i,8)-S1(i,8) < 4.88 && (S1(i,8) > 10.93)) && (S3(i,10)-S1(i,10) < 60.68 && (S1(i,10) > 230))) || ((S3(i,9)-S1(i,9) < 15.58 && (S1(i,9) > 63.20)) && (S3(i,10)-S1(i,10) < 60.68 && (S1(i,10) > 230)))) 
       S1(i,13) = 0; % sensory
       S1(i,14) = 0; % motor
    else
       S1(i,13) = 0; % sensory
       S1(i,14) = 0; % motor
    end
end

%% create sensory and motor changes groups - clinical

% kUDT
for i = 1:length(S1(:,1))
    if (S3(i,3)-S1(i,3) >= 1) 
       S1(i,15) = 1; % sensory
    elseif (S3(i,3)-S1(i,3) < 1) 
       S1(i,15) = 0; % sensory
    end
end

% FMA
for i = 1:length(S1(:,1))
    if (S3(i,4)-S1(i,4) >= 5.2) || (S1(i,4) < 60 && S3(i,4) >= 60) 
       S1(i,16) = 1; % motor
    elseif (S3(i,4)-S1(i,4) < 5.2) && (S1(i,4) < 60 && S3(i,4) < 60) 
       S1(i,16) = 0; % motor
    end
end


% FMA Sensory 
for i = 1:length(S1(:,1))
    if (S3(i,6)-S1(i,6) >= 2)
       S1(i,17) = 1; % sensory
    elseif (S3(i,6)-S1(i,6) < 2)
       S1(i,17) = 0; % sensory 
    end
end

%% confusion matrix - how do they match - prop. & kUDT 

kUDTchange_PMchange = sum(S1(:,15)==1 & S1(:,13)==1); 
kUDTchange_PMnonchange = sum(S1(:,15)==1 & S1(:,13)==0); 
kUDTnonchange_PMchange = sum(S1(:,15)==0 & S1(:,13)==1); 
kUDTnonchange_PMnonchange = sum(S1(:,15)==0 & S1(:,13)==0); 

accuracy.sensory = (kUDTchange_PMchange + kUDTnonchange_PMnonchange)./length(S1(:,15)); % 68%
C = [kUDTchange_PMchange kUDTnonchange_PMchange; kUDTchange_PMnonchange kUDTnonchange_PMnonchange]; 
label = {'Change';'No change'}; 

figure; 
Chart = confusionchart(C,label); 
Chart.OffDiagonalColor = [1 1 1]; %[0.9290 0.6940 0.1250]; 
Chart.DiagonalColor = [0.7 0.7 0.7]; %[0.4660 0.6740 0.1880]; 
Chart.OuterPosition = [0.1 0.1 0.8 0.8]; 
Chart.FontSize = 12; 
%Chart.InnerPosition = [0.1 0.1 0.8 0.8]; 
xlabel('Kinesthetic Up-Down Test')
ylabel('Gauge Position Matching Task') 
print('plots/ConfusionMatrices/211202_PM_kUDT_ChangeGroups','-dpng')

%% confusion matrix - how do they match - prop. & FMA Sensory

FMSchange_PMchange = sum(S1(:,17)==1 & S1(:,13)==1); 
FMSchange_PMnonchange = sum(S1(:,17)==1 & S1(:,13)==0); 
FMSnonchange_PMchange = sum(S1(:,17)==0 & S1(:,13)==1); 
FMSnonchange_PMnonchange = sum(S1(:,17)==0 & S1(:,13)==0); 

accuracy.sensory2 = (FMSchange_PMchange + FMSnonchange_PMnonchange)./length(S1(:,15)); % 58%

%% confusion matrix - how do they match - motor & FMA

FMAchange_Mchange = sum(S1(:,16)==1 & S1(:,14)==1); 
FMAchange_Mnonchange = sum(S1(:,16)==1 & S1(:,14)==0); 
FMAnonchange_Mchange = sum(S1(:,16)==0 & S1(:,14)==1); 
FMAnonchange_Mnonchange = sum(S1(:,16)==0 & S1(:,14)==0); 

accuracy.motor = (FMAchange_Mchange + FMAnonchange_Mnonchange)./length(S1(:,16)); % 58%
C = [FMAchange_Mchange FMAnonchange_Mchange; FMAchange_Mnonchange FMAnonchange_Mnonchange]; 
label = {'Change';'No change'}; 

figure; 
Chart = confusionchart(C,label); 
Chart.OffDiagonalColor = [1 1 1]; %[0.9290 0.6940 0.1250]; 
Chart.DiagonalColor = [0.7 0.7 0.7]; %[0.4660 0.6740 0.1880]; 
Chart.OuterPosition = [0.1 0.1 0.8 0.8]; 
Chart.FontSize = 12; 
%Chart.InnerPosition = [0.1 0.1 0.8 0.8]; 
xlabel('Fugl-Meyer Upper Limb Assessment')
ylabel('Robotic motor tasks') 
print('plots/ConfusionMatrices/211202_Motor_FMA_ChangeGroups','-dpng')




