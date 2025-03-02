clc;
clear;
close all;

% Directory and file paths
directory = cd;
root = directory(1:end-length('\AAD_MatlabAnalysis'));
filefolder = fullfile(root, '\AAB_DataCollection\Try_PackedDevice');

if isfolder(filefolder)
    name = dir(filefolder);
    start=1;
    fileIOR = readtable(fullfile(filefolder,name(3).name));
    figure()
 
    time_OEP = fileIOR{start:end, 8} * 0.001;
    accx = fileIOR{start:end, 5};
    accy = fileIOR{start:end, 6};
    accz = fileIOR{start:end, 7};
    gyrox = fileIOR{start:end, 2};
    gyroy = fileIOR{start:end,3};
    gyroz = fileIOR{start:end,4};
    pressure = fileIOR{start:end, 1};
    pressure_abs = fileIOR{start:end, 9};
    subplot(1,2,1)
    plot(time_OEP,pressure)
    subplot(1,2,2)
    plot(time_OEP,accx)
    hold on 
    plot(time_OEP,accy)
    plot(time_OEP,accz)
  
   
end 