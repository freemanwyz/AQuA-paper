function [evtDtLst,evtDtPixLst] = anaExtractDt(rDt,mthdX,thrxx,sz)
    % anaFilterEvts choose events to report
    
    nNoise = numel(rDt);
    
    % filter detected events by z score
    evtDtLst = cell(nNoise,1);
    evtDtPixLst = cell(nNoise,1);
    for ii=1:nNoise
        evtDt = rDt{ii}.evt;
        switch(mthdX)
            case 'AQuA'
                evtDt = evtDt(rDt{ii}.fts.curve.dffMaxZ>=thrxx);
            case 'CaSCaDe'
                evtDt = evtDt(rDt{ii}.z>=thrxx & rDt{ii}.svm1_pk_class>0);
            otherwise
                evtDt = evtDt(rDt{ii}.z>=thrxx);
        end
        
        evtDtLst{ii} = evtDt;
        evtDtPix = cell(0);
        for jj=1:numel(evtDt)
            vox0 = evtDt{jj};
            [ih,iw,~] = ind2sub(sz,vox0);
            ihw = sub2ind([sz(1),sz(2)],ih,iw);
            ihw = unique(ihw);
            evtDtPix{jj} = ihw;
        end
        evtDtPixLst{ii} = evtDtPix;
    end   
    
end

