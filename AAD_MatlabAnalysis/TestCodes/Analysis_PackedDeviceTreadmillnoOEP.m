clc;
clear;
close all;

% Directory and file paths
directory = cd;
root = directory(1:end-length('\AAD_MatlabAnalysis'));
filefolder = fullfile(root, '\AAB_DataCollection\Try_PackedDevice');
%%
if isfolder(filefolder)
    name = dir(filefolder);
    start=1;
    fileIOR = readtable(fullfile(filefolder,name(4).name));
    [SF1, SF2] = CheckSF(1, fileIOR{start:end, 8}, 1);
    figure()
    time_OEP = fileIOR{start:end, 8} * 0.001;
    accx = fileIOR{start:end, 5};
    accy = fileIOR{start:end, 6};
    accz = fileIOR{start:end, 7};
    gyrox = fileIOR{start:end, 2};
    gyroy = fileIOR{start:end,3};
    gyroz = fileIOR{start:end,4};
    pressure = fileIOR{start:end, 1};
    pressure_abs = fileIOR{start:end, 9};
    subplot(2,1,1)
    plot(time_OEP,highPassFilter(pressure, 51, 0.1, 4))
    
    
    
    %%subplot(2,1,2)
    % L = length(pressure_abs); % Length of the signal
    % Y = fft(pressure_abs - mean(pressure_abs)); % FFT of the signal
    % P2 = abs(Y/L); % Two-sided spectrum
    % P1 = P2(1:L/2+1); % Single-sided spectrum
    % P1(2:end-1) = 2*P1(2:end-1);  % Double the amplitude except DC and Nyquist
    % [Fs, ~] = CheckSF(198, fileIOR{:, 8}, 0);
    % f = Fs*(0:(L/2))/L;           % Frequency vector   
    % plot(f, P1);
    % title('Single-Sided Amplitude Spectrum of Signal');
    % xlabel('Frequency (Hz)');
    % ylabel('|P1(f)|');
end 
%%

function filtered_signal = highPassFilter(signal, sampling_freq, cutoff_freq, filter_order)
    % HIGHPASSFILTER Applies a high-pass Butterworth filter to the input signal
    %
    % Inputs:
    %   - signal: The input signal to filter (vector)
    %   - sampling_freq: The sampling frequency of the signal (Hz)
    %   - cutoff_freq: The cutoff frequency of the high-pass filter (Hz)
    %   - filter_order: The order of the Butterworth filter
    %
    % Output:
    %   - filtered_signal: The filtered signal

    % Normalize the cutoff frequency (0 to 1, where 1 corresponds to Nyquist frequency)
    nyquist_freq = sampling_freq / 2;  % Nyquist frequency
    normalized_cutoff = cutoff_freq / nyquist_freq;

    % Design the Butterworth high-pass filter
    [b, a] = butter(filter_order, normalized_cutoff, 'high');

    % Apply the filter to the signal
    filtered_signal = filtfilt(b, a, signal);  % Zero-phase filtering

    % Optional: Plot the original and filtered signal for comparison
    % figure;
    % plot(signal, 'b'); hold on;
    % plot(filtered_signal, 'r', 'LineWidth', 1.5);
    % legend('Original Signal', 'Filtered Signal');
    % title('High-Pass Filtering');
    % xlabel('Sample Index');
    % ylabel('Amplitude');
    % grid on;
end

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