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

%% Save for reference of non-impaired side calculation

save('SubjectsT1T3Analysis_29112021.mat','S1')


%% mean and std 

S1_mean(1,:) = nanmean(S1); 
S1_mean(2,:) = nanstd(S1); 

S3_mean(1,:) = nanmean(S3); 
S3_mean(2,:) = nanstd(S3); 

%% ttests

[h1_PM,p1_PM] = ttest(S1(:,7),S3(:,7)); 
[h1_F,p1_F] = ttest(S1(:,8),S3(:,8)); 
[h1_R,p1_R] = ttest(S1(:,9),S3(:,9)); 
[h1_V,p1_V] = ttest(S1(:,10),S3(:,10)); 

%% number of subjects that improved above SRD 
n = 1; 
m = 1;
k = 1; 
j = 1; 
for i=1:length(S1(:,1))
    if S1(i,7)-S3(i,7) >= 9.12 
        srd.PM(n) = 1; 
        n = n+1; 
    end
end
for i=1:length(S1(:,1))
    if S3(i,8)-S1(i,8) >= 4.88
        srd.F(m) = 1; 
        m = m +1; 
    end
end
for i=1:length(S1(:,1))
    if S3(i,9)-S1(i,9) >= 15.58
        srd.R(k) = 1; 
        k = k +1; 
    end
end
for i=1:length(S1(:,1))
    if S3(i,10)-S1(i,10) >= 60.68
        srd.V(j) = 1; 
        j = j +1; 
    end
end
srd.PM = sum(srd.PM); 
srd.F = sum(srd.F); 
srd.R = sum(srd.R); 
srd.V = sum(srd.V);

%% number of subjects that improved below -SRD 
n = 1; 
m = 1;
k = 1; 
j = 1; 
for i=1:length(S1(:,1))
    if S1(i,7)-S3(i,7) < -9.12 
        srdneg.PM(n) = 1; 
        n = n+1; 
    end
end
for i=1:length(S1(:,1))
    if S3(i,8)-S1(i,8) < -4.88
        srdneg.F(m) = 1; 
        m = m +1; 
    end
end
for i=1:length(S1(:,1))
    if S3(i,9)-S1(i,9) < -15.58
        srdneg.R(k) = 1; 
        k = k +1; 
    end
end
for i=1:length(S1(:,1))
    if S3(i,10)-S1(i,10) < -60.68
        srdneg.V(j) = 1; 
        j = j +1; 
    end
end
srdneg.PM = sum(srdneg.PM); 
srdneg.F = sum(srdneg.F); 
srdneg.R = sum(srdneg.R); 
srdneg.V = sum(srdneg.V);

%% number of subjects that changed from impaired to not-impaired 
n = 1; 
m = 1;
k = 1; 
j = 1; 
for i=1:length(S1(:,1))
    if S1(i,7)> 10.64 && S3(i,7) <= 10.64 
        imp.PM(n) = 1; 
        n = n+1; 
    end
end
for i=1:length(S1(:,1))
    if S1(i,8)< 10.93 && S3(i,8) >= 10.93 
        imp.F(m) = 1; 
        m = m +1; 
    end
end
for i=1:length(S1(:,1))
    if S1(i,9)< 63.20 && S3(i,9) >= 63.20
        imp.R(k) = 1; 
        k = k +1;
    end
end
for i=1:length(S1(:,1))
    if S1(i,10)< 255.6 && S3(i,10) >= 255.6
        imp.V(j) = 1; 
        j = j +1; 
    end
end
imp.PM = sum(imp.PM); 
imp.F = sum(imp.F); 
imp.R = sum(imp.R); 
imp.V = sum(imp.V);

%% number of subjects that changed from non-impaired to impaired 
n = 1; 
m = 1;
k = 1; 
j = 1; 
for i=1:length(S1(:,1))
    if S1(i,7)<= 10.64 && S3(i,7) > 10.64 
        impneg.PM(n) = 1; 
        n = n+1; 
    end
end
for i=1:length(S1(:,1))
    if S1(i,8)>= 10.93 && S3(i,8) < 10.93 
        impneg.F(m) = 1; 
        m = m +1; 
    end
end
for i=1:length(S1(:,1))
    if S1(i,9)>= 63.20 && S3(i,9) < 63.20
        impneg.R(k) = 1; 
        k = k +1; 
    end
end
for i=1:length(S1(:,1))
    if S1(i,10)>= 255.6 && S3(i,10) < 255.6
        impneg.V(j) = 1; 
        j = j +1; 
    end
end
impneg.PM = sum(impneg.PM); 
impneg.F = sum(impneg.F); 
impneg.R = sum(impneg.R); 
impneg.V = sum(impneg.V);

%% number of subjects that sign. improved 

n = 1; 
m = 1;
k = 1; 
j = 1; 
for i=1:length(S1(:,1))
    if ((S1(i,7)-S3(i,7)>= 9.12)) || (S1(i,7)> 10.64 && S3(i,7) <= 10.64)
        changepos.PM(n) = 1; 
        n = n+1; 
    end
end
for i=1:length(S1(:,1))
    if ((S3(i,8)-S1(i,8))>= 4.88) || (S1(i,8)< 10.93 && S3(i,8) >= 10.93)
        changepos.F(m) = 1; 
        m = m +1; 
    end
end
for i=1:length(S1(:,1))
    if ((S3(i,9)-S1(i,9))>= 15.58) || (S1(i,9)< 63.20 && S3(i,9) >= 63.20)
        changepos.R(k) = 1; 
        k = k +1; 
    end
end
for i=1:length(S1(:,1))
    if ((S3(i,10)-S1(i,10))>= 60.68) || (S1(i,10)< 255.6 && S3(i,10) >= 255.6)
        changepos.V(j) = 1; 
        j = j +1; 
    end
end
changepos.PM = sum(changepos.PM); 
changepos.F = sum(changepos.F); 
changepos.R = sum(changepos.R); 
changepos.V = sum(changepos.V);

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
xticklabels({'Inclusion','Discharge'})
ylabel('Position Matching Absolute Error (deg)')
title('Proprioception')
set(gca,'FontSize',12)
print('plots/Paper/220321_Figure1A','-dpng')


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
xticklabels({'Inclusion','Discharge'})
ylabel('Maximum Force Flexion (N)')
title('Motor function')
set(gca,'FontSize',12)
print('plots/Paper/220321_Figure1B','-dpng')


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
xticklabels({'Inclusion','Discharge'})
ylabel('Active Range of Motion (deg)')
title('Motor function')
set(gca,'FontSize',12)
print('plots/Paper/240321_FigureSM6A','-dpng')


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
xticklabels({'Inclusion','Discharge'})
ylabel('Maximum Velocity Extension (deg/s)')
title('Motor function')
set(gca,'FontSize',12)
print('plots/Paper/240321_FigureSM6B','-dpng')
