function plotSRD_robotic(filename,ID,array,names,axisDir)
% iterate through the data I need to plot longitudinally 
%   Detailed explanation goes here

M = readtable(filename); 


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


%% Calculate if above SRD 

for j = 1:length(names)
    
    SRD = table2array(M(ID(j),7)); 
    healthyAvrg = table2array(M(ID(j),6));
        n = 1;  
        k = 1; 
        for i = 1:length(array(:,1))
            if array(i,1) == 3
                if array(i,2) == 1
                    Sesh1(n,:) = array(i,:);
                    n = n+1; 
                elseif array(i,2) == 2
                    Sesh3(k,:) = array(i,:);
                    k = k+1; 
                end
            elseif array(i,1) == 11
                if array(i,2) == 1
                    Sesh1(n,:) = array(i,:);
                    n = n+1; 
                elseif array(i,2) == 5
                    Sesh3(k,:) = array(i,:);
                    k = k+1; 
                end
            elseif array(i,1) == 6 && j == 7
                if array(i,2) == 1
                    Sesh1(n,:) = array(i,:);
                    n = n+1; 
                elseif array(i,2) == 4
                    Sesh3(k,:) = array(i,:);
                    k = k+1; 
                end
            elseif array(i,1) == 6 && j == 1
                if array(i,2) == 1
                    Sesh1(n,:) = array(i,:);
                    n = n+1; 
                elseif array(i,2) == 6 
                    Sesh3(k,:) = array(i,:);
                    k = k+1; 
                end    
            else
                if array(i,2) == 1
                    Sesh1(n,:) = array(i,:);
                    n = n+1; 
                elseif array(i,2) == 3
                    Sesh3(k,:) = array(i,:);
                    k = k+1; 
                end
            end
        end

        inclDisDiff(:,1) = Sesh1(:,1); 
        inclDisDiff(:,2) = Sesh3(:,2+j) - Sesh1(:,2+j); 

        n = 1; 
        subjectImproved = []; 
        for i=1:length(inclDisDiff(:,1))
            if isnan(SRD) 
            else
                if inclDisDiff(i,2) > abs(SRD) 
                    subjectImproved(n) = inclDisDiff(i,1); 
                    n = n+1; 
                end
            end
        end

        figure; 
        for i=unique(array(:,1))'
            if (j == 4 && i == 2) || (j == 10 && i == 2)
            else
                if sum(i == subjectImproved) > 0 
                    temp = find(array(:,1)==i); 
                    txt = ['Nr = ',num2str(i)];
                    F = plot(array(temp,2),array(temp,2+j),'o--','DisplayName',txt,'Linewidth',2); 
                    F.MarkerFaceColor = colors{i};
                    F.Color = colors{i}; 
                    hold on 

                else
                    temp = find(array(:,1)==i); 
                    txt = ['Nr = ',num2str(i)];
                    F = plot(array(temp,2),array(temp,2+j),'o-','DisplayName',txt); 
                    F.MarkerFaceColor = colors{i};
                    F.Color = colors{i}; 
                    hold on 
                end
            end
        end
        if isnan(healthyAvrg) 
        else
            hold on 
            yline(healthyAvrg,'-.k','Linewidth',2); 
        end
        set(gca,'FontSize',12)
        xlim([0.5 6.5]) 
        xticks([1 2 3 4 5 6]) 
        if axisDir(j) == 1
            set (gca,'YDir','reverse')
        end
        xlabel('Robotic Session Nr.') 
        ylabel(names{j}) 
        print(['Plots/LongitudinalPlots/robotic/210119_Indiv_' names{j}],'-dpng')
end


end

