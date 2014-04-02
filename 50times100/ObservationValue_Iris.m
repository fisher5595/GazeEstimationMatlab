function [ ObservationValue ] = ObservationValue_Iris( EdgeMag, Xc, Xe, Theta, R)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Value=0;
[Height,Width]=size(EdgeMag);
Delta=2*pi/20;
for CircleTheta=0:Delta:(2*pi)
    x0=R*cos(CircleTheta)+Xc(2);
    y0=R*sin(CircleTheta)+Xc(1);
    Normal=tan(CircleTheta);
    k=1/Normal;
    if abs(Normal)<1 || abs(k)>1
        for x=(x0-5):1:(x0+5)
            y=Normal*(x-x0)+y0;
            ImageCor=NewCor2ImgCor([y;x], Xe, Theta);
            if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
                Value=Value-norm([y-y0;x-x0],2)^2/EdgeMag(ImageCor(1),ImageCor(2));
            end
        end
    else
        for y=(y0-5):1:(y0+5)
            x=k*(y-y0)+x0;
            ImageCor=NewCor2ImgCor([y;x], Xe, Theta);
            if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
                Value=Value-norm([y-y0;x-x0],2)^2/EdgeMag(ImageCor(1),ImageCor(2));
            end
        end
    end
end

ObservationValue=exp(Value);

end