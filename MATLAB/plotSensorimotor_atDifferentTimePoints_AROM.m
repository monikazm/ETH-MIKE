%% Motor (AROM) vs Sensorimotor at two different time points (inclusion and discharge) %% 
% created: 11.08.2021

% are the relationships between the two different at inclusion and
% discharge 

clear 
close all
clc

%% read table %% 

T = readtable('data/20210811_DataImpaired.csv'); 
M = readtable('data/20210121_metricInfo.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR
% 125 - RMSE slow 

A = table2array(T(:,[3 5 127 92])); 

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

% N = 27 
Sesh1(1,:) = []; 
Sesh3(1,:) = []; %remove the outlier 

Sesh1(26,:) = []; 
Sesh3(26,:) = []; %remove the outlier 

%% calculate change
change(:,1) = Sesh1(:,1); 
change(:,2) = Sesh1(:,3)-Sesh3(:,3); 
change(:,3) = Sesh3(:,4)-Sesh1(:,4); 

%% plot Sensorimotor vs Sensory 
% raw metric for now, eventually do it in z-score  

txt1 = string(Sesh1(:,1)');
txt2 = string(Sesh3(:,1)');
txt3 = string(change(:,1)');

% T1 
figure;
scatter(Sesh1(:,4),Sesh1(:,3), 'filled'); % x-sensory, y-sensorimotor
hold on
labelpoints(Sesh1(:,4),Sesh1(:,3), txt1); 
%set(gca,'XDir','reverse')
xlabel('Active Range of Motion (deg)') 
ylabel('Smoothness MAPR') 
% xlim([-1.2 0.8])
ylim([0 1.1])
title('AROM vs MAPR @ T1')
print('Plots/ScatterPlots/210811_MAPRvsAROM_T1','-dpng')

% T3
figure; 
scatter(Sesh3(:,4),Sesh3(:,3), 'filled','r'); % x-sensory, y-motor
hold on
labelpoints(Sesh3(:,4),Sesh3(:,3), txt2);
%set(gca,'XDir','reverse')
xlabel('Active Range of Motion (deg)') 
ylabel('Smoothness MAPR') 
% xlim([-1.2 0.8])
ylim([0 1.1])
title('AROM vs MAPR @ T3')
print('Plots/ScatterPlots/210811_MAPRvsAROM_T3','-dpng')

% T3 & T1
figure; 
scatter(Sesh1(:,4),Sesh3(:,3), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(Sesh1(:,4),Sesh3(:,3), txt2);
%set(gca,'XDir','reverse')
xlabel('Active Range of Motion (deg) @ T1') 
ylabel('Smoothness MAPR @ T3') 
% xlim([-1.2 0.8])
ylim([0 1.1])
title('AROM vs MAPR')
print('Plots/ScatterPlots/210811_MAPRvsAROM_T1T3','-dpng')

% change
figure; 
scatter(change(:,3),change(:,2), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(change(:,3),change(:,2), txt3);
%set(gca,'XDir','reverse')
xlabel('Delta Active Range of Motion (deg)') 
ylabel('Delta Smoothness MAPR') 
% xlim([-1.2 0.8])
%ylim([-2 4])
title('Delta AROM vs MAPR')
print('Plots/ScatterPlots/210811_MAPRvsAROM_delta','-dpng')


%% correlations

[RHO1,PVAL1] = corr(Sesh1(:,4),Sesh1(:,3),'Type','Spearman');
[RHO2,PVAL2] = corr(Sesh3(:,4),Sesh3(:,3),'Type','Spearman');
[RHO3,PVAL3] = corr([Sesh1(:,4);Sesh3(:,4)], [Sesh1(:,3); Sesh3(:,3)],'Type','Spearman');
[RHO4,PVAL4] = corr(change(:,3),change(:,2),'Type','Spearman');
[RHO5,PVAL5] = corr(Sesh1(:,4),Sesh3(:,3),'Type','Spearman');




