% quality control of detection results

f0 = 'ex_domain_avgsize_oneseed_fixed_nospasmo_noprop_samedf_201809241238';
pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\';
tb = readtable('resLst.csv','Delimiter',',');

% get files
f00 = dir([pOut,'res_*']);
for ii=1:numel(f00)
    if isempty(strfind(f00(ii).name,f0))
        continue
    end
    if ~isempty(strfind(f00(ii).name,'aqua'))
        tb.res{1} = f00(ii).name;
    end
    if ~isempty(strfind(f00(ii).name,'geci'))
        tb.res{2} = f00(ii).name;
    end
    if ~isempty(strfind(f00(ii).name,'cascade'))
        tb.res{3} = f00(ii).name;
    end
    if ~isempty(strfind(f00(ii).name,'calman'))
        tb.res{4} = f00(ii).name;
    end
    if ~isempty(strfind(f00(ii).name,'suite2p'))
        tb.res{5} = f00(ii).name;
    end
end

rIn = load([pOut,tb.res{1}]);
xx = load([pIn,f0,'.mat']);
datSim = xx.datSim;
datSim = cat(3,datSim,zeros(size(datSim,1),size(datSim,2),100,'uint16'));
% if isa(datSim,'uint16')
%     datSim = double(datSim)/65535;
% end


%% results of different methods
zzshow(regionMapWithData(xx.evtLst,zeros(size(datSim))),'Ground truth')
pause(0.5)
for ii=1:size(tb,1)
    disp(tb.mthd{ii})
    try
        rIn1 = load([pOut,tb.res{ii}]);
        r0 = rIn1.resx{1};
        zzshow(regionMapWithData(r0.evt,zeros(size(datSim))),tb.mthd{ii})
    catch
        fprintf('Error\n')
    end
    pause(0.5)
end


%% debug
evt = r0.evt;
tx1 = zeros(numel(evt),1);
for ii=1:numel(evt)
    [~,~,it0] = ind2sub(size(datSim),evt{ii});
    tx1(ii) = max(it0)-min(it0);
end

evt = xx.evtLst;
tx0 = zeros(numel(evt),1);
for ii=1:numel(evt)
    [~,~,it0] = ind2sub(size(datSim),evt{ii});
    tx0(ii) = max(it0)-min(it0);
end
















