function plotLongitudinal_robotic(array,names,axisDir)
% iterate through the data I need to plot longitudinally 
%   Detailed explanation goes here


%% Define colors to be used %% 
colors = {  [0.8500, 0.3250, 0.0980]
            [1, 0, 0]    
          	[0.9290, 0.6940, 0.1250]	          	
          	[0.4940, 0.1840, 0.5560]	          	
          	[0.4660, 0.6740, 0.1880]	          	
          	[0.3010, 0.7450, 0.9330]	          	 
          	[0.6350, 0.0780, 0.1840]	
            [0.25, 0.25, 0.25]
            [0.1, 0.7, 0]
            [0, 0.4470, 0.7410] 
            [0.75, 0, 0.75]
            [0.75, 0.75, 0]
            [0, 0, 1]
            [178/255, 255/255, 102/255]
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
            [102/255 255/255 102/255]
            [255/255 128/255 0/255]
            [204/255 0/255 204/255]
            [102/255 178/255 255/255]
            };

%% plot longitudinal data - individual subjects 

for j = 1:length(names)

    figure; 
    for i=unique(array(:,1))'
        if (j == 4 && i == 2) || (j == 10 && i == 2)
        else
            temp = find(array(:,1)==i); 
            txt = ['Nr = ',num2str(i)];
            F = plot(array(temp,2),array(temp,2+j),'o-','DisplayName',txt); 
            F.MarkerFaceColor = colors{i};
            F.Color = colors{i}; 
            hold on 
        end
        
    end
    %legend show
    set(gca,'FontSize',12)
    xlim([0.5 8.5]) 
    xticks([1 2 3 4 5 6 7 8]) 
    xlabel('Robotic Session Nr.') 
    if axisDir(j) == 1
        set (gca,'YDir','reverse')
    end
    ylabel(names{j}) 
    print(['Plots/LongitudinalPlots/robotic/210518_Indiv_' names{j}],'-dpng')

end


%% group trends - mean for S1,S2,S3

for j = 1:length(names)
       
    n = 1; 
    m = 1; 
    k = 1; 
    for i = 1:length(array(:,1))
        if array(i,2) == 1
                S1(n,:) = array(i,:);
                n = n+1; 
        elseif array(i,2) == 2
                S2(m,:) = array(i,:);
                m = m+1; 
        elseif array(i,2) == 3
                S3(k,:) = array(i,:);
                k = k+1; 
        end
    end
    
    if j == 4 || j == 10
        S1(1,:) = []; 
        S2(1,:) = []; 
        S3(1,:) = [];        
    end
    S1_mean = mean(S1(:,2+j)); 
    S2_mean = mean(S2(:,2+j)); 
    S3_mean = mean(S3(:,2+j)); 

    % plot subjects plus mean

    figure; 
    for i=unique(array(:,1))'
        if (j == 4 && i == 2) || (j == 10 && i == 2)
        else
            temp = find(array(:,1)==i); 
            F = plot(array(temp,2),array(temp,2+j),'o-'); 
            F.MarkerFaceColor = [0.6 0.6 0.6];
            F.Color = [0.6 0.6 0.6]; 
            hold on 
        end
    end 
    M = plot(1:3,[S1_mean S2_mean S3_mean],'d-'); 
    M.MarkerFaceColor = 'k';
    M.Color = 'k'; 
    set(gca,'FontSize',12)
    xlim([0.5 6.5]) 
    xticks([1 2 3 4 5 6]) 
    xlabel('Robotic Session Nr.') 
    if axisDir(j) == 1
        set (gca,'YDir','reverse')
    end
    ylabel(names{j}) 
    print(['Plots/LongitudinalPlots/robotic/210518_Sum_' names{j}],'-dpng')

end


end

