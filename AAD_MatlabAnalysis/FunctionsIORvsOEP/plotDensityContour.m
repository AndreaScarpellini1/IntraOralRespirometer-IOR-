function plotDensityContour(Flow_clean, Pressure_clean, color, plotscatter)
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
    idx = find(cumulative >= 0.75 * totalDensity, 1, 'first');
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
