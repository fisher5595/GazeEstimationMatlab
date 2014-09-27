function [ ResultImg ] = WriteThreeCornerOnImg( InputImg, CloserInnerCorner, FarInnerCorner, FarOuterCorner )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
ResultImg=InputImg;
[Height,Width,Channel]=size(InputImg);
Delta=2*pi/100;
R=2;
for CircleTheta=0:Delta:(2*pi)
    x0=R*cos(CircleTheta)+CloserInnerCorner(2);
    y0=R*sin(CircleTheta)+CloserInnerCorner(1);
    ImageCor=[round(y0);round(x0)];
    if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
        ResultImg(ImageCor(1),ImageCor(2),1)=255;
    end
    x0=R*cos(CircleTheta)+FarInnerCorner(2);
    y0=R*sin(CircleTheta)+FarInnerCorner(1);
    ImageCor=[round(y0);round(x0)];
    if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
        ResultImg(ImageCor(1),ImageCor(2),2)=255;
    end
    x0=R*cos(CircleTheta)+FarOuterCorner(2);
    y0=R*sin(CircleTheta)+FarOuterCorner(1);
    ImageCor=[round(y0);round(x0)];
    if ImageCor(1)<=Height && ImageCor(1)>=1 && ImageCor(2)<=Width && ImageCor(2)>=1
        ResultImg(ImageCor(1),ImageCor(2),1)=255;
        ResultImg(ImageCor(1),ImageCor(2),2)=255;
    end
end

end