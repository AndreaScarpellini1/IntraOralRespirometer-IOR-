clc
clear
close all
% Directory and file paths
directory = cd;
root = directory(1:end-length('\AAD_MatlabAnalysis'));
filefolder = fullfile(root, '\AAB_DataCollection\PreliminaryCollection');

if isfolder(filefolder)
    excels = dir(filefolder);
    excels = excels(3:end);
    names = {excels(:).name};
    fileIOR = readtable(fullfile(filefolder, names{1,3}));
    disp("okay");
    start = 1;
    CheckSF(start,fileIOR{1:end, 8},0);



    start = 1;
    time_OEP = fileIOR{start:24163, 8} * 0.001;
    accx = fileIOR{start:24163, 5};
    accy = fileIOR{start:24163, 6};
    accz = fileIOR{start:24163, 7};
    gyrox = fileIOR{start:24163, 2};
    gyroy = fileIOR{start:24163,3};
    gyroz = fileIOR{start:24163,4};
    pressure = fileIOR{start:24163, 1};
    pressure_abs = fileIOR{start:24163, 9};

    labels = {'Resting',   'Walking', 'Running in Place', 'Resting',...
              'Transition','Supine',  'LDL','LDR'};

    time_points = [time_OEP(1), 125,215, 278, 340,356,391,417,time_OEP(end)];
    % Find nearest indices for time points
    indices = arrayfun(@(t) find(abs(time_OEP - t) == min(abs(time_OEP - t)), 1), time_points);
    
    % Add counters for repeated labels
    label_counts = containers.Map(); % Initialize a map to count labels
    numbered_labels = cell(size(labels));
    for i = 1:length(labels)
        label = labels{i};
        if isKey(label_counts, label)
            label_counts(label) = label_counts(label) + 1;
        else
            label_counts(label) = 1;
        end
        numbered_labels{i} = sprintf('%s%d', label, label_counts(label));
    end
    
    % Organize all data into a single struct
    activities = struct();
    for i = 1:length(labels)
        activities(i).Label = numbered_labels{i};
        activities(i).StartTime = time_OEP(indices(i));
        activities(i).EndTime = time_OEP(indices(i+1));
        activities(i).Time = time_OEP(indices(i):indices(i+1));
        activities(i).AccX = accx(indices(i):indices(i+1));
        activities(i).AccY = accy(indices(i):indices(i+1));
        activities(i).AccZ = accz(indices(i):indices(i+1));
        activities(i).Pressure = pressure(indices(i):indices(i+1));
        activities(i).PressureAbs = pressure_abs(indices(i):indices(i+1));
        activities(i).gyroX = gyrox (indices(i):indices(i+1));
        activities(i).gyroY = gyroy (indices(i):indices(i+1));
        activities(i).gyroZ = gyroz (indices(i):indices(i+1));
    end
    % Plot for visualization
    figure;
    subplot(2, 1, 1);
    plot(time_OEP, pressure, '.-');
    ylim([-50, 50]);
    hold on;
    arrayfun(@(i) xline(time_points(i)), 1:length(time_points));
    
    subplot(2, 1, 2);
    plot(time_OEP, accx, '.-');
    hold on;
    plot(time_OEP, accy, '.-');
    plot(time_OEP, accz, '.-');
    ylim([-1.5, 3.2]);
    arrayfun(@(i) xline(time_points(i)), 1:length(time_points));
    arrayfun(@(i) text(time_points(i), -1.1, numbered_labels{i}), 1:length(labels));

end 

%%
function [SF1, SF2] = CheckSF(start, time_OEP, plotflag)
% CheckSF  Computes and optionally visualizes the sampling frequency of a signal.
%
%   [SF1, SF2] = CheckSF(start, time_OEP, plotflag)
%
%   Inputs:
%       start     : The starting index to analyze the time vector.
%       time_OEP  : A time vector in milliseconds (will be converted to seconds).
%       plotflag  : A flag (1 or 0) to enable or disable plotting for diagnostics.
%
%   Outputs:
%       SF1       : Sampling frequency calculated as the inverse of the mean time difference.
%       SF2       : Sampling frequency calculated as the number of samples divided by total time.
%
%   Example:
%       [SF1, SF2] = CheckSF(10, timeVector, 1);

    % Convert time from milliseconds to seconds
    time_OEP = time_OEP * 0.001;

    % Plot the time vector if plotflag is enabled
    if plotflag
        figure();
        plot(time_OEP, '*');                        % Plot the time vector with markers
        hold on;
        xline(start, 'r', LineWidth = 2);           % Highlight the starting index
        title('Time Vector with Starting Index');
        xlabel('Index');
        ylabel('Time (s)');
    end

    % Extract the portion of the time vector starting from the specified index
    T = time_OEP(start:end);

    % Calculate the sampling frequency (Method 1): 1 divided by the mean time difference
    SF1 = 1 / mean(diff(T));

    % Calculate the sampling frequency (Method 2): Total number of samples divided by total time
    SF2 = length(T) / (T(end) - T(1));

    % If plotflag is enabled, visualize the distribution of time differences
    if plotflag == 1
        figure();
        histogram(diff(T));                         % Plot a histogram of time differences
        xline(1/50, 'r', LineWidth = 2);            % Highlight a reference time difference (50 Hz)
        title('Histogram of Time Differences');
        xlabel('Time Difference (s)');
        ylabel('Frequency');
    end

    % Display the calculated sampling frequencies in the command window
    disp('Sampling Frequency (Method 1):');
    disp(SF1);
    disp('Sampling Frequency (Method 2):');
    disp(SF2);
end
function [breathsPerMin, peakTimes] = countBreathsPerMinute(time, pressure, varargin)
% countBreathsPerMinute estimates the respiration rate (breaths per minute) 
% from a sampled pressure/time series.
%
% USAGE:
%   [breathsPerMin, peakTimes] = countBreathsPerMinute(time, pressure)
%   [breathsPerMin, peakTimes] = countBreathsPerMinute(time, pressure, 'MinPeakProminence', 0.05)
%
% INPUTS:
%   - time:     1D array of time points (seconds, typically)
%   - pressure: 1D array of pressure measurements, same length as time
%
% OPTIONAL NAME-VALUE PAIRS:
%   - 'MinPeakProminence': Minimum prominence of detected peaks (default = 0.05)
%   - 'FilterCutoff':      Cutoff frequency in Hz for optional low-pass filtering (default = 2)
%                          (helps remove high-frequency noise above typical breathing frequencies)
%
% OUTPUTS:
%   - breathsPerMin: Estimated breathing rate in breaths per minute
%   - peakTimes:     Time points at which the function detected inhalation peaks
%
% EXAMPLE:
%   % Generate synthetic signal
%   fs       = 50;                            % 50 Hz sampling rate
%   t        = 0:1/fs:60;                     % 1 minute of data
%   pressure = sin(2*pi*0.25*t) + 0.1*randn(size(t)); % ~15 breaths per minute + noise
%   [bpm, pTimes] = countBreathsPerMinute(t, pressure, 'MinPeakProminence', 0.1);
%   fprintf('Estimated breathing rate: %.2f BPM\n', bpm);

    % -------------
    % Parse inputs
    % -------------
    p = inputParser;
    addRequired(p, 'time', @isnumeric);
    addRequired(p, 'pressure', @isnumeric);
    addParameter(p, 'MinPeakProminence', 0.05, @isnumeric);
    addParameter(p, 'FilterCutoff', 2, @isnumeric); % typical breathing < 1 Hz, allow some margin
    parse(p, time, pressure, varargin{:});
    
    minProminence = p.Results.MinPeakProminence;
    filterCutoff  = p.Results.FilterCutoff;

    % ---------------------------
    % Check length & orientation
    % ---------------------------
    if length(time) ~= length(pressure)
        error('Time and pressure vectors must be the same length.');
    end
    
    time     = time(:);
    pressure = pressure(:);
    
    % ----------------------------
    % Optional: low-pass filtering
    % ----------------------------
    % Estimate sampling frequency from time vector (assuming uniform sampling)
    dt = mean(diff(time));
    fs = 1/dt;
    
    % Design a simple low-pass filter (Butterworth) 
    % around "filterCutoff" Hz to remove high-frequency noise
    % (You can skip this step if your data is already relatively clean.)
    [b, a] = butter(4, filterCutoff / (fs/2), 'low');
    pressureFiltered = filtfilt(b, a, pressure);

    % -----------------
    % Detect the peaks
    % -----------------
    % 'MinPeakProminence' helps ignore small noise spikes.
    [pks, locs] = findpeaks(pressureFiltered, ...
                            'MinPeakProminence', minProminence);

    peakTimes = time(locs);

    % -----------------------------------------------------------------
    % Method 1: Directly compute total # of peaks / total duration (min)
    % -----------------------------------------------------------------
    totalDurationSec = time(end) - time(1);
    totalDurationMin = totalDurationSec / 60;
    
    numPeaks = length(locs);
    breathsPerMin = numPeaks / totalDurationMin;
    
    % ----------------------------------------------------------------
    % Method 2 (alternative): 
    %    Average time between peaks → BPM = 60 / average_intersummit_time
    % Commented out here, but can be used if you prefer an "instantaneous" 
    % measurement. Usually both approaches should be consistent if the 
    % data is stable.
    % ----------------------------------------------------------------
    % if numPeaks > 1
    %     peakIntervalsSec = diff(peakTimes);
    %     avgPeakIntervalSec = mean(peakIntervalsSec);
    %     breathsPerMin_alt = 60 / avgPeakIntervalSec;
    % else
    %     breathsPerMin_alt = NaN;
    % end
    
    % Output results:
    %  - breathsPerMin: (float) number of detected breaths per minute
    %  - peakTimes:     (array) time points at which peaks occur
end
