clc
clear 
close all

directory =  cd;
root  = directory(1:end-length('\AAD_MatlabAnalysis'));
filefolder = fullfile(root,'\AAB_DataCollection\Validation_7_30_2024');
savefolder = fullfile(root,'Data/OPTOvsIOR1_Processed');
Data = [];
if isfolder(filefolder)
    % FIRST FILE ---------------------------------------------------------  
    % PRESSURE ------------------------------------------------------------
    clc
    excels = dir(filefolder);
    excels = excels(3:end);
    names ={excels(:).name};
    fileIOR = readtable(fullfile(filefolder,'ANSC1_Respirometer.csv'));
    fileEOP = load(fullfile(filefolder,'AnSc1.dat'));

    time_OEP = fileEOP(:,1);
    volume_OEP = fileEOP(:,5);
    [flow,flow_time]  = calculate_air_flow (volume_OEP,time_OEP,50,0.01,3);

    
    figure () 
    subplot(5,1,1)
    plot(flow,'b.') % Sampling 50 Hz 
    xline(949,'LineWidth',2)
    title("Flow")
   
    %----------------------------------------------------------------------
    % PRESSURE ------------------------------------------------------------
    

    % Pressure and time 
    pressure_rel = fileIOR{:, 1};
    time_IOR  =  fileIOR{:, 8}*0.001; %from ms to sec

    subplot(5,1,2)
    plot(pressure_rel,'r.') % Sampling 17 Hz 
    xline(634,'LineWidth',2)
    title('Pressure')
    
    [new_time_IOR, new_pressure_rel, fs] = resampleTimeofData(time_IOR, pressure_rel, 284, 634);
    subplot(5,1,3)
    plot(new_time_IOR,new_pressure_rel,'.')
    hold on 
    new_pressure_rel_plot = detrend_with_moving_window(new_pressure_rel, 200);
    %new_pressure_rel_plot2 = detrend_with_moving_window(new_pressure_rel, 50);
    plot(new_time_IOR,new_pressure_rel_plot,'.')
    %plot(new_time_IOR,new_pressure_rel_plot2,'.')
    yline(0,'k')
    title('Correct Pressure over time')
    
    [new_time_OEP, new_flow, fs] = resampleTimeofData(time_OEP, flow, 949, 949);
    subplot(5,1,4)
    plot(new_time_OEP,new_flow);
    new_flow_res = resampleOnTime(new_time_OEP, new_flow, new_time_IOR, 0);
    title('Correct Flow over time')
    
    new_pressure_rel =mapToRange(new_pressure_rel,-5,6);
    
    subplot(5,1,5)
    plot(new_time_IOR,new_flow_res,'b','LineWidth',2);
    hold  on 
    new_pressure_rel = detrend_with_moving_window(new_pressure_rel, 200);
    plot(new_time_IOR,new_pressure_rel,'r','LineWidth',2);
    xlim([0 160])
    ylim([-6 6])
    legend('flow','pressure')
   
    close  
    figure()
    plot(new_time_IOR,new_flow_res,'b','LineWidth',2);
    hold  on 
    new_pressure_rel = detrend_with_moving_window(new_pressure_rel, 200);
    plot(new_time_IOR,new_pressure_rel,'r','LineWidth',2);
    xlim([0 160])
    ylim([-6 6])
    legend('flow','pressure')
    FILE1 = [new_flow_res',new_pressure_rel];

    %----------------------------------------------------------------------
    % SECOND FILE ---------------------------------------------------------
    % PRESSURE ------------------------------------------------------------
    clc
    fileIOR = readtable(fullfile(filefolder,'ANSC2_Respirometer.csv'));
    fileEOP = load(fullfile(filefolder,'AnSc2.dat'));

    time_OEP = fileEOP(:,1);
    volume_OEP = fileEOP(:,5);
    [flow,flow_time]  = calculate_air_flow (volume_OEP,time_OEP,50,0.01,3);

    
    figure () 
    subplot(5,1,1)
    plot(flow,'b.') % Sampling 50 Hz 
    xline(1207,'LineWidth',2)
    title("Flow")
   






    %----------------------------------------------------------------------
    % PRESSURE ------------------------------------------------------------
    

    % Pressure and time 
    pressure_rel = fileIOR{:, 1};
    time_IOR  =  fileIOR{:, 8}*0.001; %from ms to sec

    subplot(5,1,2)
    plot(pressure_rel,'r.') % Sampling 17 Hz 
    xline(564,'LineWidth',2)
    title('Pressure')
    




    [new_time_IOR, new_pressure_rel, fs] = resampleTimeofData(time_IOR, pressure_rel, 564, 564);
    subplot(5,1,3)
    plot(new_time_IOR,new_pressure_rel,'.')
    hold on 
   
    new_pressure_rel_plot1 = detrend_with_moving_window(new_pressure_rel(1:1230), 250);
    new_pressure_rel_plot2 = detrend_with_moving_window(new_pressure_rel(1231:1616), 386);
    new_pressure_rel_plot3 = detrend_with_moving_window(new_pressure_rel(1617:2901), 1285);
    new_pressure_rel_plot4 = detrend_with_moving_window(new_pressure_rel(2902:3254), 10);
    new_pressure_rel_plot5 = detrend_with_moving_window(new_pressure_rel(3255:3729), 2);
    new_pressure_rel_plot6 = detrend_with_moving_window(new_pressure_rel(3730:end), 266);
    new_pressure_rel_plot = [new_pressure_rel_plot1',new_pressure_rel_plot2',new_pressure_rel_plot3',new_pressure_rel_plot4',new_pressure_rel_plot5',new_pressure_rel_plot6'];
    
    %new_pressure_rel_plot2 = detrend_with_moving_window(new_pressure_rel, 50);
    plot(new_time_IOR,new_pressure_rel_plot','.')
    %plot(new_time_IOR,new_pressure_rel_plot2,'.')
    yline(0,'k')
    title('Correct Pressure over time')
    
    [new_time_OEP, new_flow, fs] = resampleTimeofData(time_OEP, flow, 1207, 1207);
    subplot(5,1,4)
    plot(new_time_OEP,new_flow);
    new_flow_res = resampleOnTime(new_time_OEP, new_flow, new_time_IOR, 0);
    title('Correct Flow over time')
    
    new_pressure_rel =mapToRange(new_pressure_rel,-1,1);
   
    
    subplot(5,1,5)
    plot(new_time_IOR,new_flow_res,'b','LineWidth',2);
    hold  on 
    new_pressure_rel_plot1 = detrend_with_moving_window(new_pressure_rel(1:1230), 250);
    new_pressure_rel_plot2 = detrend_with_moving_window(new_pressure_rel(1231:1616), 386);
    new_pressure_rel_plot3 = detrend_with_moving_window(new_pressure_rel(1617:2901), 1285);
    new_pressure_rel_plot4 = detrend_with_moving_window(new_pressure_rel(2902:3254), 10);
    new_pressure_rel_plot5 = detrend_with_moving_window(new_pressure_rel(3255:3729), 2);
    new_pressure_rel_plot6 = detrend_with_moving_window(new_pressure_rel(3730:end), 266);
    new_pressure_rel_plot = [new_pressure_rel_plot1',new_pressure_rel_plot2',new_pressure_rel_plot3',new_pressure_rel_plot4',new_pressure_rel_plot5',new_pressure_rel_plot6'];
    plot(new_time_IOR,3*new_pressure_rel_plot,'r','LineWidth',2);
    xlim([0 200])
    ylim([-6 6])
    legend('flow','pressure')

    close  
    figure()
    plot(new_time_IOR,new_flow_res,'b','LineWidth',2);
    hold  on 
    new_pressure_rel_plot1 = detrend_with_moving_window(new_pressure_rel(1:1230), 250);
    new_pressure_rel_plot2 = detrend_with_moving_window(new_pressure_rel(1231:1616), 386);
    new_pressure_rel_plot3 = detrend_with_moving_window(new_pressure_rel(1617:2901), 1285);
    new_pressure_rel_plot4 = detrend_with_moving_window(new_pressure_rel(2902:3254), 10);
    new_pressure_rel_plot5 = detrend_with_moving_window(new_pressure_rel(3255:3729), 2);
    new_pressure_rel_plot6 = detrend_with_moving_window(new_pressure_rel(3730:end), 266);
    new_pressure_rel_plot = [new_pressure_rel_plot1',new_pressure_rel_plot2',new_pressure_rel_plot3',new_pressure_rel_plot4',new_pressure_rel_plot5',new_pressure_rel_plot6'];
    plot(new_time_IOR,3*new_pressure_rel_plot,'r','LineWidth',2);
    xlim([0 200])
    ylim([-6 6])
    legend('scaled flow','scaled pressure')

    FILE2 = [new_flow_res',new_pressure_rel_plot'];
end 

close all 
FILE2(2877:3233,2)=FILE2(2877:3233,2).*4;
FILE1= FILE1(1:3079,:);
FILE2= FILE2(1:3853,:);


save(fullfile(savefolder,'OPTvsIOR1.mat'),'FILE1')
save(fullfile(savefolder,'OPTvsIOR2.mat'),'FILE2')



