%% extract from CSV and plot longitudinal data %% 
% created: 02.07.2021

% lognitudinal plotting, grouping, Position Matching (PM)

clear 
close all
clc

%% pre-processing

filename = 'data/20210811_DataImpaired.csv'; 
%filename = '20210408_DataImpaired.csv'; 
metricInfo = '20210121_metricInfo.csv'; 
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
        elseif array(i,2) == 3
                S3(k,:) = array(i,[1 task]);
                k = k+1; 
        end
    end
    
% clean up and merge
S3(26,:) = []; 

Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];
  
Lia = double(ismember(S2(:,1),S3(:,1))); 
S2(:,1) = Lia.*S2(:,1); 
S2(S2(:,1)==0,:)= [];

S = [S1 S2(:,2) S3(:,2)]; 

S(1,:) = []; 
S(13,3) = 20.0; 

%% mark subjects that started from impaired side
% start from imapaired = 1
S(:,5) = [0 1 0 1 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 1 0 1 0 1 1 0 1 1]; 

%% mean across all

S1_mean = mean(S(:,2)); 
S1_std = std(S(:,2)); 

S2_mean = mean(S(:,3)); 
S2_std = std(S(:,3)); 

S3_mean = mean(S(:,4)); 
S3_std = std(S(:,4)); 

%% plot all points
figure; 
for i=1:length(S)
    p = plot(1:3, [S(i,2) S(i,3) S(i,4)],'-o', 'Linewidth',1);
    p.MarkerFaceColor = [0.7 0.7 0.7];
    p.Color = [0.7 0.7 0.7]; 
    hold on 
end
pM = plot(1:3,[S1_mean S2_mean S3_mean],'d-', 'Linewidth',1);
pM.MarkerFaceColor = 'k';
pM.Color = 'k'; 
set (gca,'YDir','reverse')
xlim([0.5 3.5]) 
xticks([1 2 3]) 
ylim([0 30]) 
xlabel('Robotic session nr.') 
ylabel('Position Matching Error (deg)') 
print('Plots/LongitudinalPlots/robotic/210819_PM_3sessions','-dpng')

%% t-test between the two groups

[h1,p1] = ttest(S(:,2), S(:,4)); 

%% plot with starting hand 
S_notImpStart = []; 
S_ImpStart = []; 

n = 1; 
m = 1; 
figure; 
for i=1:length(S)
    if S(i,5) == 0 
        p = plot(1:3, [S(i,2) S(i,3) S(i,4)],'-o');
        S_notImpStart(n,:) = [S(i,2) S(i,3) S(i,4)]; 
        p.MarkerFaceColor = [153/255 204/255 255/255]; % blue: start not impaired 
        p.Color = [153/255 204/255 255/255]; 
        hold on 
        n = n +1; 
    else
        p = plot(1:3, [S(i,2) S(i,3) S(i,4)],'-o');
        S_ImpStart(m,:) = [S(i,2) S(i,3) S(i,4)];
        p.MarkerFaceColor = [255/255 153/255 153/255]; % red: start impaired 
        p.Color = [255/255 153/255 153/255]; 
        hold on
        m = m +1; 
    end
end
% pM = plot(1:2,[S1_mean Sesh3_mean],'d-', 'Linewidth',3);
% pM.MarkerFaceColor = 'k';
% pM.Color = 'k'; 
set (gca,'YDir','reverse')
xlim([0.5 3.5]) 
xticks([1 2 3]) 
ylim([0 30])
print('Plots/LongitudinalPlots/robotic/210817_PM_3sessions_withColors','-dpng')

S_notImpStart_mean(1) = mean(S_notImpStart(:,1)); 
S_notImpStart_mean(2) = mean(S_notImpStart(:,2)); 
S_notImpStart_mean(3) = mean(S_notImpStart(:,3));
S_ImpStart_mean(1) = mean(S_ImpStart(:,1));
S_ImpStart_mean(2) = mean(S_ImpStart(:,2));
S_ImpStart_mean(3) = mean(S_ImpStart(:,3));

%% what if I only consider inclusion and discharge and take all the subjects - will t-test be significant?

%% clean-up the table 

T = readtable('data/20210811_DataImpaired.csv'); 

A = table2array(T(:,[3 5 122])); 

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

%% combine 
Lia = double(ismember(Sesh1(:,1),Sesh3(:,1))); 
Sesh1(:,1) = Lia.*Sesh1(:,1); 
Sesh1(Sesh1(:,1)==0,:)= [];

Sesh = [Sesh1(:,1) Sesh1(:,3) Sesh3(:,3)]; 
Sesh(1,:) = []; 

%% mean across Sesh

Sesh1_mean = mean(Sesh1(:,3)); 
Sesh1_std = std(Sesh1(:,3)); 

Sesh3_mean = mean(Sesh3(:,3)); 
Sesh3_std = std(Sesh3(:,3));  

%% plot all points Sesh

figure; 
for i=1:length(Sesh)
    p = plot(1:2, [Sesh(i,2) Sesh(i,3)],'-o','Linewidth',1);
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
print('Plots/LongitudinalPlots/robotic/210817_PM_InclDisch','-dpng')

%% t-test between the two groups

[h2,p2] = ttest(Sesh(:,2), Sesh(:,3)); 

%% mark subjects that started from impaired side
% start from imapaired = 1
Sesh(:,4) = [1 0 1 0 1 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 1 0 1 0 1 0 1 0 1 1]; 


Sesh_notImpStart = []; 
Sesh_ImpStart = []; 
n = 1;
m = 1; 
figure; 
for i=1:length(Sesh)
    if Sesh(i,4) == 0 
        p = plot(1:2, [Sesh(i,2) Sesh(i,3)],'-o');
        Sesh_notImpStart(n,:) = [Sesh(i,2) Sesh(i,3)];
        p.MarkerFaceColor = [153/255 204/255 255/255];
        p.Color = [153/255 204/255 255/255]; 
        hold on
        n = n+1; 
    else
        p = plot(1:2, [Sesh(i,2) Sesh(i,3)],'-o');
        Sesh_ImpStart(m,:) = [Sesh(i,2) Sesh(i,3)];
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
print('Plots/LongitudinalPlots/robotic/210817_PM_InclDisch_withcolors','-dpng')

% are both groups improving ? 

Sesh_notImpStart_mean(1) = mean(Sesh_notImpStart(:,1)); 
Sesh_notImpStart_mean(2) = mean(Sesh_notImpStart(:,2));
Sesh_ImpStart_mean(1) = mean(Sesh_ImpStart(:,1)); 
Sesh_ImpStart_mean(2) = mean(Sesh_ImpStart(:,2));




 