%% ttests to define if change is significant %% 
% created: 12.10.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 47 - kUDT
% 41 - FM M UL
% 48 - BB imp 
% 49 - BB nonimp
% 50 - barther index tot
% 44 - FMA Hand 
% 61 - MoCA

A = table2array(T(:,[3 5 47 41 48 49 50 44 61])); 

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

%% Divide into S1 and S3

n = 1;  
k = 1; 
m = 1; 
for i = 1:length(C(:,1))
        if C(i,2) == 1
            S1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 2 && isnan(C(i,3))==0
            S3(m,:) = C(i,:);
            m = m+1;
        elseif C(i,2) == 3 && isnan(C(i,3))==0
            S3(m,:) = C(i,:);
            m = m+1; 
        end
end

% % clean up and merge 
Lia = double(ismember(S1(:,1),S3(:,1))); 
S1(:,1) = Lia.*S1(:,1); 
S1(S1(:,1)==0,:)= [];

% remove subjects that only have 2 measurements
% S1(find(S1(:,1)==3),:) = []; 
% S3(find(S3(:,1)==3),:) = []; 
% 
% S1(find(S1(:,1)==33),:) = []; 
% S3(find(S3(:,1)==33),:) = []; 
% 
% S1(find(S1(:,1)==37),:) = []; 
% S3(find(S3(:,1)==37),:) = []; 
% 
% S1(find(S1(:,1)==38),:) = []; 
% S3(find(S3(:,1)==38),:) = []; 
% 
% S1(find(S1(:,1)==48),:) = []; 
% S3(find(S3(:,1)==48),:) = []; 

%% ttests kUDT

[h1_kUDT,p1_kUDT] = ttest(S1(:,3),S3(:,3)); 

%% ttests FMAM

[h1_FM,p1_FM] = ttest(S1(:,4),S3(:,4)); 

%% ttests BBT imp 

[h1_BBI,p1_BBI] = ttest(S1(:,5),S3(:,5)); 

%% ttests BBT nonimp 

[h1_BBNI,p1_BBNI] = ttest(S1(:,6),S3(:,6)); 

%% ttests Barthel 

[h1_Barth,p1_Barth] = ttest(S1(:,7),S3(:,7)); 

%% ttests FMA Hand

[h1_FMH,p1_FMH] = ttest(S1(:,8),S3(:,8)); 

%% ttests MoCA

[h1_MoCA,p1_MoCA] = ttest(S1(:,9),S3(:,9)); 

%% Mean and std

mean_kUDT_t1 = nanmean(S1(:,3)); 
mean_kUDT_t3 = nanmean(S3(:,3)); 
std_kUDT_t1 = nanstd(S1(:,3)); 
std_kUDT_t3 = nanstd(S3(:,3)); 

mean_FMA_t1 = nanmean(S1(:,4)); 
mean_FMA_t3 = nanmean(S3(:,4)); 
std_FMA_t1 = nanstd(S1(:,4)); 
std_FMA_t3 = nanstd(S3(:,4)); 

mean_BBI_t1 = nanmean(S1(:,5)); 
mean_BBI_t3 = nanmean(S3(:,5)); 
std_BBI_t1 = nanstd(S1(:,5)); 
std_BBI_t3 = nanstd(S3(:,5)); 

mean_BBNI_t1 = nanmean(S1(:,6)); 
mean_BBNI_t3 = nanmean(S3(:,6)); 
std_BBNI_t1 = nanstd(S1(:,6)); 
std_BBNI_t3 = nanstd(S3(:,6));

mean_Barth_t1 = nanmean(S1(:,7)); 
mean_Barth_t3 = nanmean(S3(:,7)); 
std_Barth_t1 = nanstd(S1(:,7)); 
std_Barth_t3 = nanstd(S3(:,7)); 

mean_FMH_t1 = nanmean(S1(:,8)); 
mean_FMH_t3 = nanmean(S3(:,8)); 
std_FMH_t1 = nanstd(S1(:,8)); 
std_FMH_t3 = nanstd(S3(:,8));

mean_MoCA_t1 = nanmean(S1(:,9)); 
mean_MoCA_t3 = nanmean(S3(:,9)); 
std_MoCA_t1 = nanstd(S1(:,9)); 
std_MoCA_t3 = nanstd(S3(:,9)); 

%% plotting scatter

k = 1; 
figure; 
for i = 1:length(S1(:,3))
    if isnan(S3(i,3))
    else
    temp1(k,:) = [S1(i,3) S3(i,3)]; 
    F = plot(1:2, [S1(i,3) S3(i,3)],'-o'); 
    F.Color = 'k'; 
    F.MarkerFaceColor = 'k'; 
    hold on 
    k = k+1; 
    end
end
ylabel('kinesthetic Up-Down Test') 
xlim([0.75 2.25]) 
ylim([-0.25 3.25]) 
xticks([1 2])
xticklabels({'T1','T3'})
xlabel('Measurement Session Nr') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/clinical/211012_kUDT','-dpng')

figure; 
for i = 1:length(S1(:,4))
    F = plot(1:2, [S1(i,4) S3(i,4)],'-o'); 
    F.Color = 'k'; 
    F.MarkerFaceColor = 'k'; 
    hold on 
end
xlim([0.75 2.25]) 
ylabel('Fugl-Meyer Upper Limb Motor Assessment') 
xticks([1 2])
xticklabels({'T1','T3'})
xlabel('Measurement Session Nr') 

kUDT = [S1(:,1) S1(:,3) S3(:,3)]; 

n = 1; 
figure; 
for i = 1:length(S1(:,8))
    if isnan(S3(i,8))
    else
        temp2(n,:) = [S1(i,8) S3(i,8)]; 
        F = plot(1:2, [S1(i,8) S3(i,8)],'-o'); 
        F.Color = 'k'; 
        F.MarkerFaceColor = 'k'; 
        hold on 
        n = n+1; 
    end
end
xlim([0.75 2.25])
ylim([-0.5 14.5])
ylabel('Fugl-Meyer Upper Limb Hand') 
xticks([1 2])
xticklabels({'T1','T3'})
xlabel('Measurement Session Nr') 
set(gca,'FontSize',12)
print('C:/Users/monikaz/eth-mike-data-analysis/MATLAB/Plots/LongitudinalPlots/clinical/211012_FMAHand','-dpng')


