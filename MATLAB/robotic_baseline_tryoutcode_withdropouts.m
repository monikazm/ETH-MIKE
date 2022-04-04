%% Plot robotic data (especially Positon Matching) at baseline (less and more affected sides) %%
% created: 04.05.2021

% plot robotic data at baseline compare affected and less affected sides,
% see how many patients impaired at baseline (as compared to the control
% threshold) 

% NOTE: would be interesting to also add the info on weeks since stroke
% into the analysis pipeline 

clear 
clc
close all

colors = {  [0.8500, 0.3250, 0.0980]
            [1, 0, 0]    
          	[0.9290, 0.6940, 0.1250]	          	
          	[0.4940, 0.1840, 0.5560]	          	
          	[0.4660, 0.6740, 0.1880]	          	
          	[0.3010, 0.7450, 0.9330]	          	 
          	[0.6350, 0.0780, 0.1840]	
            [0.25, 0.25, 0.25]
            [0, 0.5, 0]
            [0, 0.4470, 0.7410] 
            [0.75, 0, 0.75]
            [0.75, 0.75, 0]
            [0, 0, 1]
            [0, 1, 0]
            [0.75, 0.75, 0.75]
            [0.8, 0.4, 0]
            [0.25, 0.75, 0.5]
            [1.0, 0.4, 0.6]
            [0.45, 0.65, 0.87]
            [0.7, 0.6, 0.5]
            [1, 0.6, 0.1]
            [0.65, 0.32, 0.12]
            [0, 0.4470, 0.7410]
            [0.8500, 0.3250, 0.0980]	
            [0.9290, 0.6940, 0.1250]	
            [0.4940, 0.1840, 0.5560]	
            [0.453, 0.587, 0.978]
            };

%% read from CSV

filename1 = 'data/20210517_DataImpaired.csv'; 
filename2 = 'data/20210517_DataNonImpaired.csv'; 
columnNrs = 122; % Position Matching
kUDT = 47; 

T1 = readtable(filename1); 
T2 = readtable(filename2); 
A = table2array(T1(:,[3 5 kUDT columnNrs]));
B = table2array(T2(:,[3 5 kUDT columnNrs]));

%% clean up the table - impaired 

% remove subjects that don't have redcap

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
% third column: what I want to plot as y-axis

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

% take only the first session (to plot baseline scores) 
Imp = C(find(C(:,2)==1),:); 
Imp(:,2) = []; 

%% clean up the table - non-impaired 

% remove subjects that don't have redcap
n = 1; 
withREDCap = []; 
for i = 1:1:length(B(:,1))
    if isnan(B(i,2))
        
    else
        withREDCap(n,:) = B(i,:); 
        n=n+1; 
    end

end

withREDCap2 = []; 
withREDCap2(:,1) = withREDCap(:,2); 
withREDCap2(:,2) = withREDCap(:,1); 
withREDCap2(:,3) = withREDCap(:,3); 
withREDCap2(:,4) = withREDCap(:,4); 

C = []; 
C = sortrows(withREDCap2,'ascend'); 

% take only the first session (to plot baseline scores) 
NonImp = C(find(C(:,2)==1),:); 
NonImp(:,2) = []; 
Lia = double(ismember(NonImp(:,1),Imp(:,1))); 
NonImp(:,1) = Lia.*NonImp(:,1); 
NonImp(NonImp(:,1)==0,:)= [];

%% Join imp and nonimp

Both = [Imp NonImp(:,3)]; 

%% Mark subjects that are impaired

Both(:,5) = Both(:,3)>10.63; 
filename = 'PMimpaired_source_170521.xlsx';
writematrix(Both,filename)

%% Plot scatter - with different subjects indicated in different colors

figure; 
for i=1:length(Both)
    txt = num2str(Both(i,1)); 
    P = plot([1 2], [Both(i,3) Both(i,4)],'o--','DisplayName',txt);
    P.MarkerSize = 6; 
    P.MarkerFaceColor = colors{i}; 
    P.MarkerEdgeColor = colors{i}; 
    P.Color = colors{i}; 
    hold on 
end
%legend show
xlim([0.5 2.5])
hold on 
yline(10.63) 
xticks([1,2]) 
xticklabels({'Affected' , 'Less affected'}); 
ylabel('Position Matching Absolute Error (deg)') 
print('Plots/BaselineComparison/robotic/210517_PM_Indiv','-dpng')

%% Plot scatter and mean across subjects

meanImp = mean(Both(:,3)); 
meanNonImp = mean(Both(:,4)); 

figure; 
for i=1:length(Both)
    txt = num2str(Both(i,1)); 
    P = plot([1 2], [Both(i,3) Both(i,4)],'o--','DisplayName',txt);
    P.MarkerSize = 6; 
    P.MarkerFaceColor = [0.5 0.5 0.5]; 
    P.MarkerEdgeColor = [0.5 0.5 0.5];
    P.Color = [0.5 0.5 0.5]; 
    hold on 
end
hold on 
M = plot([1 2], [meanImp meanNonImp],'d--');
M.MarkerSize = 8; 
M.MarkerFaceColor = 'r'; 
M.MarkerEdgeColor = 'r';
M.Color = 'r'; 
M.LineWidth = 2; 
%legend show
xlim([0.5 2.5])
hold on 
yline(10.63) 
xticks([1,2]) 
xticklabels({'Affected' , 'Less affected'}); 
ylabel('Position Matching Absolute Error (deg)') 
print('Plots/BaselineComparison/robotic/210517_PM_withMean','-dpng')


