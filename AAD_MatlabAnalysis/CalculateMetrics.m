clc
clear 
close all 

directory = cd;
filefolder = fullfile(directory(1:end-length('\AAD_MatlabAnalysis')),'Data','OPTOvsIOR_Processed');
list_Of_files = dir(filefolder);
list_Of_files=list_Of_files(3:end);
plott = 1; 

for j = 1:length(list_Of_files) 
 
    Res_Cor = []; 
    Res =[];
    filepath  = fullfile(list_Of_files(j).folder,list_Of_files(j).name);
    load(filepath)
    
    %Adjust the th level based on the apnea 
    rootname = list_Of_files(j).name(1:4);
    if rootname == 'ANSC'
        th =0.5 ;
    elseif rootname == 'LNUR'
        th =0.2;
    elseif rootname == 'LCFS'
        th=0.2;
    elseif rootname == 'GVCL'
        th =0.3;
    end 

    disp(list_Of_files(j).name)
    disp(j)
    patterns = fieldnames(data.indices);
    
    if (data.phase == 'B')
        L = length(patterns)-1;
    else
        L = length(patterns);
    end 

    for i = 1:L


        y_pressure  = data.pressure_cleaned(data.indices.(patterns{i,1}));
        time = concatenate_time_chunks(data.commonTime, data.indices.(patterns{i,1}));
    
        [zeroCrossingIndices_pressure,...
         zeroCrossingTimes_pressure,...
         signedTimeIntervals_pressure,...
         signedAbsMaxValues_pressure,...
         absMaxIndices_pressure, ...
         zeroCrossingIndices_corrected_pressure,...
         zeroCrossingTimes_corrected_pressure,...
         signedTimeIntervals_corrected_pressure, ...
         signedAbsMaxValues_corrected_pressure,...
         absMaxIndices_corrected_pressure] = findZeroCrossingsWithSign(time, y_pressure,th);
          


        y_flow = data.flow_cleaned(data.indices.(patterns{i,1}));
        time =  concatenate_time_chunks(data.commonTime, data.indices.(patterns{i,1}));
        [zeroCrossingIndices_flow,...
         zeroCrossingTimes_flow,...
         signedTimeIntervals_flow,...
         signedAbsMaxValues_flow,...
         absMaxIndices_flow, ...
         zeroCrossingIndices_corrected_flow,...
         zeroCrossingTimes_corrected_flow,...
         signedTimeIntervals_corrected_flow, ...
         signedAbsMaxValues_corrected_flow,...
         absMaxIndices_corrected_flow] = findZeroCrossingsWithSign(time, y_flow,th);
        
        if plott == 0 
            figure(j)
            subplot(L,1,i)
            plot(time,y_pressure,'r')
            hold on 
            scatter(zeroCrossingTimes_corrected_pressure,0,'filled','r');
            yline(0)
            plot(time,y_flow,'b')
            hold on 
            scatter(zeroCrossingTimes_corrected_flow,0,'filled','b');
            title(patterns{i})
            yline(th)
            yline(-th)
        end 


        disp("--- Results --- ")
        disp((patterns{i,1}))
        results_corrected = analyze_breathing(signedTimeIntervals_corrected_pressure, signedTimeIntervals_corrected_flow,1);
   
        results = analyze_breathing(signedTimeIntervals_pressure, signedTimeIntervals_flow,0);
    
        disp("_____________________________________________")
        

        Res =[Res results];
        Res_Cor = [Res_Cor results_corrected];
    end 
    data.results = Res;
    data.resultscorrected = Res_Cor;
    save(filepath,'data');
end 


%%

function continuous_time = concatenate_time_chunks(time_vector, indices)
    % Concatenates time chunks while maintaining continuous time without jumps.
    %
    % INPUTS:
    % time_vector - A vector of time values.
    % indices     - A vector of indices representing continuous chunks of time.
    %
    % OUTPUT:
    % continuous_time - A vector without jumps
    
    % Extract the selected time points
    continuous_time = time_vector(indices);
    
    % Find gaps in the indices
    index_diff = diff(indices); 
    jump_locs = find(index_diff > 1); % Locations where there is a jump in indices
    
    
    % Adjust time after each jump
    for i = 1:length(jump_locs)
        jump_idx = jump_locs(i) + 1; % Start of the new segment
        
        % Compute the time step from the last continuous chunk
        prev_time_step = mean(diff(continuous_time(1:jump_idx-1))); 
        
        % Compute shift amount
        time_shift = continuous_time(jump_idx-1) + prev_time_step - continuous_time(jump_idx);
        
        % Apply shift to all subsequent time values
        continuous_time(jump_idx:end) = continuous_time(jump_idx:end) + time_shift;
    end
   
end

function bland_altman_plot(flow1, flow2, titleText)
    % BLAND_ALTMAN_PLOT Generates a Bland-Altman plot
    % Inputs:
    %   - flow1: First set of flow measurements (e.g., instrument)
    %   - flow2: Second set of flow measurements (e.g., OEP)
    %   - titleText: Title for the plot (optional)
    %
    % Example:
    %   bland_altman_plot(flow_instrument, flow_OEP, 'Flow Comparison')

    if nargin < 3
        titleText = 'Bland-Altman Plot';
    end

    % Compute the mean and difference
    meanValues = (flow1 + flow2) / 2;
    differences = flow1 - flow2;
    
    % Compute statistics
    meanDiff = mean(differences);
    stdDiff = std(differences);
    upperLoA = meanDiff + 1.96 * stdDiff; % Upper limit of agreement
    lowerLoA = meanDiff - 1.96 * stdDiff; % Lower limit of agreement

    % Create the plot
    figure;
    scatter(meanValues, differences, 'b', 'filled');
    hold on;
    
    % Plot mean difference line
    yline(meanDiff, 'k-', 'LineWidth', 2, 'Label', sprintf('Mean Diff: %.2f', meanDiff));
    
    % Plot limits of agreement
    yline(upperLoA, 'r--', 'LineWidth', 2, 'Label', sprintf('+1.96SD: %.2f', upperLoA));
    yline(lowerLoA, 'r--', 'LineWidth', 2, 'Label', sprintf('-1.96SD: %.2f', lowerLoA));

    % Formatting
    xlabel('Mean of Two Measurements');
    ylabel('Difference (Flow1 - Flow2)');
    title(titleText);
    grid on;
    hold off;
end
