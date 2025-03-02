function [modified_pressure,pres_idx] = trick2(vol_start, vol_end,pres_start,pres_end,timeVol,Volume, timeIOR,pressure, p,pp,h)
    % Define sampling frequencies
    Fs_vol = 100;  % Volume signal sampled at 100 Hz
    Fs_pres = 80;  % Pressure signal sampled at 80 Hz
        
    % Extract Volume segment
    vol_idx = timeVol >= vol_start & timeVol <= vol_end;
    vol_segment = Volume(vol_idx);
    time_vol_segment = timeVol(vol_idx);
    time_vol_segment = bandpass_filter(time_vol_segment, 100, 0.2, 5);
    % Compute dominant frequency using FFT
    L = length(vol_segment);
    Y = fft(vol_segment);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs_vol * (0:(L/2)) / L;
    
    
    % Find peak frequency
    [~, idx_max] = max(P1);
    dominant_freq = f(idx_max);
    
    % Plot the frequency spectrum
    figure;
    plot(f, P1, 'LineWidth', 2);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    title('Dominant Frequency in Volume Signal');
    hold on 
    grid on;
    scatter(0.27,0.39,'r','filled')
    
    % Find the two highest peaks
    [sortedPeaks, sortedIdx] = sort(P1, 'descend'); % Sort amplitudes in descending order
    second_max_freq = f(sortedIdx(2)); % Second highest frequency
    dominant_freq = 1.38;
    disp(dominant_freq)
    disp(dominant_freq)
    % Extract Pressure segment
    pres_idx = timeIOR >= pres_start & timeIOR <= pres_end;
    pressure_segment = pressure;
    pressure_segment = pressure_segment(pres_idx);
    time_pres_segment = timeIOR(pres_idx);
    
    % Generate sinusoidal wave with dominant frequency
    sin_wave = 0.5 * max(pressure_segment) * sin(2 * pi * dominant_freq * (time_pres_segment - time_pres_segment(1)));
    
    % Add sinusoidal wave to pressure segment
    modified_pressure =pp*pressure_segment + h*sin_wave;
    modified_pressure = modified_pressure-mean(modified_pressure);
    if  p 
        % Plot results
        figure;  
        % Plot Volume signal with interval
        subplot(2,1,1);
        plot(timeVol, Volume);
        hold on;
        xlim([vol_start vol_end]);
        title('Volume Signal and Interval');
        xlabel('Time (s)');
        ylabel('Volume');
        hold off;
        
        % Plot Pressure signal with modified segment
        subplot(2,1,2);
        plot(timeIOR, bandpass_filter(pressure, Fs_pres, 0.1, 10));
        hold on;
        plot(time_pres_segment, modified_pressure, 'r', 'LineWidth', 1.5);
        xlim([pres_start pres_end]);
    end 
end 
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