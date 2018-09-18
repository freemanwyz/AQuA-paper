function Xf = getFisherTrans( X, L )
%GETFISHERTRANS Fisher transform on X

if L<3
    warning('Too short signal.\n')
    L = 5
end

Xf = 0.5*log((1+X)./(1-X))*sqrt(L-3);

end

