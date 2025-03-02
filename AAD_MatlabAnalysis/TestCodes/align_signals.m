function [aligned_signal1, aligned_signal2] = align_signals(signal1, signal2)
    % This function aligns two signals by adding NaNs before or after the signals
    % to make them the same length, with rescaling between -1 and 1 for alignment
    % but returns the original signals aligned.

    % Rescale signals between -1 and 1 for alignment
    rescaled_signal1 = rescale_signal(signal1);
    rescaled_signal2 = rescale_signal(signal2);
    
    % Cross-correlation to find the lag
    [correlation, lags] = xcorr(rescaled_signal1, rescaled_signal2);
    
    % Find the index of the maximum correlation
    [~, maxIndex] = max(abs(correlation));
    
    % Determine the lag
    lag = lags(maxIndex);
    
    % Align original signals based on the lag
    if lag > 0
        % signal1 lags behind signal2
        aligned_signal1 = [nan(lag, 1); signal1];
        aligned_signal2 = [signal2; nan(lag, 1)];
    else
        % signal2 lags behind signal1
        aligned_signal1 = [signal1; nan(-lag, 1)];
        aligned_signal2 = [nan(-lag, 1); signal2];
    end
    
    % Make sure both signals have the same length by adding NaNs at the end
    maxLength = max(length(aligned_signal1), length(aligned_signal2));
    aligned_signal1(end+1:maxLength) = nan;
    aligned_signal2(end+1:maxLength) = nan;
end

function rescaled_signal = rescale_signal(signal)
    % This function rescales a signal to the range [-1, 1]
    min_val = min(signal);
    max_val = max(signal);
    rescaled_signal = 2 * (signal - min_val) / (max_val - min_val) - 1;
end
