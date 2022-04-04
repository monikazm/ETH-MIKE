%% association model between motor and sensory scores %% 
% created: 20.08.2021
% metrics to start with: PM and AROM 

clear 
close all
clc

%% read table

T = readtable('data/20210811_DataImpaired.csv'); 

% 122 - PM AE 
% 114 - max force flex
% 92 - AROM
% 160 - max vel ext
% 127 - smoothness MAPR

A = table2array(T(:,[3 5 92 114 160 127 122])); 

%% time since stroke

timeRoboticTest = table2cell(T(:,25)); 
timeStroke = table2cell(T(:,18)); 
timeSinceStroke = [];
for i=1:length(timeStroke)
    timeSinceStroke(i,:) = datenum(timeRoboticTest{i,1}) - datenum(timeStroke{i,1}); 
end
A(:,8) = timeSinceStroke; 

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

%% Divide into S1 S2 and S3

n = 1;  
k = 1; 
m = 1; 
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
        end
end

% clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];
  
Lia = double(ismember(S2(:,1),S3(:,1))); 
S2(:,1) = Lia.*S2(:,1); 
S2(S2(:,1)==0,:)= [];

S1(1,:) = []; 
S2(1,:) = []; 
S3(1,:) = []; 
S2(19,4) = 20; 

%% Correlations

%% AROM vs PM

txt1 = string(S1(:,1)');

[R.AROMPMS1,PVAL.AROMPMS1] = corr(S1(:,3),S1(:,7),'Type','Spearman');
[R.AROMPMS2,PVAL.AROMPMS2] = corr(S2(:,3),S2(:,7),'Type','Spearman');
[R.AROMPMS3,PVAL.AROMPMS3] = corr(S3(:,3),S3(:,7),'Type','Spearman');

[R.AROMPMDelta,PVAL.AROMPMDelta] = corr(S3(:,3)-S1(:,3),S1(:,7)-S3(:,7),'Type','Spearman');
[R.AROMPMDelta2,PVAL.AROMPMDelta2] = corr((S3(:,3)-S1(:,3))./S1(:,3),(S1(:,7)-S3(:,7))./S1(:,7),'Type','Spearman');
[R.AROMPMDelta3,PVAL.AROMPMDelta3] = corr(S3(:,3)./(90-S1(:,3)),S1(:,7)./S3(:,7),'Type','Spearman');

figure;
scatter(S1(:,7)./S3(:,7), S3(:,3)./(90-S1(:,3)), 'filled'); % x-sensory, y-motor
hold on
labelpoints(S1(:,7)./S3(:,7), S3(:,3)./(90-S1(:,3)), txt1); 
xlabel('Recovery Position Matching') 
ylabel('Recovery Active Range of Motion') 
print('Plots/ScatterPlots/210820_recovery_AROMPM','-dpng')


%% ForceFlex vs PM

[R.FPMS1,PVAL.FPMS1] = corr(S1(:,4),S1(:,7),'Type','Spearman');
[R.FPMS2,PVAL.FPMS2] = corr(S2(:,4),S2(:,7),'Type','Spearman');
[R.FPMS3,PVAL.FPMS3] = corr(S3(:,4),S3(:,7),'Type','Spearman');

[R.FPMDelta,PVAL.FPMDelta] = corr(S3(:,4)-S1(:,4),S1(:,7)-S3(:,7),'Type','Spearman');
[R.FPMDelta2,PVAL.FPMDelta2] = corr((S3(:,4)-S1(:,4))./S1(:,4),(S1(:,7)-S3(:,7))./S1(:,7),'Type','Spearman');

S1(23,:) = []; 
S3(23,:) = [];  
txt2 = string(S1(:,1)');


[R.FPMDelta3,PVAL.FPMDelta3] = corr(S3(:,4)./(60-S1(:,4)),S1(:,7)./S3(:,7),'Type','Spearman');

figure;
scatter(S1(:,7)./S3(:,7), S3(:,4)./(60-S1(:,4)), 'filled'); % x-sensory, y-motor
hold on
labelpoints(S1(:,7)./S3(:,7), S3(:,4)./(60-S1(:,4)), txt2); 
xlabel('Recovery Position Matching') 
ylabel('Recovery Maximum Force Flexion') 
print('Plots/ScatterPlots/210820_recovery_ForcePM','-dpng')

%% MaxVel vs PM

[R.VPMS1,PVAL.VPMS1] = corr(S1(:,5),S1(:,7),'Type','Spearman');
[R.VPMS2,PVAL.VPMS2] = corr(S2(:,5),S2(:,7),'Type','Spearman');
[R.VPMS3,PVAL.VPMS3] = corr(S3(:,5),S3(:,7),'Type','Spearman');

[R.VPMDelta,PVAL.VPMDelta] = corr(S3(:,5)-S1(:,5),S1(:,7)-S3(:,7),'Type','Spearman');
[R.VPMDelta2,PVAL.VPMDelta2] = corr((S3(:,5)-S1(:,5))./S1(:,5),(S1(:,7)-S3(:,7))./S1(:,7),'Type','Spearman');
[R.VPMDelta3,PVAL.VPMDelta3] = corr(S3(:,5)./(600-S1(:,5)),S1(:,7)./S3(:,7),'Type','Spearman');

figure;
scatter(S1(:,7)./S3(:,7), S3(:,5)./(600-S1(:,5)), 'filled'); % x-sensory, y-motor
hold on
labelpoints(S1(:,7)./S3(:,7), S3(:,5)./(600-S1(:,5)), txt2); 
xlabel('Recovery Position Matching') 
ylabel('Recovery Maximum Velocity Extension') 
print('Plots/ScatterPlots/210820_recovery_VelExtPM','-dpng')




