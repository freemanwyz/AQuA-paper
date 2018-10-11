function [datOut,evtSpk] = addSparkling(datSim,p)
    % add sparklings to generated events
    % Duration is 3, intensity is 0.2
    
    szx = p.sparklingSz; 
    szRg = min(szx):max(szx);
    datOut = datSim;
    [H,W,T] = size(datSim);
    evtMap = zeros(H,W,T);    
    spkNum = p.sparklingDensity*T/numel(szRg);
    diTmp = 5;
    
    cnt = 1;
    for nn=1:numel(szRg)  % sparklings of different sizes
        fprintf('Sparkling size %d\n',szRg(nn))
        hRg = ceil(sqrt(szRg(nn)));
        hx = floor(hRg/2);
        diSpa = hx+5;
        
        strDi = ones(diSpa*2+1,diSpa*2+1,diTmp*2+1);
        mskDi = imdilate(datOut>0,strDi);
        
        mskBd0 = true(H,W);
        mskBd0(hRg+1:H-hRg,hRg+1:W-hRg) = false;
        mskDi = mskDi | mskBd0;
        mskDi(:,:,1:5) = 1;
        mskDi(:,:,end-4:end) = 1;
        
        for ii=1:spkNum            
            % search the location to put sparklings
            for jj=1:1000
                ih = randi(H); iw = randi(W); it = randi(T);
                %pix = sub2ind([H,W,T],h0,w0,t0);
                if mskDi(ih,iw,it)==0
                    break
                end
            end
            if jj==1000
                break
            end
            
            rgh0 = max(ih-hx,1):min(ih+hx,H);
            rgw0 = max(iw-hx,1):min(iw+hx,W);
            rgt0 = max(it-1,1):min(it+1,T);
            datOut(rgh0,rgw0,rgt0) = 0.2;
            evtMap(rgh0,rgw0,rgt0) = cnt;
            cnt = cnt + 1;
            
            rgh1 = max(ih-2*hx-3,1):min(ih+2*hx+3,H);
            rgw1 = max(iw-2*hx-3,1):min(iw+2*hx+3,W);
            rgt1 = max(it-2*1-4,1):min(it+2*1+4,T);
            mskDi(rgh1,rgw1,rgt1) = true;
        end
    end
    evtSpk = label2idx(evtMap);
    
end



