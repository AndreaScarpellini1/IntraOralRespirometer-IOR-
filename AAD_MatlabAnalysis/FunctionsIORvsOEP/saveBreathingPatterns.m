function saveBreathingPatterns(flow_cleaned, pressure_cleaned, commonTime, indices, phase, savedest, filename)
    % SAVE BREATHING PATTERNS STRUCTURE
    % This function organizes breathing patterns in a structured format and
    % saves it to a MAT-file.
    
    data.phase = phase;
    data.commonTime = commonTime;
    data.flow_cleaned = flow_cleaned;
    data.pressure_cleaned = pressure_cleaned;
    
    if phase == 'A'
        patterns = {'Still', 'Walking', 'Running'};
        data.indices.Still = [indices(1):indices(2),...
                              indices(5):indices(6)];
        data.indices.Walking = [indices(2):indices(3),...
                                indices(4):indices(5)];
        data.indices.Running = [indices(3):indices(4)];
    elseif phase == 'B'
        patterns = {'Spontaneous', 'RapidShallow', 'DeepSlow', 'Hyper', 'Apnea'};
        data.indices.Spontaneous = [indices(1):indices(2),... 
                                    indices(3):indices(4),...
                                    indices(5):indices(6),...
                                    indices(7):indices(8),...
                                    indices(9):indices(10)];
        data.indices.RapidShallow = [indices(4):indices(5)];
        data.indices.DeepSlow = [indices(6):indices(7)];
        data.indices.Hyper = [indices(8):indices(9)];
        data.indices.Apnea = [indices(2):indices(3)];
    else
        error('Unknown phase type. Must be "A" or "B".');
    end
    
    % Save the struct to a MAT file
    
    save(fullfile(savedest,filename), 'data');
    fprintf('Breathing patterns saved in %s\n', filename);
end
