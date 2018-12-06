try
    x+a;
catch e
    fprintf('%s\n',e.message)
    rethrow(e)
end