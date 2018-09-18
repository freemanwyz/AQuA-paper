function res = save4Suite2p(ops,db)
    % FIXME: support multiple files
    
    iplane = 1;
    ops = build_ops3(db, ops);
    fpath = sprintf('%s/F_%s_%s_plane%d.mat', ops.ResultsSavePath, ...
        ops.mouse_name, ops.date, iplane);
    x = load(fpath);
    ops = x.ops;
                
    nRoi = numel(x.stat);    
    roiLst = cell(nRoi,1);
    bdLst = cell(nRoi,1);
    [H,W] = size(ops.mimg);
    evtMap = zeros(H,W);
    for ii=1:nRoi
        if mod(ii,100)==0
            fprintf('%d\n',ii)
        end
        roi0 = x.stat(ii).ipix;
        evtMap(roi0) = ii;
        roiLst{ii} = roi0;
        map0 = zeros(H,W);
        map0(roi0) = 1;
        roi0Bd = bwboundaries(full(map0)>0);
        bdLst{ii} = roi0Bd;
    end
    
    res = [];
    res.dff = x.Fcell{1};
    res.dffDeconv = x.Fcell{1};
    res.dffDeconv1 = x.sp{1};
    res.opts = ops;
    res.bgMap = ops.mimg;
    res.bdLst = bdLst;
    res.roiLst = roiLst;
    res.evtMap = evtMap;
    res.db = db;
    
    %output_filename = [folderPrj,filesep,fDat,'_Suite2p.mat'];
    %save(output_filename,'res');
    
end