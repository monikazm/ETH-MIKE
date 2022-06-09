%% FIGURE 1 - LONGITUDINAL CHANGES MOTOR FUNCTION (FORCE) & PROPRIOCEPTION %% 
% created: 21.03.2022

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 47 - kUDT
% 41 - FM M UL
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

A = table2array(T(:,[3 5 47 41 48 61 122 114 92 160 8])); 
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
S3(33,4) = S1(33,4); 
S3(33,5) = S1(33,5); 
S3(33,6) = S1(33,6); 

%% mean and std 

S1_mean(1,:) = nanmean(S1); 
S1_mean(2,:) = nanstd(S1); 

S3_mean(1,:) = nanmean(S3); 
S3_mean(2,:) = nanstd(S3); 

%% number of subjects that improved above SRD or from imp to nonimp  
n = 1; 
m = 1;
k = 1; 
j = 1; 
for i=1:length(S1(:,1))
    if (S1(i,7)-S3(i,7) >= 9.12) || (S1(i,7)> 10.64 && S3(i,7) <= 10.64) 
        consider.PM(n) = 1; 
        n = n+1; 
    end
end
for i=1:length(S1(:,1))
    if (S3(i,8)-S1(i,8) >= 4.88) || (S1(i,8)< 10.93 && S3(i,8) >= 10.93 )
        consider.F(m) = 1; 
        m = m +1; 
    end
end
for i=1:length(S1(:,1))
    if (S3(i,9)-S1(i,9) >= 15.58) || (S1(i,9)< 63.20 && S3(i,9) >= 63.20)
        consider.R(k) = 1; 
        k = k +1; 
    end
end
for i=1:length(S1(:,1))
    if (S3(i,10)-S1(i,10) >= 60.68) || (S1(i,10)< 255.6 && S3(i,10) >= 255.6)
        consider.V(j) = 1; 
        j = j +1; 
    end
end
consider.PM = sum(consider.PM); 
consider.F = sum(consider.F); 
consider.R = sum(consider.R); 
consider.V = sum(consider.V);

%% number of subjects that sign. decreased 
n = 1; 
m = 1;
k = 1; 
j = 1; 
o = 1; 
for i=1:length(S1(:,1))
    if ((S1(i,7)-S3(i,7)< -9.12)) || (S1(i,7)<= 10.64 && S3(i,7) > 10.64)
        changeneg.PM(n) = 1; 
        n = n+1; 
    end
end
for i=1:length(S1(:,1))
    if ((S3(i,8)-S1(i,8))< -4.88) || (S1(i,8)>= 10.93 && S3(i,8) < 10.93)
        changeneg.F(m) = 1; 
        m = m +1; 
    end
end
for i=1:length(S1(:,1))
    if ((S3(i,9)-S1(i,9))< -15.58) || (S1(i,9)>= 63.20 && S3(i,9) < 63.20)
        changeneg.R(k) = 1; 
        k = k +1; 
    end
end
for i=1:length(S1(:,1))
    if ((S3(i,10)-S1(i,10))< -60.68) || (S1(i,10)>= 255.6 && S3(i,10) < 255.6)
        changeneg.V(j) = 1; 
        j = j +1; 
    end
end
for i=1:length(S1(:,1))
    if (((S3(i,10)-S1(i,10))< -60.68) || (S1(i,10)>= 255.6 && S3(i,10) < 255.6)) || (((S3(i,9)-S1(i,9))< -15.58) || (S1(i,9)>= 63.20 && S3(i,9) < 63.20)) || (((S3(i,8)-S1(i,8))< -4.88) || (S1(i,8)>= 10.93 && S3(i,8) < 10.93))
        changeneg.M(o) = 1; 
        o = o +1; 
    end
end
changeneg.PM = sum(changeneg.PM); 
changeneg.F = sum(changeneg.F); 
changeneg.R = sum(changeneg.R); 
changeneg.V = sum(changeneg.V);
changeneg.M = sum(changeneg.M);

%% plot with subjects that changed significantly - PM 

figure; 
hold on 
yline(10.64, '--k');
for i=1:length(S1)
    p = plot(1:2, [S1(i,7) S3(i,7)],'-o','Linewidth',1);
    p.MarkerFaceColor = [0.7,0.7,0.7];
    p.Color =  [0.7,0.7,0.7];
    hold on 
end
for i=1:length(S1)
    if ((S1(i,7)-S3(i,7)>= 9.12)) || (S1(i,7)> 10.64 && S3(i,7) <= 10.64)
        p = plot(1:2, [S1(i,7) S3(i,7)],'-o','Linewidth',1);
        p.MarkerFaceColor = 'k';
        p.Color =  'k';
        hold on        
    end
end
set(gca,'YDir','reverse')
xlim([0.5 2.5]) 
xticks([1 2]) 
xticklabels({'Baseline','Discharge'})
ylabel('Absolute Error AE (deg)')
%title('Proprioception')
set(gca,'FontSize',12)
print('plots/Paper/20220609_Figure1A','-dpng')
figure2pdf('plots/Paper/20220609_Figure1A'); 

%% plot with subjects that changed significantly - Force Flexion

figure; 
hold on 
yline(10.93, '--k'); 
for i=1:length(S1)
    p = plot(1:2, [S1(i,8) S3(i,8)],'-o','Linewidth',1);
    p.MarkerFaceColor = [0.7,0.7,0.7];
    p.Color =  [0.7,0.7,0.7];
    hold on 
end
for i=1:length(S1)
    if ((S3(i,8)-S1(i,8))>= 4.88) || (S1(i,8)< 10.93 && S3(i,8) >= 10.93)
        p = plot(1:2, [S1(i,8) S3(i,8)],'-o','Linewidth',1);
        p.MarkerFaceColor = 'k';
        p.Color =  'k';
        hold on        
    end
end
xlim([0.5 2.5]) 
xticks([1 2]) 
xticklabels({'Baseline','Discharge'})
ylabel('Flexion Force FF (N)')
%title('Motor function')
set(gca,'FontSize',12)
print('plots/Paper/20220609_Figure1B','-dpng')
figure2pdf('plots/Paper/20220609_Figure1B'); 

%% plot with subjects that changed significantly - Active Range of Motion

figure; 
hold on 
yline(63.20, '--k'); 
for i=1:length(S1)
    p = plot(1:2, [S1(i,9) S3(i,9)],'-o','Linewidth',1);
    p.MarkerFaceColor = [0.7,0.7,0.7];
    p.Color =  [0.7,0.7,0.7];
    hold on 
end
for i=1:length(S1)
    if ((S3(i,9)-S1(i,9))>= 15.58) || (S1(i,9)< 63.20 && S3(i,9) >= 63.20)
        p = plot(1:2, [S1(i,9) S3(i,9)],'-o','Linewidth',1);
        p.MarkerFaceColor = 'k';
        p.Color =  'k';
        hold on        
    end
end
xlim([0.5 2.5]) 
xticks([1 2]) 
xticklabels({'Baseline','Discharge'})
ylabel('Active Range of Motion AROM (deg)')
title('Motor function')
set(gca,'FontSize',12)
print('plots/Paper/20220521_FigureSM6A','-dpng')


%% plot with subjects that changed significantly - Maximum Velocity Extension
figure; 
hold on 
yline(255.60, '--k'); 
for i=1:length(S1)
    p = plot(1:2, [S1(i,10) S3(i,10)],'-o','Linewidth',1);
    p.MarkerFaceColor = [0.7,0.7,0.7];
    p.Color =  [0.7,0.7,0.7];
    hold on 
end
for i=1:length(S1)
    if ((S3(i,10)-S1(i,10))>= 60.68) || (S1(i,10)< 255.60 && S3(i,10) >= 255.60)
        p = plot(1:2, [S1(i,10) S3(i,10)],'-o','Linewidth',1);
        p.MarkerFaceColor = 'k';
        p.Color =  'k';
        hold on        
    end
end
xlim([0.5 2.5]) 
xticks([1 2]) 
xticklabels({'Baseline','Discharge'})
ylabel('Extension Velocity EV (deg/s)')
title('Motor function')
set(gca,'FontSize',12)
print('plots/Paper/20220521_FigureSM6B','-dpng')
