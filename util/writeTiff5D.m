function writeTiff5D(datOut,labelMovie,pOut,nameOut)
    % writeTiff5D export 3D+channel+time data
    % each 3D+channel is save in one TIFF file, stacking along Z direction
    
    for ii=1:size(datOut,4)
        if mod(ii,10)==0
            fprintf('Frame %d\n',ii)
        end
        x = datOut(:,:,:,ii);
        x = double(x)/255+randn(size(x))*0.03;
        if ~isempty(labelMovie)
            lbl = 1*(labelMovie(:,:,:,ii)>0);
            y = zeros(size(x,1),size(x,2),3,size(x,3));
            x1 = x;
            x1(lbl>0) = 0;
            for tt=1:size(x,3)
                y(:,:,1,tt) = x(:,:,tt);
                y(:,:,2,tt) = x1(:,:,tt);
                y(:,:,3,tt) = x1(:,:,tt);
            end
        else
            y = x;
        end
        writeTiffSeq([pOut,nameOut,sprintf('%04d',ii),'.tif'],y,8);
    end
    
end