function fh = single(datIn,nameIn,sz,visFig)
    % GUI for curve visualization
    
    if ~exist('nameIn','var')
        nameIn = '';
    end
    if ~exist('sz','var')
        sz = size(datIn);
    end
    if ~exist('visFig','var')
        visFig = 'on';
    end
    
    fh = figure('Visible','off','WindowButtonDownFcn',@img_click,...
        'Name',nameIn,'NumberTitle','off','Visible',visFig);
    fh.Units = 'pixels';
    fh.Position = [360,500,sz(2),sz(1)];
    
    hImg = axes('Units','pixels','Position',[0,0,sz(2),sz(1)],'Tag','aImage');
    hImg.XTick = [];hImg.YTick = [];
    
    data = guihandles(fh);
    
    if exist('datIn','var')
        vid0 = datIn;
        imshow(vid0,'Parent',hImg);
        
        data.vid = datIn;
        data.iL = 0;
        data.iH = 1;
    end
    guidata(fh,data)
    
end

% selection callback
function img_click(hObj,~)
    
    data = guidata(hObj);
    
    cursorPoint = data.aImage.CurrentPoint;
    curX = round(cursorPoint(1,1));
    curY = round(cursorPoint(1,2));
    xLimits = data.aImage.XLim;
    yLimits = data.aImage.YLim;
    
    if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
        fprintf('(H,W): (%d,%d) --',curY,curX)
        val = data.vid(curY,curX);
        fprintf('Value: %f\n',val);
    end
    guidata(hObj,data);
    
end












