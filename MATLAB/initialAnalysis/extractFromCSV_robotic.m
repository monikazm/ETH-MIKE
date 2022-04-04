%% extract datat from CSV (cheater) %% 
% created: 19.01.2021

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

ID = 28; 
M = readtable('20210121_metricInfo.csv'); 
SRD = table2array(M(ID,7)); 
healthyAvrg = table2array(M(ID,6));

A = table2array(T(:,[3 5 114])); 

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

%% plot longitudinal data - individual subjects 
% N = 11 

figure; 
for i=unique(C(:,1))'
        temp = find(C(:,1)==i); 
        txt = ['Nr = ',num2str(i)];
        F = plot(C(temp,2),C(temp,3),'o-','DisplayName',txt); 
        F.MarkerFaceColor = colors{i};
    	F.Color = colors{i}; 
        hold on 
%    end
end
legend show
set(gca,'FontSize',12)
xlim([0.5 6.5]) 
xticks([1 2 3 4 5 6]) 
xlabel('Robotic Session Nr.') 
ylabel('Max. Force Flexion (N)') 
%print('Plots/LongitudinalPlots/210119_Indiv_MaxForce','-dpng')

%% group trends - mean for S1,S2,S3
n = 1; 
m = 1; 
k = 1; 
for i = 1:length(C(:,1))
    if C(i,2) == 1
        S1(n,:) = C(i,:);
        n = n+1; 
    elseif C(i,2) == 2
        S2(m,:) = C(i,:);
        m = m+1; 
    elseif C(i,2) == 3
        S3(k,:) = C(i,:);
        k = k+1; 
    end
end

S1_mean = mean(S1(:,3)); 
S2_mean = mean(S2(:,3)); 
S3_mean = mean(S3(:,3)); 

%% plot subjects plus mean

figure; 
for i=unique(C(:,1))'
        temp = find(C(:,1)==i); 
        F = plot(C(temp,2),C(temp,3),'o-'); 
        F.MarkerFaceColor = [0.6 0.6 0.6];
    	F.Color = [0.6 0.6 0.6]; 
        hold on 
end 
M = plot(1:3,[S1_mean S2_mean S3_mean],'d-'); 
M.MarkerFaceColor = 'k';
M.Color = 'k'; 
set(gca,'FontSize',12)
xlim([0.5 6.5]) 
xticks([1 2 3 4 5 6]) 
xlabel('Robotic Session Nr.') 
ylabel('Max. Force Flexion (N)') 
%print('Plots/LongitudinalPlots/210119_Sum_MaxForce','-dpng')

%% is there significant difference between the 3 timepoints? 
% let's plug in an anova bitches

% anovadata = [S1(:,3); S2(:,3); S3(:,3)]; 
% 
% for i=1:length(S1)
%     gr1(i,1) = {'S1'}; %control
% end
% for i=1:length(S2)
%     gr2(i,1) = {'S2'}; %NI
% end
% for i=1:length(S3)
%     gr3(i,1) = {'S3'}; %I
% end
% anovagroups = [gr1;gr2;gr3]; 
% 
% [~,~,stats_anova] = kruskalwallis(anovadata,anovagroups); 
% [c,~,~,gnames] = multcompare(stats_anova,'CType','bonferroni'); 
% GroupComparison = [gnames(c(:,1)), gnames(c(:,2)), num2cell(c(:,3:6))]; 
% 
% figure; 
% boxplot(anovadata,anovagroups);
% %ylim([0 32]) 
% ylabel('Maximum Force (N)')
% xlabel('Groups')
% title('Force vs session nr')
% set(gca,'FontSize',12)
% print('Plots/LongitudinalPlots/210119_ANOVA_MaxForce','-dpng')


%% Calculate if above SRD 

n = 1; 
m = 1; 
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
for i=1:length(inclDisDiff(:,1))
    if inclDisDiff(i,2) > abs(SRD) 
        subjectImproved(n) = inclDisDiff(i,1); 
        n = n+1; 
    end
end


figure; 
for i=unique(C(:,1))'
    if sum(i == subjectImproved) > 0 
        temp = find(C(:,1)==i); 
        txt = ['Nr = ',num2str(i)];
        F = plot(C(temp,2),C(temp,3),'o--','DisplayName',txt,'Linewidth',2); 
        F.MarkerFaceColor = colors{i};
    	F.Color = colors{i}; 
        hold on 
    else
        temp = find(C(:,1)==i); 
        txt = ['Nr = ',num2str(i)];
        F = plot(C(temp,2),C(temp,3),'o-','DisplayName',txt); 
        F.MarkerFaceColor = colors{i};
    	F.Color = colors{i}; 
        hold on 
    end
%    end
end
if isnan(healthyAvrg) 
else
    hold on 
    yline(healthyAvrg,'-.k','DisplayName','HealthyAvg','Linewidth',2); 
end
legend show
set(gca,'FontSize',12)
xlim([0.5 6.5]) 
xticks([1 2 3 4 5 6]) 
xlabel('Robotic Session Nr.') 
ylabel('Max Force Flexion (N)') 
print('Plots/LongitudinalPlots/robotic/210121_Indiv_MaxForce','-dpng')



