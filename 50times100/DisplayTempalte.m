function OutImg = DisplayTempalte( InImg, radius, xe)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
OutImg=InImg;
[ImgHeight,ImgWidth]=size(InImg);
for x=ceil(xe(2)-radius):floor(xe(2)+radius)
    y1=round(sqrt(double(radius)^2-(x-xe(2))^2))+xe(1);
    y2=-round(sqrt(double(radius)^2-(x-xe(2))^2))+xe(1);
    if x<=ImgWidth && x>=1
        if y1<=ImgHeight && y1>=1
            OutImg(y1,x)=255;
        end
        if y2<=ImgHeight && y2>=1
            OutImg(y2,x)=255;
        end
    end
end

end

