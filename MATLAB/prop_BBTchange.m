%% Plot proprioception (PM) at baseline vs change in BBT %% 
% created: 04.05.2021

% H3: sensorimotor recovery & proprioception 

clear 
clc
close all

% 41 - FM
% 44 - FM hand
% 46 - FM sensory 
% 47 - kUDT

%% read from CSV

filename1 = 'data/20210517_DataImpaired.csv'; 
PM = 122; % Position Matching
BBT = 48; % Box&Block Test
FMHand = 44; % Fugl-Meyer Hand

T1 = readtable(filename1); 
A = table2array(T1(:,[3 5 PM]));
B = table2array(T1(:,[3 5 BBT]));
D = table2array(T1(:,[3 5 FMHand]));

%% Position matching at baseline 

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

C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: what I want to plot as y-axis

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

% take only the first session (to plot baseline scores) 
PMImp = C(find(C(:,2)==1),:); 
PMImp(:,2) = []; 

%% Change in BBT

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

withREDCap2(:,1) = withREDCap(:,2); 
withREDCap2(:,2) = withREDCap(:,1); 
withREDCap2(:,3) = withREDCap(:,3); 
C = []; 
C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: what I want to plot as y-axis

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

% remove 2nd measurement (non existant for BBT) 
C(find(C(:,2)==2),:) = [];  
C(find(C(:,2)>3),:) = [];  
C(isnan(C(:,3)),:) = []; 

% divide into S1 and S2
BBT1 = C(find(C(:,2)==1),:); 
BBT2 = C(find(C(:,2)==3),:); 

% merge into one 
Lia = double(ismember(BBT1(:,1),BBT2(:,1))); 
BBT1(:,1) = Lia.*BBT1(:,1); 
BBT1(BBT1(:,1)==0,:)= [];

% calculate the change 
BBTchange(:,1) = BBT1(:,1); 
BBTchange(:,2) = BBT2(:,3)-BBT1(:,3); 

%% Change in FMHand

% remove subjects that don't have redcap
n = 1; 
withREDCap = []; 
for i = 1:1:length(D(:,1))
    if isnan(D(i,2))
        
    else
        withREDCap(n,:) = D(i,:); 
        n=n+1; 
    end

end

withREDCap2(:,1) = withREDCap(:,2); 
withREDCap2(:,2) = withREDCap(:,1); 
withREDCap2(:,3) = withREDCap(:,3); 
C = []; 
C = sortrows(withREDCap2,'ascend'); 

% first column: subject ID
% second column: session nr
% third column: what I want to plot as y-axis

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

% remove 2nd measurement (non existant for BBT) 
C(find(C(:,2)==2),:) = [];  
C(find(C(:,2)>3),:) = [];  
C(isnan(C(:,3)),:) = []; 

% divide into S1 and S2
FMH1 = C(find(C(:,2)==1),:); 
FMH2 = C(find(C(:,2)==3),:); 

% merge into one 
Lia = double(ismember(FMH1(:,1),FMH2(:,1))); 
FMH1(:,1) = Lia.*FMH1(:,1); 
FMH1(FMH1(:,1)==0,:)= [];

% calculate the change 
FMHchange(:,1) = FMH1(:,1);
FMHchange(:,3) = FMH2(:,3)-FMH1(:,3); % change
FMHchange(:,2) = FMH2(:,3); % discharge 

%% merge with proprioception

% merge into one 
Lia = double(ismember(PMImp(:,1),BBTchange(:,1))); 
PMImp(:,1) = Lia.*PMImp(:,1); 
PMImp(PMImp(:,1)==0,:)= [];

% into one table
BBTchange(:,3) = BBT2(:,3); % BBT at discharge
BBTchange(:,4) = PMImp(:,2); % PM at baseline 

% merge into one 
Lia = double(ismember(PMImp(:,1),FMHchange(:,1))); 
PMImp(:,1) = Lia.*PMImp(:,1); 
PMImp(PMImp(:,1)==0,:)= [];
FMHchange(:,4) = PMImp(:,2); % PM at baseline 

%% scatter 

figure; 
scatter(BBTchange(:,4), BBTchange(:,2), 'filled'); 
xlabel('Position Matching Absolute Error @ baseline') 
ylabel('Change in Box & Block Test') 
print('Plots/ScatterPlots/210518_PMbase_BBTchange','-dpng')

txt = string(BBTchange(:,1)');
figure;
scatter(BBTchange(:,4), BBTchange(:,3), 'filled'); 
hold on 
labelpoints(BBTchange(:,4), BBTchange(:,3), txt)
xlabel('Position Matching Absolute Error @ baseline') 
ylabel('Box & Block @ discharge') 
print('Plots/ScatterPlots/210518_PMbase_BBTdischarge','-dpng')

figure; 
scatter(FMHchange(:,4), FMHchange(:,3), 'filled'); 
xlabel('Position Matching Absolute Error @ baseline') 
ylabel('Change in FMA Hand') 
print('Plots/ScatterPlots/210518_PMbase_FMHchange','-dpng')


txt = string(FMHchange(:,1)'); 
figure; 
scatter(FMHchange(:,4), FMHchange(:,2), 'filled'); 
hold on 
labelpoints(FMHchange(:,4), FMHchange(:,2), txt)
xlabel('Position Matching Absolute Error @ baseline') 
ylabel('FMA Hand @ discharge') 
print('Plots/ScatterPlots/210518_PMbase_FMHdischarge','-dpng')












