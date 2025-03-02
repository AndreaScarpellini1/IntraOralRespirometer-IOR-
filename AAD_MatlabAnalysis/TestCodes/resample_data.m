function resampled_vector = resample_data(original_vector, original_fs, target_fs)
    % Function to resample a vector of numbers from original_fs to target_fs
    %
    % Inputs:
    %   original_vector - vector of original data
    %   original_fs - original sampling frequency in Hz
    %   target_fs - target sampling frequency in Hz
    %
    % Output:
    %   resampled_vector - resampled vector at target_fs

    % Calculate the resampling factor
    [P, Q] = rat(target_fs / original_fs);

    % Resample the data
    resampled_vector = resample(original_vector, P, Q);
end
