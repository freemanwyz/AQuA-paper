function d = radiusFromSize(r1,r2,minIoU,e)
% get the distance from two overlapping circles
if nargin <4
    e=10^-4;
end
dmax = r1+r2;
dmin = abs(r1-r2);
if minIoU<1
    d = dmax;
    return;
end

d =dichotomyRoot(r1,r2,dmin,dmax,minIoU,e);
% for dd = dmin+1:dmax
%     S = 1/4*sqrt((r1+r2+dd)*(r1+r2-dd)*(r1-r2+dd)*(-r1+r2+dd));
%     yk = 2*S/dd;
%     xk = sqrt(r1^2-yk^2);
%     %fprintf('%f,%f\n',xk,yk);
%     if xk==0 || yk==0
%         M = 0;
%     else
%         M = r1^2*atan2(yk,xk)+ r2^2*atan2(yk,dd-xk)-dd*yk;
%     end
%     if M<minIoU
%         d = dd;
%         break;
%     end
% end

end