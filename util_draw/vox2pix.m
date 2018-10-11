function pixLst = vox2pix(voxLst,sz)
    % Event list to footprint list
    
    nLst = numel(voxLst);
    pixLst = cell(nLst,1);
    for ii=1:nLst
        vox0 = voxLst{ii};
        [ih0,iw0,~] = ind2sub(sz,vox0);
        pixLst{ii} = unique(sub2ind(sz(1:2),ih0,iw0));        
    end
    
end