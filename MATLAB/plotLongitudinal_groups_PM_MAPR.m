%% extract from CSV and plot longitudinal data %% 
% created: 08.07.2021

% lognitudinal plotting, grouping based on PM, apply same group in AROM 

clear 
close all
clc

%% pre-processing

filename = 'data/20210702_DataImpaired.csv'; 
%filename = '20210408_DataImpaired.csv'; 
metricInfo = '20210121_metricInfo.csv'; 
columnNrs = [92 109 114 122 127 144 160 170 142 123 148 146]; 
namesPlots = [{'AROM'},{'Force Ext'},{'Force Flex (N)'},{'Position Matching AE (deg)'},{'MAPR Slow (deg)'},{'Smoothness MAPR'},{'Max Velocity Extension'},{'MaxVel Flex'},{'Tracking Error RMSE (deg)'},{'Position Matching VE'},{'TrajFollow ROM'},{'TrajFollow minROM'}]; 
% ROM ForceE ForceF PM MAPRS MAPRF MaxVelE MaxVelF
axisDir = [0 0 0 1 1 1 0 0 1 1 0 1]; 
ID = [6 23 28 36 41 58 74 84 56 37 62 60];   

% run function to get data
C = extractLongitudinal_robotic(filename,columnNrs); 


%% split into groups based on PM @ baseline 

array = C; 
task1 = 2 + 4; 
task2 = 2 + 5; 

    n = 1; 
    m = 1; 
    k = 1; 
    for i = 1:length(array(:,1))
        if array(i,2) == 1
                S1(n,:) = array(i,:);
                n = n+1; 
        elseif array(i,2) == 2
                S2(m,:) = array(i,:);
                m = m+1; 
        elseif array(i,2) == 3
                S3(k,:) = array(i,:);
                k = k+1; 
        end
    end
    
    n = 1; 
    m = 1; 
    k = 1; 
    PM_G1 = []; 
    PM_G2 = []; 
    PM_G3 = []; 
    for i = 1:length(S1(:,1))
        if S1(i,task1) <= 12
            PM_G3(n,1) = S1(i,1); 
            n = n+1; 
        elseif S1(i,task1) > 12 && S1(i,task1) <= 19
            PM_G2(m,1) = S1(i,1); 
            m = m+1; 
        elseif S1(i,task1) > 19
            PM_G1(k,1) = S1(i,1); 
            k = k+1; 
        end
    end

    
    
%%  Divide PM task into groups 

n = 1; 
for i = 1:length(PM_G1)
    PM_G1(n,2) = S1(find(S1(:,1)==PM_G1(i)),task1); 
    if isempty(S2(find(S2(:,1)==PM_G1(i)),task1)) == 0 
        PM_G1(n,3) = S2(find(S2(:,1)==PM_G1(i)),task1); 
    else
        PM_G1(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==PM_G1(i)),task1)) == 0 
        PM_G1(n,4) = S3(find(S3(:,1)==PM_G1(i)),task1);
    else
        PM_G1(n,4) = NaN; 
    end
    n = n+1; 
end
PM_G1_mean(1,1) = nanmean(PM_G1(:,2)); 
PM_G1_mean(1,2) = nanmean(PM_G1(:,3)); 
PM_G1_mean(1,3) = nanmean(PM_G1(:,4)); 
PM_G1_mean(2,1) = nanstd(PM_G1(:,2)); 
PM_G1_mean(2,2) = nanstd(PM_G1(:,3)); 
PM_G1_mean(2,3) = nanstd(PM_G1(:,4)); 

PM_G1_mean(1,4) = ((PM_G1_mean(1,3) - PM_G1_mean(1,1))/PM_G1_mean(1,3))*100;
PM_G1_mean(1,5) = PM_G1_mean(1,3) - PM_G1_mean(1,1); 


n = 1; 
for i = 1:length(PM_G2)
    PM_G2(n,2) = S1(find(S1(:,1)==PM_G2(i)),task1); 
    if isempty(S2(find(S2(:,1)==PM_G2(i)),task1)) == 0 
        PM_G2(n,3) = S2(find(S2(:,1)==PM_G2(i)),task1); 
    else
        PM_G2(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==PM_G2(i)),task1)) == 0 
        PM_G2(n,4) = S3(find(S3(:,1)==PM_G2(i)),task1);
    else
        PM_G2(n,4) = NaN; 
    end
    n = n+1; 
end
PM_G2(1,:) = []; 
PM_G2_mean(1,1) = nanmean(PM_G2(:,2)); 
PM_G2_mean(1,2) = nanmean(PM_G2(:,3)); 
PM_G2_mean(1,3) = nanmean(PM_G2(:,4)); 
PM_G2_mean(2,1) = nanstd(PM_G2(:,2)); 
PM_G2_mean(2,2) = nanstd(PM_G2(:,3)); 
PM_G2_mean(2,3) = nanstd(PM_G2(:,4)); 

PM_G2_mean(1,4) = ((PM_G2_mean(1,3) - PM_G2_mean(1,1))/PM_G2_mean(1,3))*100;
PM_G2_mean(1,5) = PM_G2_mean(1,3) - PM_G2_mean(1,1); 


n = 1; 
for i = 1:length(PM_G3)
    PM_G3(n,2) = S1(find(S1(:,1)==PM_G3(i)),task1); 
    if isempty(S2(find(S2(:,1)==PM_G3(i)),task1)) == 0 
        PM_G3(n,3) = S2(find(S2(:,1)==PM_G3(i)),task1); 
    else
        PM_G3(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==PM_G3(i)),task1)) == 0 
        PM_G3(n,4) = S3(find(S3(:,1)==PM_G3(i)),task1);
    else
        PM_G3(n,4) = NaN; 
    end
    n = n+1; 
end
PM_G3_mean(1,1) = nanmean(PM_G3(:,2)); 
PM_G3_mean(1,2) = nanmean(PM_G3(:,3)); 
PM_G3_mean(1,3) = nanmean(PM_G3(:,4)); 
PM_G3_mean(2,1) = nanstd(PM_G3(:,2)); 
PM_G3_mean(2,2) = nanstd(PM_G3(:,3)); 
PM_G3_mean(2,3) = nanstd(PM_G3(:,4)); 

PM_G3_mean(1,4) = ((PM_G3_mean(1,3) - PM_G3_mean(1,1))/PM_G3_mean(1,3))*100;
PM_G3_mean(1,5) = PM_G3_mean(1,3) - PM_G3_mean(1,1); 

%%  Divide AROM task into groups 
MAPR_G1(:,1) = PM_G1(:,1); 
MAPR_G2(:,1) = PM_G2(:,1); 
MAPR_G3(:,1) = PM_G3(:,1); 

n = 1; 
for i = 1:length(MAPR_G1)
    MAPR_G1(n,2) = S1(find(S1(:,1)==MAPR_G1(i)),task2); 
    if isempty(S2(find(S2(:,1)==MAPR_G1(i)),task2)) == 0 
        MAPR_G1(n,3) = S2(find(S2(:,1)==MAPR_G1(i)),task2); 
    else
        MAPR_G1(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==MAPR_G1(i)),task2)) == 0 
        MAPR_G1(n,4) = S3(find(S3(:,1)==MAPR_G1(i)),task2);
    else
        MAPR_G1(n,4) = NaN; 
    end
    n = n+1; 
end
MAPR_G1_mean(1,1) = nanmean(MAPR_G1(:,2)); 
MAPR_G1_mean(1,2) = nanmean(MAPR_G1(:,3)); 
MAPR_G1_mean(1,3) = nanmean(MAPR_G1(:,4)); 
MAPR_G1_mean(2,1) = nanstd(MAPR_G1(:,2)); 
MAPR_G1_mean(2,2) = nanstd(MAPR_G1(:,3)); 
MAPR_G1_mean(2,3) = nanstd(MAPR_G1(:,4)); 

MAPR_G1_mean(1,4) = ((MAPR_G1_mean(1,3) - MAPR_G1_mean(1,1))/MAPR_G1_mean(1,3))*100;
MAPR_G1_mean(1,5) = MAPR_G1_mean(1,3) - MAPR_G1_mean(1,1); 


n = 1; 
for i = 1:length(MAPR_G2)
    MAPR_G2(n,2) = S1(find(S1(:,1)==MAPR_G2(i)),task2); 
    if isempty(S2(find(S2(:,1)==MAPR_G2(i)),task2)) == 0 
        MAPR_G2(n,3) = S2(find(S2(:,1)==MAPR_G2(i)),task2); 
    else
        MAPR_G2(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==MAPR_G2(i)),task2)) == 0 
        MAPR_G2(n,4) = S3(find(S3(:,1)==MAPR_G2(i)),task2);
    else
        MAPR_G2(n,4) = NaN; 
    end
    n = n+1; 
end
MAPR_G2(1,:) = []; 
MAPR_G2_mean(1,1) = nanmean(MAPR_G2(:,2)); 
MAPR_G2_mean(1,2) = nanmean(MAPR_G2(:,3)); 
MAPR_G2_mean(1,3) = nanmean(MAPR_G2(:,4)); 
MAPR_G2_mean(2,1) = nanstd(MAPR_G2(:,2)); 
MAPR_G2_mean(2,2) = nanstd(MAPR_G2(:,3)); 
MAPR_G2_mean(2,3) = nanstd(MAPR_G2(:,4)); 

MAPR_G2_mean(1,4) = ((MAPR_G2_mean(1,3) - MAPR_G2_mean(1,1))/MAPR_G2_mean(1,3))*100;
MAPR_G2_mean(1,5) = MAPR_G2_mean(1,3) - MAPR_G2_mean(1,1); 


n = 1; 
for i = 1:length(MAPR_G3)
    MAPR_G3(n,2) = S1(find(S1(:,1)==MAPR_G3(i)),task2); 
    if isempty(S2(find(S2(:,1)==MAPR_G3(i)),task2)) == 0 
        MAPR_G3(n,3) = S2(find(S2(:,1)==MAPR_G3(i)),task2); 
    else
        MAPR_G3(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==MAPR_G3(i)),task2)) == 0 
        MAPR_G3(n,4) = S3(find(S3(:,1)==MAPR_G3(i)),task2);
    else
        MAPR_G3(n,4) = NaN; 
    end
    n = n+1; 
end
MAPR_G3_mean(1,1) = nanmean(MAPR_G3(:,2)); 
MAPR_G3_mean(1,2) = nanmean(MAPR_G3(:,3)); 
MAPR_G3_mean(1,3) = nanmean(MAPR_G3(:,4)); 
MAPR_G3_mean(2,1) = nanstd(MAPR_G3(:,2)); 
MAPR_G3_mean(2,2) = nanstd(MAPR_G3(:,3)); 
MAPR_G3_mean(2,3) = nanstd(MAPR_G3(:,4)); 

MAPR_G3_mean(1,4) = ((MAPR_G3_mean(1,3) - MAPR_G3_mean(1,1))/MAPR_G3_mean(1,3))*100;
MAPR_G3_mean(1,5) = MAPR_G3_mean(1,3) - MAPR_G3_mean(1,1);

%% plot all the groups - PM 

figure; 
for i=1:length(PM_G1)
    gr1 = plot(1:3, PM_G1(i,2:4), 'o-');
    gr1.MarkerFaceColor = 'r';
    gr1.Color = 'r'; 
    hold on 
end

for i=1:length(PM_G2)
    gr2 = plot(1:3, PM_G2(i,2:4), 'o-');
    gr2.MarkerFaceColor = [0.9290, 0.6940, 0.1250];
    gr2.Color = [0.9290, 0.6940, 0.1250]; 
    hold on 
end


for i=1:length(PM_G3)
    gr3 = plot(1:3, PM_G3(i,2:4), 'o-');
    gr3.MarkerFaceColor = [0.4660, 0.6740, 0.1880];
    gr3.Color = [0.4660, 0.6740, 0.1880]; 
    hold on 
end

gr1M = plot(1:3,[PM_G1_mean(1,1) PM_G1_mean(1,2) PM_G1_mean(1,3)],'d-', 'Linewidth',3); 
gr1M.MarkerFaceColor = 'r';
gr1M.Color = 'r'; 
hold on 
gr2M = plot(1:3,[PM_G2_mean(1,1) PM_G2_mean(1,2) PM_G2_mean(1,3)],'d-', 'Linewidth',3); 
gr2M.MarkerFaceColor = [0.9290, 0.6940, 0.1250];
gr2M.Color = [0.9290, 0.6940, 0.1250];
hold on 
gr3M = plot(1:3,[PM_G3_mean(1,1) PM_G3_mean(1,2) PM_G3_mean(1,3)],'d-', 'Linewidth',3); 
gr3M.MarkerFaceColor = [0.4660, 0.6740, 0.1880];
gr3M.Color = [0.4660, 0.6740, 0.1880];
hold on 
%ylim([-5 110])
xlim([0.5 3.5])
xticks([1 2 3]) 
set (gca,'YDir','reverse')
xlabel('Robotic Session Nr.') 
ylabel('Position Matching Error (deg)') 
print('Plots/LongitudinalPlots/robotic/groups/210701_Sum_PM_groups','-dpng')

 %% plot all the groups - AROM 

figure; 
for i=1:length(MAPR_G1)
    gr1 = plot(1:3, MAPR_G1(i,2:4), 'o-');
    gr1.MarkerFaceColor = 'r';
    gr1.Color = 'r'; 
    hold on 
end

for i=1:length(MAPR_G2)
    gr2 = plot(1:3, MAPR_G2(i,2:4), 'o-');
    gr2.MarkerFaceColor = [0.9290, 0.6940, 0.1250];
    gr2.Color = [0.9290, 0.6940, 0.1250]; 
    hold on 
end


for i=1:length(MAPR_G3)
    gr3 = plot(1:3, MAPR_G3(i,2:4), 'o-');
    gr3.MarkerFaceColor = [0.4660, 0.6740, 0.1880];
    gr3.Color = [0.4660, 0.6740, 0.1880]; 
    hold on 
end

gr1M = plot(1:3,[MAPR_G1_mean(1,1) MAPR_G1_mean(1,2) MAPR_G1_mean(1,3)],'d-', 'Linewidth',3); 
gr1M.MarkerFaceColor = 'r';
gr1M.Color = 'r'; 
hold on 
gr2M = plot(1:3,[MAPR_G2_mean(1,1) MAPR_G2_mean(1,2) MAPR_G2_mean(1,3)],'d-', 'Linewidth',3); 
gr2M.MarkerFaceColor = [0.9290, 0.6940, 0.1250];
gr2M.Color = [0.9290, 0.6940, 0.1250];
hold on 
gr3M = plot(1:3,[MAPR_G3_mean(1,1) MAPR_G3_mean(1,2) MAPR_G3_mean(1,3)],'d-', 'Linewidth',3); 
gr3M.MarkerFaceColor = [0.4660, 0.6740, 0.1880];
gr3M.Color = [0.4660, 0.6740, 0.1880];
hold on 
ylim([0.1 1.05])
xlim([0.5 3.5])
xticks([1 2 3]) 
set(gca,'YDir','reverse')
xlabel('Robotic Session Nr.') 
ylabel('Tracking Smoothness MAPR') 
print('Plots/LongitudinalPlots/robotic/groups/210708_Sum_MAPR_groups_basedOnPM','-dpng')

