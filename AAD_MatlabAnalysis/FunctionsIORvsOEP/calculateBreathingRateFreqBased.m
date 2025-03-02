function [breathingRate, peakIndices] = calculateBreathingRateFreqBased(signal, samplingRate,fi,titlestr,k)
% calculateBreathingRateFreqBased estimates the breathing rate from a signal by:
%   1. Analyzing the frequency domain to find the dominant frequency.
%   2. Setting the minimum peak distance based on 0.6 times the expected period.
%   3. Detecting peaks using findpeaks with dynamic parameters.
%   4. Filtering out peaks that are negative.
%   5. Removing consecutive peaks without a zero crossing (i.e. a valley below zero)
%      between them.
%   6. Plotting the signal along with the valid detected peaks.
%
% INPUTS:
%   signal       - Vector containing the breathing signal.
%   samplingRate - Sampling rate in Hz.
%
% OUTPUTS:
%   breathingRate - Estimated breathing rate in breaths per minute.
%   peakIndices   - Indices of the valid detected peaks.
%
% Example:
%   [rate, peaks] = calculateBreathingRateFreqBased(breathSignal, 100);
%   fprintf('Estimated breathing rate: %.2f BPM\n', rate);

    %% Frequency Domain Analysis
    L = length(signal);
    Y = fft(signal);
    P2 = abs(Y/L);
    % Construct single-sided spectrum
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = samplingRate*(0:(floor(L/2)))/L;
    
    % Exclude the DC component (f=0) and find the dominant frequency
    [~, idx] = max(P1(2:end));
    dominantFrequency = f(idx+1); % adjust index due to exclusion of DC
    
    fprintf('Dominant frequency detected: %.2f Hz\n', dominantFrequency);
    
    % Expected period of a breath (in seconds)
    expectedPeriod = 1/dominantFrequency;
    
    %% Define Dynamic Peak Detection Parameters
    % Set minimum peak distance to 0.6 times the expected period (in samples)
    minPeakDistance = floor(k * expectedPeriod * samplingRate);
    
    % Define a prominence threshold as a factor of the signal's standard deviation.
    prominenceThreshold = std(signal) * 0.2;  % Adjust factor as needed
    
    %% Initial Peak Detection
    [~, peakIndices] = findpeaks(signal, 'MinPeakDistance', minPeakDistance, ...
                                            'MinPeakProminence', prominenceThreshold);
    
    %% Filter Out Invalid Peaks
    % 1. Remove peaks that are negative (they are not valid breaths)
    peakIndices = peakIndices(signal(peakIndices) > 0);
    
    % 2. Remove consecutive peaks if there's no zero crossing in between.
    %    This ensures that a valid breath cycle has a valley that crosses zero.
    validPeakIndices = [];
    if ~isempty(peakIndices)
        validPeakIndices(end+1) = peakIndices(1); % Always keep the first detected peak
        for i = 2:length(peakIndices)
            prevIdx = validPeakIndices(end);
            currIdx = peakIndices(i);
            % Check the minimum value between the current valid peak and the new candidate peak
            if min(signal(prevIdx:currIdx)) < 0
                validPeakIndices(end+1) = currIdx;
            else
                fprintf('Peak at index %d skipped due to lack of zero crossing between peaks.\n', currIdx);
            end
        end
    end
    peakIndices = validPeakIndices;
    
    %% Calculate Breathing Rate
    if length(peakIndices) < 2
        warning('Not enough valid peaks detected to calculate breathing rate.');
        breathingRate = NaN;
    else
        intervals = diff(peakIndices) / samplingRate; % intervals in seconds
        avgInterval = mean(intervals);
        breathingRate = 60 / avgInterval; % Convert seconds to minutes (BPM)
    end
    
    %% Plot the Breathing Signal and Valid Detected Peaks
    t = (0:L-1) / samplingRate;
    figure(fi);
    plot(t, signal, 'b', 'LineWidth', 1.2);
    hold on;
    plot(t(peakIndices), signal(peakIndices), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 2);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(strcat(titlestr,sprintf('(%.2f BPM)', breathingRate)));
    grid on;
    hold off;
end
