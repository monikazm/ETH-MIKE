%% FIGURE SM4 - groups of MEP (absent, impaired, normal) vs delta ROM & ROM @ T1  %% 
% created: 04.05.2022
clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211104_MEP.csv'); 

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
        latamp.T1.abs(n,5) = A(i,14); % ROM T1
        latamp.T1.abs(n,6) = A(i,15); % ROM T3
        latamp.T1.abs(n,7) = A(i,15)-A(i,14); % ROM Delta
        n = n+1; 
    elseif A(i,6)-A(i,8) > 1.2 || A(i,2) < 0.5*A(i,4) 
        latamp.T1.imp(m,1) = A(i,1); 
        latamp.T1.imp(m,2) = A(i,6); 
        latamp.T1.imp(m,3) = A(i,8);
        latamp.T1.imp(m,4) = A(i,6)-A(i,8); 
        latamp.T1.imp(m,5) = A(i,14); % ROM T1
        latamp.T1.imp(m,6) = A(i,15); % ROM T3
        latamp.T1.imp(m,7) = A(i,15)-A(i,14); % ROM Delta
        m = m+1; 
    elseif A(i,6)-A(i,8) <= 1.2 && A(i,2) >= 0.5*A(i,4)
        latamp.T1.norm(k,1) = A(i,1); 
        latamp.T1.norm(k,2) = A(i,6); 
        latamp.T1.norm(k,3) = A(i,8); 
        latamp.T1.norm(k,4) = A(i,6)-A(i,8);
        latamp.T1.norm(k,5) = A(i,14); % ROM T1
        latamp.T1.norm(k,6) = A(i,15); % ROM T3
        latamp.T1.norm(k,7) = A(i,15)-A(i,14); % ROM Delta
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
sz = 70;
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
    if latamp.T1.abs(i,7) >= 15.58
       scatter(1,latamp.T1.abs(i,7),sz,'*','MarkerEdgeColor','b'); 
    elseif latamp.T1.abs(i,6) >= 63.20 && latamp.T1.abs(i,5) < 63.20
       scatter(1,latamp.T1.abs(i,7),sz,'*','MarkerEdgeColor','b'); 
    else
       scatter(1,latamp.T1.abs(i,7),'filled','k');
    end
end
hold on
for i=1:length(latamp.T1.imp(:,7))
    if latamp.T1.imp(i,7) >= 15.58
       scatter(2,latamp.T1.imp(i,7),sz,'*','MarkerEdgeColor','b'); 
    elseif latamp.T1.imp(i,6) >= 63.20 && latamp.T1.imp(i,5) < 63.20
       scatter(2,latamp.T1.imp(i,7),sz,'*','MarkerEdgeColor','b'); 
    else
       scatter(2,latamp.T1.imp(i,7),'filled','k');
    end
end
hold on
for i=1:length(latamp.T1.norm(:,7))
    if latamp.T1.norm(i,7) >= 15.58
       p1 = scatter(3,latamp.T1.norm(i,7),sz,'*','MarkerEdgeColor','b'); 
    elseif latamp.T1.norm(i,6) >= 63.20 && latamp.T1.norm(i,5) < 63.20
       p1 = scatter(3,latamp.T1.norm(i,7),sz,'*','MarkerEdgeColor','b'); 
    else
       p2 = scatter(3,latamp.T1.norm(i,7),'filled','k');
    end
end
xlabel('MEP latency & amplitude @ T1') 
ylabel('Delta Range of Motion (deg)') 
legend([p1(1),p2(1)],'considerable improvement','not considerable improvement','Location','best')
set(gca,'FontSize',12)
title('Change in ROM vs MEP groups') 
print('plots/Paper/220504_FigureSM4_2B','-dpng')
figure2pdf('plots/Paper/220504_FigureSM4_2B'); 

% Kruskal Wallis
p_ROM_1 = kruskalwallis([latamp.T1.abs(:,7); latamp.T1.norm(:,7)],[g1;g3]); 
p_ROM_2 = kruskalwallis([latamp.T1.abs(:,7); latamp.T1.imp(:,7)],[g1;g2]); 
% not significant 

%% plot MEP latampitude groups vs ROM at T1

% 3 groups 

g1 = repmat({'Absent (N=7)'},length(latamp.T1.abs(:,5)),1);
g2 = repmat({'Impaired (N=19)'},length(latamp.T1.imp(:,5)),1);
g3 = repmat({'Normal (N=14)'},length(latamp.T1.norm(:,5)),1);
g = [g1;g2;g3]; 
figure;
hold on 
yline(63.20,'k--');
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
set(gca,'FontSize',12)
xlabel('MEP amplitude & latency group @ T1') 
ylabel('Range of Motion (deg) @ T1') 
ylim([-10 100])
title('ROM @ T1 vs MEP groups') 
print('plots/Paper/220504_FigureSM4_2A','-dpng')

% Kruskal Wallis
p_V_4 = kruskalwallis([latamp.T1.abs(:,5); latamp.T1.norm(:,5)],[g1;g3]); 
p_V_5 = kruskalwallis([latamp.T1.imp(:,5); latamp.T1.norm(:,5)],[g2;g3]); 
p_V_6 = kruskalwallis([latamp.T1.abs(:,5); latamp.T1.imp(:,5)],[g1;g2]); 


