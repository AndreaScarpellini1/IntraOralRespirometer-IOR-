clc
clear 
close all
%%
directory =  cd;
root  = directory(1:end-length('\AAD_MatlabAnalysis'));
filefolder = fullfile(root,'\AAB_DataCollection\Validation_7_30_2024');
figure()
DataOEP_Vector = [];
Data_Vector = []; 
DataIOR_Vector = [];
if isfolder(filefolder)
    %Excels path
    clc
    excels = dir(filefolder);
    excels = excels(3:end);
    names ={excels(:).name};
  
    for fi = 1:length(names)
        if(strcmp(names{fi},'ANSC1_Respirometer.csv') || strcmp(names{fi},'ANSC2_Respirometer.csv'))
            
            Data = struct('Name', '','Time',[], 'pressure_rel', [], 'pressure_rel_det', [],'SampleStartBaseline',[]);
            disp(names{fi})
            file = readtable(fullfile(filefolder,names{fi}));
            pressure_rel = file{:, 1};
            time_IOR  =  file{:, 8}*0.001; %from ms to sec
            Data.Time = time_IOR;
            if(fi==1)
               Data.SampleStartBaseline=283;
            elseif (fi==2)
               Data.SampleStartBaseline=237;
            end 

            % Calculate the sampling frequency in two different methods 
            fs1 = 1 / mean(diff(time_IOR));
            fs2 = ((time(end)-time(1))/(length(time_IOR)-1))^(-1);
            disp(fs1)
            disp(fs2)

            if(fi==1)
                pressure_rel_det = detrend_with_moving_window(pressure_rel,200);
            elseif(fi==2)
                pressure_rel_det = detrend_with_moving_window(pressure_rel,25);
            end 
            subplot(2,1,fi)
            plot(pressure_rel_det)
            hold on 
            linkaxes
            title(strcat('ANSC',num2str(fi)));

            Data.Name = names{fi};
            Data.pressure_rel = pressure_rel;
            Data.pressure_rel_det = pressure_rel_det;

            DataIOR_Vector = [DataIOR_Vector, Data];
        end 
    end
%%
    figure()
    count = 0;
    for fi = 1:length(names)
        names ={excels(:).name};
        if(strcmp(names{fi},'AnSc1.dat') || strcmp(names{fi},'AnSc2.dat'))
            Data = struct('Name', '','SF',[],'Time',[], 'DataVolume', [],'Flow',[]);

            count = count +1;
            disp(names{fi});
            AnSc = load(fullfile(filefolder,names{fi}));
            time_OEP = AnSc(:,1);
            volume_OEP = AnSc(:,5);

            Data.Name = names{fi};
            Data.Time = time_OEP;
            Data.DataVolume = volume_OEP;
            Data.SF =50;           
            flow  = calculate_air_flow (volume_OEP,50,0.01,3);
            Data.Flow = flow;

            %resampling 
            resampled_flow = resample_data(flow,50,17);
            Data.resampled_flow = resampled_flow;


            subplot(2,1,count);
            plot(resampled_flow);
           
            DataOEP_Vector = [DataOEP_Vector, Data];
        end 
    end 
end
savePath = fullfile(root,'\AAB_DataCollection\Validation_7_30_2024\Processed_Data\');
save(strcat(savePath,'DataEOP'),'DataOEP_Vector');
save(strcat(savePath,'DataIOR'),'DataIOR_Vector');




%% Functions 
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
