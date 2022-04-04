%% scatter plots to look at changes by individual subjects %% 
% created: 15.09.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20210914_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR

A = table2array(T(:,[3 5 92 114 160 127 122 47 41])); 

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

S1(1,:) = []; 
S2(1,:) = []; 
S3(1,:) = []; 
S2(13,7) = 20;  

%% scatter Position Matching 

figure; 
for i = 1:length(S1(:,1))
    if S1(i,7)-S3(i,7) >= 9.12
        p = scatter(S1(i,7),S3(i,7),'filled');
        p.MarkerFaceColor = [0/255 153/255 76/255];
        p.MarkerEdgeColor = [0/255 153/255 76/255];
        hold on 
    else
        scatter(S1(i,7),S3(i,7),'k');
        hold on 
    end
end
xlim([0 26])
ylim([0 26])
xlabel('Position Matching @ T1') 
ylabel('Position Matching @ T3') 
hold on 
xline(10.63, '--k'); 
yline(10.63, '--k'); 
plot([0:26], [0:26],'k'); 
% set(gca, 'YDir','reverse')
% set(gca, 'XDir','reverse')
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210915_PM_change','-dpng')

%% scatter AROM

figure; 
for i = 1:length(S1(:,1))
    if S3(i,3)-S1(i,3) >= 15.58
        scatter(S1(i,3),S3(i,3),'filled','k');
        hold on 
    else
        scatter(S1(i,3),S3(i,3),'k');
        hold on 
    end
end
xlim([0 100])
ylim([0 100])
xlabel('AROM @ T1') 
ylabel('AROM @ T3') 
hold on 
xline(63.20, '--k'); 
yline(63.20, '--k'); 
plot([0:100], [0:100],'k'); 
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210915_AROM_change','-dpng')

%% scatter Force Flex

figure; 
for i = 1:length(S1(:,1))
    if S3(i,4)-S1(i,4) >= 4.88
        scatter(S1(i,4),S3(i,4),'filled','k');
        hold on 
    else
        scatter(S1(i,4),S3(i,4),'k');
        hold on 
    end
end
xlim([0 50])
ylim([0 50])
xlabel('Force Flex @ T1') 
ylabel('Force Flex @ T3') 
hold on 
xline(10.93, '--k'); 
yline(10.93, '--k'); 
plot([0:50], [0:50],'k'); 
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210915_ForceFlex_change','-dpng')

%% ttests Vel Ext 

figure; 
for i = 1:length(S1(:,1))
    if S3(i,5)-S1(i,5) >= 60.68
        scatter(S1(i,5),S3(i,5),'filled','k');
        hold on 
    else
        scatter(S1(i,5),S3(i,5),'k');
        hold on 
    end
end
xlim([0 550])
ylim([0 550])
xlabel('Velocity Ext @ T1') 
ylabel('Velocity Ext @ T3') 
hold on 
xline(255.6, '--k'); 
yline(255.6, '--k'); 
plot([0:550], [0:550],'k'); 
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/ScatterPlots/210915_VelExt_change','-dpng')

%% bring together 

% PM 
PM.IMP_THR = 10.63; 
PM.SRD = 9.12; 
PM.all = [S1(:,1) S1(:,7) S3(:,7) (S1(:,7)-S3(:,7))]; 
PM.imp_T1 = sum(double(PM.all(:,2)>PM.IMP_THR)); 
PM.imp_T1_proc = PM.imp_T1./length(PM.all(:,1)); 
PM.imp_T3 = sum(double(PM.all(:,3)>PM.IMP_THR)); 
PM.imp_T3_proc = PM.imp_T3./length(PM.all(:,1)); 
PM.deltaSign = sum(double(PM.all(:,4)>PM.SRD)); 
PM.deltaSign_proc = PM.deltaSign./length(PM.all(:,1)); 
PM.changeState = sum(double(PM.all(:,2)>PM.IMP_THR & PM.all(:,3)<PM.IMP_THR)); 
PM.changeState_proc = PM.changeState./length(PM.all(:,1)); 

% AROM 
AROM.IMP_THR = 63.20; 
AROM.SRD = 15.58; 
AROM.all = [S1(:,1) S1(:,3) S3(:,3) (S3(:,3)-S1(:,3))]; 
AROM.imp_T1 = sum(double(AROM.all(:,2)<AROM.IMP_THR)); 
AROM.imp_T1_proc = AROM.imp_T1./length(AROM.all(:,1)); 
AROM.imp_T3 = sum(double(AROM.all(:,3)<AROM.IMP_THR)); 
AROM.imp_T3_proc = AROM.imp_T3./length(AROM.all(:,1)); 
AROM.deltaSign = sum(double(AROM.all(:,4)>AROM.SRD)); 
AROM.deltaSign_proc = AROM.deltaSign./length(AROM.all(:,1)); 
AROM.changeState = sum(double(AROM.all(:,2)<AROM.IMP_THR & AROM.all(:,3)>AROM.IMP_THR)); 
AROM.changeState_proc = AROM.changeState./length(AROM.all(:,1)); 

% Force Flex
Force.IMP_THR = 10.93; 
Force.SRD = 4.88; 
Force.all = [S1(:,1) S1(:,4) S3(:,4) (S3(:,4)-S1(:,4))]; 
Force.imp_T1 = sum(double(Force.all(:,2)<Force.IMP_THR)); 
Force.imp_T1_proc = Force.imp_T1./length(Force.all(:,1)); 
Force.imp_T3 = sum(double(Force.all(:,3)<Force.IMP_THR)); 
Force.imp_T3_proc = Force.imp_T3./length(Force.all(:,1)); 
Force.deltaSign = sum(double(Force.all(:,4)>Force.SRD)); 
Force.deltaSign_proc = Force.deltaSign./length(Force.all(:,1)); 
Force.changeState = sum(double(Force.all(:,2)<Force.IMP_THR & Force.all(:,3)>Force.IMP_THR)); 
Force.changeState_proc = Force.changeState./length(Force.all(:,1)); 

% Velocity Ext
Vel.IMP_THR = 255.6; 
Vel.SRD = 60.68; 
Vel.all = [S1(:,1) S1(:,5) S3(:,5) (S3(:,5)-S1(:,5))]; 
Vel.imp_T1 = sum(double(Vel.all(:,2)<Vel.IMP_THR)); 
Vel.imp_T1_proc = Vel.imp_T1./length(Vel.all(:,1)); 
Vel.imp_T3 = sum(double(Vel.all(:,3)<Vel.IMP_THR)); 
Vel.imp_T3_proc = Vel.imp_T3./length(Vel.all(:,1)); 
Vel.deltaSign = sum(double(Vel.all(:,4)>Vel.SRD)); 
Vel.deltaSign_proc = Vel.deltaSign./length(Vel.all(:,1)); 
Vel.changeState = sum(double(Vel.all(:,2)<Vel.IMP_THR & Vel.all(:,3)>Vel.IMP_THR)); 
Vel.changeState_proc = Vel.changeState./length(Vel.all(:,1)); 

%% Heatmap of significant changes 


H = [PM.all(:,4)./PM.SRD AROM.all(:,4)./AROM.SRD Force.all(:,4)./Force.SRD Vel.all(:,4)./Vel.SRD]; 

H2 = [double(PM.all(:,2)>PM.IMP_THR) double(AROM.all(:,2)<AROM.IMP_THR) double(Force.all(:,2)<Force.IMP_THR) double(Vel.all(:,2)<Vel.IMP_THR)]'; 

% done in excel 










