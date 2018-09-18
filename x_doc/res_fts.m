%% features, recursive
fts = res.fts;
sz = size(res.datOrg);
tb = res_fts_rec(fts,sz);
% for ii=1:size(tb,1)
%     tb{ii,1} = ['``res.fts.',tb{ii,1},'``'];
% end

tbx = table(tb(:,1),tb(:,2),tb(:,3),tb(:,4),tb(:,5));
tbx.Properties.VariableNames = {'Field','Type','Size','Units','Description'};
writetable(tbx,'res_fts.csv');




