%% ttests to define if change is significant %% 
% also calculate mean & std for each metric 
% created: 12.10.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

%T = readtable('data/20210914_DataImpaired.csv'); 
T = readtable('data/20211013_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR
% 48 - BB imp 

A = table2array(T(:,[3 5 92 114 160 127 122 47 41 48])); 

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

S3(1,7) = S2(1,7); 
S2(13,7) = 20;  

%% plot change vs initial impairment 

figure; 
scatter(110-S1(:,3),S3(:,3)-S1(:,3),'filled') 
hold on 
labelpoints(110-S1(:,3),S3(:,3)-S1(:,3),string(S1(:,1))); 
xlabel('Max AROM - AROM @ T1 (deg)')
ylabel('Delta AROM (deg)')
print('plots/ScatterPlots/211122_ROM_Delta_Initial','-dpng')

%% change in Max Force vs initial Max Force

figure; 
scatter(55-S1(:,4),S3(:,4)-S1(:,4),'filled') 
hold on 
labelpoints(55-S1(:,4),S3(:,4)-S1(:,4),string(S1(:,1))); 

%% change in Max Vel vs initial Max Vel

figure; 
scatter(400-S1(:,5),S3(:,5)-S1(:,5),'filled') 
hold on 
labelpoints(400-S1(:,5),S3(:,5)-S1(:,5),string(S1(:,1))); 
ylim([-200 200]) 

%% motor-sensory

% Force
figure; 
scatter(S1(:,7),S3(:,4)-S1(:,4),'filled') 
xlabel('Position Matching Absoluter Error (deg) @ T1')
ylabel('Delta Maximum Force Flexion (N)') 
print('plots/ScatterPlots/211122_MaxForce_Delta_InitialPM','-dpng')


% ROM
figure; 
scatter(S1(:,7),S3(:,3)-S1(:,3),'filled') 
xlabel('Position Matching Absoluter Error (deg) @ T1')
ylabel('Delta Active Range of Motion (deg)') 
print('plots/ScatterPlots/211122_ROM_Delta_InitialPM','-dpng')

%Max Vel 
figure; 
scatter(S1(:,7),S3(:,5)-S1(:,5),'filled') 
xlabel('Position Matching Absoluter Error (deg) @ T1')
ylabel('Delta Maximum Velocity Extension (deg/s)') 
print('plots/ScatterPlots/211122_MaxVel_Delta_InitialPM','-dpng')

% Box & Block test 
figure; 
scatter(S1(:,7),S3(:,10)-S1(:,10),'filled') 
xlabel('Position Matching Absoluter Error (deg) @ T1')
ylabel('Delta Box & Block Test') 
print('plots/ScatterPlots/211122_BBT_Delta_InitialPM','-dpng')

%% change vs initial FMA

figure; 
scatter(66-S1(:,9),S3(:,4)-S1(:,4),'filled') 

%% groups according to impairment severity - ROM

group1 = []; 
group2 = []; 
group3 = []; 
n = 1; 
m = 1; 
k = 1; 
for i = 1:length(S1(:,1))
    if S1(i,9)< 10
        group1(n,1) = S1(i,1); 
        group1(n,2) = S1(i,3); 
        group1(n,3) = S3(i,3); 
        group1(n,4) = S3(i,3) - S1(i,3); 
        n = n+1; 
    elseif S1(i,9)>= 10 && S1(i,9)< 54
        group2(m,1) = S1(i,1); 
        group2(m,2) = S1(i,3); 
        group2(m,3) = S3(i,3);
        group2(m,4) = S3(i,3) - S1(i,3); 
        m = m+1; 
    elseif S1(i,9)>= 54
        group3(k,1) = S1(i,1); 
        group3(k,2) = S1(i,3); 
        group3(k,3) = S3(i,3);
        group3(k,4) = S3(i,3) - S1(i,3); 
        k = k + 1; 
    end
end

g1 = repmat({'Severe'},length(group1(:,1)),1);
g2 = repmat({'Moderate'},length(group2(:,1)),1);
g3 = repmat({'Mild'},length(group3(:,1)),1);
g = [g1;g2;g3];

figure; 
boxplot([group1(:,4); group2(:,4); group3(:,4)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(group1(:,4))
    scatter(1,group1(i,4),'filled','k'); 
end
hold on 
for i=1:length(group2(:,4))
    scatter(2,group2(i,4),'filled','k'); 
end
hold on 
for i=1:length(group3(:,4))
    scatter(3,group3(i,4),'filled','k'); 
end
xlabel('Fugl-Meyer Upper Limb Motor @ T1') 
ylabel('Delta Active Range of Motion (deg)') 
print('plots/BoxPlots/211122_FMAIni_AROM_Delta','-dpng')


figure; 
boxplot([group1(:,2); group2(:,2); group3(:,2)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(group1(:,2))
    scatter(1,group1(i,2),'filled','k'); 
end
hold on 
for i=1:length(group2(:,2))
    scatter(2,group2(i,2),'filled','k'); 
end
hold on 
for i=1:length(group3(:,2))
    scatter(3,group3(i,2),'filled','k'); 
end
xlabel('Fugl-Meyer Upper Limb Motor @ T1') 
ylabel('Active Range of Motion (deg) @ T1') 
print('plots/BoxPlots/211122_FMAIni_AROM_Init','-dpng')


%% groups according to impairment severity - Max Force 

group1 = []; 
group2 = []; 
group3 = []; 
n = 1; 
m = 1; 
k = 1; 
for i = 1:length(S1(:,1))
    if S1(i,9)< 10
        group1(n,1) = S1(i,1); 
        group1(n,2) = S1(i,4); 
        group1(n,3) = S3(i,4); 
        group1(n,4) = S3(i,4) - S1(i,4); 
        n = n+1; 
    elseif S1(i,9)>= 10 && S1(i,9)< 54
        group2(m,1) = S1(i,1); 
        group2(m,2) = S1(i,4); 
        group2(m,3) = S3(i,4);
        group2(m,4) = S3(i,4) - S1(i,4); 
        m = m+1; 
    elseif S1(i,9)>= 54
        group3(k,1) = S1(i,1); 
        group3(k,2) = S1(i,4); 
        group3(k,3) = S3(i,4);
        group3(k,4) = S3(i,4) - S1(i,4); 
        k = k + 1; 
    end
end

g1 = repmat({'Severe'},length(group1(:,1)),1);
g2 = repmat({'Moderate'},length(group2(:,1)),1);
g3 = repmat({'Mild'},length(group3(:,1)),1);
g = [g1;g2;g3];

figure; 
boxplot([group1(:,4); group2(:,4); group3(:,4)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(group1(:,4))
    scatter(1,group1(i,4),'filled','k'); 
end
hold on 
for i=1:length(group2(:,4))
    scatter(2,group2(i,4),'filled','k'); 
end
hold on 
for i=1:length(group3(:,4))
    scatter(3,group3(i,4),'filled','k'); 
end
xlabel('Fugl-Meyer Upper Limb Motor @ T1') 
ylabel('Delta Maximum Force Flexion (N)') 
print('plots/BoxPlots/211122_FMAIni_MaxForceFlex_Delta','-dpng')


%% groups according to impairment severity - FMA

group1 = []; 
group2 = []; 
group3 = []; 
n = 1; 
m = 1; 
k = 1; 
for i = 1:length(S1(:,1))
    if S1(i,9)< 10
        group1(n,1) = S1(i,1); 
        group1(n,2) = S1(i,9); 
        group1(n,3) = S3(i,9); 
        group1(n,4) = S3(i,9) - S1(i,9); 
        n = n+1; 
    elseif S1(i,9)>= 10 && S1(i,9)< 54
        group2(m,1) = S1(i,1); 
        group2(m,2) = S1(i,9); 
        group2(m,3) = S3(i,9);
        group2(m,4) = S3(i,9) - S1(i,9); 
        m = m+1; 
    elseif S1(i,9)>= 54
        group3(k,1) = S1(i,1); 
        group3(k,2) = S1(i,9); 
        group3(k,3) = S3(i,9);
        group3(k,4) = S3(i,9) - S1(i,9); 
        k = k + 1; 
    end
end

g1 = repmat({'Severe'},length(group1(:,1)),1);
g2 = repmat({'Moderate'},length(group2(:,1)),1);
g3 = repmat({'Mild'},length(group3(:,1)),1);
g = [g1;g2;g3];

figure; 
boxplot([group1(:,4); group2(:,4); group3(:,4)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(group1(:,4))
    scatter(1,group1(i,4),'filled','k'); 
end
hold on 
for i=1:length(group2(:,4))
    scatter(2,group2(i,4),'filled','k'); 
end
hold on 
for i=1:length(group3(:,4))
    scatter(3,group3(i,4),'filled','k'); 
end
xlabel('Fugl-Meyer Upper Limb Motor @ T1') 
ylabel('Delta Fugl-Meyer Upper Limb Motor') 
print('plots/BoxPlots/211122_FMAIni_FMA_Delta','-dpng')


