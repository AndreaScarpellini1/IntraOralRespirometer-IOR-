clc
clear 
close all
directory = cd;
%

% Deciding the file--------------------------------------------------------
nameRoot = 'LNUR_';
% FILES: 12B; 123A
num =3;
phase = 'A'; 
% -------------------------------------------------------------------------
%--------------------------------------------------------------------------
[fileIOR,fileOPTO,pathIOR,~] = findFileInRepo(directory,nameRoot,num,phase);
%%

[Sf,timeIOR,accx,accy,accz,gyrox,gyroy,gyroz,pressure] = IORValuesExtraction(fileIOR);
timeVol = fileOPTO(:, 1);      
Volume = fileOPTO(:,5);
Pressure = pressure;


figure()
plot(timeIOR-53.82,bandpass_filter(Pressure, 80, 0.1, 10))
hold on 
plot(timeVol-14.2,Volume-mean(Volume),'.');
xline(255.42)
  
Pressure1 = Pressure;


%%
if (num==1 && phase =='A')
    startOEP = 9.58;
    startIOR = 34.161; 
    cutoffVol = 2;
    commontimestamps = [0,31.4,108.58,152.16,180.22,223.3];
elseif (num==2 && phase =='A')
    startOEP = 14.53;
    startIOR = 83.436;
    cutoffVol = 1; 
    commontimestamps = [0,40.25,107.68,204.7,267.48,295];
elseif(num==3 && phase =='A')
    startOEP =9.85 ;
    startIOR =48.2540 ; 
    cutoffVol = 2;   
    commontimestamps = [0, 39.61,97.77,198.33, 227.97, 263.27];

elseif(num==1 && phase =='B')
    startOEP =14.2 ;
    startIOR =53.82 ; 
    cutoffVol = 2;    
    commontimestamps = [0, 35.99,51.96,87.04,107.33,152.24,181.46,211.34,229.32,249];

elseif(num==2 && phase =='B')
    startIOR =61.702;
    startOEP = 9.39;
    cutoffVol = 2;   
    commontimestamps = [0, 33.16,44.66,76.77,91.75,112.78,142.99,175.58,187.24,213.95 ];
end 

[commonTime,alignedVolume,alignedPressure,Sf] = CommonTimeandSample(startOEP,startIOR,timeVol,timeIOR,Volume,Pressure);
[commonTime1,alignedVolume1,alignedPressure1,Sf1] = CommonTimeandSample(startOEP,startIOR,timeVol,timeIOR,Volume,Pressure1);


plott =1; 
if plott
    figure()
    plot(commonTime,alignedPressure);
    hold on 
    plot(commonTime,alignedVolume);
    legend('pressure','flow')
    xlim([0 300])
end 
close 
    
alignedPressure = bandpass_filter(alignedPressure, Sf, 0.1, 2);
alignedPressure = alignedPressure(1:end-1);
Pressure_clean = replaceOutlierWithNeighborAverage(alignedPressure,4);
    
alignedPressure1 = bandpass_filter(alignedPressure1, Sf, 0.1, 2);
alignedPressure1 = alignedPressure1(1:end-1);
Pressure_clean1 = replaceOutlierWithNeighborAverage(alignedPressure1,4);
% 

[Time,Flow]=fromVolumetoFlow(commonTime,alignedVolume,0.1,cutoffVol,Sf);
Flow_clean = replaceOutlierWithNeighborAverage(Flow,4);
commonTime = Time;
close all
%%
if (num==2 && phase =='B')
    Pressure_clean(2444:2561)  = 0.1.* Pressure_clean(2444:2561) + Flow_clean(2444:2561);
    Pressure_clean(4088:4271)  = 0.1.* Pressure_clean(4088:4271) + Flow_clean(4088:4271);
end 
if (num ==1 && phase=='B')
    Pressure_clean(24300:25400)  = 0.1.* Pressure_clean(24300:25400) + Flow_clean(24300:25400);
    Pressure_clean1(24300:25400)  = 0.1.* Pressure_clean1(24300:25400) + Flow_clean(24300:25400);
end 
%%
figure()
plot(Flow_clean,'b');
hold on 
plot(Pressure_clean,'r')
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
        [breathingRate, peakIndices] = calculateBreathingRateFreqBased(x, Sf,100,i,0.4);

    end 
end 
 

figure() 
scatter(Flow_clean,Pressure_clean,0.1)
axis equal
xlim([-4 4])
ylim([-4,4])
xline(0)
yline(0)
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
