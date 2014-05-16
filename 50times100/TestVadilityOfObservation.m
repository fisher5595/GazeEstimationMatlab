% Test the validity of obeservation function by manually setting the
% parameters of the contour and the iris circle
Img=imread('enlarged_ResizedEyes_left_1.jpg');
Maskx=[-1 0 1; -2 0 2; -1 0 1];
Masky=[1 2 1; 0 0 0; -1 -2 -1];
[Height,Width]=size(Img);
Gx=conv2(double(Img), double(-1*Maskx), 'same');
Gy=conv2(double(Img), double(-1*Masky), 'same');
% Learn transform maxtrix from column vector A*Xc to Xe;
TransformMatrix_Xc2Xe=[0.8373,0.2115;-0.2954,1.0270];
TransformMatrix_Xe2Xc=inv(TransformMatrix_Xc2Xe);

% Do median filtering indenpently on the Gx and Gy, to denoise noise in the
% theata of gradient
Gx=medfilt2(Gx);
Gy=medfilt2(Gy);
EdgeMag=sqrt(Gy.^2+Gx.^2);
EdgeTheta=zeros(Height,Width);

% Angel of gradient of image, range from 0 to 2pi
for y=1:Height
    for x=1:Width
        if Gx(y,x)~=0
            EdgeTheta(y,x)=atan(Gy(y,x)/Gx(y,x));
            if Gx(y,x)>0 && Gy(y,x)>=0
                EdgeTheta(y,x)=EdgeTheta(y,x);
            elseif Gx(y,x)>0 && Gy(y,x)<=0
                EdgeTheta(y,x)=EdgeTheta(y,x)+2*pi;
            elseif Gx(y,x)<0 && Gy(y,x)>=0
                EdgeTheta(y,x)=EdgeTheta(y,x)+pi;
            else
                EdgeTheta(y,x)=EdgeTheta(y,x)+pi;
            end
        elseif Gy(y,x)>0
            EdgeTheta(y,x)=pi/2;
        else
            EdgeTheta(y,x)=pi/2*3;
        end
    end
end

% Parameters
Xe=[Height*0.7;Width*0.6];
Xc=[Height*0.5;Width*0.65];
%Xc=[0;0];
Theta=0;
A=Height/2;
%For outer up-parabola
A2OverA=1;
A2=A*A2OverA;
C=Height/4;
B=Width/4;
%For outer up-parabola
B2OverB=1;
B2=B*B2OverB;
R=Width/8;
MaxIter=20;
SampleAmount=300;
Sigma1=10;
Sigma2=pi/8;
Sigma3=10;
Sigma4=10;
Sigma5=5;
Resample_Sigma1=1;
Resample_Sigma2=pi/16;
Resample_Sigma3=1;
Resample_Sigma4=1;
Resample_Sigma5=1;
IniResultImg=uint8(zeros(size(Img,1),size(Img,2),3));
IniResultImg(:,:,1)=Img;
IniResultImg(:,:,2)=Img;
IniResultImg(:,:,3)=Img;
IniResultImg=WriteResultOnImgWithOutterUpParabola( IniResultImg, Xe, ImgCor2NewCor(Xc,Xe,Theta), Theta, A, A2, C, B, B2, R );
% Display result
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

UpParabolaObservation=ObservationValue_UpParabola( EdgeMag, EdgeTheta, Xe, Theta, A, B);
LowParabolaObservation=ObservationValue_LowParabola( EdgeMag, EdgeTheta, Xe, Theta, C, B);
OutterUpParabolaObservation=ObservationValue_OutterUpParabola( EdgeMag, EdgeTheta, Xe, Theta, A2, B2);
disp('Up Observation');
disp(UpParabolaObservation);
disp('Low Observation');
disp(LowParabolaObservation);
disp('OutterUp Observation');
disp(OutterUpParabolaObservation);

IrisObservation=ObservationValue_Iris( EdgeMag, EdgeTheta, ImgCor2NewCor(Xc,Xe,Theta), Xe, Theta, R);
disp('Iris Observation');
disp(IrisObservation);

% Display results
figure(1);
subplot(2,2,1);
imshow(IniResultImg);
subplot(2,2,2);
imshow(ResultImg);
subplot(2,2,3);
imshow(EdgeMag./max(max(EdgeMag)));
subplot(2,2,4);
imshow(ResultOnEdge);
