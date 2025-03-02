clc
clear 
close all
directory = cd;
%

% Deciding the file--------------------------------------------------------
nameRoot = 'LCFS_';
% FILES: 1B; 1A
num =1;
phase = 'B'; 
%
% -------------------------------------------------------------------------
%--------------------------------------------------------------------------
[fileIOR,fileOPTO,pathIOR,~] = findFileInRepo(directory,nameRoot,num,phase);

[Sf,timeIOR,accx,accy,accz,gyrox,gyroy,gyroz,pressure] = IORValuesExtraction(fileIOR);
timeVol = fileOPTO(:, 1);      
Volume = fileOPTO(:,5);
Pressure= pressure;

figure()
plot(timeIOR - 29.9379,bandpass_filter(Pressure, 80, 0.1, 10))
hold on 
plot(timeVol - 4.3,Volume-mean(Volume))


%%
startOEP = 4.3;
startIOR = 29.9379; 
cutoffVol = 3;
commontimestamps = [];
[commonTime,alignedVolume,alignedPressure,Sf] = CommonTimeandSample(startOEP,startIOR,timeVol,timeIOR,Volume,Pressure);


plott =1; 
if plott
    figure()
    plot(commonTime,alignedPressure);
    hold on 
    plot(commonTime,alignedVolume)
    legend('pressure','flow')
end 

alignedPressure = bandpass_filter(alignedPressure, Sf, 0.1, 8);
alignedPressure = alignedPressure(1:end-1);
Pressure_clean = replaceOutlierWithNeighborAverage(alignedPressure,3);
    
[Time,Flow]=fromVolumetoFlow(commonTime,alignedVolume,0.1,cutoffVol,Sf);
Flow_clean = replaceOutlierWithNeighborAverage(Flow,4);
commonTime = Time;
close all

figure()
plot(commonTime,Flow_clean);
hold on 
plot(commonTime,Pressure_clean)

commontimestamps = [6.26,45.33,64.46,99.86,134.07,156.43,198.47,227,246,278];
xline(commontimestamps)
%%
Pressure_clean(20002:20316)= 0.2.*Pressure_clean(20002:20316)+ Flow_clean(20002:20316);
Pressure_clean(872:1761)= 0.2.*Pressure_clean(872:1761)+ Flow_clean(872:1761);
Pressure_clean(23050:23236)= 0.2.*Pressure_clean(23050:23236)+ Flow_clean(23050:23236);
Pressure_clean(28245:end)= 0.2.*Pressure_clean(28245:end)+ Flow_clean(28245:end);
Pressure_clean(13768:14291)= 0.1.*Pressure_clean(13768:14291)+ Flow_clean(13768:14291);
%%
close all
figure()
Flow_clean([1:10492,13789:23244:25114])=bandpass_filter(Flow_clean([1:10492,13789:23244:25114]),100,0.1,1);
plot(Flow_clean);
hold on 
plot(Pressure_clean)
legend('flow','Pressure')
%%
commontimestamps = [6.26,45.33,64.46,99.86,134.07,156.43,198.47,227,246,278];
figure()
scatter(Flow_clean,Pressure_clean,0.1)
xlim([-4 4])
ylim([-4 4])
xline(0)
yline(0)
axis equal
if phase=='B'
    pattern = {'Spontaneous','RapidShallow','DeepSlow','Hyper'};     
    indices = findNearestIndices(commonTime, commontimestamps);
    figure(100)
    x = [];
    y = [];
    color = {[0, 1, 0],[.5 0 .5],[0, 0, 1], [1, 0, 0]};
    c= 0 ;
    for i = pattern
        c = c+1;
        if (strcmp(i,'Spontaneous'))
            x = Pressure_clean([indices(1):indices(2), ...
                                indices(3):indices(4), ...
                                indices(5):indices(6), ...
                                indices(7):indices(8), ...
                                indices(9):indices(10)]);
            y = Flow_clean([indices(1):indices(2), ...
                                indices(3):indices(4), ...
                                indices(5):indices(6), ...
                                indices(7):indices(8), ...
                                indices(9):indices(10)]);
        elseif  (strcmp(i,'RapidShallow'))
            x = Pressure_clean(indices(4):indices(5));
            y = Flow_clean(indices(4):indices(5));
        elseif  (strcmp(i,'DeepSlow'))
            x = Pressure_clean(indices(6):indices(7));
            y = Flow_clean(indices(6):indices(7));
        elseif  (strcmp(i,'Hyper'))
            x = Pressure_clean(indices(8):indices(9));
            y = Flow_clean(indices(8):indices(9));
        end 
        if c==1
            pl =1;
        elseif c==2
            pl =2;
        elseif c==3
            pl =4;
        elseif c==4
            pl =5;
        end 
        subplot(2,3,pl)
        plotLissajous(y,x,color{c},1,1,36,100)
        xlabel('Flow [L/s]')
        ylabel('Pressure [cmH20]')
        axis equal
        xlim([-7 7])
        ylim([-7 7])
        title(i)
        
        if c==1
            pl =3;
        elseif c==2
            pl =6;
        elseif c==3
            pl =9;
        elseif c==4
            pl =12;
        end 
        subplot(4,3,pl)
        [breathingRate, peakIndices] = calculateBreathingRateFreqBased(x, Sf,100,i,0.8);

    end 
end
%%
close all
savedest = fullfile(directory(1:end-length('\AAD_MatlabAnalysis')),'\Data\OPTOvsIOR_Processed');
saveBreathingPatterns(Flow_clean, Pressure_clean, commonTime, indices, phase, savedest, strcat(nameRoot,phase,num2str(num),'processed'));


%%
function y = bandpass_filter(x, sf, fLow, fHigh)
% BANDPASS_FILTER Applies a band-pass Butterworth filter to a signal.
%
%   y = BANDPASS_FILTER(x, sf, fLow, fHigh)
% 
%   Inputs:
%       x       - Input signal (vector)
%       sf      - Sampling frequency (in Hz)
%       fLow    - Lower cutoff frequency (in Hz)
%       fHigh   - Upper cutoff frequency (in Hz)
%
%   Output:
%       y       - Filtered signal

    % Normalize frequencies to the Nyquist frequency
    nyq = sf / 2;
    Wn = [fLow, fHigh] / nyq;

    % Choose the order of the Butterworth filter
    filterOrder = 4;

    % Design a bandpass Butterworth filter
    [b, a] = butter(filterOrder, Wn, 'bandpass');

    % Use filtfilt for zero-phase filtering (recommended for most applications)
    y = filtfilt(b, a, x);
end
function [time, derivative] = fromVolumetoFlow(time,volume,fLow,fHigh,fs)
    volfilt = bandpass_filter(volume, fs, fLow, fHigh);
    derivative = diff(volfilt) ./ diff(time);
    time = time(1:end-1);
    derivative = -derivative;
end



