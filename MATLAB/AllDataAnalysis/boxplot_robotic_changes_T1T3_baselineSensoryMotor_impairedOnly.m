%% change motor / sensory - how do they relate?  %% 
% 3 groups
% created: 24.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20220127_BaselineImpairedOnly.csv'); 
A = table2array(T); 

%% boxplot - motor change 

nochangeM.val = [A(1:11,:);A(22,:)]; 
changeM.val = A(12:21,:); 

changeM.meanF = mean(changeM.val(:,8)); 
changeM.stdF = std(changeM.val(:,8)); 

changeM.meanPM = mean(changeM.val(:,7)); 
changeM.stdPM = std(changeM.val(:,7)); 

nochangeM.meanF = mean(nochangeM.val(:,8)); 
nochangeM.stdF = std(nochangeM.val(:,8)); 

nochangeM.meanPM = mean(nochangeM.val(:,7)); 
nochangeM.stdPM = std(nochangeM.val(:,7)); 


% baseline PM
g1 = repmat({'Change (N=10)'},length(changeM.val(:,1)),1);
g2 = repmat({'No change (N=12)'},length(nochangeM.val(:,1)),1);
g = [g1;g2]; 

figure; 
hold on
yline(10.63,'k--');
boxplot([changeM.val(:,7); nochangeM.val(:,7)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(changeM.val(:,7))
    scatter(1,changeM.val(i,7),'filled','k'); 
end
for i=1:length(nochangeM.val(:,7))
    scatter(2,nochangeM.val(i,7),'filled','k');
end
set(gca,'YDir','reverse')
xlabel('Groups') 
ylabel('Position Matching Absolute Error @ T1') 
print('plots/BoxPlots/220127_MotorChangeGroups_PM_v2','-dpng')

% baseline Force
g1 = repmat({'Change (N=10)'},length(changeM.val(:,1)),1);
g2 = repmat({'No change (N=12)'},length(nochangeM.val(:,1)),1);
g = [g1;g2]; 

figure; 
hold on
yline(10.93,'k--');
boxplot([changeM.val(:,8); nochangeM.val(:,8)],g) 
b = findobj(gca,'tag','Median');
set(b,{'linew'},{2})
colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
end
hold on 
for i=1:length(changeM.val(:,8))
    scatter(1,changeM.val(i,8),'filled','k'); 
end
for i=1:length(nochangeM.val(:,8))
    scatter(2,nochangeM.val(i,8),'filled','k');
end
xlabel('Groups') 
ylabel('Maximum Force Flexion @ T1') 
print('plots/BoxPlots/220127_MotorChangeGroups_Force_v2','-dpng')

% % baseline Velocity 
% g1 = repmat({'Change (N=25)'},length(changeM.S1(:,1)),1);
% g2 = repmat({'No change (N=20)'},length(nochangeM.S1(:,1)),1);
% g = [g1;g2]; 
% 
% figure; 
% boxplot([changeM.S1(:,10); nochangeM.S1(:,10)],g) 
% b = findobj(gca,'tag','Median');
% set(b,{'linew'},{2})
% colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
% h = findobj(gca,'Tag','Box');
% for j=1:length(h)
%     patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
% end
% hold on 
% for i=1:length(changeM.S1(:,10))
%     scatter(1,changeM.S1(i,10),'filled','k'); 
% end
% for i=1:length(nochangeM.S1(:,10))
%     scatter(2,nochangeM.S1(i,10),'filled','k');
% end
% xlabel('Groups') 
% ylabel('Maximum Velocity Extension @ T1') 
% print('plots/BoxPlots/220127_MotorChangeGroups_Vel','-dpng')
% 
% statistical difference 
p_groupsM_PM = kruskalwallis([changeM.val(:,7); nochangeM.val(:,7)],g); 
p_groupsM_F = kruskalwallis([changeM.val(:,8); nochangeM.val(:,8)],g); 
p_groupsM_V = kruskalwallis([changeM.val(:,10); nochangeM.val(:,10)],g); 
p_groupsM_ROM = kruskalwallis([changeM.val(:,9); nochangeM.val(:,9)],g); 
% 
% 
% %% boxplot - sensory change 
% 
% changeS.S1 = [both.S1; sensory.S1]; 
% nochangeS.S1 = [neither.S1; motor.S1; good.S1];
% 
% changeS.meanF = mean(changeS.S1(:,8)); 
% changeS.stdF = std(changeS.S1(:,8)); 
% 
% changeS.meanPM = mean(changeS.S1(:,7)); 
% changeS.stdPM = std(changeS.S1(:,7)); 
% 
% nochangeS.meanF = mean(nochangeS.S1(:,8)); 
% nochangeS.stdF = std(nochangeS.S1(:,8)); 
% 
% nochangeS.meanPM = mean(nochangeS.S1(:,7)); 
% nochangeS.stdPM = std(nochangeS.S1(:,7)); 
% 
% 
% % sensory function at baseline
% g1 = repmat({'Change (N=10)'},length(changeS.S1(:,1)),1);
% g2 = repmat({'No change (N=35)'},length(nochangeS.S1(:,1)),1);
% g = [g1;g2]; 
% 
% figure; 
% boxplot([changeS.S1(:,7); nochangeS.S1(:,7)],g) 
% b = findobj(gca,'tag','Median');
% set(b,{'linew'},{2})
% colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
% h = findobj(gca,'Tag','Box');
% for j=1:length(h)
%     patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
% end
% hold on 
% for i=1:length(changeS.S1(:,7))
%     scatter(1,changeS.S1(i,7),'filled','k'); 
% end
% for i=1:length(nochangeS.S1(:,7))
%     scatter(2,nochangeS.S1(i,7),'filled','k');
% end
% hold on
% yline(10.63,'k--');
% set(gca,'YDir','reverse')
% xlabel('Groups') 
% ylabel('Position Matching Absolute Error @ T1') 
% print('plots/BoxPlots/211206_SensoryChangeGroups_PM','-dpng')
% 
% % motor function at baseline
% figure; 
% hold on
% yline(10.93,'k--');
% boxplot([changeS.S1(:,8); nochangeS.S1(:,8)],g) 
% b = findobj(gca,'tag','Median');
% set(b,{'linew'},{2})
% colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
% h = findobj(gca,'Tag','Box');
% for j=1:length(h)
%     patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
% end
% hold on 
% for i=1:length(changeS.S1(:,8))
%     scatter(1,changeS.S1(i,8),'filled','k'); 
% end
% for i=1:length(nochangeS.S1(:,8))
%     scatter(2,nochangeS.S1(i,8),'filled','k');
% end
% xlabel('Groups') 
% ylabel('Maximum Force Flexion @ T1') 
% print('plots/BoxPlots/211206_SensoryChangeGroups_F','-dpng')
% 
% % motor function at baseline
% figure; 
% boxplot([changeS.S1(:,10); nochangeS.S1(:,10)],g) 
% b = findobj(gca,'tag','Median');
% set(b,{'linew'},{2})
% colors = {[0.85, 0.85, 0.85], [0.85, 0.85, 0.85]};  
% h = findobj(gca,'Tag','Box');
% for j=1:length(h)
%     patch(get(h(j),'XData'),get(h(j),'YData'),colors{:,j},'FaceAlpha',0.5);
% end
% hold on 
% for i=1:length(changeS.S1(:,10))
%     scatter(1,changeS.S1(i,10),'filled','k'); 
% end
% for i=1:length(nochangeS.S1(:,10))
%     scatter(2,nochangeS.S1(i,10),'filled','k');
% end
% xlabel('Groups') 
% ylabel('Maximum Velocity Extension @ T1') 
% print('plots/BoxPlots/211206_SensoryChangeGroups_V','-dpng')
% 
% 
% % statistical difference  
% p_groupsS_PM = kruskalwallis([changeS.S1(:,7); nochangeS.S1(:,7)],g); 
% p_groupsS_F = kruskalwallis([changeS.S1(:,8); nochangeS.S1(:,8)],g); 
% p_groupsS_ROM = kruskalwallis([changeS.S1(:,9); nochangeS.S1(:,9)],g); 
% p_groupsS_V = kruskalwallis([changeS.S1(:,10); nochangeS.S1(:,10)],g); 
% 
