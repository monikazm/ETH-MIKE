function plotLongitudinal_robotic_sum(array,names,axisDir)
% iterate through the data I need to plot longitudinally 
%   Detailed explanation goes here


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
    S1_mean = nanmean(S1(:,2+j)); 
    S2_mean = nanmean(S2(:,2+j)); 
    S3_mean = nanmean(S3(:,2+j)); 

    % plot subjects plus mean

    figure; 
    for i=unique(array(:,1))'
        if (j == 4 && i == 2) || (j == 10 && i == 2)
        else
            temp = find(array(:,1)==i); 
            F = plot(array(temp,2),array(temp,2+j),'o-'); 
            F.MarkerFaceColor = [0.6 0.6 0.6];
            F.Color = [0.6 0.6 0.6]; 
            F.MarkerSize = 4; 
            hold on 
        end
    end 
%    M = plot(1:3,[S1_mean S2_mean S3_mean],'d-'); 
%     M.MarkerFaceColor = 'k';
%     M.Color = 'k'; 
%     M.MarkerSize = 4; 
    set(gca,'FontSize',12)
    xlim([0.5 8.5]) 
    xticks([1 2 3 4 5 6 7 8]) 
    xlabel('Robotic Session Nr.') 
    if axisDir(j) == 1
        set (gca,'YDir','reverse')
    end
    ylabel(names{j}) 
    print(['Plots/LongitudinalPlots/robotic/210914_Sum_' names{j}],'-dpng')

end


end

