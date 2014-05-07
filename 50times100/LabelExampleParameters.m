% Label key points in example images. Key points including two corners,
% three points on eye circle. Mid point of two corner points is the eye
% cneter, fit a circle with three points on circle to get the radius and
% center of iris. Each labeled image has five points.
clear;
clc;
img_basename='enlarged_ResizedEyes_left_';
img_extention_name='.jpg';
img_amount=36;
TotalX=[];
TotalY=[];
for ImgCount=1:img_amount
    img_name=[img_basename int2str(ImgCount) img_extention_name];
    img=imread(img_name);
    figure(1);
    imshow(img);
    [x,y]=ginput(6);
    for i=1:5
        LabelImg=LabelImageWithRectangle(img,[uint16(y(i));uint16(x(i))],[2;2]);
        imshow(LabelImg);
        pause
    end
    TotalX=[TotalX x];
    TotalY=[TotalY y];
end

Xc=zeros(2,img_amount);
Xe=zeros(2,img_amount);
R=zeros(1,img_amount);
for ImgCount=1:img_amount
    xe1=[TotalY(1,ImgCount);TotalX(1,ImgCount)];
    xe2=[TotalY(2,ImgCount);TotalX(2,ImgCount)];
    PointOnCircle1=[TotalY(3,ImgCount);TotalX(3,ImgCount)];
    PointOnCircle2=[TotalY(4,ImgCount);TotalX(4,ImgCount)];
    PointOnCircle3=[TotalY(5,ImgCount);TotalX(5,ImgCount)];
    PointOnCircle4=[TotalY(6,ImgCount);TotalX(6,ImgCount)];
    Xe(:,ImgCount)=1/2*(xe1+xe2);
    [Xc(2,ImgCount),Xc(1,ImgCount),R(ImgCount)]=circfit(TotalX(3:6,ImgCount),TotalY(3:6,ImgCount));    
end

