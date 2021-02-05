%% extract datat from CSV (cheater) %% 
% created: 22.01.2021

% plot in thicker line subjects that changed above MDC on FM (5.2 Wagner et al 2008) 

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
% 41 = Fugl-Meyer total 

A = table2array(T(:,[3 5 41])); 

MDC = 5.2; 


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

% remove all rows for which clinical data doesn't exist 
temp = find(isnan(C(:,3))); 
C(temp,:) = []; 

% change all 3rd into second session 
temp2 = find(C(:,2) == 3); 
C(temp2,2) = 2; 

%% which subject above MDC

n = 1;  
k = 1; 
for i = 1:length(C(:,1))
        if C(i,2) == 1
            Sesh1(n,:) = C(i,:);
            n = n+1; 
        elseif C(i,2) == 2
            Sesh2(k,:) = C(i,:);
            k = k+1; 
        end

end

inclDisDiff(:,1) = Sesh1(:,1); 
inclDisDiff(:,2) = Sesh2(:,3) - Sesh1(:,3); 

n = 1; 
subjectImproved = []; 
for i=1:length(inclDisDiff(:,1))
    if isnan(MDC) 
    else
        if abs(inclDisDiff(i,2)) > abs(MDC) 
            subjectImproved(n) = inclDisDiff(i,1); 
            n = n+1; 
        end
    end
end

    
%% plot longitudinal data - individual subjects 
% N = 11 

figure; 
for i=unique(C(:,1))'
        if  sum(i == subjectImproved) > 0 
            temp = find(C(:,1)==i); 
            txt = ['Nr = ',num2str(i)];
            F = plot(C(temp,2),C(temp,3),'o--','DisplayName',txt,'Linewidth',2); 
            F.MarkerFaceColor = colors{i};
            F.Color = colors{i}; 
            hold on 
        else
            temp = find(C(:,1)==i); 
            txt = ['Nr = ',num2str(i)];
            F = plot(C(temp,2),C(temp,3),'o-','DisplayName',txt); 
            F.MarkerFaceColor = colors{i};
            F.Color = colors{i}; 
            hold on 
        end

end
%legend show
set(gca,'FontSize',12)
xlim([0.5 2.5]) 
xticks([1 2]) 
xlabel('Clinical Session Nr.') 
ylabel('Fugl-Meyer UL') 
print('Plots/LongitudinalPlots/clinical/210122_Indiv_FMA','-dpng')










