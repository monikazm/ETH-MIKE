%% Sensory vs Motor at two different time points (inclusion and discharge and change) %% 
% created: 17.08.2021

% are the relationships between the two different at inclusion and
% discharge and well as between delta? 

% inspired from: https://pubmed.ncbi.nlm.nih.gov/28566461/ 

clear 
close all
clc

%% read table %% 

T = readtable('data/20210811_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR
% FMSensory = 46; 
% FMA = 41; 
% FMAH = 44; 

A = table2array(T(:,[3 5 44 122])); 

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

%% calculate change
change(:,1) = Sesh1(:,1); 
change(:,2) = Sesh3(:,3)-Sesh1(:,3); 
change(:,3) = Sesh3(:,4)-Sesh1(:,4); 

%% remove NaNs for correlations

Sesh2_new = []; 
for i = 1:length(Sesh3)
    if isnan(Sesh3(i,:)) == 0 
       Sesh2_new(i,:) = Sesh3(i,:); 
    end
end
% Remove zero rows
Sesh2_new( all(~Sesh2_new,2), : ) = [];

Lia = double(ismember(Sesh1(:,1),Sesh2_new(:,1))); 
Sesh1(:,1) = Lia.*Sesh1(:,1); 
Sesh1(Sesh1(:,1)==0,:)= [];

Lia = double(ismember(change(:,1),Sesh2_new(:,1))); 
change(:,1) = Lia.*change(:,1); 
change(change(:,1)==0,:)= [];

%% Divide into two groups
change_2 = []; 
change_3 = []; 
for i = 1:length(change)
    if change(i,2) >= 1
       change_2(i,:) = change(i,:); 
    else 
       change_3(i,:) = change(i,:);  
    end
end
% Remove zero rows
change_2( all(~change_2,2), : ) = [];
change_3( all(~change_3,2), : ) = [];


Sesh1_2 = []; 
Sesh1_3 = []; 
for i = 1:length(Sesh1)
    if change(i,2) >= 1
       Sesh1_2(i,:) = Sesh1(i,:); 
    else
       Sesh1_3(i,:) = Sesh1(i,:);  
    end
end
% Remove zero rows
Sesh1_2( all(~Sesh1_2,2), : ) = [];
Sesh1_3( all(~Sesh1_3,2), : ) = [];

%% plot Motor vs Sensory 
% raw metric for now, eventually do it in z-score  

txt1 = string(Sesh1(:,1)');
txt2 = string(Sesh2_new(:,1)');
txt3 = string(change(:,1)');
txt4 = string(change_2(:,1)'); 
txt5 = string(change_3(:,1)'); 

% T1 
figure;
scatter(Sesh1(:,4),Sesh1(:,3), 'filled'); % x-sensory, y-motor
hold on
labelpoints(Sesh1(:,4),Sesh1(:,3), txt1); 
xlabel('Position Matching Error @ T1') 
ylabel('FMA Hand @ T1') 
%xlim([-0.5 12.5])
%ylim([-2 4])
title('FMAH vs PM @ T1')
print('Plots/ScatterPlots/210817_FMAH_PM_T1','-dpng')

% T3
figure; 
scatter(Sesh2_new(:,4),Sesh2_new(:,3), 'filled','r'); % x-sensory, y-motor
hold on
labelpoints(Sesh2_new(:,4),Sesh2_new(:,3), txt2);
xlabel('Position Matching Error @ T3') 
ylabel('FMA Hand @ T3') 
%xlim([-0.5 12.5])
%ylim([-2 4])
title('FMAH vs PM @ T3')
print('Plots/ScatterPlots/210817_FMAH_PM_T3','-dpng')

% change
figure; 
scatter(change(:,3),change(:,2), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(change(:,3),change(:,2), txt3);
%set(gca,'XDir','reverse')
xlabel('Delta Position Matching Error') 
ylabel('Delta FMA Hand') 
% xlim([-1.2 0.8])
%ylim([-2 4])
title('Delta FMAH vs PM')
print('Plots/ScatterPlots/210817_FMAH_PM_delta','-dpng')

% change vs PM @ T1
figure; 
scatter(Sesh1(:,4),change(:,2), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(Sesh1(:,4),change(:,2), txt3);
%set(gca,'XDir','reverse')
xlabel('Position Matching Error @ T1') 
ylabel('Delta FMA Hand') 
% xlim([-1.2 0.8])
%ylim([-5 27])
title('Delta FMAH vs PM @ T1')
print('Plots/ScatterPlots/210817_FMAH_delta_PMT1','-dpng')

% change vs PM @ T1 - IMPROVING GROUP 
figure; 
scatter(Sesh1_2(:,4),change_2(:,2), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(Sesh1_2(:,4),change_2(:,2), txt4);
%set(gca,'XDir','reverse')
xlabel('Position Matching Error @ T1') 
ylabel('Delta FMA Hand') 
xlim([0 26])
%ylim([-5 27])
title('Delta FMAH vs PM @ T1 - IMPROVING')
print('Plots/ScatterPlots/210817_FMAH_delta_PMT1_IMPROVING','-dpng')

% change vs PM @ T1 - NOT IMPROVING GROUP 
figure; 
scatter(Sesh1_3(:,4),change_3(:,2), 'filled','k'); % x-sensory, y-motor
hold on
labelpoints(Sesh1_3(:,4),change_3(:,2), txt5);
%set(gca,'XDir','reverse')
xlabel('Position Matching Error @ T1') 
ylabel('Delta FMA Hand') 
xlim([0 26])
%ylim([-5 27])
title('Delta FMAH vs PM @ T1 - NON-IMPROVING')
print('Plots/ScatterPlots/210817_FMAH_delta_PMT1_NONIMPROVING','-dpng')



%% correlations

[RHO1,PVAL1] = corr(Sesh1(:,4),Sesh1(:,3),'Type','Spearman');
[RHO2,PVAL2] = corr(Sesh2_new(:,4),Sesh2_new(:,3),'Type','Spearman');
[RHO3,PVAL3] = corr([Sesh1(:,4);Sesh2_new(:,4)], [Sesh1(:,3); Sesh2_new(:,3)],'Type','Spearman');
[RHO4,PVAL4] = corr(change(:,3),change(:,2),'Type','Spearman');
[RHO5,PVAL5] = corr(Sesh1(:,4),change(:,2),'Type','Spearman');
[RHO6,PVAL6] = corr(Sesh1_2(:,4),change_2(:,2),'Type','Spearman');
[RHO7,PVAL7] = corr(Sesh1_3(:,4),change_3(:,2),'Type','Spearman');



