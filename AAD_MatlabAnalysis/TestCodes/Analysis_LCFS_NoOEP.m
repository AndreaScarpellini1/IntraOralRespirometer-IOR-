clc
clear 
close all
%%
name ="C:\Users\scrpa\OneDrive\POLIMI\Thesis_LaRes\SmartRetainer\AAB_DataCollection\ValidationDevice1LCFS\data_2025-02-09_13-39-40.csv";
fileIOR = readtable(name);

 baseline_index=firstNonZeroIndex(fileIOR{1:end, 1});
[SF1, SF2] = CheckSF(61, fileIOR{baseline_index:end, 8}, 0);
Fs = (SF1+SF2)/2;
time_OEP = fileIOR{baseline_index:end, 8} * 0.001;
accx = fileIOR{baseline_index:end, 5};
accy = fileIOR{baseline_index:end, 6};
accz = fileIOR{baseline_index:end, 7};
gyrox = fileIOR{baseline_index:end, 2};
gyroy = fileIOR{baseline_index:end,3};
gyroz = fileIOR{baseline_index:end,4};
pressure = fileIOR{baseline_index:end, 1};
pressure_abs = fileIOR{baseline_index:end, 9};

figure()
subplot(2,1,1)
plot(bandpass_filter(pressure_abs,Fs,0.1,10),'-*')
subplot(2,1,2)
plot(accx);
hold on
plot(accy);
plot(accz);
%%
function y = bandpass_filter(x, sf, fLow, fHigh)
% BANDPASS_FILTER Applies a band-pass Butterworth filter to a signal.
%
%   y = BANDPASS_FILTER(x, sf, fLow, fHigh)
% 
%   Inputs:
%       x       - Input signal (vector)
%       sf      - Sampling frequency (in Hz)
%       fLow    - Lower cutoff frequency (in Hz)
%       fHigh   - Upper cutoff frequency (in Hz)
%
%   Output:
%       y       - Filtered signal

    % Normalize frequencies to the Nyquist frequency
    nyq = sf / 2;
    Wn = [fLow, fHigh] / nyq;

    % Choose the order of the Butterworth filter
    filterOrder = 4;

    % Design a bandpass Butterworth filter
    [b, a] = butter(filterOrder, Wn, 'bandpass');

    % Use filtfilt for zero-phase filtering (recommended for most applications)
    y = filtfilt(b, a, x);
end
function [SF1, SF2] = CheckSF(baseline_index, time_OEP, plotflag)
% CheckSF  Computes and optionally visualizes the sampling frequency of a signal.
%
%   [SF1, SF2] = CheckSF(baseline_index, time_OEP, plotflag)
%
%   Inputs:
%       baseline_index     : The baseline_indexing index to analyze the time vector.
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
        xline(baseline_index, 'r', LineWidth = 2);           % Highlight the baseline_indexing index
        title('Time Vector with baseline_indexing Index');
        xlabel('Index');
        ylabel('Time (s)');
    end

    % Extract the portion of the time vector baseline_indexing from the specified index
    T = time_OEP(baseline_index:end);

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
function idx = firstNonZeroIndex(vec)
    % firstNonZeroIndex returns the index of the first nonzero element 
    % in 'vec'. If no nonzero element is found, it returns [].

    idx = find(vec ~= 0, 1);

    % If no index is found, idx will be empty
    if isempty(idx)
        idx = [];
    end
end

