clc
clear 
close all
directory = cd;

%%

% Deciding the file--------------------------------------------------------

nameRoot = 'ANSC_';
% FILES: 1,3,4B; 4 5A
num =3;
phase = 'B'; 

% -------------------------------------------------------------------------
%--------------------------------------------------------------------------

[fileIOR,fileOPTO,pathIOR,~] = findFileInRepo(directory,nameRoot,num,phase);
[Sf,timeIOR,accx,accy,accz,gyrox,gyroy,gyroz,pressure,Hr,stat] = IORValuesExtraction(fileIOR);

timeVol = fileOPTO(:, 1);      
Volume = fileOPTO(:,5);
Pressure = pressure;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Different Options -------------------------------------------------------
if (num==4 && phase =='B')
    startOEP = 1.2;
    startIOR = 32.984; 
    cutoffVol = 10;
    commontimestamps = [5.4,32.20, 52.83,81.07,111.83,175.2,236.99,266.67,295.84,325.74];
    colors = {'green','magenta','green','blue','green','red','green'};
elseif (num==4 && phase =='A')
    startOEP = 1.2;
    startIOR = 154.2;
    cutoffVol = 1; 
    commontimestamps = [6.35,46.67,111.7,209.35,272.32,301.89];
    colors = {'green','magenta','red','magenta','green'};
elseif(num==3 && phase =='B')
    startOEP = 2.52;
    startIOR = 38.2; 
    cutoffVol = 10;   
    commontimestamps = [5.52,40.03,52.83,84.2,113.99,161.71,221.14,251.96,284.17,315.25];
    colors = {'green','magenta','green','blue','green','red','green'};
    
elseif(num==1 && phase =='B')
    startOEP = 2.18;
    startIOR = 30.44; 
    cutoffVol = 10;
    commontimestamps = [6.5 38.58 55.4,85.39,115.5,166.6,227.01,256.4,287.76,323.38];
    colors = {'green','green','magenta','green','blue','green','red','green'};     

elseif(num==5 && phase =='A')
    startOEP = 9.06;
    startIOR = 69.079; 
    cutoffVol = 2;
    commontimestamps = [0,39.87,102.22,197.11,266,301.48];
    colors = {'green','magenta','red','magenta','green'};  
end 
%--------------------------------------------------------------------------
% -------------------------------------------------------------------------

[commonTime,alignedVolume,alignedPressure,Sf] = CommonTimeandSample(startOEP,startIOR,timeVol,timeIOR,Volume,Pressure);

plott =0; 
if plott
    figure()
    plot(commonTime,alignedPressure);
    hold on 
    plot(commonTime,alignedVolume)
    legend('pressure','flow')
    xline(301.08)
end 

alignedPressure = bandpass_filter(alignedPressure, Sf, 0.1, 8);
alignedPressure = alignedPressure(1:end-1);
Pressure_clean = replaceOutlierWithNeighborAverage(alignedPressure,4);
    
[Time,Flow]=fromVolumetoFlow(commonTime,alignedVolume,0.1,cutoffVol,Sf);
Flow_clean = replaceOutlierWithNeighborAverage(Flow,4);
commonTime = Time;



%%
close all
close 
figure()
plot(Pressure_clean)
hold on 
if num== 1 && phase == 'B'
    Flow_clean(16251:22681)  = bandpass_filter(Flow_clean(16251:22681), 100, 0.1, 1);
elseif num==3 && phase =='B'
    Flow_clean([1:8680,11654:25459,28676:end])  = bandpass_filter(Flow_clean([1:8680,11654:25459,28676:end]), 100, 0.1, 1);
end 
plot(Flow_clean)
xline(commontimestamps)
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
        plotLissajous(y,x,color{c},0,1,36,100)
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
clc
if phase == 'B'
    pattern = {'Apnea'};
    indices = findNearestIndices(commonTime, commontimestamps);
    x = Pressure_clean(indices(2):indices(3));
    y = Flow_clean(indices(2):indices(3));
    figure(1000)
    subplot(1,2,1)
    plotLissajous(y,x,'k',1,0,36,1000)
    xlabel("Flow")
    ylabel("Pressure")
    xlim([-6 6])
    ylim([-6 6])
    subplot(1,2,2)
    plot(x)
    hold on 
    plot(y)
    legend('pressure','flow')
    disp(max(x))
    disp(min(x))
end 
%%
close all
savedest = fullfile(directory(1:end-length('\AAD_MatlabAnalysis')),'\Data\OPTOvsIOR_Processed');
saveBreathingPatterns(Flow_clean, Pressure_clean, commonTime, indices, phase, savedest, strcat(nameRoot,phase,num2str(num),'processed'));

%% FUNCTIONS
function [f,P1] = SingleSidedSpectrum(new_p,Fs)
    L = length(new_p); % Length of the signal
    Y = fft(new_p); % FFT of the signal
    P2 = abs(Y/L); % Two-sided spectrum
    P1 = P2(1:L/2+1); % Single-sided spectrum
    P1(2:end-1) = 2*P1(2:end-1);  % Double the amplitude except DC and Nyquist
    f = Fs*(0:(L/2))/L;           % Frequency vector  
end 
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
