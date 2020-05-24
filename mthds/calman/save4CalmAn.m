function res = save4CalmAn(A_keep,Cn,F_dff,F0,C_dec,S_dec,options)
    % FIXME: support multiple files
    
    nRoi = size(A_keep,2);
    roiLst = cell(nRoi,1);
    bdLst = cell(nRoi,1);
    [H,W] = size(Cn);
    for ii=1:nRoi
        if mod(ii,100)==0
            fprintf('%d\n',ii)
        end
        roi0 = A_keep(:,ii);
        roiLst{ii} = find(roi0);
        roi0 = reshape(roi0,H,W);
        roi0Bd = bwboundaries(full(roi0)>0);
        bdLst{ii} = roi0Bd;
    end
    
    res = [];
    res.dff = F_dff;
    res.f0 = F0;
    res.dffDeconv = C_dec;
    res.dffSpk = S_dec;
    res.bgMap = Cn;
    res.opts = options;
    res.bdLst = bdLst;
    res.roiLst = roiLst;
    
    %[folder_name,file_name,~] = fileparts(fileIn);
    %output_filename = fullfile(folder_name,[file_name,'_calman.mat']);
    %save(output_filename,'res');
    
end