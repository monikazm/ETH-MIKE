%% Plot like figure 3 in Zandvliet %% 
% created: 27.01.2021

% % change in sensory / motor 

clear 
close all
clc

%% Define colors to be used %% 
colors =    {[0, 0.4470, 0.7410]                    
          	[0.8500, 0.3250, 0.0980]	          	
          	[0.9290, 0.6940, 0.1250]	          	
          	[0.4940, 0.1840, 0.5560]	          	
          	[0.4660, 0.6740, 0.1880]	          	
          	[0.3010, 0.7450, 0.9330]	          	 
          	[0.6350, 0.0780, 0.1840]	
            [0.25, 0.25, 0.25]
            [0, 0.5, 0]
            [1, 0, 0]
            [0.75, 0, 0.75]
            [0.75, 0.75, 0]
            [0, 0, 1]
            [0, 1, 0]
            [0.75, 0.75, 0.75]
            [0.8, 0.4, 0]
            [0.25, 0.75, 0.5]
            [1.0, 0.4, 0.6]
            };

%% read table %% 

T = readtable('20210119_dbExport_impaired.csv'); 
M = readtable('20210121_metricInfo.csv'); 
ID = 36; 
SRD_sensory = table2array(M(ID,7)); 
% 28 - force flex
% 6 - AROM
% 74 - max vel ext
ID = 28; 
SRD_motor = table2array(M(ID,7)); 
healthyAvrg = table2array(M(ID,6));

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext

A = table2array(T(:,[3 5 122 114])); 

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

change(:,1) = Sesh1(:,1); 
change(:,2) = Sesh1(:,3) - Sesh3(:,3); 
change(:,3) = Sesh3(:,4) - Sesh1(:,4); 

n = 1; 
m = 1; 
j = 1; 
sensoryImproved = []; 
motorImproved = []; 
bothImproved = []; 
for i=1:length(change(:,1))
    if isnan(SRD_motor) 
    else
        if change(i,3) > abs(SRD_motor) && change(i,2) < abs(SRD_sensory)
            motorImproved(n) = change(i,1); 
            n = n+1; 
        elseif change(i,2) > abs(SRD_sensory) && change(i,3) < abs(SRD_motor)
            sensoryImproved(m) = change(i,1); 
            m = m+1; 
        elseif change(i,2) > abs(SRD_sensory) && change(i,3) > abs(SRD_motor)
            bothImproved(j) = change(i,1); 
            j = j+1;
        end
    end
end

%% plot longitudinal data - individual subjects 
% N = 11 

figure; 
for i=2:length(change) 
    if sum(change(i,1)== motorImproved) > 0 
        txt = ['Nr = ',num2str(i)];
        F = scatter(change(i,2),change(i,3),'filled','DisplayName',txt); 
        F.MarkerFaceColor = 'g';
        F.MarkerEdgeColor ='g'; 
        hold on 
    elseif sum(change(i,1) == sensoryImproved) > 0 
        txt = ['Nr = ',num2str(i)];
        F = scatter(change(i,2),change(i,3),'filled','DisplayName',txt); 
        F.MarkerFaceColor = 'b';
        F.MarkerEdgeColor ='b'; 
        hold on
    elseif sum(change(i,1) == bothImproved) > 0 
        txt = ['Nr = ',num2str(i)];
        F = scatter(change(i,2),change(i,3),'filled','DisplayName',txt); 
        F.MarkerFaceColor = 'm';
        F.MarkerEdgeColor ='m'; 
        hold on
    else
        txt = ['Nr = ',num2str(i)];
        F = scatter(change(i,2),change(i,3),'filled','DisplayName',txt); 
        F.MarkerFaceColor = 'k';
        F.MarkerEdgeColor ='k'; 
        hold on 
    end
end
%legend show
set(gca,'FontSize',12)
xlim([-10 15])
ylim([-10 15])
xlabel('Change in sensory') 
ylabel('Change in motor') 
print('Plots/ScatterPlots/210127_ChangeMotorSensory','-dpng')




