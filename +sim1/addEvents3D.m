function [labelMovie,eventsMovie,allowMap] = addEvents3D(...
        labelMovie,eventsMovie,allowMap,nEvts,template,templateMsk,useSmall,k)
    % addEvents3D generate bursts first, they occupy distinct time slots
    % Temporal smoothing on falling edge only
    %
    % TODO: Spatial smoothing for each frame when generating events
    % TODO: Different propagation speed on different directions
    
    %k = 1;
    [H,W,D,T] = size(labelMovie);
    
    cnt = 1;
    for ii=1:nEvts*100
        if cnt>nEvts
            break
        end
        if mod(ii,1000)==0
            fprintf('%d\n',ii);
        end
        
        % find seed and time
        % must be inside templateMsk and be bright enough
        while 1
            x = ceil(rand()*H*W*D);
            tStart = ceil(rand()*T);
            if template(x)>0.1 && tStart<T-15 && tStart>5 && templateMsk(x)>0
                break
            end
        end
        
        allowFrame = allowMap(:,:,:,tStart);
        if allowFrame(x)==0
            continue
        end
               
        % distance to seed
        dist0 = bwdistgeodesic(templateMsk,x,'quasi-euclidean');
        if useSmall==0
            propSpeed = 5;  % pixels per frame
            tDur = randi([6,12]);
        else
            propSpeed = 2;
            tDur = randi([3,6]);
        end
        
        % grow frame by frame
        evtLst = cell(tDur,1);
        labelMovLst = cell(tDur,1);
        evtMovLst = cell(tDur,1);
        suc = 1;
        for t=1:tDur
            tNow = tStart+t-1;
            labelFrame = labelMovie(:,:,:,tNow);
            eventsFrame = eventsMovie(:,:,:,tNow);
            allowFrame = allowMap(:,:,:,tNow);
            
            % voxels propagated
            idx0 = find(dist0<propSpeed*t & templateMsk);
            
            % do not interfere other events
            if sum(allowFrame(idx0)==0)>0 || isempty(idx0)
                suc = 0;
                break
            end
            labelFrame(idx0) = k;
            evtLst{t} = idx0;
            
            % falling edge
            if t==tDur
                eventsFrame(idx0) = 128;
            else
                eventsFrame(idx0) = 255;
            end
            evtMovLst{t} = eventsFrame;
            labelMovLst{t} = labelFrame;
        end
        
        if suc==0
            continue
        end
        
        % update allow map
        for t=1:tDur
            tNow = tStart+t-1;
            labelMovie(:,:,:,tNow) = labelMovLst{t};
            eventsMovie(:,:,:,tNow) = evtMovLst{t};
            
            [ih,iw,id] = ind2sub([H,W,D],evtLst{t});
            rgh = max(min(ih)-5,1):min(max(ih)+5,H);
            rgw = max(min(iw)-5,1):min(max(iw)+5,W);
            rgd = max(min(id)-5,1):min(max(id)+5,D);
            
            % update nearby frames based on current frame
            for t1=tNow-3:tNow+3
                if t1>0 && t1<T
                    allowFrame = allowMap(:,:,:,t1);
                    allowFrame(rgh,rgw,rgd) = 0;
                    allowMap(:,:,:,t1) = allowFrame;
                end
            end
        end
        
        fprintf('Event %d\n',k)
        k = k + 1;        
        cnt = cnt + 1;
        if k==16
%             keyboard
        end
    end
end



