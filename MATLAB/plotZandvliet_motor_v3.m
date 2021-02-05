%% Categorize subjects %% 
% created: 26.01.2021

% playing around with data to get a bit of a feeling 

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

% 28 - force flex
% 6 - AROM
% 74 - max vel ext

ID = 74; 
M = readtable('20210121_metricInfo.csv'); 
SRD = table2array(M(ID,7)); 
healthyAvrg = table2array(M(ID,6));

% % 41 = Fugl-Meyer total 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext

%A = table2array(T(:,[3 5 114 41])); 
%A = table2array(T(:,[3 5 92 41]));
A = table2array(T(:,[3 5 160 41]));

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

% only consider S1 and S3 for this analysis, because I'm comparing to
% clinical 

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
    elseif C(i,1) == 12
        if C(i,2) == 1
            Sesh1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 2
            Sesh3(k,1:3) = C(i,1:3);
            Sesh3(k,4) = C(i,4);
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

inclDisDiff(:,1) = Sesh1(:,1); 
inclDisDiff(:,2) = Sesh3(:,3) - Sesh1(:,3); 
inclDisDiff(:,3) = Sesh3(:,4) - Sesh1(:,4); 

n = 1; 
subjectImprovedSRD = []; 
for i=1:length(inclDisDiff(:,1))
    if isnan(SRD) 
    else
        if inclDisDiff(i,2) > abs(SRD) 
            subjectImprovedSRD(n) = inclDisDiff(i,1); 
            n = n+1; 
        end
    end
end

n = 1; 
subjectImprovedMDC = []; 
for i=1:length(inclDisDiff(:,1))
    if isnan(SRD) 
    else
        if inclDisDiff(i,3) > 5.2
            subjectImprovedMDC(n) = inclDisDiff(i,1); 
            n = n+1; 
        end
    end
end



%% Plot longitudinal 
figure; 
temp = [];
for i=unique(C(:,1))'
    temp = find(C(:,1)==i); 
    if sum(i == subjectImprovedSRD) > 0 && sum(i == subjectImprovedMDC) > 0 
        txt = ['Nr = ',num2str(i)];
        B = plot(C(temp,2),C(temp,3),'o--','Linewidth',2); 
        B.MarkerFaceColor = [0, 0.4470, 0.7410];
        B.Color = [0, 0.4470, 0.7410];
        hold on 
        temp = [];
    elseif sum(i == subjectImprovedSRD) > 0 && sum(i == subjectImprovedMDC) == 0 
        txt = ['Nr = ',num2str(i)];
        S = plot(C(temp,2),C(temp,3),'o-'); 
        S.MarkerFaceColor = [0, 0.4470, 0.7410];
        S.Color = [0, 0.4470, 0.7410]; 
        hold on 
        temp = [];
    elseif sum(i == subjectImprovedSRD) == 0 && sum(i == subjectImprovedMDC) > 0 
        txt = ['Nr = ',num2str(i)];
        F = plot(C(temp,2),C(temp,3),'o--','Linewidth',2); 
        F.MarkerFaceColor = [0.8500, 0.3250, 0.0980];
        F.Color = [0.8500, 0.3250, 0.0980];  
        hold on 
        temp = []; 
    else
        txt = ['Nr = ',num2str(i)];
        N = plot(C(temp,2),C(temp,3),'o-'); 
        N.MarkerFaceColor = [0.8500, 0.3250, 0.0980];
        N.Color =[0.8500, 0.3250, 0.0980]; 
        hold on 
        temp = []; 
    end
end
legend([B S F N],'>SRD&>MDC','>SRD&<MDC','<SRD&>MDC','<SRD&<MDC')
set(gca,'FontSize',12)
xlim([0.5 6.5]) 
xticks([1 2 3 4 5 6]) 
if isnan(healthyAvrg) 
else
    hold on 
    txt = 'HealthyAvrg'; 
    yline(healthyAvrg,'-.g','DisplayName',txt,'Linewidth',2); 
end
xlabel('Robotic Session Nr.') 
% ylabel('Max Force Flex (N)') 
% print('Plots/LongitudinalPlots/Zandvliet/210127_Indiv_ForceFlex','-dpng')
% ylabel('AROM (deg)') 
% print('Plots/LongitudinalPlots/Zandvliet/210127_Indiv_AROM','-dpng')
ylabel('Max Vel Ext (deg/s)') 
print('Plots/LongitudinalPlots/Zandvliet/210127_Indiv_MaxVelExt','-dpng')
