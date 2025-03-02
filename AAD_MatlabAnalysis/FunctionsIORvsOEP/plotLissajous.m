function [] = plotLissajous(x,y,color,boundary,PCA,numsectors,f)
    figure(f)
    xline(0,'Color',[0.5,0.5,0.5],'LineWidth',0.2)
    yline(0,'Color',[0.5,0.5,0.5],'LineWidth',0.2)
    hold on;
    scatter(x, y,0.1,'MarkerEdgeColor',color);
    axis equal
    % Combine the data into one matrix (each row is an observation)
    data = [x, y];
    % Compute PCA. coeff contains the principal component directions.
    [coeff, score, latent] = pca(data);
    % The first principal component direction is in the first column of coeff.
    pc1 = coeff(:,1);
    % Compute the mean of the data to center the line.
    dataMean = mean(data);    
    % Choose a scaling factor to define how long the line should be.
    % Here, 'scaleFactor' is chosen based on the data range.
    scaleFactor = max(max(abs(data - dataMean)));     
    % Define endpoints for the PC1 line
    pt1 = dataMean - scaleFactor * pc1';
    pt2 = dataMean + scaleFactor * pc1';
    % Plot the first PC on the existing Lissajous figure.
    hold on;
    if PCA
     plot([pt1(1) pt2(1)], [pt1(2) pt2(2)], 'LineWidth', 1,'Color',color);
    end 
    [boundary_x, boundary_y] = PercentileBoundary(x, y, 90,numsectors);
    hold on
    if boundary
        plot(boundary_x,boundary_y,'LineWidth',0.5,'Color',color)
    end 
end 
function [boundary_x, boundary_y] = PercentileBoundary(x, y, percentile, num_sectors)
    % plotPercentileBoundary calculates and optionally plots the boundary 
    % that encloses a specified percentile of data points from two input vectors.
    %
    % Inputs:
    %   - x: Vector of x-coordinates 
    %   - y: Vector of y-coordinates 
    %   - percentile: The desired percentile boundary to be calculated (e.g., 90 for the 90th percentile)
    %   - plotM: Boolean flag to indicate whether to plot the results (true for plotting, false otherwise)
    %   - num_sectors: Number of sectors (angles) to divide the data for percentile calculation
    %
    % Outputs:
    %   - area: The calculated area enclosed by the percentile boundary
    %   - boundary_x: x-coordinates of the boundary points
    %   - boundary_y: y-coordinates of the boundary points
    %
    % ~ Andrea Scarpellini  (2024)

    
    % Ensure x and y are column vectors
    if isrow(x)
        x = x';
    end
    if isrow(y)
        y = y';
    end

    % Step 1: Remove NaN values from the data
    valid_idx = ~isnan(x) & ~isnan(y);
    x = x(valid_idx);
    y = y(valid_idx);

    % Step 2: Compute the mean of the data
    mu = mean([x y]);

    % Center the data around the mean
    x_centered = x - mu(1);
    y_centered = y - mu(2);

    % Convert to polar coordinates
    [theta, rho] = cart2pol(x_centered, y_centered);

    % Step 3: Calculate the percentile distance for each angle sector
    percentile_distances = zeros(1, num_sectors);
    angles = linspace(-pi, pi, num_sectors);

    for i = 1:num_sectors-1
        sector_idx = theta >= angles(i) & theta < angles(i+1);
        sector_rho = rho(sector_idx);
        if ~isempty(sector_rho)
            percentile_distances(i) = prctile(sector_rho, percentile);
        end
    end
    % Close the loop
    percentile_distances(end) = percentile_distances(1);

    % Convert back to Cartesian coordinates
    [boundary_x, boundary_y] = pol2cart(angles, percentile_distances);
    boundary_x = boundary_x + mu(1);
    boundary_y = boundary_y + mu(2);

end


