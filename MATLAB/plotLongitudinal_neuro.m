function plotLongitudinal_neuro(array,columns,names,axisDir)
% iterate through the data I need to plot longitudinally 
%   Detailed explanation goes here


%% Define arrayolors to be used %% 
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


%% plot longitudinal data - individual subjearrayts 
% N = 11
k = 1; 

for j = 1:2:length(columns)
    newarray = []; 
    newarray = array(:,[1 2 3 3+j 4+j]); 
    
    % remove all rows for which clinical data doesn't exist 
    n = 1; 
    t = []; 
    for i = 1:length(newarray(:,4))
        if isnan(newarray(i,4)) && isnan(newarray(i,5))
            t(n) = i; 
            n = n+1; 
        end
    end
    newarray(t,:) = []; 

    % change all 3rd into second session 
    temp2 = find(newarray(:,2) == 3); 
    newarray(temp2,2) = 2; 
    
    
    figure; 
    for i=unique(newarray(:,1))'
            temp = find(newarray(:,1)==i); 
            txt = ['Nr = ',num2str(i)];
                if newarray(temp,3) == 1
                    F = plot(newarray(temp,2),newarray(temp,4),'o-','DisplayName',txt); 
                    F.MarkerFaceColor = colors{i};
                    F.Color = colors{i}; 
                    hold on 
                    F = plot(newarray(temp,2)+2,newarray(temp,5),'o-','DisplayName',txt); 
                    F.MarkerFaceColor = colors{i};
                    F.Color = colors{i}; 
                    hold on 
                else
                    F = plot(newarray(temp,2),newarray(temp,5),'o-','DisplayName',txt); 
                    F.MarkerFaceColor = colors{i};
                    F.Color = colors{i}; 
                    hold on 
                    F = plot(newarray(temp,2)+2,newarray(temp,4),'o-','DisplayName',txt); 
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
    if axisDir(k) == 1
        set (gca,'YDir','reverse')
    end
    ylabel(names{k}) 
    print(['Plots/LongitudinalPlots/neuro/210121_Indiv_' names{k}],'-dpng')
    k = k+1; 
    
end


end

