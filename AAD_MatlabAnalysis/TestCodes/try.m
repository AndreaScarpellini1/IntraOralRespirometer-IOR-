clc
clear 
close all
directory = cd;

%%

% Deciding the file--------------------------------------------------------

nameRoot = 'ANSC_';
%1,3,4B; 4A
num =1;
phase = 'B'; 

% -------------------------------------------------------------------------
%--------------------------------------------------------------------------

[fileIOR,fileOPTO] = findFileInRepo(directory,nameRoot,num,phase);
[Sf,timeIOR,accx,accy,accz,gyrox,gyroy,gyroz,pressure] = IORValuesExtraction(fileIOR);
timeVol = fileOPTO(:, 1);      
Volume = fileOPTO(:,5);
Pressure = pressure;

figure()
plot(timeIOR,Pressure)
hold on
plot(timeIOR, circshift(Pressure,1));
legend('first','second')
xlim([116.33, 145])