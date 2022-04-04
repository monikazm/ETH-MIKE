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


%% Grouping 

n = 1; 
m = 1; 
k = 1; 
o = 1; 
p = 1; 
for i = 1:length(S1(:,1))
    if (S1(i,7)-S3(i,7) > 9.12 || (S1(i,7) > 10.64 && S3(i,7) <= 10.64)) && (((S3(i,8)-S1(i,8) > 4.88 || (S1(i,8) < 10.93 && S3(i,8) >= 10.93))) || ((S3(i,9)-S1(i,9) > 15.58 || (S1(i,9) < 63.20 && S3(i,9) >= 63.20))) || ((S3(i,10)-S1(i,10) > 60.68 || (S1(i,10) < 230 && S3(i,10) >= 230)))) 
       both.S1(n,:) = S1(i,:); 
       both.S3(n,:) = S3(i,:); 
       n = n+1; 
    elseif (S1(i,7)-S3(i,7) < 9.12) && (((S3(i,8)-S1(i,8) > 4.88 || (S1(i,8) < 10.93 && S3(i,8) >= 10.93))) || ((S3(i,9)-S1(i,9) > 15.58 || (S1(i,9) < 63.20 && S3(i,9) >= 63.20))) || ((S3(i,10)-S1(i,10) > 60.68 || (S1(i,10) < 230 && S3(i,10) >= 230)))) 
       motor.S1(m,:) = S1(i,:); 
       motor.S3(m,:) = S3(i,:);  
       m = m+1; 
    elseif (S1(i,7)-S3(i,7) > 9.12 || (S1(i,7) > 10.64 && S3(i,7) <= 10.64)) && (((S3(i,8)-S1(i,8) < 4.88) && (S3(i,9)-S1(i,9) < 15.58)) && (S3(i,10)-S1(i,10) < 60.68)) 
       sensory.S1(p,:) = S1(i,:); 
       sensory.S3(p,:) = S3(i,:);  
       p = p+1; 
    elseif  (S1(i,7)-S3(i,7) < 9.12 && (S1(i,7) < 10.64)) && (((S3(i,8)-S1(i,8) < 4.88 && (S1(i,8) > 10.93)) && (S3(i,9)-S1(i,9) < 15.58 && (S1(i,9) > 63.20))) || ((S3(i,8)-S1(i,8) < 4.88 && (S1(i,8) > 10.93)) && (S3(i,10)-S1(i,10) < 60.68 && (S1(i,10) > 230))) || ((S3(i,9)-S1(i,9) < 15.58 && (S1(i,9) > 63.20)) && (S3(i,10)-S1(i,10) < 60.68 && (S1(i,10) > 230)))) 
       good.S1(k,:) = S1(i,:); 
       good.S3(k,:) = S3(i,:); 
       k = k+1; 
    else
       neither.S1(o,:) = S1(i,:); 
       neither.S3(o,:) = S3(i,:); 
       o = o+1; 
    end
end

%% calculate mean and std for each group

both.S1_mean(1,:) = nanmean(both.S1); 
both.S1_mean(2,:) = nanstd(both.S1); 
both.S3_mean(1,:) = nanmean(both.S3); 
both.S3_mean(2,:) = nanstd(both.S3); 

neither.S1_mean(1,:) = nanmean(neither.S1); 
neither.S1_mean(2,:) = nanstd(neither.S1);
neither.S3_mean(1,:) = nanmean(neither.S3); 
neither.S3_mean(2,:) = nanstd(neither.S3);

good.S1_mean(1,:) = nanmean(good.S1); 
good.S1_mean(2,:) = nanstd(good.S1);
good.S3_mean(1,:) = nanmean(good.S3); 
good.S3_mean(2,:) = nanstd(good.S3);

motor.S1_mean(1,:) = nanmean(motor.S1); 
motor.S1_mean(2,:) = nanstd(motor.S1);
motor.S3_mean(1,:) = nanmean(motor.S3); 
motor.S3_mean(2,:) = nanstd(motor.S3);

sensory.S1_mean(1,:) = nanmean(sensory.S1); 
sensory.S1_mean(2,:) = nanstd(sensory.S1);
sensory.S3_mean(1,:) = nanmean(sensory.S3); 
sensory.S3_mean(2,:) = nanstd(sensory.S3);

%% plot longitudinal - force 

figure; 
hold on 
yline(10.93, '--k'); 
%both
for i=1:length(both.S1(:,8))
    b = plot(1:2, [both.S1(i,8),both.S3(i,8)],'-o','Linewidth',1); 
    b.MarkerFaceColor = [0.7,0.7,0.7];
    b.Color = [0.7,0.7,0.7];
end 
%neither
for i=1:length(neither.S1(:,8))
    n = plot(1:2, [neither.S1(i,8),neither.S3(i,8)],'-o','Linewidth',1); 
    n.MarkerFaceColor = [255/255,153/255,153/255];
    n.Color = [255/255,153/255,153/255];
end
%good
for i=1:length(good.S1(:,8))
    g = plot(1:2, [good.S1(i,8),good.S3(i,8)],'-o','Linewidth',1); 
    g.MarkerFaceColor = [178/255,255/255,102/255];
    g.Color = [178/255,255/255,102/255];
end
%motor only 
for i=1:length(motor.S1(:,8))
    m = plot(1:2, [motor.S1(i,8),motor.S3(i,8)],'-o','Linewidth',1); 
    m.MarkerFaceColor = [153/255,204/255,255/255];
    m.Color = [153/255,204/255,255/255];
end
%sensory only 
for i=1:length(sensory.S1(:,8))
    s = plot(1:2, [sensory.S1(i,8),sensory.S3(i,8)],'-o','Linewidth',1); 
    s.MarkerFaceColor = [204/255,153/255,255/255];
    s.Color = [204/255,153/255,255/255];
end
%both
bm = plot(1:2, [both.S1_mean(1,8),both.S3_mean(1,8)],'-o','Linewidth',2.5); 
bm.MarkerFaceColor = 'k'; 
bm.Color = 'k';
%none
nm = plot(1:2, [neither.S1_mean(1,8),neither.S3_mean(1,8)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [255/255,51/255,51/255];
nm.Color = [255/255,51/255,51/255];
%good
nm = plot(1:2, [good.S1_mean(1,8),good.S3_mean(1,8)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [51/255,255/255,51/255];
nm.Color = [51/255,255/255,51/255];
% motor
mm = plot(1:2, [motor.S1_mean(1,8),motor.S3_mean(1,8)],'-o','Linewidth',2.5); 
mm.MarkerFaceColor = [0/255,128/255,255/255];
mm.Color = [0/255,128/255,255/255];
% sensory
sm = plot(1:2, [sensory.S1_mean(1,8),sensory.S3_mean(1,8)],'-o','Linewidth',2.5); 
sm.MarkerFaceColor = [153/255,51/255,255/255];
sm.Color = [153/255,51/255,255/255];
xlim([0.5 2.5]) 
ylim([-2 52])
xticks([1 2]) 
xticklabels({'Inclusion','Discharge'})
ylabel('Maximum Force Flexion (N)')
print('plots/LongitudinalPlots/211126_Force_T1T3_changeGroups_v1','-dpng')

%% plot longitudinal - ROM

figure; 
hold on 
yline(63.20, '--k'); 
%both
for i=1:length(both.S1(:,9))
    b = plot(1:2, [both.S1(i,9),both.S3(i,9)],'-o','Linewidth',1); 
    b.MarkerFaceColor = [0.7,0.7,0.7];
    b.Color = [0.7,0.7,0.7];
end 
%neither
for i=1:length(neither.S1(:,9))
    n = plot(1:2, [neither.S1(i,9),neither.S3(i,9)],'-o','Linewidth',1); 
    n.MarkerFaceColor = [255/255,153/255,153/255];
    n.Color = [255/255,153/255,153/255];
end
%good
for i=1:length(good.S1(:,9))
    g = plot(1:2, [good.S1(i,9),good.S3(i,9)],'-o','Linewidth',1); 
    g.MarkerFaceColor = [178/255,255/255,102/255];
    g.Color = [178/255,255/255,102/255];
end
%motor only 
for i=1:length(motor.S1(:,9))
    m = plot(1:2, [motor.S1(i,9),motor.S3(i,9)],'-o','Linewidth',1); 
    m.MarkerFaceColor = [153/255,204/255,255/255];
    m.Color = [153/255,204/255,255/255];
end
%sensory only 
for i=1:length(sensory.S1(:,9))
    s = plot(1:2, [sensory.S1(i,9),sensory.S3(i,9)],'-o','Linewidth',1); 
    s.MarkerFaceColor = [204/255,153/255,255/255];
    s.Color = [204/255,153/255,255/255];
end
%both
bm = plot(1:2, [both.S1_mean(1,9),both.S3_mean(1,9)],'-o','Linewidth',2.5); 
bm.MarkerFaceColor = 'k'; 
bm.Color = 'k';
%none
nm = plot(1:2, [neither.S1_mean(1,9),neither.S3_mean(1,9)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [255/255,51/255,51/255];
nm.Color = [255/255,51/255,51/255];
%good
nm = plot(1:2, [good.S1_mean(1,9),good.S3_mean(1,9)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [51/255,255/255,51/255];
nm.Color = [51/255,255/255,51/255];
% motor
mm = plot(1:2, [motor.S1_mean(1,9),motor.S3_mean(1,9)],'-o','Linewidth',2.5); 
mm.MarkerFaceColor = [0/255,128/255,255/255];
mm.Color = [0/255,128/255,255/255];
% sensory
sm = plot(1:2, [sensory.S1_mean(1,9),sensory.S3_mean(1,9)],'-o','Linewidth',2.5); 
sm.MarkerFaceColor = [153/255,51/255,255/255];
sm.Color = [153/255,51/255,255/255];
xlim([0.5 2.5]) 
ylim([-5 110])
xticks([1 2]) 
xticklabels({'Inclusion','Discharge'})
ylabel('Active Range of Motion (deg)')
print('plots/LongitudinalPlots/211126_ROM_T1T3_changeGroups_v1','-dpng')

%% plot longitudinal - Vel

figure; 
hold on 
yline(230, '--k'); 
%both
for i=1:length(both.S1(:,10))
    b = plot(1:2, [both.S1(i,10),both.S3(i,10)],'-o','Linewidth',1); 
    b.MarkerFaceColor = [0.7,0.7,0.7];
    b.Color = [0.7,0.7,0.7];
end 
%neither
for i=1:length(neither.S1(:,10))
    n = plot(1:2, [neither.S1(i,10),neither.S3(i,10)],'-o','Linewidth',1); 
    n.MarkerFaceColor = [255/255,153/255,153/255];
    n.Color = [255/255,153/255,153/255];
end
%good
for i=1:length(good.S1(:,10))
    g = plot(1:2, [good.S1(i,10),good.S3(i,10)],'-o','Linewidth',1); 
    g.MarkerFaceColor = [178/255,255/255,102/255];
    g.Color = [178/255,255/255,102/255];
end
%motor only 
for i=1:length(motor.S1(:,10))
    m = plot(1:2, [motor.S1(i,10),motor.S3(i,10)],'-o','Linewidth',1); 
    m.MarkerFaceColor = [153/255,204/255,255/255];
    m.Color = [153/255,204/255,255/255];
end
%sensory only 
for i=1:length(sensory.S1(:,10))
    s = plot(1:2, [sensory.S1(i,10),sensory.S3(i,10)],'-o','Linewidth',1); 
    s.MarkerFaceColor = [204/255,153/255,255/255];
    s.Color = [204/255,153/255,255/255];
end
%both
bm = plot(1:2, [both.S1_mean(1,10),both.S3_mean(1,10)],'-o','Linewidth',2.5); 
bm.MarkerFaceColor = 'k'; 
bm.Color = 'k';
%none
nm = plot(1:2, [neither.S1_mean(1,10),neither.S3_mean(1,10)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [255/255,51/255,51/255];
nm.Color = [255/255,51/255,51/255];
%good
nm = plot(1:2, [good.S1_mean(1,10),good.S3_mean(1,10)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [51/255,255/255,51/255];
nm.Color = [51/255,255/255,51/255];
% motor
mm = plot(1:2, [motor.S1_mean(1,10),motor.S3_mean(1,10)],'-o','Linewidth',2.5); 
mm.MarkerFaceColor = [0/255,128/255,255/255];
mm.Color = [0/255,128/255,255/255];
% sensory
sm = plot(1:2, [sensory.S1_mean(1,10),sensory.S3_mean(1,10)],'-o','Linewidth',2.5); 
sm.MarkerFaceColor = [153/255,51/255,255/255];
sm.Color = [153/255,51/255,255/255];
xlim([0.5 2.5]) 
ylim([-10 655])
xticks([1 2]) 
xticklabels({'Inclusion','Discharge'})
ylabel('Maximum Velocity Extension (deg/s)')
print('plots/LongitudinalPlots/211126_VelExt_T1T3_changeGroups_v1','-dpng')

%% plot longitudinal - proprioception 

figure; 
hold on 
yline(10.63, '--k'); 
%both
for i=1:length(both.S1(:,7))
    b = plot(1:2, [both.S1(i,7),both.S3(i,7)],'-o','Linewidth',1); 
    b.MarkerFaceColor = [0.7,0.7,0.7];
    b.Color = [0.7,0.7,0.7];
end 
%neither
for i=1:length(neither.S1(:,7))
    n = plot(1:2, [neither.S1(i,7),neither.S3(i,7)],'-o','Linewidth',1); 
    n.MarkerFaceColor = [255/255,153/255,153/255];
    n.Color = [255/255,153/255,153/255];
end
%good
for i=1:length(good.S1(:,7))
    g = plot(1:2, [good.S1(i,7),good.S3(i,7)],'-o','Linewidth',1); 
    g.MarkerFaceColor = [178/255,255/255,102/255];
    g.Color = [178/255,255/255,102/255];
end
%motor only 
for i=1:length(motor.S1(:,7))
    m = plot(1:2, [motor.S1(i,7),motor.S3(i,7)],'-o','Linewidth',1); 
    m.MarkerFaceColor = [153/255,204/255,255/255];
    m.Color = [153/255,204/255,255/255];
end
%sensory only 
for i=1:length(sensory.S1(:,7))
    s = plot(1:2, [sensory.S1(i,7),sensory.S3(i,7)],'-o','Linewidth',1); 
    s.MarkerFaceColor = [204/255,153/255,255/255];
    s.Color = [204/255,153/255,255/255];
end
%both
bm = plot(1:2, [both.S1_mean(1,7),both.S3_mean(1,7)],'-o','Linewidth',2.5); 
bm.MarkerFaceColor = 'k'; 
bm.Color = 'k';
%none
nm = plot(1:2, [neither.S1_mean(1,7),neither.S3_mean(1,7)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [255/255,51/255,51/255];
nm.Color = [255/255,51/255,51/255];
%good
nm = plot(1:2, [good.S1_mean(1,7),good.S3_mean(1,7)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [51/255,255/255,51/255];
nm.Color = [51/255,255/255,51/255];
% motor
mm = plot(1:2, [motor.S1_mean(1,7),motor.S3_mean(1,7)],'-o','Linewidth',2.5); 
mm.MarkerFaceColor = [0/255,128/255,255/255];
mm.Color = [0/255,128/255,255/255];
% sensory
sm = plot(1:2, [sensory.S1_mean(1,7),sensory.S3_mean(1,7)],'-o','Linewidth',2.5); 
sm.MarkerFaceColor = [153/255,51/255,255/255];
sm.Color = [153/255,51/255,255/255];
xlim([0.5 2.5]) 
%ylim([-2 52])
xticks([1 2]) 
set(gca,'YDir','reverse')
xticklabels({'Inclusion','Discharge'})
ylabel('Position Matching Absolute Error (deg)')
print('plots/LongitudinalPlots/211126_PM_T1T3_changeGroups_v1','-dpng')

%% plot longitudinal plot v2

figure; 
hold on 
%both
for i=1:length(both.S1(:,8))
    b = plot(1:2, [both.S1(i,8),both.S3(i,8)],'-o','Linewidth',1); 
    b.MarkerFaceColor = [0.7,0.7,0.7];
    b.Color = [0.7,0.7,0.7];
end 
%neither
for i=1:length(neither.S1(:,8))
    n = plot(1:2, [neither.S1(i,8),neither.S3(i,8)],'-o','Linewidth',1); 
    n.MarkerFaceColor = [0.7,0.7,0.7];
    n.Color = [0.7,0.7,0.7];
end
%good
for i=1:length(good.S1(:,8))
    g = plot(1:2, [good.S1(i,8),good.S3(i,8)],'-o','Linewidth',1); 
    g.MarkerFaceColor = [0.7,0.7,0.7];
    g.Color = [0.7,0.7,0.7];
end
%motor only 
for i=1:length(motor.S1(:,8))
    m = plot(1:2, [motor.S1(i,8),motor.S3(i,8)],'-o','Linewidth',1); 
    m.MarkerFaceColor = [0.7,0.7,0.7];
    m.Color = [0.7,0.7,0.7];
end
%sensory only 
for i=1:length(sensory.S1(:,8))
    s = plot(1:2, [sensory.S1(i,8),sensory.S3(i,8)],'-o','Linewidth',1); 
    s.MarkerFaceColor = [0.7,0.7,0.7];
    s.Color = [0.7,0.7,0.7];
end
%both
bm = plot(1:2, [both.S1_mean(1,8),both.S3_mean(1,8)],'-o','Linewidth',2.5); 
bm.MarkerFaceColor = 'k'; 
bm.Color = 'k';
%none
nm = plot(1:2, [neither.S1_mean(1,8),neither.S3_mean(1,8)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [255/255,51/255,51/255];
nm.Color = [255/255,51/255,51/255];
%good
nm = plot(1:2, [good.S1_mean(1,8),good.S3_mean(1,8)],'-o','Linewidth',2.5); 
nm.MarkerFaceColor = [51/255,255/255,51/255];
nm.Color = [51/255,255/255,51/255];
% motor
mm = plot(1:2, [motor.S1_mean(1,8),motor.S3_mean(1,8)],'-o','Linewidth',2.5); 
mm.MarkerFaceColor = [0/255,128/255,255/255];
mm.Color = [0/255,128/255,255/255];
% sensory
sm = plot(1:2, [sensory.S1_mean(1,8),sensory.S3_mean(1,8)],'-o','Linewidth',2.5); 
sm.MarkerFaceColor = [153/255,51/255,255/255];
sm.Color = [153/255,51/255,255/255];
xlim([0.5 2.5]) 
ylim([-2 52])
xticks([1 2]) 
xticklabels({'Inclusion','Discharge'})
ylabel('Maximum Force Flexion (N)')
print('plots/LongitudinalPlots/211126_Force_T1T3_changeGroups_v2','-dpng')