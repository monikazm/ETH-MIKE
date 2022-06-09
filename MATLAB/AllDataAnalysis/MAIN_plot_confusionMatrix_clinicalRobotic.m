%% changes motor / sensory according to robotic, how do they compare to clinical  %% 
% created: 22.05.2022

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 47 - kUDT
% 41 - FM M UL
% 48 - BB imp 
% 44 - FMA Hand 
% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 127 - extension velocity 

A = table2array(T(:,[3 5 47 41 48 44 122 114 92 160])); 

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
        elseif C(i,2) == 2 && isnan(C(i,3))==0
            S3(m,:) = C(i,:);
            m = m+1;
        elseif C(i,2) == 3 && isnan(C(i,3))==0
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

S3(1,7) = 14.5926361100000; 
S3(32,8) = S1(32,8); 
S3(32,9) = S1(32,9); 
S3(32,10) = S1(32,10); 

%% add one missing subject entry (#40)

S1(43,1) = 40; 
S1(43,2) = 1; 
S1(43,3) = 2;
S1(43,4) = 51;
S1(43,5) = 31;
S1(43,6) = 12;
S1(43,7) = 14.4014303;
S1(43,8) = 5.891059822;
S1(43,9) = 60.00324717; 
S1(43,10) = 77.13920413; 

S3(43,1) = 40; 
S3(43,2) = 2; 
S3(43,3) = 3;
S3(43,4) = 54;
S3(43,5) = 15;
S3(43,6) = 11;
S3(43,7) = 10.81948228;
S3(43,8) = 7.140993862;
S3(43,9) = 52.25931944; 
S3(43,10) = 53.58038117;


%% Grouping - robotic

% sensory
for i = 1:length(S1(:,1))
    if (S1(i,7)-S3(i,7) > 9.12 || (S1(i,7) > 10.64 && S3(i,7) <= 10.64)) 
       S1(i,11) = 1; 
    else
       S1(i,11) = 0; 
    end
end
% motor 
for i = 1:length(S1(:,1))
    if (((S3(i,8)-S1(i,8) > 4.88 || (S1(i,8) < 10.93 && S3(i,8) >= 10.93))) || ((S3(i,9)-S1(i,9) > 15.58 || (S1(i,9) < 63.20 && S3(i,9) >= 63.20))) || ((S3(i,10)-S1(i,10) > 60.68 || (S1(i,10) < 230 && S3(i,10) >= 230)))) 
       S1(i,12) = 1; 
    else
       S1(i,12) = 0; 
    end
end

%% create sensory and motor changes groups - clinical

% kUDT
for i = 1:length(S1(:,1))
    if (S3(i,3)-S1(i,3) >= 1) 
       S1(i,13) = 1; 
    else
       S1(i,13) = 0; 
    end
end

% FMA
for i = 1:length(S1(:,1))
    if (S3(i,4)-S1(i,4) >= 5.2 || (S1(i,4) < 60 && S3(i,4) >= 60)) 
       S1(i,14) = 1;
    else
       S1(i,14) = 0; 
    end
end


% FMA Hand
for i = 1:length(S1(:,1))
    if (S3(i,6)-S1(i,6) >= 1) 
       S1(i,15) = 1;
    else
       S1(i,15) = 0; 
    end
end

%% confusion matrix - how do they match - prop. & kUDT 

kUDTchange_PMchange = sum(S1(:,13)==1 & S1(:,11)==1); 
kUDTchange_PMnonchange = sum(S1(:,13)==1 & S1(:,11)==0); 
kUDTnonchange_PMchange = sum(S1(:,13)==0 & S1(:,11)==1); 
kUDTnonchange_PMnonchange = sum(S1(:,13)==0 & S1(:,11)==0); 

accuracy.sensory = (kUDTchange_PMchange + kUDTnonchange_PMnonchange)./length(S1(:,13)); %60%
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
print('plots/Paper/20220522_FigureSM2A','-dpng')

%% confusion matrix - how do they match - motor & FMA

FMAchange_Mchange = sum(S1(:,14)==1 & S1(:,12)==1); 
FMAchange_Mnonchange = sum(S1(:,14)==1 & S1(:,12)==0); 
FMAnonchange_Mchange = sum(S1(:,14)==0 & S1(:,12)==1); 
FMAnonchange_Mnonchange = sum(S1(:,14)==0 & S1(:,12)==0); 

accuracy.motor = (FMAchange_Mchange + FMAnonchange_Mnonchange)./length(S1(:,14)); %53%
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
print('plots/Paper/20220522_FigureSM2B','-dpng')

%% confusion matrix - how do they match - motor & FMA

FMAHchange_Mchange = sum(S1(:,15)==1 & S1(:,12)==1); 
FMAHchange_Mnonchange = sum(S1(:,15)==1 & S1(:,12)==0); 
FMAHnonchange_Mchange = sum(S1(:,15)==0 & S1(:,12)==1); 
FMAHnonchange_Mnonchange = sum(S1(:,15)==0 & S1(:,12)==0); 

accuracy.motorHand = (FMAHchange_Mchange + FMAHnonchange_Mnonchange)./length(S1(:,14)); %53%
C = [FMAHchange_Mchange FMAHnonchange_Mchange; FMAHchange_Mnonchange FMAHnonchange_Mnonchange]; 
label = {'Change';'No change'}; 

figure; 
Chart = confusionchart(C,label); 
Chart.OffDiagonalColor = [1 1 1]; %[0.9290 0.6940 0.1250]; 
Chart.DiagonalColor = [0.7 0.7 0.7]; %[0.4660 0.6740 0.1880]; 
Chart.OuterPosition = [0.1 0.1 0.8 0.8]; 
Chart.FontSize = 12; 
%Chart.InnerPosition = [0.1 0.1 0.8 0.8]; 
xlabel('Fugl-Meyer Upper Limb Assessment - Hand')
ylabel('Robotic motor tasks') 
print('plots/Paper/20220522_FigureSM2C','-dpng')



