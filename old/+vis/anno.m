function anno(datIn,evtLst)
    % GUI for event manual annotation
    
    if ~exist('datIn','var')
        datIn = rand(64,64,10);
    end
    
    f = figure('Visible','off','Toolbar','none','MenuBar','none','NumberTitle','off');
    f.Position = [360,500,520,580];
    f.Name = 'Annotator';
    f.WindowKeyPressFcn   = {@checkKey,f};
    
    % controls
    hTop = uix.HBox('Parent',f);
    vDat = uix.VBox('Parent',hTop);
    vLst = uix.VBox('Parent',hTop);
    hTop.Widths = [-1,70];
    
    aImg = axes(vDat,'Tag','aImage');
    aImg.Position = [0 0 1 1];
    aImg.XTick = [];
    aImg.YTick = [];
    uicontrol(vDat,'Style','slider','Tag','imageScroll','Callback',{@imgSlide,f});
    vDat.Heights = [-1,25];
    
    uicontrol(vLst,'Style','listbox','Tag','evtLst');
    hLstCon = uix.VButtonBox('Parent',vLst,'Spacing',5);
    uicontrol(hLstCon,'String','Add [a]','Callback',{@addEvt,f});
    uicontrol(hLstCon,'String','Delete [x]','Callback',{@delEvt,f});
    uicontrol(hLstCon,'String','Export [e]','Callback',{@saveEvt,f});
    vLst.Heights = [-1,80];
    
    % init figure
    f.Units = 'normalized';
    xx = f.Position;
    xx(1:2) = [0.2,0.2];
    f.Position = xx;
    f.Visible = 'on';
    fh = guihandles(f);
    guidata(f,fh);
    setappdata(f,'vid',datIn);
    
    % change scroll bar
    if length(size(datIn))==2
        T = 1;
    else
        T = size(datIn,3);
    end
    fh.imageScroll.Value = 1;
    fh.imageScroll.Min = 1;
    fh.imageScroll.Max = T;
    if T>1
        fh.imageScroll.SliderStep = [1/(T-1),1/(T-1)*10];
    else
        fh.imageScroll.Enable = 'off';
    end    
    
    % events
    if ~exist('evtLst','var')
        evtLst = [];
    else
        nEvt = numel(evtLst); 
        xx = 1:nEvt;
        fh.evtLst.String = arrayfun(@num2str,xx,'UniformOutput',false);
    end
    setappdata(f,'evtLst',evtLst);
    
    imgSlide([],[],f);    
end

% ----------------------------------------------------------- %
% add events
function addEvt(~,~,f)
    fh = guidata(f);
    evtLst = getappdata(f,'evtLst');
    x = [];
    x.frames = [];
    x.bds = [];
    evtLst{end+1} = x;
    nEvt = numel(evtLst);    
    xx = 1:nEvt;
    fh.evtLst.String = arrayfun(@num2str,xx,'UniformOutput',false);
    fh.evtLst.Value = nEvt;
    setappdata(f,'evtLst',evtLst);
end

% delete events
function delEvt(~,~,f)
    fh = guidata(f);
    evtLst = getappdata(f,'evtLst');
    if isempty(evtLst)
        return
    end
    evtNow = fh.evtLst.Value;
    evtLst(evtNow) = [];
    nEvt = numel(evtLst);
    xx = 1:nEvt;
    fh.evtLst.String = arrayfun(@num2str,xx,'UniformOutput',false);
    fh.evtLst.Value = nEvt;
    setappdata(f,'evtLst',evtLst);
    imgSlide([],[],f);
end

% save events
function saveEvt(~,~,f)
    %vid = getappdata(f,'vid');
    evtLst = getappdata(f,'evtLst');
    assignin('base','evtLst',evtLst);
end

% keyboard shortcuts
function checkKey(~,evtDat,f)   
    fh = guidata(f);
    nn = round(fh.imageScroll.Value);
    T = fh.imageScroll.Max;
    switch evtDat.Key
        case 'a'
            addEvt([],[],f);
        case 'x'
            delEvt([],[],f);
        case 'd'
            evtDraw([],[],f);
        case 'e'
            saveDraw([],[],f);   
        case 'rightarrow'
            fh.imageScroll.Value = min(nn+1,T);
            imgSlide([],[],f);
        case 'leftarrow'
            fh.imageScroll.Value = max(nn-1,1);
            imgSlide([],[],f);
    end
end

% ----------------------------------------------------------- %
% draw events
function evtDraw(~,~,f)
    fh = guidata(f);
    axMov = fh.aImage;
    evtLst = getappdata(f,'evtLst');
    if isempty(evtLst)
        return
    end
    curEvt = fh.evtLst.Value;
    xx = evtLst{curEvt};
    hh = impoly(axMov);
    if ~isempty(hh)
        nPts = size(hh.getPosition,1);
        if nPts>2
            xx.bds{end+1} = hh.getPosition;
            xx.frames(end+1) = round(fh.imageScroll.Value);
            evtLst{curEvt} = xx;
            setappdata(f,'evtLst',evtLst);
            delete(hh)
            imgSlide([],[],f);
        end
    end
end

% ----------------------------------------------------------- %
% show movie
function imgSlide(~,~,f)
    fh = guidata(f);
    vid = getappdata(f,'vid');    
    nFrameNow = round(fh.imageScroll.Value);
    if length(size(vid))==2
        vid0 = vid;
    end
    if length(size(vid))==3
        vid0 = vid(:,:,nFrameNow);
    end
    fprintf('%d\n',nFrameNow)
    [H,W] = size(vid0);
    axMov = fh.aImage;
    axMov.XLim = [0.5 W+0.5];
    axMov.YLim = [0.5 H+0.5];
    im1 = image(axMov,'CData',flipud(vid0));
    im1.CDataMapping = 'scaled';
    im1.ButtonDownFcn = {@evtDraw,f};
    colormap('gray')
    axMov.DataAspectRatio = [1 1 1];
    axMov.CLim = [0,1];
    
    h00 = findobj(axMov,'Type','patch');
    if ~isempty(h00)
        delete(h00)
    end
    
    % regions            
    evtLst = getappdata(f,'evtLst');
    for ii=1:numel(evtLst)
        xx = evtLst{ii};
        idx = find(xx.frames==nFrameNow);
        for jj=idx
            x = xx.bds{jj};
            patch(axMov,x(:,1),x(:,2),'y','FaceAlpha',0.25,'EdgeColor','y');
            text(x(1,1),x(1,2),num2str(ii),'Color','red','FontSize',15);
        end
    end
    
end












