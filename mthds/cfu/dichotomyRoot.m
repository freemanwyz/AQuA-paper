function y=dichotomyRoot(r1,r2,x1,x2,minIoU, e)
x1 = x1+e/10;
x = (x1+x2)/2;
f3 = myFun(r1,r2,x,minIoU);
f1 = myFun(r1,r2,x1,minIoU);
if(f1*f3<0)
    m = x-x1;
    if(m>e)
        x2 = x;
        y=dichotomyRoot(r1,r2,x1,x2,minIoU, e);
    else
        y=x;
    end
else
    m=x2-x;
    if(m>e)
        x1 = x;
        y=dichotomyRoot(r1,r2,x1,x2,minIoU, e);
    else
        y=x;
    end
end
end

function M = myFun(r1,r2,dd,minIoU)

S = 1/4*sqrt((r1+r2+dd)*(r1+r2-dd)*(r1-r2+dd)*(-r1+r2+dd));
yk = 2*S/dd;
xk = sqrt(r1^2-yk^2);
%fprintf('%f,%f\n',xk,yk);
if xk==0 || yk==0
    M = 0;
else
    M = r1^2*atan2(yk,xk)+ r2^2*atan2(yk,dd-xk)-dd*yk;
end
M = M-minIoU;
end