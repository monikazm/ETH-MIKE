%% create groups - neurophysiology - SSEP %% 
% created: 01.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211101_Neurophysiology.csv'); 

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
        ampl.T1.abs(n,4) = A(i,10); % PM T1
        ampl.T1.abs(n,5) = A(i,12); % kUDT T1
        n = n+1; 
    elseif A(i,2) < 0.5*A(i,4) 
        ampl.T1.imp(m,1) = A(i,1); 
        ampl.T1.imp(m,2) = A(i,2); 
        ampl.T1.imp(m,3) = A(i,4); 
        ampl.T1.imp(m,4) = A(i,2)./A(i,4); 
        ampl.T1.imp(m,5) = A(i,10); % PM T1
        ampl.T1.imp(m,6) = A(i,12); % kUDT T1
        m = m+1; 
    elseif A(i,2) >= 0.5*A(i,4)
        ampl.T1.norm(k,1) = A(i,1); 
        ampl.T1.norm(k,2) = A(i,2); 
        ampl.T1.norm(k,3) = A(i,4); 
        ampl.T1.norm(k,4) = A(i,2)./A(i,4);
        ampl.T1.norm(k,5) = A(i,10); % PM T1
        ampl.T1.norm(k,6) = A(i,12); % kUDT T1
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
        lat.T1.abs(n,4) = A(i,10); % PM T1
        lat.T1.abs(n,5) = A(i,12); % kUDT T1
        n = n+1; 
    elseif A(i,6) >= 22.3 || A(i,6)-A(i,8) > 1.1
        lat.T1.imp(m,1) = A(i,1); 
        lat.T1.imp(m,2) = A(i,6); 
        lat.T1.imp(m,3) = A(i,8);
        lat.T1.imp(m,4) = A(i,6)-A(i,8); 
        lat.T1.imp(m,5) = A(i,10); % PM T1
        lat.T1.imp(m,6) = A(i,12); % kUDT T1
        m = m+1; 
    elseif A(i,6) < 22.3 
        lat.T1.norm(k,1) = A(i,1); 
        lat.T1.norm(k,2) = A(i,6); 
        lat.T1.norm(k,3) = A(i,8); 
        lat.T1.norm(k,4) = A(i,6)-A(i,8);
        lat.T1.norm(k,5) = A(i,10); % PM T1
        lat.T1.norm(k,6) = A(i,12); % kUDT T1
        k = k+1; 
    end
end

%% Grouping: T3

% amplitude 
n = 1; 
m = 1; 
k = 1; 
for i=1:length(A)
    if A(i,3) == 0 
        ampl.T3.abs(n,1) = A(i,1); 
        ampl.T3.abs(n,2) = A(i,3); 
        ampl.T3.abs(n,3) = A(i,5);
        ampl.T3.abs(n,4) = A(i,11); % PM T3
        ampl.T3.abs(n,5) = A(i,13); % kUDT T3
        n = n+1; 
    elseif A(i,3) < 0.5*A(i,5) 
        ampl.T3.imp(m,1) = A(i,1); 
        ampl.T3.imp(m,2) = A(i,3); 
        ampl.T3.imp(m,3) = A(i,5); 
        ampl.T3.imp(m,4) = A(i,3)./A(i,5); 
        ampl.T3.imp(m,5) = A(i,11); % PM T3
        ampl.T3.imp(m,6) = A(i,13); % kUDT T3
        m = m+1; 
    elseif A(i,3) >= 0.5*A(i,5)
        ampl.T3.norm(k,1) = A(i,1); 
        ampl.T3.norm(k,2) = A(i,3); 
        ampl.T3.norm(k,3) = A(i,5); 
        ampl.T3.norm(k,4) = A(i,3)./A(i,5);
        ampl.T3.norm(k,5) = A(i,11); % PM T3
        ampl.T3.norm(k,6) = A(i,13); % kUDT T3
        k = k+1; 
    end
end

% latency
n = 1; 
m = 1; 
k = 1; 
for i=1:length(A)
    if A(i,7) == 35
        lat.T3.abs(n,1) = A(i,1); 
        lat.T3.abs(n,2) = A(i,7); 
        lat.T3.abs(n,3) = A(i,9); 
        lat.T1.abs(n,4) = A(i,11); % PM T3
        lat.T1.abs(n,5) = A(i,13); % kUDT T3
        n = n+1; 
    elseif A(i,7) >= 22.3 || A(i,7)-A(i,9) > 1.1
        lat.T3.imp(m,1) = A(i,1); 
        lat.T3.imp(m,2) = A(i,7); 
        lat.T3.imp(m,3) = A(i,9);
        lat.T3.imp(m,4) = A(i,7)-A(i,9);
        lat.T1.imp(m,5) = A(i,11); % PM T3
        lat.T1.imp(m,6) = A(i,13); % kUDT T3
        m = m+1; 
    elseif A(i,7) < 22.3 
        lat.T3.norm(k,1) = A(i,1); 
        lat.T3.norm(k,2) = A(i,7); 
        lat.T3.norm(k,3) = A(i,9); 
        lat.T3.norm(k,4) = A(i,7)-A(i,9);
        lat.T3.norm(k,5) = A(i,11); % PM T3
        lat.T3.norm(k,6) = A(i,13); % kUDT T3
        k = k+1; 
    end
end

%% plot SSEP amplitude groups vs PM and vs kUDT - T1

% PM
g1 = repmat({'Absent'},length(ampl.T1.abs(:,4)),1);
g2 = repmat({'Impaired'},length(ampl.T1.imp(:,5)),1);
g3 = repmat({'Normal'},length(ampl.T1.norm(:,5)),1);
g = [g1;g2;g3]; 
figure; 
boxplot([ampl.T1.abs(:,4); ampl.T1.imp(:,5); ampl.T1.norm(:,5)],g) 
title('T1')
xlabel('SSEP amplitude @ T1') 
ylabel('Position Matching Absolute Error (deg) @ T1') 
print('plots/BoxPlots/211101_SSEPamp_PM_T1','-dpng')

% kUDT
g1 = repmat({'Absent'},length(ampl.T1.abs(:,4)),1);
g2 = repmat({'Impaired'},length(ampl.T1.imp(:,5)),1);
g3 = repmat({'Normal'},length(ampl.T1.norm(:,5)),1);
g = [g1;g2;g3]; 
figure; 
boxplot([ampl.T1.abs(:,5); ampl.T1.imp(:,6); ampl.T1.norm(:,6)],g) 
title('T1')
xlabel('SSEP amplitude @ T1') 
ylabel('kUDT @ T1') 
print('plots/BoxPlots/211101_SSEPamp_kUDT_T1','-dpng')

% calculations
ampl.T1.norm_PMmedian = nanmedian(ampl.T1.norm(:,5)); 
ampl.T1.norm_PMiqr = iqr(ampl.T1.norm(:,5)); 
ampl.T1.imp_PMmedian = nanmedian(ampl.T1.imp(:,5)); 
ampl.T1.imp_PMiqr = iqr(ampl.T1.imp(:,5)); 
ampl.T1.abs_PMmedian = nanmedian(ampl.T1.abs(:,4)); 
ampl.T1.abs_PMiqr = iqr(ampl.T1.abs(:,4)); 

% Kruskal Wallis
p_PM_T1 = kruskalwallis([ampl.T1.imp(:,5); ampl.T1.norm(:,5)],[g2;g3]); 

%% plot SSEP amplitude groups vs PM and vs kUDT - T3

% PM
g1 = repmat({'Absent'},length(ampl.T3.abs(:,4)),1);
g2 = repmat({'Impaired'},length(ampl.T3.imp(:,5)),1);
g3 = repmat({'Normal'},length(ampl.T3.norm(:,5)),1);
g = [g1;g2;g3]; 
figure; 
boxplot([ampl.T3.abs(:,4); ampl.T3.imp(:,5); ampl.T3.norm(:,5)],g)
title('T3')
xlabel('SSEP amplitude @ T3') 
ylabel('Position Matching Absolute Error (deg) @ T3') 
print('plots/BoxPlots/211101_SSEPamp_PM_T3','-dpng')

% calculations
ampl.T3.norm_PMmedian = nanmedian(ampl.T3.norm(:,5)); 
ampl.T3.norm_PMiqr = iqr(ampl.T3.norm(:,5)); 
ampl.T3.imp_PMmedian = nanmedian(ampl.T3.imp(:,5)); 
ampl.T3.imp_PMiqr = iqr(ampl.T3.imp(:,5)); 
ampl.T3.abs_PMmedian = nanmedian(ampl.T3.abs(:,4)); 
ampl.T3.abs_PMiqr = iqr(ampl.T3.abs(:,4)); 

% Kruskal Wallis
p_PM_T3 = kruskalwallis([ampl.T3.imp(:,5); ampl.T3.norm(:,5)],[g2;g3]); 

% kUDT
g1 = repmat({'Absent'},length(ampl.T3.abs(:,4)),1);
g2 = repmat({'Impaired'},length(ampl.T3.imp(:,5)),1);
g3 = repmat({'Normal'},length(ampl.T3.norm(:,5)),1);
g = [g1;g2;g3]; 
figure; 
boxplot([ampl.T3.abs(:,5); ampl.T3.imp(:,6); ampl.T3.norm(:,6)],g) 
title('T3')
xlabel('SSEP amplitude @ T3') 
ylabel('kUDT @ T3') 
print('plots/BoxPlots/211101_SSEPamp_kUDT_T3','-dpng')

%% plot SSEP LATENCY groups vs PM and vs kUDT - T1

% PM
g1 = repmat({'Absent'},length(lat.T1.abs(:,4)),1);
g2 = repmat({'Impaired'},length(lat.T1.imp(:,5)),1);
g3 = repmat({'Normal'},length(lat.T1.norm(:,5)),1);
g = [g1;g2;g3]; 
figure; 
boxplot([lat.T1.abs(:,4); lat.T1.imp(:,5); lat.T1.norm(:,5)],g) 
title('T1')
xlabel('SSEP latency @ T1') 
ylabel('Position Matching Absolute Error (deg) @ T1') 
print('plots/BoxPlots/211101_SSEPlat_PM_T1','-dpng')

% kUDT
g1 = repmat({'Absent'},length(lat.T1.abs(:,4)),1);
g2 = repmat({'Impaired'},length(lat.T1.imp(:,5)),1);
g3 = repmat({'Normal'},length(lat.T1.norm(:,5)),1);
g = [g1;g2;g3]; 
figure; 
boxplot([lat.T1.abs(:,5); lat.T1.imp(:,6); lat.T1.norm(:,6)],g) 
title('T1')
xlabel('SSEP amplitude @ T1') 
ylabel('kUDT @ T1') 
print('plots/BoxPlots/211101_SSEPlat_kUDT_T1','-dpng')

% calculations
lat.T1.norm_PMmedian = nanmedian(lat.T1.norm(:,5)); 
lat.T1.norm_PMiqr = iqr(lat.T1.norm(:,5)); 
lat.T1.imp_PMmedian = nanmedian(lat.T1.imp(:,5)); 
lat.T1.imp_PMiqr = iqr(lat.T1.imp(:,5)); 
lat.T1.abs_PMmedian = nanmedian(lat.T1.abs(:,4)); 
lat.T1.abs_PMiqr = iqr(lat.T1.abs(:,4)); 

% Kruskal Wallis
p_PM_T1_lat = kruskalwallis([lat.T1.imp(:,5); lat.T1.norm(:,5)],[g2;g3]); 


%% AMPLITUDE: change













