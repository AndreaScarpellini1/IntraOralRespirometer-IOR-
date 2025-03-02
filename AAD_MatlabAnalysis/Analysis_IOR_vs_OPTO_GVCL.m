clc
clear 
close all
directory = cd;
%

% Deciding the file--------------------------------------------------------
nameRoot = 'GVCL_';
% FILES: 1B; 1A
num =1;
phase = 'B'; 
% -------------------------------------------------------------------------
%--------------------------------------------------------------------------
[fileIOR,fileOPTO,pathIOR,~] = findFileInRepo(directory,nameRoot,num,phase);
[Sf,timeIOR,accx,accy,accz,gyrox,gyroy,gyroz,pressure] = IORValuesExtraction(fileIOR);


% [fileIOR1,fileOPTO1,pathIOR1,~] = findFileInRepo(directory,nameRoot,2,phase);
% [~,~,~,~,~,~,~,~,pressure1] = IORValuesExtraction(fileIOR1);

timeVol = fileOPTO(:, 1);      
Volume = fileOPTO(:,5);
Pressure= pressure;
figure()

plot(timeVol-2.6800, Volume);
hold on 
plot(timeIOR-46.3270,Pressure,'r')


%%
if (num==1 && phase =='A')
    startOEP =2.6800;
    startIOR = 46.3270; 
    cutoffVol = 1;
    commontimestamps = [0,52.585,79.975,133.712,218.849,269.053,303.447];

elseif(num ==1 && phase == 'B')
    startOEP = 12.03;
    startIOR = 156.0882; 
    cutoffVol = 2; 
    commontimestamps = [0,36.13,49.05,80.7,97.33,122.78,159.27,181.18,200.74,215.28];
end 

[commonTime,alignedVolume,alignedPressure,Sf] = CommonTimeandSample(startOEP,startIOR,timeVol,timeIOR,Volume,Pressure);
%%
plott =0; 
if plott
    figure()
    plot(commonTime,alignedPressure);
    hold on 
    plot(commonTime,alignedVolume)
    legend('pressure','flow')
    xlim([0 250])
    xline(34.67)
end
close all
%%

[Time,Flow]=fromVolumetoFlow(commonTime,alignedVolume,0.1,cutoffVol,Sf);
Flow_clean = replaceOutlierWithNeighborAverage(Flow,4);
commonTime = Time;

alignedPressure = bandpass_filter(alignedPressure, Sf, 0.1, 8);
alignedPressure = alignedPressure(1:end-1);
Pressure_clean = replaceOutlierWithNeighborAverage(alignedPressure,3);
%%

%%

close all
figure()
plot(commonTime,Flow_clean)
hold on 
plot(commonTime,Pressure_clean)
legend('flow','pressure')


%%
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
if phase=='A'
    pattern = {'Still','Walking','Running'};     
    indices = findNearestIndices(commonTime, commontimestamps);
    figure()
    x = [];
    y = [];
    color = {[0, 1, 0],[0, 0, 1], [1, 0, 0]};
    c= 0 ;
    for i = pattern
        c = c+1;
        if (strcmp(i,'Still'))
            x = Pressure_clean([indices(1):indices(2), ...
                                indices(5):indices(6)]);
            y = Flow_clean([indices(1):indices(2), ...
                                indices(5):indices(6)]);
        elseif  (strcmp(i,'Walking'))
            x = Pressure_clean([indices(2):indices(3),...
                                indices(4):indices(5)]);
            y = Flow_clean([indices(2):indices(3),...
                                indices(4):indices(5)]);
        elseif  (strcmp(i,'Running'))
            x = Pressure_clean(indices(3):indices(4));
            y = Flow_clean(indices(3):indices(4));
        end 
        figure(100)
        subplot(1,2,1)
        plotLissajous(y,x,color{c},1,1,36,100)
        axis equal
        xlim([-4 4])
        ylim([-4 4])
        xlabel('Flow [L/s]')
        ylabel('Pressure [cmH20]')
        hold on 
        figure(11+c)
        results = compute_resistance(y, x,11+c);        

        figure(100)
        if c==1
            pl=2;
        elseif c==2
            pl=4;
        elseif c==3
            pl=6;
        end 
        subplot(3,2,pl)
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
function optimalShift = findOptimalShift(signal1, signal2)
    % FINDOPTIMALSHIFT Finds the best circular shift to align two signals
    % Usage: optimalShift = findOptimalShift(signal1, signal2)
    %
    % INPUTS:
    %   signal1 - Reference signal
    %   signal2 - Signal to be aligned
    %
    % OUTPUT:
    %   optimalShift - Number of samples to shift signal2 to best align with signal1

    % Compute cross-correlation
    [corr, lags] = xcorr(signal2, signal1, 'coeff');

    % Find the lag corresponding to the maximum correlation
    [~, maxIdx] = max(corr);
    optimalShift = lags(maxIdx);
end
function [signal1, correctedSignal2, shifts] = alignAndPlotLissajous(signal1, signal2, windowPercentage)
    % ALIGNANDPLOTLISSAJOUS Aligns signal2 to signal1 in windows and returns shifts
    % Usage: [signal1, correctedSignal2, shifts] = alignAndPlotLissajous(signal1, signal2, 10);
    
    if nargin < 3
        windowPercentage = 10; % Default to 10% if not provided
    end

    signalLength = length(signal1);
    windowSize = round((windowPercentage / 100) * signalLength);
    numWindows = floor(signalLength / windowSize);
    correctedSignal2 = signal2; % Initialize corrected signal
    shifts = zeros(1, numWindows); % Store shifts

    % Compute and apply optimal shift for each window
    for i = 1:numWindows
        startIdx = (i-1) * windowSize + 1;
        endIdx = min(startIdx + windowSize - 1, signalLength);

        % Extract windowed segments
        segment1 = signal1(startIdx:endIdx);
        segment2 = signal2(startIdx:endIdx);

        % Compute optimal shift for the current window
        shift = findOptimalShift(segment1, segment2);
        shifts(i) = shift;

        % Apply circular shift to the corresponding segment
        correctedSignal2(startIdx:endIdx) = circshift(segment2, -shift);
    end
end

