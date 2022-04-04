%% Plot curves like figure 2 in Zandvliet %% 
% created: 25.01.2021

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

ID = 36; 
M = readtable('20210121_metricInfo.csv'); 
SRD = table2array(M(ID,7)); 
healthyAvrg = table2array(M(ID,6));

% 122 - PM AE 
% 123 - PM VE
% 47 - kUDT

A = table2array(T(:,[3 5 122 47])); 

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
    elseif C(i,1) == 11
        if C(i,2) == 1
            Sesh1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 5
            Sesh3(k,:) = C(i,:);
            k = k+1; 
        end
    elseif C(i,1) == 6
        if C(i,2) == 1
            Sesh1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 4
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

inclDisDiff(:,1) = Sesh1(:,1); 
inclDisDiff(:,2) = Sesh3(:,3) - Sesh1(:,3); 

n = 1; 
subjectImproved = []; 
for i=1:length(inclDisDiff(:,1))
    if isnan(SRD) 
    else
        if abs(inclDisDiff(i,2)) > abs(SRD) 
            subjectImproved(n) = inclDisDiff(i,1); 
            n = n+1; 
        end
    end
end

%% plot longitudinal data - individual subjects 
% N = 11 

figure; 
temp = [];
for i=unique(C(:,1))'
    if i == 2
    else
    temp = find(C(:,1)==i); 
    if C(temp(1),4) < 3
        if sum(i == subjectImproved) > 0 
            txt = ['Nr = ',num2str(i)];
            F = plot(C(temp,2),C(temp,3),'o--','DisplayName',txt,'Linewidth',2); 
            F.MarkerFaceColor = 'r';
            F.Color ='r'; 
            hold on 
            temp = [];
        else
            txt = ['Nr = ',num2str(i)];
            F = plot(C(temp,2),C(temp,3),'o-','DisplayName',txt); 
            F.MarkerFaceColor = 'r';
            F.Color ='r'; 
            hold on 
            temp = []; 
        end
    elseif C(temp(1),4) == 3
        if sum(i == subjectImproved) > 0
            txt = ['Nr = ',num2str(i)];
            F = plot(C(temp,2),C(temp,3),'o--','DisplayName',txt,'Linewidth',2); 
            F.MarkerFaceColor = 'g';
            F.Color ='g'; 
            hold on 
            temp = [];
        else
            txt = ['Nr = ',num2str(i)];
            F = plot(C(temp,2),C(temp,3),'o-','DisplayName',txt); 
            F.MarkerFaceColor = 'g';
            F.Color ='g'; 
            hold on 
            temp = [];
        end
    end
    end
end
legend show
set(gca,'FontSize',12)
xlim([0.5 6.5]) 
xticks([1 2 3 4 5 6]) 
if isnan(healthyAvrg) 
else
    hold on 
    yline(healthyAvrg,'-.k'); 
end
xlabel('Robotic Session Nr.') 
ylabel('Positon Matching AE') 
set (gca,'YDir','reverse')
%print('Plots/LongitudinalPlots/Zandvliet/210125_Indiv_PMAE','-dpng')

% ylabel('Positon Matching AE') 
% print('Plots/LongitudinalPlots/Zandvliet/210125_Indiv_PMAE','-dpng')

% also include on this plot which subjects improved above SRD? 




