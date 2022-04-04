%% change motor / sensory - how do they relate?  %% 
% created: 13.10.2021

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
        elseif C(i,2) == 3 
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

S3(1,7) = 14.5926361100000; 

% % remove subjects that only have 2 measurements
% S1(find(S1(:,1)==3),:) = []; 
% S3(find(S3(:,1)==3),:) = []; 
% 
% S1(find(S1(:,1)==33),:) = []; 
% S3(find(S3(:,1)==33),:) = []; 
% 
% S1(find(S1(:,1)==37),:) = []; 
% S3(find(S3(:,1)==37),:) = []; 
% 
% S1(find(S1(:,1)==38),:) = []; 
% S3(find(S3(:,1)==38),:) = []; 
% 
% S1(find(S1(:,1)==48),:) = []; 
% S3(find(S3(:,1)==48),:) = []; 

%% Force vs Position Matching

figure; 
scatter(S1(:,7),S1(:,8),'filled','k');
hold on 
labelpoints(S1(:,7),S1(:,8),S1(:,1));
yline(10.93, '--k'); 
xline(10.63, '--k'); 
xlabel('Position Matching Absolute Error (deg) @ T1')
set(gca, 'XDir','reverse')
ylabel('Maximum Force Flexion (N) @ T1')
print('plots/ScatterPlots/211123_PM_Force_T1','-dpng')

figure; 
scatter(S3(:,7),S3(:,8),'filled','k');
yline(10.93, '--k'); 
xline(10.63, '--k'); 
hold on 
labelpoints(S3(:,7),S3(:,8),S3(:,1));
xlabel('Position Matching Absolute Error (deg) @ T3')
set(gca, 'XDir','reverse')
ylabel('Maximum Force Flexion (N) @ T3')
print('plots/ScatterPlots/211123_PM_Force_T3','-dpng')

figure; 
scatter((S1(:,7)-S3(:,7))./S3(:,7),(S3(:,8)-S1(:,8))./S1(:,3),'filled','k');
% yline(1, '--k'); 
% xline(1, '--k'); 
xlabel('Delta/T3 Position Matching Absolute Error (deg)')
ylabel('Delta/T1 Maximum Force Flexion (N)')
print('plots/ScatterPlots/211111_PM_Force_DeltabyInitial','-dpng')


figure; 
scatter((S1(:,7)-S3(:,7))./9.12,(S3(:,8)-S1(:,8))./4.88,'filled','k');
yline(1, '--k'); 
xline(1, '--k'); 
hold on 
labelpoints((S1(:,7)-S3(:,7))./9.12,(S3(:,8)-S1(:,8))./4.88,S1(:,1));
xlabel('Delta/SRD Position Matching Absolute Error (deg)')
ylabel('Delta/SRD Maximum Force Flexion (N)')
print('plots/ScatterPlots/211123_PM_Force_DeltabySRD','-dpng')

% only subjects impaired at inclusion in both
figure;
for i=1:length(S1(:,1))
    if S1(i,7) > 10.93 && S1(i,8) < 10.93
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','r');
        hold on 
    else
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','k');
        hold on 
    end
end
yline(1, '--k'); 
xline(1, '--k'); 
xlabel('Delta/SRD Position Matching Absolute Error (deg)')
ylabel('Delta/SRD Maximum Force Flexion (N)')
xlim([-1 1.5]) 
ylim([-2 3]) 
print('plots/ScatterPlots/211111_PM_Force_DeltabySRD_markedImpairedT1','-dpng')




% figure; 
% scatter((S1(:,7)-S3(:,7))./S3(:,7),(S3(:,8)-S1(:,8))./S1(:,8),'filled','k');
% yline(1, '--k'); 
% xline(1, '--k'); 
% xlabel('Delta/initial Position Matching Absolute Error (deg)')
% ylabel('Delta/initial Maximum Force Flexion (N)')
% title('T3')
% print('plots/ScatterPlots/211013_PM_Force_Deltabyini','-dpng')


[rho.FPM_T1,pval.FPM_T1] = corr(S1(:,7),S1(:,8), 'Type', 'Spearman');
[rho.FPM_T3,pval.FPM_T3] = corr(S3(:,7),S3(:,8), 'Type', 'Spearman');
[rho.FPM_delta,pval.FPM_delta] = corr(S1(:,7)-S3(:,7),S3(:,8)-S1(:,8), 'Type', 'Spearman');


figure; 
scatter(S1(:,7),S3(:,8),'filled','k');
yline(10.93, '--k'); 
xline(10.63, '--k'); 
xlabel('Position Matching Absolute Error (deg) @ T1')
set(gca, 'XDir','reverse')
ylabel('Maximum Force Flexion (N) @ T3')
title('T1 vs T3')
print('plots/ScatterPlots/211019_PM_Force_T1T3','-dpng')

figure; 
scatter(S1(:,7)-S3(:,7),S3(:,8),'filled','k');
xlabel('Change in Position Matching Absolute Error')
ylabel('Maximum Force Flexion @ T3')
title('Delta vs T3')
print('plots/ScatterPlots/211019_PM_Force_T3Change','-dpng')

figure; 
scatter(S1(:,7),S3(:,8)-S1(:,8),'filled','k');
xlabel('Position Matching Absolute Error @ T1')
ylabel('Change in Maximum Force Flexion @ T3')
title('Delta vs T1')
print('plots/ScatterPlots/211019_PM_Force_T1Change','-dpng')



%% color coding of initial impairment

figure; 
for i = 1:length(S1(:,1))
    if S1(i,7) > 10.63 && S1(i,8) < 10.93 % both impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','r');
        hold on 
    elseif S1(i,7) <= 10.63 && S1(i,8) >= 10.93 % both not impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','g');
        hold on 
    elseif S1(i,7) > 10.63 && S1(i,8) >= 10.93 % only sensory impaire at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','b');
        hold on 
    elseif S1(i,7) <= 10.63 && S1(i,8) < 10.93 % only motor impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','k');
        hold on 
    end
end
yline(1, '--k'); 
xline(1, '--k'); 
xlabel('Delta/SRD Position Matching Absolute Error (deg)')
ylabel('Delta/SRD Maximum Force Flexion (N)')
print('plots/ScatterPlots/211019_PM_Force_DeltabySRD','-dpng')


%% no color coding of initial impairment

figure; 
for i = 1:length(S1(:,1))
    if S1(i,7) > 10.63 && S1(i,8) < 10.93 % both impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','k');
        hold on 
    elseif S1(i,7) <= 10.63 && S1(i,8) >= 10.93 % both not impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','k');
        hold on 
    elseif S1(i,7) > 10.63 && S1(i,8) >= 10.93 % only sensory impaire at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','k');
        hold on 
    elseif S1(i,7) <= 10.63 && S1(i,8) < 10.93 % only motor impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','k');
        hold on 
    end
end
yline(1, '--k'); 
xline(1, '--k'); 
xlabel('Delta/SRD Position Matching Absolute Error (deg)')
ylabel('Delta/SRD Maximum Force Flexion (N)')
print('plots/ScatterPlots/211026_PM_Force_DeltabySRD_nocolor','-dpng')

%% color coding of initial impairment - labelpoints 
% with Force 

txt1 = string(S1(:,1)');

figure; 
for i = 1:length(S1(:,1))
    if S1(i,7) > 10.63 && S1(i,8) < 10.93 % both impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','r');
        hold on 
        txt = string(S1(i,1)); 
        labelpoints((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,txt); 
        hold on 
    elseif S1(i,7) <= 10.63 && S1(i,8) >= 10.93 % both not impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','g');
        hold on 
        labelpoints((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88, string(S1(i,1))); 
        hold on 
    elseif S1(i,7) > 10.63 && S1(i,8) >= 10.93 % only sensory impaire at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','b');
        hold on 
        labelpoints((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88, string(S1(i,1))); 
        hold on 
    elseif S1(i,7) <= 10.63 && S1(i,8) < 10.93 % only motor impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88,'filled','k');
        hold on 
        labelpoints((S1(i,7)-S3(i,7))./9.12,(S3(i,8)-S1(i,8))./4.88, string(S1(i,1))); 
        hold on 
    end
end
yline(1, '--k'); 
xline(1, '--k'); 
xlabel('Delta/SRD Position Matching Absolute Error (deg)')
ylabel('Delta/SRD Maximum Force Flexion (N)')
print('plots/ScatterPlots/211026_PM_Force_DeltabySRD_labelpoints','-dpng')

%% color coding of initial impairment - labelpoints 
% with ROM

txt1 = string(S1(:,1)');

figure; 
for i = 1:length(S1(:,1))
    if S1(i,7) > 10.63 && S1(i,9) < 59 % both impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,9)-S1(i,9))./15.58,'filled','r');
        hold on 
        txt = string(S1(i,1)); 
        labelpoints((S1(i,7)-S3(i,7))./9.12,(S3(i,9)-S1(i,9))./15.58,txt); 
        hold on 
    elseif S1(i,7) <= 10.63 && S1(i,9) >= 59 % both not impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,9)-S1(i,9))./15.58,'filled','g');
        hold on 
        labelpoints((S1(i,7)-S3(i,7))./9.12,(S3(i,9)-S1(i,9))./15.58, string(S1(i,1))); 
        hold on 
    elseif S1(i,7) > 10.63 && S1(i,9) >= 59 % only sensory impaire at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,9)-S1(i,9))./15.58,'filled','b');
        hold on 
        labelpoints((S1(i,7)-S3(i,7))./9.12,(S3(i,9)-S1(i,9))./15.58, string(S1(i,1))); 
        hold on 
    elseif S1(i,7) <= 10.63 && S1(i,9) < 59 % only motor impaired at T1
        scatter((S1(i,7)-S3(i,7))./9.12,(S3(i,9)-S1(i,9))./15.58,'filled','k');
        hold on 
        labelpoints((S1(i,7)-S3(i,7))./9.12,(S3(i,9)-S1(i,9))./15.58, string(S1(i,1))); 
        hold on 
    end
end
yline(1, '--k'); 
xline(1, '--k'); 
xlabel('Delta/SRD Position Matching Absolute Error (deg)')
ylabel('Delta/SRD Active Range of Motion (deg)')
print('plots/ScatterPlots/211026_PM_AROM_DeltabySRD_labelpoints','-dpng')



