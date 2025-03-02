function new_data = resampleOnTime(original_time, original_data, new_time, f)
    % Interpolate the original data at the new time points
    % interp1 performs 1-D interpolation (linear in this case)
    new_data = interp1(original_time, original_data, new_time, 'linear');

    if (f)  % Check if the plotting flag is set to true
        % Plot the original and resampled data
        figure;  % Create a new figure window
        plot(original_time, original_data, 'o-', 'DisplayName', 'Original Data');  % Plot original data
        hold on;  % Hold the current plot to add more data to it
        plot(new_time, new_data, 'x--', 'DisplayName', 'Resampled Data');  % Plot resampled data
        legend show;  % Show the legend with the display names
        xlabel('Time');  % Label the x-axis as 'Time'
        ylabel('Data');  % Label the y-axis as 'Data'
        title('Original and Resampled Data');  % Add a title to the plot
    end 
end
