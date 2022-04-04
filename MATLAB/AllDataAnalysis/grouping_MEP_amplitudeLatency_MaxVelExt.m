%% create groups - neurophysiology - SSEP %% 
% only consider groups at T1
% created: 15.11.2021

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
        latamp.T1.abs(n,5) = A(i,16); % Max Vel Ext T1
        latamp.T1.abs(n,6) = A(i,17); % Max Vel Ext T3
        latamp.T1.abs(n,7) = A(i,17)-A(i,16); % Max Vel Ext  Delta
        n = n+1; 
    elseif A(i,6)-A(i,8) > 1.2 || A(i,2) < 0.5*A(i,4) 
        latamp.T1.imp(m,1) = A(i,1); 
        latamp.T1.imp(m,2) = A(i,6); 
        latamp.T1.imp(m,3) = A(i,8);
        latamp.T1.imp(m,4) = A(i,6)-A(i,8); 
        latamp.T1.imp(m,5) = A(i,16); % Max Vel Ext T1
        latamp.T1.imp(m,6) = A(i,17); % Max Vel Ext  T3
        latamp.T1.imp(m,7) = A(i,17)-A(i,16); % Max Vel Ext  Delta
        m = m+1; 
    elseif A(i,6)-A(i,8) <= 1.2 && A(i,2) >= 0.5*A(i,4)
        latamp.T1.norm(k,1) = A(i,1); 
        latamp.T1.norm(k,2) = A(i,6); 
        latamp.T1.norm(k,3) = A(i,8); 
        latamp.T1.norm(k,4) = A(i,6)-A(i,8);
        latamp.T1.norm(k,5) = A(i,16); % Max Vel Ext  T1
        latamp.T1.norm(k,6) = A(i,17); % Max Vel Ext  T3
        latamp.T1.norm(k,7) = A(i,17)-A(i,16); % Max Vel Ext  Delta
        k = k+1; 
    end
end



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
    if latamp.T1.abs(i,7) >= 60.68
       scatter(1,latamp.T1.abs(i,7),'filled','g'); 
    elseif latamp.T1.abs(i,6) >= 255.6 && latamp.T1.abs(i,5) < 255.6
       scatter(1,latamp.T1.abs(i,7),'filled','b'); 
    else
       scatter(1,latamp.T1.abs(i,7),'filled','k');
    end
end
hold on
for i=1:length(latamp.T1.imp(:,7))
    if latamp.T1.imp(i,7) >= 60.68
       scatter(2,latamp.T1.imp(i,7),'filled','g'); 
    elseif latamp.T1.imp(i,6) >= 255.6 && latamp.T1.imp(i,5) < 255.6
       scatter(2,latamp.T1.imp(i,7),'filled','b'); 
    else
       scatter(2,latamp.T1.imp(i,7),'filled','k');
    end
end
hold on
for i=1:length(latamp.T1.norm(:,7))
    if latamp.T1.norm(i,7) >= 60.68
       scatter(3,latamp.T1.norm(i,7),'filled','g'); 
    elseif latamp.T1.norm(i,6) >= 255.6 && latamp.T1.norm(i,5) < 255.6
       scatter(3,latamp.T1.norm(i,7),'filled','b'); 
    else
       scatter(3,latamp.T1.norm(i,7),'filled','k');
    end
end
xlabel('MEP latency & amplitude @ T1') 
ylabel('Delta Max Velocity Extension (deg/s)') 
print('plots/BoxPlots/211115_MEPamplatT1_MaxVelExt_Delta','-dpng')

