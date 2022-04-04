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

% amplitude 
n = 1; 
m = 1; 
k = 1; 
for i=1:length(A)
    if A(i,2) == 0 
        ampl.T1.abs(n,1) = A(i,1); 
        ampl.T1.abs(n,2) = A(i,2); 
        ampl.T1.abs(n,3) = A(i,4);
        ampl.T1.abs(n,4) = 0; %A(i,2)./A(i,4); 
        ampl.T1.abs(n,5) = A(i,10); % PM T1
        ampl.T1.abs(n,6) = A(i,11); % PM T3
        ampl.T1.abs(n,7) = A(i,10)-A(i,11); % PM Delta
        n = n+1; 
    elseif A(i,2) < 0.5*A(i,4) 
        ampl.T1.imp(m,1) = A(i,1); 
        ampl.T1.imp(m,2) = A(i,2); 
        ampl.T1.imp(m,3) = A(i,4); 
        ampl.T1.imp(m,4) = A(i,2)./A(i,4); 
        ampl.T1.imp(m,5) = A(i,10); % PM T1
        ampl.T1.imp(m,6) = A(i,11); % PM T3
        ampl.T1.imp(m,7) = A(i,10)-A(i,11); % PM Delta
        m = m+1; 
    elseif A(i,2) >= 0.5*A(i,4)
        ampl.T1.norm(k,1) = A(i,1); 
        ampl.T1.norm(k,2) = A(i,2); 
        ampl.T1.norm(k,3) = A(i,4); 
        ampl.T1.norm(k,4) = A(i,2)./A(i,4);
        ampl.T1.norm(k,5) = A(i,10); % PM T1
        ampl.T1.norm(k,6) = A(i,11); % PM T3
        ampl.T1.norm(k,7) = A(i,10)-A(i,11); % PM Delta
        k = k+1; 
    end
end

% latency
n = 1; 
m = 1; 
k = 1; 
for i=1:length(A)
    if A(i,6) == 35
        lat.T1.abs(n,1) = A(i,1); 
        lat.T1.abs(n,2) = A(i,6); 
        lat.T1.abs(n,3) = A(i,8); 
        lat.T1.abs(n,3) = A(i,6)-A(i,8);  
        lat.T1.abs(n,5) = A(i,10); % PM T1
        lat.T1.abs(n,6) = A(i,11); % PM T3
        lat.T1.abs(n,7) = A(i,10)-A(i,11); % PM Delta
        n = n+1; 
    elseif A(i,6)-A(i,8) > 1.1
        lat.T1.imp(m,1) = A(i,1); 
        lat.T1.imp(m,2) = A(i,6); 
        lat.T1.imp(m,3) = A(i,8);
        lat.T1.imp(m,4) = A(i,6)-A(i,8); 
        lat.T1.imp(m,5) = A(i,10); % PM T1
        lat.T1.imp(m,6) = A(i,11); % PM T3
        lat.T1.imp(m,7) = A(i,10)-A(i,11); % PM Delta
        m = m+1; 
    elseif A(i,6)-A(i,8) <= 1.1
        lat.T1.norm(k,1) = A(i,1); 
        lat.T1.norm(k,2) = A(i,6); 
        lat.T1.norm(k,3) = A(i,8); 
        lat.T1.norm(k,4) = A(i,6)-A(i,8);
        lat.T1.norm(k,5) = A(i,10); % PM T1
        lat.T1.norm(k,6) = A(i,11); % PM T3
        lat.T1.norm(k,7) = A(i,10)-A(i,11); % PM Delta
        k = k+1; 
    end
end


%% plot SSEP amplitude groups vs PM change

% PM
g1 = repmat({'Absent'},length(ampl.T1.abs(:,4)),1);
g2 = repmat({'Impaired'},length(ampl.T1.imp(:,5)),1);
g3 = repmat({'Normal'},length(ampl.T1.norm(:,5)),1);
g = [g1;g2;g3]; 
figure; 
boxplot([ampl.T1.abs(:,7); ampl.T1.imp(:,7); ampl.T1.norm(:,7)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(ampl.T1.abs(:,7))
    scatter(1,ampl.T1.abs(i,7),'filled','k'); 
end
hold on
for i=1:length(ampl.T1.imp(:,7))
    scatter(2,ampl.T1.imp(i,7),'filled','k'); 
end
hold on
for i=1:length(ampl.T1.norm(:,7))
    scatter(3,ampl.T1.norm(i,7),'filled','k'); 
end
xlabel('SSEP amplitude @ T1') 
ylabel('Delta Position Matching Task (deg)') 
print('plots/BoxPlots/211115_SSEPampT1_PM_Delta','-dpng')

% % calculations
% ampl.T1.norm_PMmedian = nanmedian(ampl.T1.norm(:,5)); 
% ampl.T1.norm_PMiqr = iqr(ampl.T1.norm(:,5)); 
% ampl.T1.imp_PMmedian = nanmedian(ampl.T1.imp(:,5)); 
% ampl.T1.imp_PMiqr = iqr(ampl.T1.imp(:,5)); 
% ampl.T1.abs_PMmedian = nanmedian(ampl.T1.abs(:,4)); 
% ampl.T1.abs_PMiqr = iqr(ampl.T1.abs(:,4)); 
% 
% % Kruskal Wallis
% p_PM_T1 = kruskalwallis([ampl.T1.imp(:,5); ampl.T1.norm(:,5)],[g2;g3]); 


%% group together impaired and absent

ampl.T1.absimp = [ampl.T1.abs;ampl.T1.imp];  

% PM
g1 = repmat({'Impaired'},length(ampl.T1.absimp(:,7)),1);
g2 = repmat({'Normal'},length(ampl.T1.norm(:,7)),1);
g = [g1;g2]; 
figure; 
boxplot([ampl.T1.absimp(:,7); ampl.T1.norm(:,7)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(ampl.T1.absimp(:,7))
    if ampl.T1.absimp(i,7) >= 9.12
       scatter(1,ampl.T1.absimp(i,7),'filled','g'); 
       hold on 
       labelpoints(1,ampl.T1.absimp(i,7), string(ampl.T1.absimp(i,1))); 
    elseif ampl.T1.absimp(i,6) <= 10.63 && ampl.T1.absimp(i,5) > 10.63
       scatter(1,ampl.T1.absimp(i,7),'filled','b'); 
       hold on 
       labelpoints(1,ampl.T1.absimp(i,7), string(ampl.T1.absimp(i,1))); 
    else
       scatter(1,ampl.T1.absimp(i,7),'filled','k');
       hold on 
       labelpoints(1,ampl.T1.absimp(i,7), string(ampl.T1.absimp(i,1))); 
    end
end
hold on
for i=1:length(ampl.T1.norm(:,7))
    if ampl.T1.norm(i,7) >= 9.12
       scatter(2,ampl.T1.norm(i,7),'filled','g'); 
       hold on 
       labelpoints(2,ampl.T1.norm(i,7), string(ampl.T1.norm(i,1))); 
    elseif ampl.T1.norm(i,6) <= 10.63 && ampl.T1.norm(i,5) > 10.63
       scatter(2,ampl.T1.norm(i,7),'filled','b'); 
       hold on 
       labelpoints(2,ampl.T1.norm(i,7), string(ampl.T1.norm(i,1))); 
    else
       scatter(2,ampl.T1.norm(i,7),'filled','k'); 
       hold on 
       labelpoints(2,ampl.T1.norm(i,7), string(ampl.T1.norm(i,1))); 
    end
end
xlabel('SSEP amplitude @ T1') 
ylabel('Delta Position Matching Absolute Error (deg)') 
print('plots/BoxPlots/211115_SSEPamp_PM_Delta_v2','-dpng')

% is the difference significant between the groups? 
% Kruskal Wallis
p_PMDelta_SSEPT1 = kruskalwallis([ampl.T1.absimp(:,7); ampl.T1.norm(:,7)],[g1;g2]); 



%% group together impaired and absent

ampl.T1.absimp = [ampl.T1.abs;ampl.T1.imp];  

% PM
g1 = repmat({'Impaired'},length(ampl.T1.absimp(:,7)),1);
g2 = repmat({'Normal'},length(ampl.T1.norm(:,7)),1);
g = [g1;g2]; 
figure; 
boxplot([ampl.T1.absimp(:,7); ampl.T1.norm(:,7)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(ampl.T1.absimp(:,7))
    if ampl.T1.absimp(i,7) >= 9.12
       scatter(1,ampl.T1.absimp(i,7),'filled','g'); 
    elseif ampl.T1.absimp(i,6) <= 10.63 && ampl.T1.absimp(i,5) > 10.63
       scatter(1,ampl.T1.absimp(i,7),'filled','b'); 
    else
       scatter(1,ampl.T1.absimp(i,7),'filled','k');
    end
end
hold on
for i=1:length(ampl.T1.norm(:,7))
    if ampl.T1.norm(i,7) >= 9.12
       scatter(2,ampl.T1.norm(i,7),'filled','g'); 
    elseif ampl.T1.norm(i,6) <= 10.63 && ampl.T1.norm(i,5) > 10.63
       scatter(2,ampl.T1.norm(i,7),'filled','b'); 
    else
       scatter(2,ampl.T1.norm(i,7),'filled','k'); 
    end
end
xlabel('SSEP amplitude @ T1') 
ylabel('Delta Position Matching Absolute Error (deg)') 
print('plots/BoxPlots/211115_SSEPamp_PM_Delta_v3','-dpng')


%% initial impairment groups

% PM
g1 = repmat({'Impaired'},length(ampl.T1.absimp(:,5)),1);
g2 = repmat({'Normal'},length(ampl.T1.norm(:,5)),1);
g = [g1;g2]; 
figure; 
boxplot([ampl.T1.absimp(:,5); ampl.T1.norm(:,5)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(ampl.T1.absimp(:,5))
    if ampl.T1.absimp(i,7) >= 9.12
       scatter(1,ampl.T1.absimp(i,5),'filled','k'); 
    elseif ampl.T1.absimp(i,6) <= 10.63 && ampl.T1.absimp(i,5) > 10.63
       scatter(1,ampl.T1.absimp(i,5),'filled','k'); 
    else
       scatter(1,ampl.T1.absimp(i,5),'filled','k');
    end
end
hold on
for i=1:length(ampl.T1.norm(:,5))
    if ampl.T1.norm(i,7) >= 9.12
       scatter(2,ampl.T1.norm(i,5),'filled','k'); 
    elseif ampl.T1.norm(i,6) <= 10.63 && ampl.T1.norm(i,5) > 10.63
       scatter(2,ampl.T1.norm(i,5),'filled','k'); 
    else
       scatter(2,ampl.T1.norm(i,5),'filled','k'); 
    end
end
xlabel('SSEP amplitude @ T1') 
ylabel('Position Matching Absolute Error (deg) @ T1') 
print('plots/BoxPlots/211115_SSEPamp_PM_T1_v2','-dpng')

% is the difference significant between the groups? 
% Kruskal Wallis
p_PMT1_SSEPT1 = kruskalwallis([ampl.T1.absimp(:,5); ampl.T1.norm(:,5)],[g1;g2]); 





