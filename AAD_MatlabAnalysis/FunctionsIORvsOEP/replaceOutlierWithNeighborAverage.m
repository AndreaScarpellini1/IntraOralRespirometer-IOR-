function data_cleaned = replaceOutlierWithNeighborAverage(data,stdThreshold)
% replaceOutlierWithNeighborAverage Replaces blocks of outliers with the average
% of the neighboring non-outlier values.
%
%   data_cleaned = replaceOutlierWithNeighborAverage(data)
%
%   This function detects outliers in the input vector "data" using MATLAB's
%   isoutlier function. It then identifies contiguous blocks (series) of
%   outliers. For each block that is bounded on both sides by valid (non-outlier)
%   values, the block is replaced with the average of the last valid value
%   before the block and the first valid value after the block.
%
%   Input:
%       data - A numeric vector.
%
%   Output:
%       data_cleaned - The vector with outlier blocks replaced.
%
%   Example:
%       x = [1 2 100 200 300 4 5];
%       x_clean = replaceOutlierWithNeighborAverage(x);
%       % Assuming 100,200,300 are outliers, they will be replaced by (2+4)/2 = 3,
%       % so x_clean becomes [1 2 3 3 3 4 5].

    % Ensure the input is a vector.
    if ~isvector(data)
        error('Input must be a vector.');
    end

    % Initialize the cleaned data with the original data.
    data_cleaned = data;
    
    % Identify outlier indices using MATLAB's isoutlier.
    outlierLogical = isoutlier(data, 'mean', 'ThresholdFactor', stdThreshold);
    outlierIndices = find(outlierLogical);
    
    % If no outliers, simply return the original data.
    if isempty(outlierIndices)
        return;
    end
    
    % Identify contiguous blocks of outliers.
    blocks = {};   % Each cell will hold a two-element vector: [start, end] index
    blockStart = outlierIndices(1);
    prevIndex = outlierIndices(1);
    
    for idx = outlierIndices(2:end)'
        if idx == prevIndex + 1
            % Continue the current block.
            prevIndex = idx;
        else
            % End the current block and start a new block.
            blocks{end+1} = [blockStart, prevIndex]; %#ok<AGROW>
            blockStart = idx;
            prevIndex = idx;
        end
    end
    % Add the last block.
    blocks{end+1} = [blockStart, prevIndex];
    
    % Process each contiguous block.
    for k = 1:length(blocks)
        block = blocks{k};
        startIdx = block(1);
        endIdx = block(2);
        
        % Ensure the block is bounded by valid non-outlier neighbors.
        if startIdx == 1 || endIdx == length(data)
            warning('Block of outliers from index %d to %d touches a boundary. Skipping replacement.', startIdx, endIdx);
            continue;
        end
        
        % Calculate the average of the neighbor before and after the block.
        neighbor_avg = (data(startIdx - 1) + data(endIdx + 1)) / 2;
        
        % Replace the entire block with the computed average.
        data_cleaned(startIdx:endIdx) = neighbor_avg;
    end
end
