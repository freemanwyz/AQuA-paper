function [folderDat,fDat] = runCfg()
    
    selx = 3;
    
    datTop = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\';
        
    switch selx
        case 1
            folderDat = [datTop,'invivo_1x_reg_200\'];
            fDat = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';
        case 2
            folderDat = [datTop,'exvivo_baseline_009\'];
            fDat = 'FilteredNRMCCyto16m_slice2_Baseline3_L2 3-009cycle1channel1';
        case 3
            folderDat = [datTop,'exvivo_ttx_012\'];
            fDat = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';
        case 4
            folderDat = [datTop,'exvivo_baseline_015\'];
            fDat = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
    end
           
end