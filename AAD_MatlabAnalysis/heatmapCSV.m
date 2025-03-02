clc
clear 
close all
csvFile = 'results.csv';
%%
plotPhaseHeatmaps(csvFile,'breath_count_error_percentage', 'Breath count error percentage',[0, 0, 1], [1, 1, 1], [1, 0, 0]);

plotPhaseHeatmaps(csvFile,'expiration_error_percentage', 'Mean expiration error percentge',[1, 0.5, 0], [1, 1, 1], [0, 1, 0]);

