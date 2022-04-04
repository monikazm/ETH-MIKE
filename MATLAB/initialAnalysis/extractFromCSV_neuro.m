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
% 70 SEP N20 amplitude left
% 71 SEP N20 latency left 
% 73 SEP N20 ampl right
% 74 SEP N20 lat right
% 79 MEP N20 amp left
% 80 MEP N20 lat left
% 84 MEP N20 amp right
% 85 MEP N20 lat right
%A = table2array(T(:,[3 5 70])); 

% convert a string into a double array 
% take both left and right hand: MEP ampl
A = table2array(T(:,[80 85])); 
A2 = str2double(strrep(A,',','.'));

A3 = table2array(T(:,[5 3 2])); 
A3(:,[4 5]) = A2; 

%% clean-up the table 

% remove subjects that don't have redcap yet

n = 1; 
withREDCap = []; 
for i = 1:1:length(A3(:,1))
    if isnan(A3(i,1))
        
    else
        withREDCap(n,:) = A3(i,:); 
        n=n+1; 
    end

end

% withREDCap2(:,1) = withREDCap(:,2); 
% withREDCap2(:,2) = withREDCap(:,1); 
% withREDCap2(:,3) = withREDCap(:,3); 

C = sortrows(withREDCap,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: max force flexion 

% remove those rows where there is only one data point
n = 1; 
remove = []; 
temp = []; 
for i=1:max(C(:,1))
    temp = find(C(:,1)==i); 
    if length(temp) == 1
        remove(n) = temp; 
        n = n+1; 
    end
end
C(remove,:) = []; 

% remove all rows for which clinical data doesn't exist 
n = 1; 
t = []; 
for i = 1:length(C(:,4))
    if isnan(C(i,4)) && isnan(C(i,5))
        t(n) = i; 
        n = n+1; 
    end
end
C(t,:) = []; 

% change all 3rd into second session 
temp2 = find(C(:,2) == 3); 
C(temp2,2) = 2; 

%% plot longitudinal data - individual subjects 
% N = 11 

figure; 
temp = []; 
for i=unique(C(:,1))'
    temp = find(C(:,1)==i); 
    txt = ['Nr = ',num2str(i)];

    if C(temp,3) == 1
        F = plot(C(temp,2),C(temp,4),'o-','DisplayName',txt); 
        F.MarkerFaceColor = colors{i};
        F.Color = colors{i}; 
        hold on 
        F = plot(C(temp,2)+2,C(temp,5),'o-','DisplayName',txt); 
        F.MarkerFaceColor = colors{i};
        F.Color = colors{i}; 
        hold on 
    else
        F = plot(C(temp,2),C(temp,5),'o-','DisplayName',txt); 
        F.MarkerFaceColor = colors{i};
        F.Color = colors{i}; 
        hold on 
        F = plot(C(temp,2)+2,C(temp,4),'o-','DisplayName',txt); 
        F.MarkerFaceColor = colors{i};
        F.Color = colors{i}; 
        hold on        
    end
end
%legend show
set(gca,'FontSize',12)
xlim([0.5 4.5]) 
xticks([1 2 3 4]) 
xticklabels({'A:S1','A:S2','LA:S1','LA:S2'})
xlabel('Neurophysiology Session Nr.') 
ylabel('MEP N20 Amplitude') 
%print('Plots/LongitudinalPlots/210119_Indiv_MaxForce','-dpng')

%% group trends - mean for S1,S2,S3
% n = 1; 
% m = 1; 
% k = 1; 
% for i = 1:length(C(:,1))
%     if C(i,2) == 1
%         S1(n,:) = C(i,:);
%         n = n+1; 
%     elseif C(i,2) == 2
%         S2(m,:) = C(i,:);
%         m = m+1; 
%     end
% end
% 
% S1_mean = mean(S1(:,3)); 
% S2_mean = mean(S2(:,3)); 
% 
% %% plot subjects plus mean
% 
% figure; 
% for i=unique(C(:,1))'
%         temp = find(C(:,1)==i); 
%         F = plot(C(temp,2),C(temp,3),'o-'); 
%         F.MarkerFaceColor = [0.6 0.6 0.6];
%     	F.Color = [0.6 0.6 0.6]; 
%         hold on 
% end 
% M = plot(1:2,[S1_mean S2_mean],'d-'); 
% M.MarkerFaceColor = 'k';
% M.Color = 'k'; 
% set(gca,'FontSize',12)
% xlim([0.5 2.5]) 
% xticks([1 2]) 
% xlabel('Clinical Session Nr.') 
% ylabel('Fugl-Meyer UL') 
% %print('Plots/LongitudinalPlots/210119_Sum_MaxForce','-dpng')
% 










