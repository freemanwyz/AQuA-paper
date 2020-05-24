% alignment with NoRMCorreS

addpath(genpath('../NoRMCorre/'));

% foldername = 'D:\neuro_WORK\glia_kira\raw_proc\Mar14_Invivo\';
% f0 = {'2826451(4)_1_2_4x_reg_200um_dualwv-001_nr.tif'};

foldername = 'D:\OneDrive\projects\glia_kira\raw\GCaMP_May17\Lck_Gcamp with Aldh1l1-tdtomato\';
folderOut = 'D:\OneDrive\projects\glia_kira\raw_proc\GCaMP_May17\Lck_Gcamp with Aldh1l1-tdtomato\';
f0 = {'1_2_4x_reg_200um_dualwv-001_6.tif'};

%%
append = '_nr';

% register files one by one. use template obtained from file n to
% initialize template of file n + 1;
for ii=1:numel(f0)
    fileIn = [foldername,filesep,f0{ii}];
    FOV = size(read_file(fileIn,1,1));

    output_type = 'mat';
    options_mc = NoRMCorreSetParms('d1',FOV(1),'d2',FOV(2),'grid_size',[128,128],'init_batch',200,...
        'overlap_pre',32,'mot_uf',4,'bin_width',200,'max_shift',24,'max_dev',8,'us_fac',50,...
        'output_type',output_type);
    
    [M,shifts,template,options_mc,col_shift] = normcorre_batch_even(fileIn,options_mc,[]);
    
    [folder_name,file_name,~] = fileparts(fileIn);
    output_filename = fullfile(folderOut,[file_name,append,'.tif']);
    
    io.writeTiffSeq(output_filename,M,0);
end



