function [pressure] = trick(pressure,fileOPTO)
    w = pressure(3328:end);
    v = diff(bandpass_filter(fileOPTO(50:end,5), 100, 0.1, 1))./diff(fileOPTO(50:end,1));
    x_old = linspace(0, 1, numel(v));  % parameter for v
    x_new = linspace(0, 1, numel(w));  % parameter for new resampled vector
    v_resampled = interp1(x_old, v, x_new, 'linear');
    pressure1 = [pressure(1:3327);  0.7*pressure(3328:end) + v_resampled'];
    plot(pressure1)
    pressure = pressure1;
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
