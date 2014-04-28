function [ ObservationValue ] = ObservationValue_Iris( EdgeMag, EdgeTheta, Xc, Xe, Theta, R)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Xc is relative value
Value=0;
[Height,Width]=size(EdgeMag);
Delta=2*pi/100;
sigma=2;
displacement=1;
for CircleTheta=0:Delta:(2*pi)
    x0=R*cos(CircleTheta)+Xc(2);
    y0=R*sin(CircleTheta)+Xc(1);
    Normal=tan(CircleTheta);
    k=1/Normal;
    if CircleTheta>pi/2
        ModelTheta=CircleTheta-pi;
    else
        ModelTheta=CircleTheta;
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