%% extract from CSV and plot longitudinal data %% 
% created: 18.08.2021

% lognitudinal plotting, grouping, Position Matching (PM)

clear 
close all
clc

%% pre-processing

filename = 'data/20210818_DataNonImpaired.csv'; 
columnNrs = [92 109 114 122 127 144 160 170 142 123 148 146]; 
namesPlots = [{'AROM'},{'Force Ext'},{'Force Flex (N)'},{'Position Matching AE (deg)'},{'MAPR Slow (deg)'},{'Smoothness MAPR'},{'Max Velocity Extension'},{'MaxVel Flex'},{'Tracking Error RMSE (deg)'},{'Position Matching VE'},{'TrajFollow ROM'},{'TrajFollow minROM'}]; 
% ROM ForceE ForceF PM MAPRS MAPRF MaxVelE MaxVelF
axisDir = [0 0 0 1 1 1 0 0 1 1 0 1]; 
ID = [6 23 28 36 41 58 74 84 56 37 62 60];   

% run function to get data
C = extractLongitudinal_robotic(filename,columnNrs); 


%% split 

array = C; 
task = 2 + 4; 

    n = 1; 
    m = 1; 
    k = 1; 
    for i = 1:length(array(:,1))
        if array(i,2) == 1
                S1(n,:) = array(i,[1 task]);
                n = n+1; 
        elseif array(i,2) == 2
                S2(m,:) = array(i,[1 task]);
                m = m+1; 
        end
    end
    
% clean up and merge
%S3(26,:) = []; 

Lia = double(ismember(S1(:,1),S2(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

S = [S1 S2(:,2)]; 

S(1,:) = []; 
S(21,:) = [];
S(29,:) = []; 

%% mean across Sesh

Sesh1_mean = mean(S(:,2)); 
Sesh1_std = std(S(:,2)); 

Sesh3_mean = mean(S(:,3)); 
Sesh3_std = std(S(:,3));  

%% plot all points Sesh

figure; 
for i=1:length(S)
    p = plot(1:2, [S(i,2) S(i,3)],'-o','Linewidth',1);
    p.MarkerFaceColor = [0.7,0.7,0.7];
    p.Color = [0.7,0.7,0.7]; 
    hold on 
end
pM = plot(1:2,[Sesh1_mean Sesh3_mean],'d-', 'Linewidth',1);
pM.MarkerFaceColor = 'k';
pM.Color = 'k'; 
set (gca,'YDir','reverse')
xlim([0.5 2.5]) 
xticks([1 2]) 
xticklabels({'Inclusion','Discharge'})
ylim([0 30]) 
ylabel('Position Matching Error (deg)') 
print('Plots/LongitudinalPlots/robotic/210818_PM_InclDisch_NonImp','-dpng')

%% t-test between the two groups

[h1,p1] = ttest(S(:,2), S(:,3)); 

%% mark subjects that started from impaired side
% start from imapaired = 1
S(:,4) = [1 0 1 0 1 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 1 0 1 0 1 0 1 0 1 1]; 


Sesh_notImpStart = []; 
Sesh_ImpStart = []; 
n = 1;
m = 1; 
figure; 
for i=1:length(S)
    if S(i,4) == 0 
        p = plot(1:2, [S(i,2) S(i,3)],'-o');
        Sesh_notImpStart(n,:) = [S(i,2) S(i,3)];
        p.MarkerFaceColor = [153/255 204/255 255/255];
        p.Color = [153/255 204/255 255/255]; 
        hold on
        n = n+1; 
    else
        p = plot(1:2, [S(i,2) S(i,3)],'-o');
        Sesh_ImpStart(m,:) = [S(i,2) S(i,3)];
        p.MarkerFaceColor = [255/255 153/255 153/255]; 
        p.Color = [255/255 153/255 153/255]; 
        hold on 
        m = m +1; 
    end
end
% pM = plot(1:2,[S1_mean Sesh3_mean],'d-', 'Linewidth',3);
% pM.MarkerFaceColor = 'k';
% pM.Color = 'k'; 
set (gca,'YDir','reverse')
xlim([0.5 2.5]) 
xticks([1 2]) 
ylim([0 30])
print('Plots/LongitudinalPlots/robotic/210818_PM_InclDisch_withcolors_nonimp','-dpng')

% are both groups improving ? 

Sesh_notImpStart_mean(1) = mean(Sesh_notImpStart(:,1)); 
Sesh_notImpStart_mean(2) = mean(Sesh_notImpStart(:,2));
Sesh_ImpStart_mean(1) = mean(Sesh_ImpStart(:,1)); 
Sesh_ImpStart_mean(2) = mean(Sesh_ImpStart(:,2));




 