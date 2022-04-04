%% report all values of robotic tests %% 
% also calculate mean & std for each metric 
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

%% Divide into S1 S2 and S3

n = 1;  
k = 1; 
m = 1; 
q = 1; 
p = 1; 
r = 1; 
u = 1; 
for i = 1:length(C(:,1))
        if C(i,2) == 1
            S1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 2
            S2(k,:) = C(i,:);
            k = k+1; 
        elseif C(i,2) == 3
            S3(m,:) = C(i,:);
            m = m+1; 
        elseif C(i,2) == 4
            S4(q,:) = C(i,:);
            q = q+1; 
        elseif C(i,2) == 5
            S5(p,:) = C(i,:);
            p = p+1; 
        elseif C(i,2) == 6
            S6(r,:) = C(i,:);
            r = r+1; 
        elseif C(i,2) == 7
            S7(u,:) = C(i,:);
            u = u+1; 
        end
end

% clean up and merge 
% Lia = double(ismember(S1(:,1),S3(:,1))); 
% S1(:,1) = Lia.*S1(:,1); 
% S1(S1(:,1)==0,:)= [];
%   
% Lia = double(ismember(S2(:,1),S3(:,1))); 
% S2(:,1) = Lia.*S2(:,1); 
% S2(S2(:,1)==0,:)= [];

S3(1,7) = S2(1,7); 
S2(13,7) = 20;  

%% Save for reference of non-impaired side calculation

%save('SubjectsT1T3Analysis.mat','S1')

%% Mean and std for all time points

% position matching 
mean_PM.t1(1)  = nanmean(S1(:,7));
mean_PM.t2(1)  = nanmean(S2(:,7));
mean_PM.t3(1)  = nanmean(S3(:,7));
mean_PM.t4(1)  = nanmean(S4(:,7));
mean_PM.t5(1)  = nanmean(S5(:,7));
mean_PM.t6(1)  = nanmean(S6(:,7));
mean_PM.t7(1)  = nanmean(S7(:,7));
mean_PM.t8(1)  = mean_PM.t7; 
mean_PM.t1(2)  = nanstd(S1(:,7));
mean_PM.t2(2)  = nanstd(S2(:,7));
mean_PM.t3(2)  = nanstd(S3(:,7));
mean_PM.t4(2)  = nanstd(S4(:,7));
mean_PM.t5(2)  = nanstd(S5(:,7));
mean_PM.t6(2)  = nanstd(S6(:,7));
mean_PM.t7(2)  = nanstd(S7(:,7));
mean_PM.t8(2)  = mean_PM.t7(2); 

% active range of motion 
mean_AROM.t1(1) = nanmean(S1(:,3)); 
mean_AROM.t2(1) = nanmean(S2(:,3));
mean_AROM.t3(1) = nanmean(S3(:,3));
mean_AROM.t4(1) = nanmean(S4(:,3));
mean_AROM.t5(1) = nanmean(S5(:,3));
mean_AROM.t6(1) = nanmean(S6(:,3));
mean_AROM.t7(1) = nanmean(S7(:,3));
mean_AROM.t8(1) = mean_AROM.t7(1); 
mean_AROM.t1(2) = nanstd(S1(:,3)); 
mean_AROM.t2(2) = nanstd(S2(:,3)); 
mean_AROM.t3(2) = nanstd(S3(:,3)); 
mean_AROM.t4(2) = nanstd(S4(:,3)); 
mean_AROM.t5(2) = nanstd(S5(:,3)); 
mean_AROM.t6(2) = nanstd(S6(:,3)); 
mean_AROM.t7(2) = nanstd(S7(:,3)); 
mean_AROM.t8(2) = mean_AROM.t7(2); 

% force 
mean_Force.t1(1) = nanmean(S1(:,4)); 
mean_Force.t2(1) = nanmean(S2(:,4)); 
mean_Force.t3(1) = nanmean(S3(:,4)); 
mean_Force.t4(1) = nanmean(S4(:,4));  
mean_Force.t5(1) = nanmean(S5(:,4));  
mean_Force.t6(1) = nanmean(S6(:,4));  
mean_Force.t7(1) = nanmean(S7(:,4));  
mean_Force.t8(1) = mean_Force.t7(1); 
mean_Force.t1(2) = nanstd(S1(:,4)); 
mean_Force.t2(2) = nanstd(S2(:,4)); 
mean_Force.t3(2) = nanstd(S3(:,4)); 
mean_Force.t4(2) = nanstd(S4(:,4)); 
mean_Force.t5(2) = nanstd(S5(:,4)); 
mean_Force.t6(2) = nanstd(S6(:,4)); 
mean_Force.t7(2) = nanstd(S7(:,4)); 
mean_Force.t8(2) = mean_Force.t7(2);  

% maximum velocity extension
mean_Vel.t1(1) = nanmean(S1(:,5)); 
mean_Vel.t2(1) = nanmean(S2(:,5));
mean_Vel.t3(1) = nanmean(S3(:,5)); 
mean_Vel.t4(1) = nanmean(S4(:,5));
mean_Vel.t5(1) = nanmean(S5(:,5));
mean_Vel.t6(1) = nanmean(S6(:,5));
mean_Vel.t7(1) = nanmean(S7(:,5));
mean_Vel.t8(1) = mean_Vel.t7(1); 
mean_Vel.t1(2) = nanstd(S1(:,5)); 
mean_Vel.t2(2) = nanstd(S2(:,5)); 
mean_Vel.t3(2) = nanstd(S3(:,5)); 
mean_Vel.t4(2) = nanstd(S4(:,5)); 
mean_Vel.t5(2) = nanstd(S5(:,5)); 
mean_Vel.t6(2) = nanstd(S6(:,5)); 
mean_Vel.t7(2) = nanstd(S7(:,5)); 
mean_Vel.t8(2) = mean_Vel.t7(2); 

% time since stroke
mean_Time.t1(1) = nanmean(S1(:,10)); 
mean_Time.t2(1) = nanmean(S2(:,10));
mean_Time.t3(1) = nanmean(S3(:,10));
mean_Time.t4(1) = nanmean(S4(:,10));
mean_Time.t5(1) = nanmean(S5(:,10));
mean_Time.t6(1) = nanmean(S6(:,10));
mean_Time.t7(1) = nanmean(S7(:,10));
mean_Time.t8(1) = mean_Time.t7(1);
mean_Time.t1(2) = nanstd(S1(:,10)); 
mean_Time.t2(2) = nanstd(S2(:,10)); 
mean_Time.t3(2) = nanstd(S3(:,10)); 
mean_Time.t4(2) = nanstd(S4(:,10)); 
mean_Time.t5(2) = nanstd(S5(:,10)); 
mean_Time.t6(2) = nanstd(S6(:,10)); 
mean_Time.t7(2) = nanstd(S7(:,10)); 
mean_Time.t8(2) = mean_Time.t7(2); 


% kUDT 
mean_kUDT.t1(1) = nanmean(S1(:,8)); 
mean_kUDT.t2(1) = nanmean(S2(:,8));
mean_kUDT.t3(1) = nanmean(S3(:,8));
mean_kUDT.t1(2) = nanstd(S1(:,8)); 
mean_kUDT.t2(2) = nanstd(S2(:,8));
mean_kUDT.t3(2) = nanstd(S3(:,8));

% FMA 
mean_FMA.t1(1) = nanmean(S1(:,9)); 
mean_FMA.t2(1) = nanmean(S2(:,9));
mean_FMA.t3(1) = nanmean(S3(:,9));
mean_FMA.t1(2) = nanstd(S1(:,9)); 
mean_FMA.t2(2) = nanstd(S2(:,9));
mean_FMA.t3(2) = nanstd(S3(:,9));














