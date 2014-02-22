%Find eye corner
clear all;
clc;
img=imread('resizedEyes_1.jpg');
offset=50;
[m,n]=size(img);
partImg=img(:,offset+1:min(offset+30,n));
figure(1)
imshow(partImg);
kernelY=[1,2,1;0,0,0;-1,-2,-1];
kernelX=[-1,0,1;-2,0,2;-1,0,1];
Gx=conv2(double(partImg),double(kernelX),'same');
figure(2)
imshow(Gx./max(max(Gx)));
Gy=conv2(double(partImg),double(kernelY),'same');
figure(3)
imshow(Gy./max(max(Gy)));
GxTranspose=Gx';
GyTranspose=Gy';
G(1,:)=GxTranspose(:);
G(2,:)=GyTranspose(:);
eig(G*G')