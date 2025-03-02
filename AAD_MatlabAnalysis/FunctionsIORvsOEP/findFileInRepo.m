function [fileIOR, fileOPTO,pathFileIOR, pathFileOEP ] =  findFileInRepo(directory,nameRoot,num,phase)

% This function works for "SmartRetainer"
% Andrea Scarpellini 
% OUTPUT:
% fileIOR:Intra Oral file 
% fileOPTO: Volumes file 

    root = directory(1:end-length('\AAD_MatlabAnalysis'));
    filefolderIOR = fullfile(root, strcat('\AAB_DataCollection\DataCollectionOPTOVvsIOR\',nameRoot(1:end-1),'\IOR\'));
    filefolderOPTO = fullfile(root, strcat('\AAB_DataCollection\DataCollectionOPTOVvsIOR\',nameRoot(1:end-1),'\OPTO\'));
    
    nameIOR = dir(filefolderIOR);
    nameOPTO = dir(filefolderOPTO);
    
    nameFileIOR = strcat(nameRoot,phase,num2str(num),'.csv');
    nameFileOPTO = strcat(nameRoot,phase,num2str(num),'.dat');
    
    indexOPTO = find(contains({nameOPTO(:).name},nameFileOPTO));
    indexIOR = find(contains({nameIOR(:).name},nameFileIOR));
    
    pathFileIOR = fullfile(filefolderIOR,nameFileIOR);
    pathFileOEP = fullfile(filefolderOPTO,nameFileOPTO);
    fileOPTO = load(fullfile(filefolderOPTO,nameFileOPTO));
    fileIOR = readtable(fullfile(filefolderIOR,nameFileIOR));
end 