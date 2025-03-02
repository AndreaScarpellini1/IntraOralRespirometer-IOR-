function results = analyze_breathing(signedTimeIntervals_pressure, signedTimeIntervals_flow, fprint)
    % Compute breath counts
    results.breath_count_pressure = length(signedTimeIntervals_pressure);
    results.breath_count_flow = length(signedTimeIntervals_flow);
    
    % Breath count difference and percentage error
    results.breath_count_difference = results.breath_count_pressure - results.breath_count_flow;
    results.breath_count_error_percentage = (results.breath_count_difference / results.breath_count_flow) * 100;

    % Compute total inspiration and expiration times
    results.totaltimeinspiration_pressure = sum(signedTimeIntervals_pressure(signedTimeIntervals_pressure > 0));
    results.totaltimeespiration_pressure = sum(signedTimeIntervals_pressure(signedTimeIntervals_pressure < 0));
    
    results.totaltimeinspiration_flow = sum(signedTimeIntervals_flow(signedTimeIntervals_flow > 0));
    results.totaltimeespiration_flow = sum(signedTimeIntervals_flow(signedTimeIntervals_flow < 0));
    
    % Compute mean and standard deviation for inspiration and expiration times
    inspiration_times_pressure = signedTimeIntervals_pressure(signedTimeIntervals_pressure > 0);
    expiration_times_pressure = signedTimeIntervals_pressure(signedTimeIntervals_pressure < 0);
    inspiration_times_flow = signedTimeIntervals_flow(signedTimeIntervals_flow > 0);
    expiration_times_flow = signedTimeIntervals_flow(signedTimeIntervals_flow < 0);
    
    results.mean_inspiration_pressure = mean(inspiration_times_pressure);
    results.std_inspiration_pressure = std(inspiration_times_pressure);
    results.mean_expiration_pressure = mean(expiration_times_pressure);
    results.std_expiration_pressure = std(expiration_times_pressure);
    
    results.mean_inspiration_flow = mean(inspiration_times_flow);
    results.std_inspiration_flow = std(inspiration_times_flow);
    results.mean_expiration_flow = mean(expiration_times_flow);
    results.std_expiration_flow = std(expiration_times_flow);
    
    % Compute percentage errors on the average values
    results.inspiration_error_percentage = ((results.mean_inspiration_pressure - results.mean_inspiration_flow) / abs(results.mean_inspiration_flow)) * 100;
    results.expiration_error_percentage = ((results.mean_expiration_pressure - results.mean_expiration_flow) / abs(results.mean_expiration_flow)) * 100;
    
    if fprint
        % Display results
        fprintf('Breath Count Difference (Pressure - Flow): %d (%.2f%% error)\n', ...
                results.breath_count_difference, results.breath_count_error_percentage);
        fprintf('Inspiration Time Difference (Pressure - Flow): %.4f sec (%.2f%% error)\n', ...
                results.mean_inspiration_pressure - results.mean_inspiration_flow, results.inspiration_error_percentage);
        fprintf('Expiration Time Difference (Pressure - Flow): %.4f sec (%.2f%% error)\n', ...
                results.mean_expiration_pressure - results.mean_expiration_flow, results.expiration_error_percentage);
        
        % Display mean and standard deviation results
        fprintf('Average Inspiration Time (Pressure): %.4f sec (std: %.4f)\n', ...
                results.mean_inspiration_pressure, results.std_inspiration_pressure);
        fprintf('Average Expiration Time (Pressure): %.4f sec (std: %.4f)\n', ...
                results.mean_expiration_pressure, results.std_expiration_pressure);
        fprintf('Average Inspiration Time (Flow): %.4f sec (std: %.4f)\n', ...
                results.mean_inspiration_flow, results.std_inspiration_flow);
        fprintf('Average Expiration Time (Flow): %.4f sec (std: %.4f)\n', ...
                results.mean_expiration_flow, results.std_expiration_flow);
        
        % Interpretation of overestimation vs underestimation
        if results.breath_count_difference > 0
            fprintf('Pressure OVERestimates breath count.\n');
        elseif results.breath_count_difference < 0
            fprintf('Pressure UNDERestimates breath count.\n');
        else
            fprintf('Pressure matches Flow in breath count.\n');
        end
        
        if results.mean_inspiration_pressure > results.mean_inspiration_flow
            fprintf('Pressure OVERestimates inspiration time.\n');
        elseif results.mean_inspiration_pressure < results.mean_inspiration_flow
            fprintf('Pressure UNDERestimates inspiration time.\n');
        else
            fprintf('Pressure matches Flow in inspiration time.\n');
        end
        
        if results.mean_expiration_pressure > results.mean_expiration_flow
            fprintf('Pressure OVERestimates expiration time.\n');
        elseif results.mean_expiration_pressure < results.mean_expiration_flow
            fprintf('Pressure UNDERestimates expiration time.\n');
        else
            fprintf('Pressure matches Flow in expiration time.\n');
        end
        fprintf('---------------------------------------------\n');
    end 
end
