function mapped_data = mapToRange(data, new_min, new_max)
    % Check if new_min and new_max are provided
    if nargin < 2
        new_min = -4;
    end
    if nargin < 3
        new_max = 4;
    end
    
    % Calculate the minimum and maximum of the original data
    old_min = min(data);
    old_max = max(data);
    
    % Map the data to the new range
    mapped_data = (new_max - new_min) * (data - old_min) / (old_max - old_min) + new_min;
end
