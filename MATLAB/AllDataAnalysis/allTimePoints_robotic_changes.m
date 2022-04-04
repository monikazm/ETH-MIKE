%% report all values of robotic tests %% 
% also calculate mean & std for each metric for each time point
% created: 17.11.2021

clear 
close all
clc

%% read table

addpath(genpath('C:\Users\monikaz\eth-mike-data-analysis\MATLAB\data'))

T = readtable('data/20211013_DataImpaired.csv'); 

% 122 - PM  AE 
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

A = table2array(T(:,[3 5 122 114 92 160])); 

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

T4.S3(1,3) = T4.S2(1,3); 
T7.S2(1,3) = 20;  

%% changes
T2.S2(5,4) = T2.S1(5,4); 
T2.S2(5,5) = T2.S1(5,5); 
T2.S2(5,6) = T2.S1(5,6); 
T2.Change.F = (T2.S2(:,4)/(50 - T2.S1(:,4)))*100; 
T2.Change.ROM = (T2.S2(:,5)/(90 - T2.S1(:,5)))*100; 
T2.Change.Vel = (T2.S2(:,6)/(408 - T2.S1(:,6)))*100; 

T3.Change1.F = (T3.S2(:,4)/(50 - T3.S1(:,4)))*100; 
T2.Change1.ROM = (T3.S2(:,5)/(90 - T3.S1(:,5)))*100; 
T2.Change1.Vel = (T3.S2(:,6)/(408 - T3.S1(:,6)))*100; 

