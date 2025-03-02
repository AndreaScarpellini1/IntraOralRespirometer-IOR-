function [commonTime,alignedFlow,alignedPressure,Sf] = CommonTimeandSample(startVol,startPress,timeVol,timeIOR,Volume,Pressure)

    % --- 1. Adjust the time vectors using the given offsets ---
    timeVol    = timeVol - startVol;
    timePressure = timeIOR - startPress;

    % --- 2. Define a common time vector ---
    commonStart = max(min(timeVol), min(timePressure));
    commonEnd   = min(max(timeVol), max(timePressure));

    % Choose a time step. For example, use the smaller median dt of the two signals:
    dtFlow     = median(diff(timeVol));
    dtPressure = median(diff(timePressure));
    dt         = min(dtFlow, dtPressure);
    Sf = 1/dt;
    commonTime = (commonStart:dt:commonEnd)';  % column vector of times

    % --- 4. Remove duplicate sample points in timePressure ---
    [timePressureUnique, uniqueIdx] = unique(timePressure, 'stable');
    PressureUnique = Pressure(uniqueIdx);

    % --- 5. Interpolate each signal onto the common time grid ---
    alignedFlow     = interp1(timeVol, Volume, commonTime, 'linear', NaN);
    alignedPressure = interp1(timePressureUnique, PressureUnique, commonTime, 'linear', NaN);

end 

