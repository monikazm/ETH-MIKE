%% extract from CSV and plot longitudinal data %% 
% created: 19.08.2021

% FM Sensory longitudinal plot and ttest 

clear 
close all
clc

%% pre-processing

filename = 'data/20210811_DataImpaired.csv'; 
columnNrs = [41 44 46 47 48 50 61 49]; 
namesPlots = [{'FuglMeyer Motor'},{'Fugl-Meyer Hand'},{'FuglMeyer Sensory'},{'kUDT'},{'BoxBlock'},{'Barthel'},{'MoCA'}, {'BoxBlock non-imp'}]; 
% ROM ForceE ForceF PM MAPRS MAPRF MaxVelE MaxVelF
axisDir = [0 0 0 0 0 0 0]; 
C = extractLongitudinal_clinical(filename,columnNrs); 

%% split 

array = C; 
task = 2 + 8; 

    n = 1; 
    m = 1; 
    k = 1; 
    for i = 1:length(array(:,1))
        if array(i,2) == 1
                S1(n,:) = array(i,[1 task]);
                n = n+1; 
        elseif array(i,2) == 2
                S2(m,:) = array(i,[1 task]);
                m = m+1; 
        end
    end
    
% clean up and merge 
Lia = double(ismember(S1(:,1),S2(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];
 
S = [S1 S2(:,2)]; 

S(16,:) = []; 

%% mean across all

S1_mean = mean(S(:,2)); 
S1_std = std(S(:,2)); 

S2_mean = mean(S(:,3)); 
S2_std = std(S(:,3)); 

%% plot all points Sesh

figure; 
for i=1:length(S)
    p = plot(1:2, [S(i,2) S(i,3)],'-o','Linewidth',1);
    p.MarkerFaceColor = [0.7,0.7,0.7];
    p.Color = [0.7,0.7,0.7]; 
    hold on 
end
pM = plot(1:2,[S1_mean S2_mean],'d-', 'Linewidth',1);
pM.MarkerFaceColor = 'k';
pM.Color = 'k'; 
xlim([0.5 2.5]) 
xticks([1 2]) 
xticklabels({'Inclusion','Discharge'})
ylim([-5 75]) 
ylabel('Box&Block Test') 
print('Plots/LongitudinalPlots/robotic/210819_BBnonimp_InclDisch','-dpng')

%% t-test between the two groups

[h1,p1] = ttest(S(:,2), S(:,3)); 


 
