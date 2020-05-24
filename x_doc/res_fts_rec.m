function tb = res_fts_rec(fts0,szDat)
    % list fields, recursively    
    
    if isstruct(fts0)
        tb = cell(0,5);
        fn = fieldnames(fts0);
        for ii=1:numel(fn)
            xx = fts0.(fn{ii});
            tb0 = res_fts_rec(xx,szDat);
            for jj=1:size(tb0,1)
                n0 = tb0{jj,1};
                if isempty(n0)
                    tb0{jj,1} = fn{ii};
                else
                    tb0{jj,1} = [fn{ii},'.',n0];
                end     
            end
            nx = size(tb0,1);
            tb(end+1:end+nx,:) = tb0;
        end
    else
        tb = cell(1,5);
        tb{1,1} = [];        
        
        % type
        tb{1,2} = class(fts0);
        
        % size
        sz = size(fts0);
        sz = sz(sz~=1);
        if isempty(sz)
            s0 = '1';
        else
            for jj=1:numel(sz)
                if sz(jj)==szDat(3)
                    s00 = 'Frames';
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
        tb{1,3} = s0;        
    end
    
end

