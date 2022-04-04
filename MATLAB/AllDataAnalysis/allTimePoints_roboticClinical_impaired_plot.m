%% report all values of robotic tests %% 
% also calculate mean & std for each metric for each time point
% created: 17.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR
% 47 - kUDT
% 41 - FM M UL
% 48 - BB imp 
% 49 - BB nonimp
% 50 - barther index tot
% 44 - FMA Hand 
% 61 - MoCA
% 46 FM Sensory 

A = table2array(T(:,[3 5 92 114 160 127 122 47 41])); 

%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,10) = timeSinceStroke; 

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
withREDCap2(:,5) = withREDCap(:,5);
withREDCap2(:,6) = withREDCap(:,6);
withREDCap2(:,7) = withREDCap(:,7);
withREDCap2(:,8) = withREDCap(:,8);
withREDCap2(:,9) = withREDCap(:,9);
withREDCap2(:,10) = withREDCap(:,10);

C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: max force flexion 

% remove those rows where there is only one data point
% n = 1; 
% remove = []; 
% for i=1:max(C(:,1))
%     temp = find(C(:,1)==i); 
%     if length(temp) == 1
%         remove(n) = temp; 
%         n = n+1; 
%     end
% end
% C(remove,:) = []; 

%% Divide into groups

out = []; 
n = 1; 
%for j = 1:length(C(:,1))
    for i = unique(C(:,1))'
        out(n,1) = i; 
        out(n,2) = max(C(find(C(:,1) == i),2)); 
        n = n+1; 
    end
%end

n = 1;
m = 1; 
o = 1; 
p = 1; 
q = 1;
r = 1; 
s = 1; 
for i = out(:,1)'
    if out(find(out(:,1)==i),2) == 1
        T1.S1(n,:) = C(find(C(:,1)==out(find(out(:,1)==i),1)),:);
        n = n+1; 
    elseif out(find(out(:,1)==i),2) == 2
        T2.S1(m,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==1),:);
        T2.S2(m,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==2),:);
        m = m+1;
    elseif out(find(out(:,1)==i),2) == 3
        T3.S1(o,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==1),:);
        T3.S2(o,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==2),:);
        T3.S3(o,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==3),:);
        o = o+1;
    elseif out(find(out(:,1)==i),2) == 4
        T4.S1(p,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==1),:);
        T4.S2(p,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==2),:);
        T4.S3(p,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==3),:);
        T4.S4(p,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==4),:);
        p = p+1;    
     elseif out(find(out(:,1)==i),2) == 5
        T5.S1(q,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==1),:);
        T5.S2(q,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==2),:);
        T5.S3(q,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==3),:);
        T5.S4(q,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==4),:);
        T5.S5(q,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==5),:);
        q = q+1;   
     elseif out(find(out(:,1)==i),2) == 6
        T6.S1(r,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==1),:);
        T6.S2(r,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==2),:);
        T6.S3(r,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==3),:);
        T6.S4(r,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==4),:);
        T6.S5(r,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==5),:);
        T6.S6(r,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==6),:);
        r = r+1;   
     elseif out(find(out(:,1)==i),2) == 8
        T7.S1(s,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==1),:);
        T7.S2(s,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==2),:);
        T7.S3(s,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==3),:);
        T7.S4(s,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==4),:);
        T7.S5(s,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==5),:);
        T7.S6(s,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==6),:);
        T7.S7(s,:) = C(find((C(:,1)==out(find(out(:,1)==i),1))&C(:,2)==7),:);
        s = s+1;  
    end
end

T4.S3(1,7) = T4.S2(1,7); 
T7.S2(1,7) = 20;  

%% calculate means per group

T1.S1_mean.PM = nanmean(T1.S1(:,7)); 

T2.S1_mean.PM = nanmean(T2.S1(:,7)); 
T2.S2_mean.PM = nanmean(T2.S2(:,7)); 

T3.S1_mean.PM = nanmean(T3.S1(:,7)); 
T3.S2_mean.PM = nanmean(T3.S2(:,7)); 
T3.S3_mean.PM = nanmean(T3.S3(:,7));

T4.S1_mean.PM = nanmean(T4.S1(:,7)); 
T4.S2_mean.PM = nanmean(T4.S2(:,7)); 
T4.S3_mean.PM = nanmean(T4.S3(:,7));
T4.S4_mean.PM = nanmean(T4.S4(:,7));

T5.S1_mean.PM = nanmean(T5.S1(:,7)); 
T5.S2_mean.PM = nanmean(T5.S2(:,7)); 
T5.S3_mean.PM = nanmean(T5.S3(:,7));
T5.S4_mean.PM = nanmean(T5.S4(:,7));
T5.S5_mean.PM = nanmean(T5.S5(:,7));

T6.S1_mean.PM = nanmean(T6.S1(:,7)); 
T6.S2_mean.PM = nanmean(T6.S2(:,7)); 
T6.S3_mean.PM = nanmean(T6.S3(:,7));
T6.S4_mean.PM = nanmean(T6.S4(:,7));
T6.S5_mean.PM = nanmean(T6.S5(:,7));
T6.S6_mean.PM = nanmean(T6.S6(:,7));

T7.S1_mean.PM = T7.S1(:,7); 
T7.S2_mean.PM = T7.S2(:,7);  
T7.S3_mean.PM = T7.S3(:,7); 
T7.S4_mean.PM = T7.S4(:,7); 
T7.S5_mean.PM = T7.S5(:,7); 
T7.S6_mean.PM = T7.S6(:,7); 
T7.S7_mean.PM = T7.S7(:,7); 

%% plot evolution over time

% position matching
figure;
hold on 
for i = 1:length(T1.S1(:,7))
    scatter(1,T1.S1(i,7),'filled','r');
end
for i = 1:length(T2.S1(:,7))
    p2 = plot([1 2], [T2.S1(i,7) T2.S2(i,7)],'-o'); 
    p2.Color = 'b'; 
    p2.MarkerFaceColor = 'b'; 
end
for i = 1:length(T3.S1(:,7))
    p3 = plot([1 2 3], [T3.S1(i,7) T3.S2(i,7) T3.S3(i,7)],'-o'); 
    p3.Color = 'k'; 
    p3.MarkerFaceColor = 'k'; 
end
for i = 1:length(T4.S1(:,7))
    p4 = plot([1 2 3 4], [T4.S1(i,7) T4.S2(i,7) T4.S3(i,7) T4.S4(i,7)],'-o'); 
    p4.Color = [0.8500, 0.3250, 0.0980]; 
    p4.MarkerFaceColor = [0.8500, 0.3250, 0.0980]; 
end
for i = 1:length(T5.S1(:,7))
    p5 = plot([1 2 3 4 5], [T5.S1(i,7) T5.S2(i,7) T5.S3(i,7) T5.S4(i,7) T5.S5(i,7)],'-o'); 
    p5.Color = [0, 0.5, 0];  
    p5.MarkerFaceColor = [0, 0.5, 0]; 
end
for i = 1:length(T6.S1(:,7))
    p6 = plot([1 2 3 4 5 6], [T6.S1(i,7) T6.S2(i,7) T6.S3(i,7) T6.S4(i,7) T6.S5(i,7) T6.S6(i,7)],'-o'); 
    p6.Color = [0.4940, 0.1840, 0.5560]	;  
    p6.MarkerFaceColor = [0.4940, 0.1840, 0.5560]; 
end
for i = 1:length(T7.S1(:,7))
    p7 = plot([1 2 3 4 5 6 7], [T7.S1(i,7) T7.S2(i,7) T7.S3(i,7) T7.S4(i,7) T7.S5(i,7) T7.S6(i,7) T7.S7(i,7)],'-o'); 
    p7.Color = [0.75, 0, 0.75]	;  
    p7.MarkerFaceColor = [0.75, 0, 0.75]; 
end
xlim([0.5 7.5]) 


%% plot mean

figure;
hold on 
p1 = scatter(1,T1.S1_mean.PM,'filled','r');
p2 = plot([1 2], [T2.S1_mean.PM T2.S2_mean.PM],'-o'); 
p2.Color = 'b'; 
p2.MarkerFaceColor = 'b'; 
hold on 
p3 = plot([1 2 3], [T3.S1_mean.PM T3.S2_mean.PM T3.S3_mean.PM],'-o'); 
p3.Color = 'k'; 
p3.MarkerFaceColor = 'k'; 
hold on 
p4 = plot([1 2 3 4], [T4.S1_mean.PM T4.S2_mean.PM T4.S3_mean.PM T4.S4_mean.PM],'-o'); 
p4.Color = [0.8500, 0.3250, 0.0980];  
p4.MarkerFaceColor = [0.8500, 0.3250, 0.0980]; 
hold on 
p5 = plot([1 2 3 4 5], [T5.S1_mean.PM T5.S2_mean.PM T5.S3_mean.PM T5.S4_mean.PM T5.S5_mean.PM],'-o'); 
p5.Color = [0, 0.5, 0];    
p5.MarkerFaceColor = [0, 0.5, 0];  
hold on 
p6 = plot([1 2 3 4 5 6], [T6.S1_mean.PM T6.S2_mean.PM T6.S3_mean.PM T6.S4_mean.PM T6.S5_mean.PM T6.S6_mean.PM],'-o'); 
p6.Color = [0.4940, 0.1840, 0.5560];     
p6.MarkerFaceColor = [0.4940, 0.1840, 0.5560]; 
hold on 
p7 = plot([1 2 3 4 5 6 7], [T7.S1_mean.PM T7.S2_mean.PM T7.S3_mean.PM T7.S4_mean.PM T7.S5_mean.PM T7.S6_mean.PM T7.S7_mean.PM],'-o'); 
p7.Color = [0.75, 0, 0.75];       
p7.MarkerFaceColor = [0.75, 0, 0.75]; 
legend([p1 p2 p3 p4 p5 p6 p7], {'N=3','N=7','N=18','N=12','N=5','N=2','N=1'},'Location','best'); 
xlim([0.5 7.5]) 
ylim([0 22])

%% plot mean

figure;
hold on 
for i = 1:length(T1.S1(:,7))
    p1 = scatter(1,T1.S1(i,7),'filled');
    p1.MarkerFaceColor = [0.7,0.7,0.7];
    p1.MarkerEdgeColor = [0.7,0.7,0.7];
end
for i = 1:length(T2.S1(:,7))
    p2 = plot([1 2], [T2.S1(i,7) T2.S2(i,7)],'-o','Linewidth',0.5); 
    p2.Color = [0.7,0.7,0.7];
    p2.MarkerFaceColor = [0.7,0.7,0.7]; 
end
for i = 1:length(T3.S1(:,7))
    p3 = plot([1 2 3], [T3.S1(i,7) T3.S2(i,7) T3.S3(i,7)],'-o','Linewidth',0.5); 
    p3.Color = [0.7,0.7,0.7]; 
    p3.MarkerFaceColor = [0.7,0.7,0.7];
end
for i = 1:length(T4.S1(:,7))
    p4 = plot([1 2 3 4], [T4.S1(i,7) T4.S2(i,7) T4.S3(i,7) T4.S4(i,7)],'-o','Linewidth',0.5); 
    p4.Color = [0.7,0.7,0.7]; 
    p4.MarkerFaceColor = [0.7,0.7,0.7]; 
end
for i = 1:length(T5.S1(:,7))
    p5 = plot([1 2 3 4 5], [T5.S1(i,7) T5.S2(i,7) T5.S3(i,7) T5.S4(i,7) T5.S5(i,7)],'-o','Linewidth',0.5); 
    p5.Color = [0.7,0.7,0.7]; 
    p5.MarkerFaceColor = [0.7,0.7,0.7];
end
for i = 1:length(T6.S1(:,7))
    p6 = plot([1 2 3 4 5 6], [T6.S1(i,7) T6.S2(i,7) T6.S3(i,7) T6.S4(i,7) T6.S5(i,7) T6.S6(i,7)],'-o','Linewidth',0.5); 
    p6.Color = [0.7,0.7,0.7];
    p6.MarkerFaceColor = [0.7,0.7,0.7];
end
for i = 1:length(T7.S1(:,7))
    p7 = plot([1 2 3 4 5 6 7], [T7.S1(i,7) T7.S2(i,7) T7.S3(i,7) T7.S4(i,7) T7.S5(i,7) T7.S6(i,7) T7.S7(i,7)],'-o','Linewidth',0.5); 
    p7.Color = [0.7,0.7,0.7]; 
    p7.MarkerFaceColor = [0.7,0.7,0.7];
end

hold on 
p1 = scatter(1,T1.S1_mean.PM,'filled','r');
p2 = plot([1 2], [T2.S1_mean.PM T2.S2_mean.PM],'-o','Linewidth',2); 
p2.Color = 'b'; 
p2.MarkerFaceColor = 'b'; 
hold on 
p3 = plot([1 2 3], [T3.S1_mean.PM T3.S2_mean.PM T3.S3_mean.PM],'-o','Linewidth',2); 
p3.Color = 'k'; 
p3.MarkerFaceColor = 'k'; 
hold on 
p4 = plot([1 2 3 4], [T4.S1_mean.PM T4.S2_mean.PM T4.S3_mean.PM T4.S4_mean.PM],'-o','Linewidth',2); 
p4.Color = [0.8500, 0.3250, 0.0980];  
p4.MarkerFaceColor = [0.8500, 0.3250, 0.0980]; 
hold on 
p5 = plot([1 2 3 4 5], [T5.S1_mean.PM T5.S2_mean.PM T5.S3_mean.PM T5.S4_mean.PM T5.S5_mean.PM],'-o','Linewidth',2); 
p5.Color = [0, 0.5, 0];    
p5.MarkerFaceColor = [0, 0.5, 0];  
hold on 
p6 = plot([1 2 3 4 5 6], [T6.S1_mean.PM T6.S2_mean.PM T6.S3_mean.PM T6.S4_mean.PM T6.S5_mean.PM T6.S6_mean.PM],'-o','Linewidth',2); 
p6.Color = [0.4940, 0.1840, 0.5560];     
p6.MarkerFaceColor = [0.4940, 0.1840, 0.5560]; 
hold on 
p7 = plot([1 2 3 4 5 6 7], [T7.S1_mean.PM T7.S2_mean.PM T7.S3_mean.PM T7.S4_mean.PM T7.S5_mean.PM T7.S6_mean.PM T7.S7_mean.PM],'-o','Linewidth',2); 
p7.Color = [0.75, 0, 0.75];       
p7.MarkerFaceColor = [0.75, 0, 0.75]; 
legend([p1 p2 p3 p4 p5 p6 p7], {'N=3','N=7','N=18','N=12','N=5','N=2','N=1'},'Location','northeast'); 
xlim([0.5 7.5]) 
ylim([0 35])


