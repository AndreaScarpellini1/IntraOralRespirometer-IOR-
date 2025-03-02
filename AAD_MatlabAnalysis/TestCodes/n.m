clc
clear 
close all 
%%
%FILENAME = "C:\Users\scrpa\OneDrive\POLIMI\Thesis_LaRes\SmartRetainer\AAB_DataCollection\DataCollectionOPTOVvsIOR\ANSC\OPTO\AnSc_B2.tdf";
%[FREQUENCY,D,R,T,LABELS,LINKS,TRACKS] = tdfReadData3D (FILENAME);

file1 = "C:\Users\scrpa\OneDrive\POLIMI\Thesis_LaRes\SmartRetainer\AAB_DataCollection\DataCollectionOPTOVvsIOR\ANSC\OPTO\CalcoloVolumi\AnSc_B1.dat";
file2 = "C:\Users\scrpa\OneDrive\POLIMI\Thesis_LaRes\SmartRetainer\AAB_DataCollection\DataCollectionOPTOVvsIOR\ANSC\OPTO\CalcoloVolumi\AnSc_B4.dat";
file3 = "C:\Users\scrpa\OneDrive\POLIMI\Thesis_LaRes\SmartRetainer\AAB_DataCollection\DataCollectionOPTOVvsIOR\ANSC\OPTO\CalcoloVolumi\AnSc_B3.dat";
load(file1)
load(file2)
load(file3)
figure()
plot(AnSc_B4(:,1),AnSc_B4(:,5))
hold on 
plot(AnSc_B1(:,1),AnSc_B1(:,5))
plot(AnSc_B3(:,1),AnSc_B3(:,5))