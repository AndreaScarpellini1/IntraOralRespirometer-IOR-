clc
clear 
close all
%%
directory =  cd;
root  = directory(1:end-length('\AAD_MatlabAnalysis'));
filefolder = fullfile(root,'\AAA_InterfaceProcessing\Data_Device3');
figure()
if isfolder(filefolder)
    %Excels path
    
    excels = dir(filefolder);
    excels = excels(3:end);
    names ={excels(:).name};
    for fi = 2:2
        file = readtable(fullfile(filefolder,names{fi}));
        pressure_rel = file{:, 1};
        time  =  file{:, 8};
        
        subplot(2,1,1)
        plot(time,pressure_rel)
        hold on 
        
        pressure_rel_det = detrend_with_moving_window(pressure_rel,100);
        subplot(2,1,2)
        plot(time,pressure_rel_det)
        hold on 
    end 

end 

%%
filefolder = fullfile(root,'\AAA_InterfaceProcessing\Data1_Device1');
figure()
if isfolder(filefolder)
    %Excels path
    
    excels = dir(filefolder);
    excels = excels(3:end);
    names ={excels(:).name};
    for fi = 1:length(excels)
        file = readtable(fullfile(filefolder,names{fi}));
        pressure_rel = file{:, 1};
        time_stamp = file{:,8};
        
        subplot(2,1,1)
        plot(time_stamp,pressure_rel)
        hold on 
        
        pressure_rel_det = detrend_with_moving_window(pressure_rel,100);
        subplot(2,1,2)
        plot(time_stamp,pressure_rel_det)
        hold on 
    end 

end 

%%
function detrendedData = detrend_with_moving_window(data, windowSize)
    % Check if the input data is a row vector, if so, convert it to a column vector
    if isrow(data)
        data = data';
    end
    
    % Initialize the detrendedData array
    detrendedData = zeros(size(data));
    
    % Number of samples in the data
    numSamples = length(data);
    
    % Loop over each sample, moving the window one sample at a time
    for i = 1:numSamples
        % Determine the start and end indices of the window
        startIdx = max(1, i - floor(windowSize / 2));
        endIdx = min(numSamples, i + floor(windowSize / 2));
        
        % Extract the current window of data
        currentWindow = data(startIdx:endIdx);
        
        % Calculate the mean of the current window
        windowMean = mean(currentWindow);
        
        % Subtract the mean from the current sample
        detrendedData(i) = data(i) - windowMean;
    end
end
%%