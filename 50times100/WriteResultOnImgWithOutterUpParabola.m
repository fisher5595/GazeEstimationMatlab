function [ ResultImg ] = WriteResultOnImgWithOutterUpParabola( InputImg, Xe, Xc, Theta, A, A2, C, B, B2, R )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
ResultImg=InputImg;
[Height,Width,Channel]=size(InputImg);
Delta=2*pi/100;
for x0=-B:1:B
    y0=A-A/(B^2)*(x0^2);
    ImageCor=NewCor2ImgCor([y0;x0], Xe, Theta);
    if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
         ResultImg(ImageCor(1),ImageCor(2),1)=255;
    end
    y0=-C+C/(B^2)*(x0^2);
    ImageCor=NewCor2ImgCor([y0;x0], Xe, Theta);
    if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
         ResultImg(ImageCor(1),ImageCor(2),1)=255;
    end
end
for x0=-B2:1:B2
    y0=A2-A2/(B2^2)*(x0^2);
    ImageCor=NewCor2ImgCor([y0;x0], Xe, Theta);
    if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
         ResultImg(ImageCor(1),ImageCor(2),3)=255;
    end
end
for CircleTheta=0:Delta:(2*pi)
    x0=R*cos(CircleTheta)+Xc(2);
    y0=R*sin(CircleTheta)+Xc(1);
    ImageCor=NewCor2ImgCor([y0;x0], Xe, Theta);
    if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
        ResultImg(ImageCor(1),ImageCor(2),1)=255;
    end
end

end