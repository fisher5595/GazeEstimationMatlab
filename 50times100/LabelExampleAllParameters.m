% Label key points in example images. First two points are left right corner
% points of outter up parabola, 3,4 points are left right corner points of inner
% contour. 5 point is the mid highest point of outter up parabola, 6 point
% is the mid highest point of the inner up parabola, 7 point is the mid
% lowest of the inner low parabola. 8,9,10,11 points are four points on the
% iris circle.
clear;
clc;
img_basename='enlarged_ResizedEyes_left_';
img_extention_name='.jpg';
img_amount=36;
TotalX=[];
TotalY=[];
Xc=zeros(2,img_amount);
Xe=zeros(2,img_amount);
R=zeros(1,img_amount);
A=zeros(1,img_amount);
A2=zeros(1,img_amount);
B=zeros(1,img_amount);
B2=zeros(1,img_amount);
C=zeros(1,img_amount);
Theta=zeros(1,img_amount);
for ImgCount=1:img_amount
    img_name=[img_basename int2str(ImgCount) img_extention_name];
    img=imread(img_name);
    figure(1);
    imshow(img);
    [x,y]=ginput(11);
    TmpXe=zeros(2,1);
    TmpXc=zeros(2,1);
    TmpR=0;
    TmpA=0;
    TmpA2=0;
    TmpB=0;
    TmpB2=0;
    TmpC=0;
    TmpXe(1)=1/4*(sum(y(1:4)));
    TmpXe(2)=1/4*(sum(x(1:4)));
    TmpA2=-(y(5)-TmpXe(1));
    TmpA=-(y(6)-TmpXe(1));
    TmpC=-(TmpXe(1)-y(7));
    [TmpXc(2),TmpXc(1),TmpR]=circfit(x(8:11),y(8:11));
    TmpB2=sqrt((y(1)-y(2))^2+(x(1)-x(2))^2)/2;
    TmpB=sqrt((y(3)-y(4))^2+(x(3)-x(4))^2)/2;
    TmpTheta=atan(-(y(4)-TmpXe(1))/(x(4)-TmpXe(2)));
    if TmpTheta<0
        TmpTheta=TmpTheta+2*pi;
    end
    ResultImg=uint8(zeros(size(img,1),size(img,2),3));
    ResultImg(:,:,1)=img;
    ResultImg(:,:,2)=img;
    ResultImg(:,:,3)=img;
    ResultImg=WriteResultOnImgWithOutterUpParabola( ResultImg, TmpXe, ImgCor2NewCor(TmpXc,TmpXe,TmpTheta), TmpTheta, TmpA, TmpA2, TmpC, TmpB, TmpB2, TmpR );
    imshow(ResultImg);
    TotalX=[TotalX x];
    TotalY=[TotalY y];
    Xe(:,ImgCount)=TmpXe;
    Xc(:,ImgCount)=TmpXc;
    R(ImgCount)=TmpR;
    A(ImgCount)=TmpA;
    A2(ImgCount)=TmpA2;
    B(ImgCount)=TmpB;
    B2(ImgCount)=TmpB2;
    C(ImgCount)=TmpC;
    Theta(ImgCount)=TmpTheta;
    pause;
end

SaveFileNamePrefix='Training_';
SaveFileNameSuffix='.mat';
x=Xc;
save([SaveFileNamePrefix,'Xc',SaveFileNameSuffix],'x');
x=Xe;
save([SaveFileNamePrefix,'Xe',SaveFileNameSuffix],'x');
x=A;
save([SaveFileNamePrefix,'A',SaveFileNameSuffix],'x');
x=A2;
save([SaveFileNamePrefix,'A2',SaveFileNameSuffix],'x');
x=B;
save([SaveFileNamePrefix,'B',SaveFileNameSuffix],'x');
x=B2;
save([SaveFileNamePrefix,'B2',SaveFileNameSuffix],'x');
x=C;
save([SaveFileNamePrefix,'C',SaveFileNameSuffix],'x');
x=Theta;
save([SaveFileNamePrefix,'Theta',SaveFileNameSuffix],'x');
x=R;
save([SaveFileNamePrefix,'R',SaveFileNameSuffix],'x');

