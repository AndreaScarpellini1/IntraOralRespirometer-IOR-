function lissajoulsPhaseB(Flow_clean,Pressure_clean,indices,commontimestamps,colors,perc)  
    c = 0;
    flow_still =[];pressure_still =[];
    flow_walk  =[];pressure_walk  =[];
    flow_running  = [];pressure_running =[];
    for i = 1: length(commontimestamps)-1
        c = c+1; 
        if strcmp(colors{c},'green')
             flow_still =[flow_still;Flow_clean(indices(i):indices(i+1))];
             pressure_still =[pressure_still; Pressure_clean(indices(i):indices(i+1))]; 
        elseif strcmp(colors{c},'magenta')
             flow_walk  =[flow_walk; Flow_clean(indices(i):indices(i+1))];
             pressure_walk  =[pressure_walk; Pressure_clean(indices(i):indices(i+1))];
        elseif strcmp(colors{c},'red')
            flow_running  = [flow_running; Flow_clean(indices(i):indices(i+1))];
            pressure_running =[pressure_running; Pressure_clean(indices(i):indices(i+1))];
        end  
    end 
    figure()
    scatter(flow_still,pressure_still,1,'filled','MarkerFaceColor','k')
    plotDensityContour(flow_still, pressure_still, 'k', 0,perc)
    hold on 
    scatter(flow_walk,pressure_walk,1,'filled','MarkerFaceColor','cyan')
    plotDensityContour(flow_walk, pressure_walk, 'blue', 0,perc)
    scatter(flow_running,pressure_running,1,'filled','MarkerFaceColor','red')
    plotDensityContour(flow_running, pressure_running, 'red', 0,perc)
    
    xlabel('Flow (L/s)')
    ylabel('Pressure (cm h20)')
    grid on 
    axis equal    
    xlim([-4 4])
    ylim([-4,4])
    xline(0)
    yline(0)
end 
function plotDensityContour(Flow_clean, Pressure_clean, color, plotscatter,perc)
    % Define a grid over the range of your data
    xi = linspace(min(Flow_clean), max(Flow_clean), 100);
    yi = linspace(min(Pressure_clean), max(Pressure_clean), 100);
    [X, Y] = meshgrid(xi, yi);
    
    % Combine your data into a two-column array
    data = [Flow_clean(:), Pressure_clean(:)];
    
    % Evaluate the kernel density estimate on the grid
    f = ksdensity(data, [X(:), Y(:)]);
    F = reshape(f, size(X));
    
    % --- Determine a threshold that encloses 95% of the total density ---
    % Note: This is an approximation because F is computed on a grid.
    totalDensity = sum(F(:));
    sortedF = sort(F(:), 'descend');
    cumulative = cumsum(sortedF);
    idx = find(cumulative >= perc * totalDensity, 1, 'first');
    threshold = sortedF(idx);
    
    % --- Extract the contour at the chosen threshold ---
    % contourc returns a contour matrix C with the following format:
    %   C(1, idx) = contour level; C(2, idx) = number of points,
    %   followed by that many [x; y] points.
    C = contourc(xi, yi, F, [threshold, threshold]);
    
    % --- Parse C to find the longest contour segment (assumed outer) ---
    idx = 1;
    maxLength = 0;
    bestContour = [];
    while idx < size(C, 2)
        nPoints = C(2, idx);
        contourSegment = C(:, idx+1:idx+nPoints);
        % Calculate the arc length of this contour segment
        segmentLength = sum(sqrt(diff(contourSegment(1, :)).^2 + diff(contourSegment(2, :)).^2));
        if segmentLength > maxLength
            maxLength = segmentLength;
            bestContour = contourSegment;
        end
        idx = idx + nPoints + 1;
    end
    

    hold on;
    if plotscatter
        scatter(Flow_clean, Pressure_clean, 1, 'filled', 'MarkerFaceColor', color);
    end
    if ~isempty(bestContour)
        plot(bestContour(1, :), bestContour(2, :), 'Color', color, 'LineWidth', 0.5);
    else
        warning('No contour found at the specified threshold.');
    end
end
