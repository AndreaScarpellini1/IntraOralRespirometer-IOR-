function [zeroCrossingIndices, zeroCrossingTimes, signedTimeIntervals, signedAbsMaxValues, absMaxIndices, ...
          zeroCrossingIndices_corrected, zeroCrossingTimes_corrected, signedTimeIntervals_corrected, ...
          signedAbsMaxValues_corrected, absMaxIndices_corrected] = findZeroCrossingsWithSign(time, y, th)
    % Validate input sizes
    if length(time) ~= length(y)
        error('Time and y vectors must have the same length.');
    end

    %% Compute Original Zero-Crossing Parameters
    % Find indices where a sign change occurs
    signChanges = find((y(1:end-1) .* y(2:end)) < 0);

    % Initialize outputs for zero crossings
    zeroCrossingIndices = signChanges;
    zeroCrossingTimes = zeros(size(signChanges));

    % Estimate exact zero-crossing times using linear interpolation
    for i = 1:length(signChanges)
        idx = signChanges(i);
        t1 = time(idx);
        t2 = time(idx + 1);
        y1 = y(idx);
        y2 = y(idx + 1);
        % Linear interpolation to estimate the zero crossing time
        zeroCrossingTimes(i) = t1 - y1 * (t2 - t1) / (y2 - y1);
    end

    % Compute time intervals between consecutive zero crossings
    timeIntervals = diff(zeroCrossingTimes);

    % Assign sign to each interval based on the y-value immediately after the crossing
    signOfInterval = sign(y(zeroCrossingIndices(1:end-1) + 1));
    signedTimeIntervals = timeIntervals .* signOfInterval;

    % Compute the maximum absolute y-values (with sign) and their indices in each window
    numWindows = length(zeroCrossingIndices) - 1;
    signedAbsMaxValues = zeros(numWindows, 1);
    absMaxIndices = zeros(numWindows, 1);
    for i = 1:numWindows
        % Define the window: from just after the i-th zero crossing up to the (i+1)-th zero crossing
        startIdx = zeroCrossingIndices(i) + 1;
        endIdx = zeroCrossingIndices(i+1);
        if startIdx > endIdx
            signedAbsMaxValues(i) = NaN;  % Handle potential empty window
            absMaxIndices(i) = NaN;
        else
            % Find the index of the maximum absolute value in the current window
            [~, localMaxIdx] = max(abs(y(startIdx:endIdx)));
            % Convert the local index to an index in the original y vector
            absMaxIndices(i) = startIdx - 1 + localMaxIdx;
            % Retrieve the corresponding y value (with its original sign)
            signedAbsMaxValues(i) = y(absMaxIndices(i));
        end
    end

    %% Compute Corrected Zero-Crossing Parameters
    % The following loop selects only those zero crossings that meet a
    % threshold condition and where a sign change (compared with the last valid max)
    % is detected.
    % figure()
    % yline([-th 0 th])
    % hold on 
    % plot(time,y)
    first = 0;
    lastmaxvalid = 0;
    zeroCrossingIndices_corrected = [];
    zeroCrossingTimes_corrected = [];
    for i = 1:length(zeroCrossingIndices)
        %scatter(zeroCrossingTimes,0)
        if i < length(zeroCrossingIndices)
            if (abs(signedAbsMaxValues(i)) > th && first == 0)
                first = 1;
                zeroCrossingIndices_corrected = [zeroCrossingIndices_corrected, zeroCrossingIndices(i)];
                zeroCrossingTimes_corrected = [zeroCrossingTimes_corrected, zeroCrossingTimes(i)];
                lastmaxvalid = signedAbsMaxValues(i);
            elseif (abs(signedAbsMaxValues(i)) > th && signedAbsMaxValues(i) * lastmaxvalid < 0)
                lastmaxvalid = signedAbsMaxValues(i);
                zeroCrossingIndices_corrected = [zeroCrossingIndices_corrected, zeroCrossingIndices(i)];
                zeroCrossingTimes_corrected = [zeroCrossingTimes_corrected, zeroCrossingTimes(i)];
            end
        else
            % For the last zero crossing, use the previous window's max value as a condition
            if (abs(signedAbsMaxValues(i-1)) > th)
                zeroCrossingIndices_corrected = [zeroCrossingIndices_corrected, zeroCrossingIndices(i)];
                zeroCrossingTimes_corrected = [zeroCrossingTimes_corrected, zeroCrossingTimes(i)];
            end
        end
    end

    % Compute corrected signed time intervals (only if there are at least 2 corrected crossings)
    if length(zeroCrossingTimes_corrected) > 1
        timeIntervals_corrected = diff(zeroCrossingTimes_corrected);
        % The sign of each interval is determined by the y-value immediately after the crossing in the original vector.
        signedTimeIntervals_corrected = timeIntervals_corrected .* sign( y(zeroCrossingIndices_corrected(1:end-1) + 1) );
    else
        signedTimeIntervals_corrected = [];
    end

    % Compute the corrected maximum absolute y-values (with sign) and their indices in each window
    numCorrectedWindows = length(zeroCrossingIndices_corrected) - 1;
    signedAbsMaxValues_corrected = zeros(numCorrectedWindows, 1);
    absMaxIndices_corrected = zeros(numCorrectedWindows, 1);
    for i = 1:numCorrectedWindows
        % Define the window for corrected zero crossings
        startIdx = zeroCrossingIndices_corrected(i) + 1;
        endIdx = zeroCrossingIndices_corrected(i+1);
        if startIdx > endIdx
            signedAbsMaxValues_corrected(i) = NaN;
            absMaxIndices_corrected(i) = NaN;
        else
            [~, localMaxIdx] = max(abs(y(startIdx:endIdx)));
            absMaxIndices_corrected(i) = startIdx - 1 + localMaxIdx;
            signedAbsMaxValues_corrected(i) = y(absMaxIndices_corrected(i));
        end
    end

end
