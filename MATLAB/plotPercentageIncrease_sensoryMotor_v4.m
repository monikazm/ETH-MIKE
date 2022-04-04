%% Change in Sensory vs Motor %% 
% created: 04.05.2021

% divide by SRD 

clear 
close all
clc

%% read table %% 

T = readtable('data/20210702_DataImpaired.csv'); 
M = readtable('data/20210121_metricInfo.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR

A = table2array(T(:,[3 5 92 127])); 

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

%% Calculate if above SRD

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
change(:,2) = Sesh3(:,3) - Sesh1(:,3); % change in motor
change(:,3) = Sesh1(:,4) - Sesh3(:,4); % change in sensorimotor 

change(1,:) = []; 

%% plot longitudinal data - individual subjects
% change by mean 

txt = string(change(:,1)'); 

figure;
m = scatter(change(:,2),change(:,3), 'filled');
%m.MarkerSize = 1; 
hold on
labelpoints(change(:,2),change(:,3), txt); 
%textscatter(change_bySRD(:,2),change_bySRD(:,3), txt); 
%legend show
%set(gca,'FontSize',12)
%xlim([-10 15])
%ylim([-0.1 0.25])
xlabel('Change in motor (AROM)') 
ylabel('Change in sensorimotor (MAPR)') 
% xlim([-1.2 0.8])
%ylim([-2 4])
title('AROM vs MAPR')
print('Plots/ScatterPlots/210702_ChangeMotorSensory_AROM_MAPR_absolute','-dpng')
