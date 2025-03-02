clc
clear 
close all 

directory = cd;
filefolder = fullfile(directory(1:end-length('\AAD_MatlabAnalysis')),'Data','OPTOvsIOR_Processed');
list_Of_files = dir(filefolder);
list_Of_files = list_Of_files(3:end); % Remove '.' and '..' entries
output_file = fullfile(directory, 'results.csv');

% Open file for writing
fid = fopen(output_file, 'w');

% Write headers to CSV file
fprintf(fid, 'Subject,Phase,Num,Condition,breath_count_pressure,breath_count_flow,breath_count_difference,breath_count_error_percentage,totaltimeinspiration_pressure,totaltimeespiration_pressure,totaltimeinspiration_flow,totaltimeespiration_flow,mean_inspiration_pressure,std_inspiration_pressure,mean_expiration_pressure,std_expiration_pressure,mean_inspiration_flow,std_inspiration_flow,mean_expiration_flow,std_expiration_flow,inspiration_error_percentage,expiration_error_percentage\n');

plott = 1; 
for j = 1:length(list_Of_files) 
    filepath  = fullfile(list_Of_files(j).folder, list_Of_files(j).name);
    load(filepath) % Load the 'data' struct
    
    % Extract subject and trial identifiers
    subject = list_Of_files(j).name(1:4);
    disp(subject)
    phase = list_Of_files(j).name(6);
    disp(phase)
    num  = list_Of_files(j).name(7);
    disp(num)
    patterns = fieldnames(data.indices);

    
    if data.phase == 'B'
        L = length(patterns) - 1;
    else
        L = length(patterns);
    end 

    for i = 1:L
        condition = patterns{i,1};
        disp(condition)
        % Extract data values
        breath_count_pressure = data.resultscorrected(i).breath_count_pressure;
        breath_count_flow = data.resultscorrected(i).breath_count_flow;
        breath_count_difference = data.resultscorrected(i).breath_count_difference;
        breath_count_error_percentage = data.resultscorrected(i).breath_count_error_percentage;
        totaltimeinspiration_pressure = data.resultscorrected(i).totaltimeinspiration_pressure;
        totaltimeespiration_pressure = data.resultscorrected(i).totaltimeespiration_pressure;
        totaltimeinspiration_flow = data.resultscorrected(i).totaltimeinspiration_flow;
        totaltimeespiration_flow = data.resultscorrected(i).totaltimeespiration_flow;
        mean_inspiration_pressure =data.resultscorrected(i).mean_inspiration_pressure;
        std_inspiration_pressure =data.resultscorrected(i).std_inspiration_pressure;
        mean_expiration_pressure =data.resultscorrected(i).mean_expiration_pressure;
        std_expiration_pressure =data.resultscorrected(i).std_expiration_pressure;
        mean_inspiration_flow =data.resultscorrected(i).mean_inspiration_flow;
        std_inspiration_flow =data.resultscorrected(i).std_inspiration_flow;
        mean_expiration_flow =data.resultscorrected(i).mean_expiration_flow;
        std_expiration_flow =data.resultscorrected(i).std_expiration_flow;
        inspiration_error_percentage =data.resultscorrected(i).inspiration_error_percentage; 
        expiration_error_percentage =data.resultscorrected(i).expiration_error_percentage;
        % Write data to CSV file
        fprintf(fid, '%s,%s,%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n', ...
            subject, phase, num, condition, ...
            breath_count_pressure, breath_count_flow, ...
            breath_count_difference, breath_count_error_percentage, ...
            totaltimeinspiration_pressure, totaltimeespiration_pressure, ...
            totaltimeinspiration_flow, totaltimeespiration_flow, ...
            mean_inspiration_pressure, std_inspiration_pressure, ...
            mean_expiration_pressure, std_expiration_pressure, ...
            mean_inspiration_flow, std_inspiration_flow, ...
            mean_expiration_flow, std_expiration_flow, ...
            inspiration_error_percentage, expiration_error_percentage);
    end
end

% Close the file
fclose(fid);

disp('Results saved to results.csv');
