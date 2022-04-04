%% create groups - neurophysiology - SSEP %% 
% only consider groups at T1
% created: 15.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211102_SSEP.csv'); 

A = table2array(T(:,:)); 

%% Grouping: T1 

% latampency or latampitude 
n = 1; 
m = 1; 
k = 1; 
for i=1:length(A)
    if (A(i,6) == 35 && A(i,2) == 0) 
        latamp.T1.abs(n,1) = A(i,1); 
        latamp.T1.abs(n,2) = A(i,6); 
        latamp.T1.abs(n,3) = A(i,8); 
        latamp.T1.abs(n,3) = A(i,6)-A(i,8);  
        latamp.T1.abs(n,5) = A(i,10); % PM T1
        latamp.T1.abs(n,6) = A(i,11); % PM T3
        latamp.T1.abs(n,7) = A(i,10)-A(i,11); % PM Delta
        n = n+1; 
    elseif A(i,6)-A(i,8) > 1.2 || A(i,2) < 0.5*A(i,4) % medium
        latamp.T1.imp(m,1) = A(i,1); 
        latamp.T1.imp(m,2) = A(i,6); 
        latamp.T1.imp(m,3) = A(i,8);
        latamp.T1.imp(m,4) = A(i,6)-A(i,8); 
        latamp.T1.imp(m,5) = A(i,10); % PM T1
        latamp.T1.imp(m,6) = A(i,11); % PM T3
        latamp.T1.imp(m,7) = A(i,10)-A(i,11); % PM Delta
        m = m+1; 
    elseif A(i,6)-A(i,8) <= 1.2 && A(i,2) >= 0.5*A(i,4) % normal 
        latamp.T1.norm(k,1) = A(i,1); 
        latamp.T1.norm(k,2) = A(i,6); 
        latamp.T1.norm(k,3) = A(i,8); 
        latamp.T1.norm(k,4) = A(i,6)-A(i,8);
        latamp.T1.norm(k,5) = A(i,10); % PM T1
        latamp.T1.norm(k,6) = A(i,11); % PM T3
        latamp.T1.norm(k,7) = A(i,10)-A(i,11); % PM Delta
        k = k+1; 
    end
end

%% 

latamp.T1.norm_mean = nanmean(latamp.T1.norm(:,7)); 
latamp.T1.imp_mean = nanmean(latamp.T1.imp(:,7)); 
latamp.T1.abs_mean = nanmean(latamp.T1.abs(:,7)); 

latamp.T1.norm_std = nanstd(latamp.T1.norm(:,7)); 
latamp.T1.imp_std = nanstd(latamp.T1.imp(:,7)); 
latamp.T1.abs_std = nanstd(latamp.T1.abs(:,7)); 

latamp.T1.norm_mean2 = nanmean(latamp.T1.norm(:,5)); 
latamp.T1.imp_mean2 = nanmean(latamp.T1.imp(:,5)); 
latamp.T1.abs_mean2 = nanmean(latamp.T1.abs(:,5)); 

latamp.T1.norm_std2 = nanstd(latamp.T1.norm(:,5)); 
latamp.T1.imp_std2 = nanstd(latamp.T1.imp(:,5)); 
latamp.T1.abs_std2 = nanstd(latamp.T1.abs(:,5)); 


%% plot SSEP latampitude groups vs PM change

% 3 groups 

g1 = repmat({'Absent'},length(latamp.T1.abs(:,7)),1);
g2 = repmat({'Impaired'},length(latamp.T1.imp(:,7)),1);
g3 = repmat({'Normal'},length(latamp.T1.norm(:,7)),1);
g = [g1;g2;g3]; 
figure; 
boxplot([latamp.T1.abs(:,7); latamp.T1.imp(:,7); latamp.T1.norm(:,7)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(latamp.T1.abs(:,7))
    if latamp.T1.abs(i,7) >= 9.12
       scatter(1,latamp.T1.abs(i,7),'filled','g'); 
    elseif latamp.T1.abs(i,6) <= 10.63 && latamp.T1.abs(i,5) > 10.63
       scatter(1,latamp.T1.abs(i,7),'filled','b'); 
    else
       scatter(1,latamp.T1.abs(i,7),'filled','k');
    end
end
hold on
for i=1:length(latamp.T1.imp(:,7))
    if latamp.T1.imp(i,7) >= 9.12
       scatter(2,latamp.T1.imp(i,7),'filled','g'); 
    elseif latamp.T1.imp(i,6) <= 10.63 && latamp.T1.imp(i,5) > 10.63
       scatter(2,latamp.T1.imp(i,7),'filled','b'); 
    else
       scatter(2,latamp.T1.imp(i,7),'filled','k');
    end
end
hold on
for i=1:length(latamp.T1.norm(:,7))
    if latamp.T1.norm(i,7) >= 9.12
       scatter(3,latamp.T1.norm(i,7),'filled','g'); 
    elseif latamp.T1.norm(i,6) <= 10.63 && latamp.T1.norm(i,5) > 10.63
       scatter(3,latamp.T1.norm(i,7),'filled','b'); 
    else
       scatter(3,latamp.T1.norm(i,7),'filled','k');
    end
end
xlabel('SSEP amplitude & latency @ T1') 
ylabel('Delta Position Matching Absolute Error (deg)') 
print('plots/BoxPlots/211206_SSEPamplat_PM_Delta_3groups_V3','-dpng')

% % calculatampions
% latamp.T1.norm_PMmedian = nanmedian(latamp.T1.norm(:,5)); 
% latamp.T1.norm_PMiqr = iqr(latamp.T1.norm(:,5)); 
% latamp.T1.imp_PMmedian = nanmedian(latamp.T1.imp(:,5)); 
% latamp.T1.imp_PMiqr = iqr(latamp.T1.imp(:,5)); 
% latamp.T1.abs_PMmedian = nanmedian(latamp.T1.abs(:,4)); 
% latamp.T1.abs_PMiqr = iqr(latamp.T1.abs(:,4)); 

% Kruskal Wallis
p_PM_1 = kruskalwallis([latamp.T1.abs(:,7); latamp.T1.norm(:,7)],[g1;g3]); 
p_PM_2 = kruskalwallis([latamp.T1.abs(:,7); latamp.T1.imp(:,7)],[g1;g2]); 
% not significant 

% what if I take the outlier out (S30)
latamp.T1.imp(8,:) = []; 
g2 = repmat({'Impaired'},length(latamp.T1.imp(:,7)),1);
p_PM_3 = kruskalwallis([latamp.T1.abs(:,7); latamp.T1.imp(:,7)],[g1;g2]); 


%% plot SSEP latampitude groups vs PM @ T1

% 3 groups 

g1 = repmat({'Absent'},length(latamp.T1.abs(:,5)),1);
g2 = repmat({'Impaired'},length(latamp.T1.imp(:,5)),1);
g3 = repmat({'Normal'},length(latamp.T1.norm(:,5)),1);
g = [g1;g2;g3]; 
figure; 
hold on
yline(10.63,'k--');
boxplot([latamp.T1.abs(:,5); latamp.T1.imp(:,5); latamp.T1.norm(:,5)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(latamp.T1.abs(:,5))
    scatter(1,latamp.T1.abs(i,5),'filled','k'); 
end
hold on
for i=1:length(latamp.T1.imp(:,5))
    scatter(2,latamp.T1.imp(i,5),'filled','k'); 
end
hold on
for i=1:length(latamp.T1.norm(:,5))
    scatter(3,latamp.T1.norm(i,5),'filled','k'); 
end
xlabel('SSEP amplitude & latency @ T1') 
ylabel('Position Matching Absolute Error (deg) @ T1') 
print('plots/BoxPlots/211206_SSEPamplat_PM_T1_3groups','-dpng')

% Kruskal Wallis
p_PM_4 = kruskalwallis([latamp.T1.abs(:,5); latamp.T1.norm(:,5)],[g1;g3]); 
p_PM_5 = kruskalwallis([latamp.T1.imp(:,5); latamp.T1.norm(:,5)],[g2;g3]); 
p_PM_6 = kruskalwallis([latamp.T1.abs(:,5); latamp.T1.imp(:,5)],[g1;g2]); 


%% matrix

% change.abs = 0; % change sensory & absent SSEP
% change.imp = 5; %change sensory, impaired SSEP
% change.norm = 3; %change sensory, normal SSEP
% nochange.abs = 9; %no change absent SSEP
% nochange.imp = 5; %no change impaired SSEP
% nochange.norm = 2; % no change normal SSEP
% 
% %C = [kUDTimp_PMimp kUDTnonimp_PMimp; kUDTimp_PMnonimp kUDTnonimp_PMnonimp]; 
% C = [change.abs change.imp change.norm; nochange.abs nochange.imp nochange.norm]; 
% label = {'Absent';'Impaired'; 'Normal'}; 
% 
% figure; 
% Chart = confusionchart(C,label); 
% Chart.OffDiagonalColor = [0.7 0.7 0.7]; %[0.9290 0.6940 0.1250]; 
% Chart.DiagonalColor = [0.7 0.7 0.7]; %[0.4660 0.6740 0.1880]; 
% Chart.OuterPosition = [0.1 0.1 0.8 0.8]; 
% Chart.FontSize = 12; 
% %Chart.InnerPosition = [0.1 0.1 0.8 0.8]; 
% xlabel('Proprioception')
% ylabel('Motor function') 
% %title('Impairment classification matrix: 70% agreement')
% set(gca,'FontSize',12)
% % print('plots/ConfusionMatrices/211129_ChangeGroups','-dpng')
% 



