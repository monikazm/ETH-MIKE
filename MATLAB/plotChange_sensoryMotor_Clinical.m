%% Change in Sensory vs Motor %% 
% created: 18.05.2021

% divide by SRD 

clear 
close all
clc

%% read table %% 

T = readtable('data/20210517_DataImpaired.csv'); 

% 41 - FM
% 44 - FM hand
% 46 - FM sensory 
% 47 - kUDT

A = table2array(T(:,[3 5 46 41])); 

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

% Remove NANs
C(sum(isnan(C), 2) == 2, :) = [];

% change 2nd into 3rd session
temp2 = find(C(:,2) == 2); 
C(temp2,2) = 3; 

% split
% split into PM1 and PM2
PM1 = C(find(C(:,2) == 1),:);
PM3 = C(find(C(:,2) == 3),:);

% merge into one 
Lia = double(ismember(PM1(:,1),PM3(:,1))); 
PM1(:,1) = Lia.*PM1(:,1); 
PM1(PM1(:,1)==0,:)= [];
PM1(:,2) = []; 
PM3(:,2) = []; 

% calculate the change
Delta(:,1) = PM3(:,1); 
Delta(:,2) = PM3(:,2)-PM1(:,2); % positive = improvement
Delta(:,3) = PM3(:,3)-PM1(:,3); % positive = improvement 


%% plot longitudinal data - individual subjects 

txt = string(Delta(:,1)'); 

figure;
m = scatter(Delta(:,2),Delta(:,3), 'filled');
%m.MarkerSize = 1; 
hold on
labelpoints(Delta(:,2),Delta(:,3), txt)
%textscatter(change_bySRD(:,2),change_bySRD(:,3), txt); 
%legend show
%set(gca,'FontSize',12)
%xlim([-10 15])
%ylim([-10 15])
xlabel('Change in sensory') 
ylabel('Change in motor') 
xlim([-3.5 6.5])
ylim([-0.5 18.5])
%yline(1,'k--')
%yline(-1,'k--')
%xline(1,'k--')
%xline(-1,'k--')
title('FMA Sensory vs FMA Motor')
% yline(0,'k-.')
% xline(0,'k-.')
print('Plots/ScatterPlots/210518_ChangeMotorSensory_FMA_MotorSensory','-dpng')




