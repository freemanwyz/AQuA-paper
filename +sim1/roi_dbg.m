function [datSim,evtLst,dmMap] = roi_dbg(p)
    % roi_dbg generates simplest ROI simulations
    
    H = p.sz(1);
    W = p.sz(2);
    T = 300;
    dmMap = zeros(H,W);
    dx = 10;
    dx2 = floor(dx/2);
    dt = 3;  % 7
    evtMap = zeros(H,W,T);
    
    xCnt = 1;
    for nn=1:300
        fprintf('%d\n',nn)
        
        % add an ROI
        for ii=1:1000
            h0 = randi([2*dx,H-2*dx]);
            w0 = randi([2*dx,W-2*dx]);
            rgh0 = h0-dx-5:h0+dx+5;
            rgw0 = w0-dx-5:w0+dx+5;
            x = dmMap(rgh0,rgw0);
            if sum(x(:))==0
                break
            end
        end
        if ii==1000
            break
        end
        rgh1 = h0-dx2:h0+dx2;
        rgw1 = w0-dx2:w0+dx2;
        dmMap(rgh1,rgw1) = nn;
        
        % generate events randomly
        tNow = 5;
        kk = 1;
        while 1
            if kk==1
                tWait = randi([1,100]);
            else
                tWait = randi([51,200]);
            end
            tNow = tNow+tWait;
            if tNow>T-dt*2
                break
            end
            evtMap(rgh1,rgw1,tNow:tNow+dt-1) = xCnt;
            xCnt = xCnt+1;       
            kk = kk+1;
        end
    end
    
    datSim = 0.2*(evtMap>0);
    %evtLst = label2idx(evtMap);
    
    p.xRate = 1;
    f00 = [0.03 0.1 0.05];
    p.filter3D = reshape(f00/sum(f00),1,1,[]);
    [datSim,evtLst] = sim1.postProcSim(datSim,evtMap,p);
    
end



