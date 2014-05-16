function [ Result ] = DisplayResult(FigNum, Img, EdgeMag, Xe, Xc, Theta, A, A2, C, B, B2, R )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
ResultImg=uint8(zeros(size(Img,1),size(Img,2),3));
ResultImg(:,:,1)=Img;
ResultImg(:,:,2)=Img;
ResultImg(:,:,3)=Img;
ResultImg=WriteResultOnImgWithOutterUpParabola( ResultImg, Xe, ImgCor2NewCor(Xc,Xe,Theta), Theta, A, A2, C, B, B2, R );
ResultOnEdge=uint8(zeros(size(EdgeMag,1),size(EdgeMag,2),3));
ResultOnEdge(:,:,1)=uint8(EdgeMag./max(max(EdgeMag))*255);
ResultOnEdge(:,:,2)=uint8(EdgeMag./max(max(EdgeMag))*255);
ResultOnEdge(:,:,3)=uint8(EdgeMag./max(max(EdgeMag))*255);
ResultOnEdge=WriteResultOnImgWithOutterUpParabola( ResultOnEdge, Xe, ImgCor2NewCor(Xc,Xe,Theta), Theta, A, A2, C, B, B2, R );

figure(FigNum);
subplot(1,2,1);
imshow(ResultImg);
subplot(1,2,2);
imshow(ResultOnEdge);

end
