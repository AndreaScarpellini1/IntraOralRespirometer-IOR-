function [new_time_vector, new_data_vector, fs] = resampleTimeofData(time_vector, data_vector, start_index_time, start_index_data)
    % resampleTimeofData - Generates a new time vector based on a sampling frequency
    % calculated from a subset of the original time vector. The data is truncated
    % starting from a specified index.
    %
    % Syntax:  [new_time_vector, new_data_vector, fs] = resampleTimeofData(time_vector, data_vector, start_index_time, start_index_data)
    %
    % Inputs:
    %    time_vector - Original vector of time points.
    %    data_vector - Original vector of data points.
    %    start_index_time - Starting index for the subset of the time vector.
    %    start_index_data - Starting index for the subset of the data vector.
    %
    % Outputs:
    %    new_time_vector - New time vector based on the sampling frequency.
    %    new_data_vector - Truncated data vector, not resampled.
    %    fs - Calculated sampling frequency.


    % Calculate the time difference (deltaT)
    deltaT = abs(time_vector(start_index_time) - time_vector(end));
    
    % Determine the length of the subset of the time vector
    subset_length = size(time_vector(start_index_time:end));
    
    % Calculate the sampling frequency (fs)
    fs = subset_length(1) / deltaT;
    disp(['Sampling Frequency: ', num2str(fs)]);
    
    % Create the new data subset starting from the given start index
    new_data_vector = data_vector(start_index_data:end);
    
    % Generate the new time vector
    new_time_vector = linspace(0, (1/fs) * length(new_data_vector), length(new_data_vector));
end
