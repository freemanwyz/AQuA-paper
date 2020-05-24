function fOut = getWorkPath(xType)
    
    if ~exist('xType','var')
        xType = 'try';
    end       

    topPathLst  = {
        'D:/OneDrive/',...
        'C:/Users/eric/OneDrive/',...
        '/Users/yizhi/OneDrive/',...
        './'
        };
    
    for ii=1:numel(topPathLst)
        if exist(topPathLst{ii},'dir')
            break
        end
    end
    
    projPath = [topPathLst{ii},'/'];
    aquaPathFd = [topPathLst{ii},'/glia_kira/se_aqua/'];
    outComeFd = [aquaPathFd,'/outcome/'];
        
    switch xType
        case 'try'
            fOut = aquaPathFd;
        case 'outcome'
            fOut = outComeFd;
        case 'proj'
            fOut = projPath;
    end
    
end