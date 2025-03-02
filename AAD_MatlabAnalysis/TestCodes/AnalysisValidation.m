clc
clear 
close all

%%
directory =  cd;
root  = directory(1:end-length('\AAD_MatlabAnalysis'));
filefolder = fullfile(root,'\AAB_DataCollection\Validation_7_30_2024\Processed_Data\');
if isfolder(filefolder)
    clc
    file = dir(filefolder);
    file = file(3:end);
    names ={file(:).name};
    load(fullfile(filefolder,names{1}));
    load(fullfile(filefolder,names{2}));
    %for i = 1:2
        
    i =1;
    disp("--- Alignment-----")
    IOR_vect =mapToRange(DataIOR_Vector(i).pressure_rel,-4,4);
    EOP_vect = DataOEP_Vector(i).Flow;
    figure()
    plot(IOR_vect,'X-','Color','b')
    hold on 
    plot(EOP_vect,'X-','Color','r')
    ref_IOR = 634;
    ref_OEP = 950;
    xline(ref_IOR,'b');
    xline(ref_OEP,'r');
    offset = nan(abs(ref_IOR-ref_OEP),1);
    figure()
    plot([offset' IOR_vect'],'X-','Color','b')
    hold on 
    plot(EOP_vect,'X-','Color','r')

end 