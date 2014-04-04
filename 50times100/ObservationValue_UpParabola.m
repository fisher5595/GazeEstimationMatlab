function [ ObservationValue ] = ObservationValue_UpParabola( EdgeMag, Xe, Theta, A, B)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Value=0;
[Height,Width]=size(EdgeMag);
sigma=100;
for x0=-B:1:B
    y0=A-A/(B^2)*(x0^2);
    k=1/x0*B^2/(-2*A);
    Normal=1/k;
    if abs(Normal)<1 || abs(k)>1
        for x=(x0-5):1:(x0+5)
            y=Normal*(x-x0)+y0;
            ImageCor=NewCor2ImgCor([y;x], Xe, Theta);
            if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
                Value=Value-norm([y-y0;x-x0],2)^2/exp(EdgeMag(ImageCor(1),ImageCor(2)));
            end
        end
    else
        for y=(y0-5):1:(y0+5)
            x=k*(y-y0)+x0;
            ImageCor=NewCor2ImgCor([y;x], Xe, Theta);
            if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
                Value=Value-norm([y-y0;x-x0],2)^2/exp(EdgeMag(ImageCor(1),ImageCor(2)));
            end
        end
    end
end

ObservationValue=exp(Value/(sigma^2));

end
