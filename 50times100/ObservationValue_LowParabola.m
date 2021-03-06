function [ ObservationValue ] = ObservationValue_LowParabola( EdgeMag, EdgeTheta, Xe, Theta, C, B)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Value=0;
[Height,Width]=size(EdgeMag);
sigma=100;
displacement=1;
deltaOfParabola=B/10;
for x0=-B:deltaOfParabola:B
    y0=-C+C/(B^2)*(x0^2);
    k=1/x0*B^2/(2*C);
    Normal=1/k;
    if k==0
        ModelTheta=pi/2;
    else
        ModelTheta=atan(Normal);
        if ModelTheta<0
            ModelTheta=ModelTheta+pi;
        end
    end
    if abs(Normal)<1 || abs(k)>1
        for x=(x0-displacement):1:(x0+displacement)
            y=Normal*(x-x0)+y0;
            ImageCor=NewCor2ImgCor([y;x], Xe, Theta);
            if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
                Value=Value-exp(norm([y-y0;x-x0],2)^2)/exp(EdgeMag(ImageCor(1),ImageCor(2)))*exp(abs(EdgeTheta(ImageCor(1),ImageCor(2))-Theta-ModelTheta)/2/pi);
                if isnan(Value)
                    disp('nan');
                end
            else
                Value=Value-exp(norm([y-y0;x-x0],2)^2);
            end
        end
    else
        for y=(y0-displacement):1:(y0+displacement)
            x=k*(y-y0)+x0;
            ImageCor=NewCor2ImgCor([y;x], Xe, Theta);
            if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
                Value=Value-exp(norm([y-y0;x-x0],2)^2)/exp(EdgeMag(ImageCor(1),ImageCor(2)))*exp(abs(EdgeTheta(ImageCor(1),ImageCor(2))-Theta-ModelTheta)/2/pi);
                if isnan(Value)
                    disp('nan');
                end
            else
                Value=Value-exp(norm([y-y0;x-x0],2)^2);            
            end
        end
    end
end

if Value==0
    ObservationValue=0;
else
    ObservationValue=exp(Value/(sigma^2));
end

end