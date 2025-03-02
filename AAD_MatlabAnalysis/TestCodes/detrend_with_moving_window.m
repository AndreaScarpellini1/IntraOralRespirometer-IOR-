%% Functions 
function detrendedData = detrend_with_moving_window(data, windowSize)
    % Check if the input data is a row vector, if so, convert it to a column vector
    if isrow(data)
        data = data';
    end
    
    % Initialize the detrendedData array
    detrendedData = zeros(size(data));
    
    % Number of samples in the data
    numSamples = length(data);
    
    % Loop over each sample, moving the window one sample at a time
    for i = 1:numSamples
        % Determine the start and end indices of the window
        startIdx = max(1, i - floor(windowSize / 2));
        endIdx = min(numSamples, i + floor(windowSize / 2));
        
        % Extract the current window of data
        currentWindow = data(startIdx:endIdx);
        
        % Calculate the mean of the current window
        windowMean = mean(currentWindow);
        
        % Subtract the mean from the current sample
        detrendedData(i) = data(i) - windowMean;
    end 
end
