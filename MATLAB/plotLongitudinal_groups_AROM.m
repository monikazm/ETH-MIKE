%% extract from CSV and plot longitudinal data %% 
% created: 01.07.2021

% lognitudinal plotting, grouping, AROM 

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

% run functions 
C = extractLongitudinal_robotic(filename,columnNrs); 


%% plot 
%plotLongitudinal_robotic(C,namesPlots,axisDir)

array = C; 

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
    G1 = []; 
    for i = 1:length(S1(:,1))
        if S1(i,3) <= 25
            G1(n,1) = S1(i,1); 
            n = n+1; 
        elseif S1(i,3) > 25 && S1(i,3) <= 60
            G2(m,1) = S1(i,1); 
            m = m+1; 
        elseif S1(i,3) > 60
            G3(k,1) = S1(i,1); 
            k = k+1; 
        end
    end
    
n = 1; 
for i = 1:length(G1)
    G1(n,2) = S1(find(S1(:,1)==G1(i)),3); 
    if isempty(S2(find(S2(:,1)==G1(i)),3)) == 0 
        G1(n,3) = S2(find(S2(:,1)==G1(i)),3); 
    else
        G1(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==G1(i)),3)) == 0 
        G1(n,4) = S3(find(S3(:,1)==G1(i)),3);
    else
        G1(n,4) = NaN; 
    end
    n = n+1; 
end
G1_mean(1,1) = nanmean(G1(:,2)); 
G1_mean(1,2) = nanmean(G1(:,3)); 
G1_mean(1,3) = nanmean(G1(:,4)); 
G1_mean(2,1) = nanstd(G1(:,2)); 
G1_mean(2,2) = nanstd(G1(:,3)); 
G1_mean(2,3) = nanstd(G1(:,4)); 

G1_mean(1,4) = ((G1_mean(1,3) - G1_mean(1,1))/G1_mean(1,3))*100;
G1_mean(1,5) = G1_mean(1,3) - G1_mean(1,1); 

n = 1; 
for i = 1:length(G2)
    G2(n,2) = S1(find(S1(:,1)==G2(i)),3); 
    if isempty(S2(find(S2(:,1)==G2(i)),3)) == 0 
        G2(n,3) = S2(find(S2(:,1)==G2(i)),3); 
    else
        G2(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==G2(i)),3)) == 0 
        G2(n,4) = S3(find(S3(:,1)==G2(i)),3);
    else
        G2(n,4) = NaN; 
    end
    n = n+1; 
end
G2_mean(1,1) = nanmean(G2(:,2)); 
G2_mean(1,2) = nanmean(G2(:,3)); 
G2_mean(1,3) = nanmean(G2(:,4)); 
G2_mean(2,1) = nanstd(G2(:,2)); 
G2_mean(2,2) = nanstd(G2(:,3)); 
G2_mean(2,3) = nanstd(G2(:,4)); 

G2_mean(1,4) = ((G2_mean(1,3) - G2_mean(1,1))/G2_mean(1,3))*100;
G2_mean(1,5) = G2_mean(1,3) - G2_mean(1,1); 

n = 1; 
for i = 1:length(G3)
    G3(n,2) = S1(find(S1(:,1)==G3(i)),3); 
    if isempty(S2(find(S2(:,1)==G3(i)),3)) == 0 
        G3(n,3) = S2(find(S2(:,1)==G3(i)),3); 
    else
        G3(n,3) = NaN; 
    end
    if isempty(S3(find(S3(:,1)==G3(i)),3)) == 0 
        G3(n,4) = S3(find(S3(:,1)==G3(i)),3);
    else
        G3(n,4) = NaN; 
    end
    n = n+1; 
end
G3_mean(1,1) = nanmean(G3(:,2)); 
G3_mean(1,2) = nanmean(G3(:,3)); 
G3_mean(1,3) = nanmean(G3(:,4)); 
G3_mean(2,1) = nanstd(G3(:,2)); 
G3_mean(2,2) = nanstd(G3(:,3)); 
G3_mean(2,3) = nanstd(G3(:,4)); 

G3_mean(1,4) = ((G3_mean(1,3) - G3_mean(1,1))/G3_mean(1,3))*100;
G3_mean(1,5) = G3_mean(1,3) - G3_mean(1,1); 

%% plot all the groups 

figure; 
for i=1:length(G1)
    gr1 = plot(1:3, G1(i,2:4), 'o-');
    gr1.MarkerFaceColor = 'r';
    gr1.Color = 'r'; 
    hold on 
end

for i=1:length(G2)
    gr2 = plot(1:3, G2(i,2:4), 'o-');
    gr2.MarkerFaceColor = [0.9290, 0.6940, 0.1250];
    gr2.Color = [0.9290, 0.6940, 0.1250]; 
    hold on 
end

for i=1:length(G3)
    gr3 = plot(1:3, G3(i,2:4), 'o-');
    gr3.MarkerFaceColor = [0.4660, 0.6740, 0.1880];
    gr3.Color = [0.4660, 0.6740, 0.1880]; 
    hold on 
end

gr1M = plot(1:3,[G1_mean(1,1) G1_mean(1,2) G1_mean(1,3)],'d-', 'Linewidth',3); 
gr1M.MarkerFaceColor = 'r';
gr1M.Color = 'r'; 
hold on 
gr2M = plot(1:3,[G2_mean(1,1) G2_mean(1,2) G2_mean(1,3)],'d-', 'Linewidth',3); 
gr2M.MarkerFaceColor = [0.9290, 0.6940, 0.1250];
gr2M.Color = [0.9290, 0.6940, 0.1250];
hold on 
gr3M = plot(1:3,[G3_mean(1,1) G3_mean(1,2) G3_mean(1,3)],'d-', 'Linewidth',3); 
gr3M.MarkerFaceColor = [0.4660, 0.6740, 0.1880];
gr3M.Color = [0.4660, 0.6740, 0.1880];
hold on 
ylim([-5 110])
xlim([0.5 3.5])
xticks([1 2 3]) 
xlabel('Robotic Session Nr.') 
ylabel('Active Range of Motion (deg)') 
print('Plots/LongitudinalPlots/robotic/groups/210701_Sum_AROM_groups','-dpng')

