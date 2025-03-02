function [flow, flow_time] = calculate_air_flow(volumes, time, fs, low_cutoff, high_cutoff)
    % Function to calculate the flow of air from volume data using a Butterworth bandpass filter
    %
    % Inputs:
    %   volumes - vector of volume values
    %   time - vector of time values corresponding to volume values
    %   fs - sampling frequency in Hz
    %   low_cutoff - low cutoff frequency for bandpass filter in Hz
    %   high_cutoff - high cutoff frequency for bandpass filter in Hz
    %
    % Outputs:
    %   flow - vector of flow values (L/s)
    %   flow_time - vector of time values corresponding to flow values

    % Ensure the time vector is the same length as the volume vector
    assert(length(volumes) == length(time), 'The length of volumes and time vectors must be the same.');

    % Calculate the time interval
    delta_t = 1 / fs;  % Time interval

    % Normalize the frequencies to the Nyquist frequency (fs/2)
    low_cutoff_norm = low_cutoff / (fs / 2);
    high_cutoff_norm = high_cutoff / (fs / 2);

    % Design a Butterworth bandpass filter
    [b, a] = butter(4, [low_cutoff_norm, high_cutoff_norm]);

    % Apply the filter to the volume data using filtfilt to avoid phase distortion
    filtered_volumes = filtfilt(b, a, volumes);

    % Calculate the flow
    delta_volumes = diff(filtered_volumes);
    flow = delta_volumes / delta_t;

    % Calculate the midpoints of the time intervals for the flow time vector
    flow_time = time(1:end-1) + diff(time) / 2;
end
