%% contents of res
nn = fieldnames(res);

[H,W,T] = size(res.datOrg);

tb = cell(numel(nn),4);
for ii=1:numel(nn)
    tb{ii,1} = nn{ii};
    xx = res.(nn{ii});
    tb{ii,2} = class(xx);
    sz = size(xx);
    sz = sz(sz~=1);
    if isempty(sz)
        s0 = '1';
    else
        for jj=1:numel(sz)
            if sz(jj)==T
                s00 = 'Frames';
            elseif sz(jj)==H
                s00 = 'Height';
            else
                s00 = num2str(sz(jj));
            end
            if jj>1
                s0 = [s0,' by ',s00];
            else
                s0 = s00;
            end
        end
    end
    tb{ii,3} = s0;    
end

tbx = table(tb(:,1),tb(:,2),tb(:,3),tb(:,4));
tbx.Properties.VariableNames = {'Field','Type','Size','Description'};
writetable(tbx,'res_top.csv');




