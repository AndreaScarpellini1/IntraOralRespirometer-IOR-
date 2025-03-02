function plotPhaseHeatmaps(csvFile, parameter, titleStr, colorLow, colorMid, colorHigh)
    % Load the CSV file, ensuring proper header recognition
    opts = detectImportOptions(csvFile, 'PreserveVariableNames', true);
    data = readtable(csvFile, opts);

    % Check if the parameter exists in the table
    if ~ismember(parameter, data.Properties.VariableNames)
        error("Parameter '%s' not found in the CSV file.", parameter);
    end

    % Convert categorical or numerical columns to strings
    data.Subject = string(data.Subject);
    data.Phase = string(data.Phase);
    data.Condition = string(data.Condition);

    % Compute the mean for each (Subject, Phase, Condition) group to handle duplicates
    groupedData = groupsummary(data, {'Subject', 'Phase', 'Condition'}, 'mean', parameter);

    % Separate data for Phase A and Phase B
    phaseA = groupedData(groupedData.Phase == "A", :);
    phaseB = groupedData(groupedData.Phase == "B", :);

    % Extract unique subjects and conditions for each phase
    subjectsA = unique(phaseA.Subject);
    subjectsB = unique(phaseB.Subject);
    conditionsA = unique(phaseA.Condition);
    conditionsB = unique(phaseB.Condition);

    % Create matrices for Phase A
    phaseA_matrix = nan(numel(conditionsA), numel(subjectsA));
    for i = 1:numel(conditionsA)
        for j = 1:numel(subjectsA)
            idxA = find(phaseA.Subject == subjectsA(j) & phaseA.Condition == conditionsA(i));
            if ~isempty(idxA)
                phaseA_matrix(i, j) = phaseA.("mean_" + parameter)(idxA);
            end
        end
    end

    % Create matrices for Phase B
    phaseB_matrix = nan(numel(conditionsB), numel(subjectsB));
    for i = 1:numel(conditionsB)
        for j = 1:numel(subjectsB)
            idxB = find(phaseB.Subject == subjectsB(j) & phaseB.Condition == conditionsB(i));
            if ~isempty(idxB)
                phaseB_matrix(i, j) = phaseB.("mean_" + parameter)(idxB);
            end
        end
    end

    % Replace NaN values with 0 for better visualization
    phaseA_matrix(isnan(phaseA_matrix)) = 0;
    phaseB_matrix(isnan(phaseB_matrix)) = 0;

    % Determine symmetric color scale around zero
    max_abs_value = max(abs([phaseA_matrix(:); phaseB_matrix(:)]), [], 'omitnan');
    color_limits = [-max_abs_value, max_abs_value];

    % Define a customizable colormap
    custom_colormap = [linspace(colorLow(1), colorMid(1), 64)', linspace(colorLow(2), colorMid(2), 64)', linspace(colorLow(3), colorMid(3), 64)'; ...
                       linspace(colorMid(1), colorHigh(1), 64)', linspace(colorMid(2), colorHigh(2), 64)', linspace(colorMid(3), colorHigh(3), 64)'];

    % Create a figure with two subplots
    figure('Position',   [657.0000   49.8000-100  499.2000  828.8000]); % Adjust figure size

    % Subplot for Phase A
    subplot(2,1,1);
    h1 = heatmap(subjectsA, conditionsA, phaseA_matrix, 'Colormap', custom_colormap, 'ColorLimits', color_limits);
    h1.Title = ['Phase A - ' titleStr];
    h1.XLabel = 'Subjects';
    h1.YLabel = 'Conditions';
    h1.CellLabelFormat = '%.1f%%';
    h1.ColorbarVisible = 'on';
    h1.FontSize = 12;
    set(gca, 'Position', [0.1, 0.55, 0.8, 0.35]);

    % Subplot for Phase B
    subplot(2,1,2);
    h2 = heatmap(subjectsB, conditionsB, phaseB_matrix, 'Colormap', custom_colormap, 'ColorLimits', color_limits);
    h2.Title = ['Phase B - ' titleStr];
    h2.XLabel = 'Subjects';
    h2.YLabel = 'Conditions';
    h2.CellLabelFormat = '%.1f%%';
    h2.ColorbarVisible = 'on';
    h2.FontSize = 12;
    set(gca, 'Position', [0.1, 0.1, 0.8, 0.35]);

end

