figure()
subplot(2,1,1)
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
subplot(2,3,4)
plot(new_time_IOR(1231:1616),3*new_pressure_rel_plot2,'r',LineWidth=1)
hold on
plot(new_time_IOR(1231:1616),new_flow_res(1231:1616),'b','LineWidth',1);
ylim([-6 6])
legend('flow','pressure')

subplot(2,3,5)
plot(new_time_IOR(2902:3254),3*new_pressure_rel_plot4,'r',LineWidth=1)
hold on
plot(new_time_IOR(2902:3254),new_flow_res(2902:3254),'b','LineWidth',1);
ylim([-6 6])
legend('flow','pressure')
subplot(2,3,6)
plot(new_time_IOR(3255:3729),3*new_pressure_rel_plot5,'r',LineWidth=1)
hold on
plot(new_time_IOR(3255:3729),new_flow_res(3255:3729),'b','LineWidth',1);
ylim([-6 6])
legend('flow','pressure')