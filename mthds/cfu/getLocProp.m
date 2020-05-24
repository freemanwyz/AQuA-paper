function [ loc2d,locy,locx,loct,locRad,actReg ] = getLocProp( loc3d,movSize )
%cipsLocCircle locations of events approximated by circles

% data preprocessing
h = movSize(1);
w = movSize(2);
t = movSize(3);

numEvt = length(loc3d);

locx = zeros(numEvt,1);     % event center x-coordinate
locy = zeros(numEvt,1);     % event center y-coordinate
loct = zeros(numEvt,1);     % event start time
locRad = zeros(numEvt,1);  % event radius: all events are viewed as circles
loc2d = cell(numEvt,1);  % event coordinates (2D)
actReg = zeros(h,w);        % active region

for ii=1:numel(loc3d)
    [locyAll,locxAll, loctAll] = ind2sub([h,w,t],loc3d{ii});
    loct(ii) = min(loctAll); % start time
    uniLoc = unique([locyAll,locxAll],'rows');  
    locy(ii) = round(mean(uniLoc(:,1)));
    locx(ii) = round(mean(uniLoc(:,2)));
    locRad(ii) = sqrt(size(uniLoc,1)/pi);
    loc2d{ii} = sub2ind([h,w],uniLoc(:,1),uniLoc(:,2));
    actReg(loc2d{ii}) = actReg(loc2d{ii}) + 1;
end



