% MFMC code for deformable shape tracking. In order to get the shape parameters.
% In this situation, we have tree parts for one eye. Upper parabola, lower
% one and middle circle for iris.
clc;
clear;
Img=imread('enlarged_ResizedEyes_left_1.jpg');
Maskx=[-1 0 1; -2 0 2; -1 0 1];
Masky=[1 2 1; 0 0 0; -1 -2 -1];
[Height,Width]=size(Img);
Gx=conv2(double(Img), double(Maskx), 'same');
Gy=conv2(double(Img), double(Masky), 'same');
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
Xc=[Height*0.6;Width*0.6];
%Xc=[0;0];
Theta=0;
A=Height/2;
C=Height/8;
B=Width/4;
R=Width/8;
MaxIter=20;
SampleAmount=100;
Sigma1=10;
Sigma2=pi/4;
Sigma3=10;
Sigma4=10;
Sigma5=10;
Resample_Sigma1=1;
Resample_Sigma2=pi/16;
Resample_Sigma3=1;
Resample_Sigma4=1;
Resample_Sigma5=1;
IniResultImg=uint8(zeros(size(Img,1),size(Img,2),3));
IniResultImg(:,:,1)=Img;
IniResultImg(:,:,2)=Img;
IniResultImg(:,:,3)=Img;
IniResultImg=WriteResultOnImg( IniResultImg, Xe, ImgCor2NewCor(Xc,Xe,Theta), Theta, A, C, B, R );

% Loop body
for iter=1:MaxIter
    % Importance sampling: Importance function can use the potential function.
    % Do the sampling using the expectation of parameters.
    if iter==1
        % Up parabola samples
        Up_XeSamples=double(zeros(2,SampleAmount));
        Up_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
        Up_XeSamples(1,:)=normrnd(Xc(1),Sigma1,1,SampleAmount);
        Up_XeSamples(2,:)=normrnd(Xc(2),Sigma1,1,SampleAmount);
        Up_ThetaSamples=normrnd(Theta,Sigma2,1,SampleAmount);
        Up_ASamples=normrnd(A,Sigma3,1,SampleAmount);
        Up_BSamples=normrnd(2*R,Sigma4,1,SampleAmount);

        % Low parabola samples
        Low_XeSamples=Up_XeSamples;
        Low_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
        Low_ThetaSamples=Up_ThetaSamples;
        Low_CSamples=normrnd(C,Sigma3,1,SampleAmount);
        Low_BSamples=Up_BSamples;

        % Iris circle samples
        Iris_XcSamples=double(zeros(2,SampleAmount));
        Iris_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
        Iris_XcSamples(1,:)=normrnd(Xe(1),Sigma1,1,SampleAmount);
        Iris_XcSamples(2,:)=normrnd(Xe(2),Sigma1,1,SampleAmount);
        Iris_RSamples=normrnd(B/2,Sigma5,1,SampleAmount);
    else
        % Up parabola samples
        Up_XeSamples=double(zeros(2,SampleAmount));
        Up_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
        Up_XeSamples=GenerateSmaplesBasedOnWeights( Iris_Old_XcSamples, Iris_Samples_Old_Weight./sum(Iris_Samples_Old_Weight), Resample_Sigma1, SampleAmount);
        Up_ThetaSamples=GenerateSmaplesBasedOnWeights(Up_Old_ThetaSamples, Up_Samples_Old_Weight./sum(Up_Samples_Old_Weight)/2+Low_Samples_Old_Weight./sum(Low_Samples_Old_Weight)/2, Resample_Sigma2, SampleAmount);
        Up_ASamples=GenerateSmaplesBasedOnWeights(Up_Old_ASamples, Up_Samples_Old_Weight./sum(Up_Samples_Old_Weight), Resample_Sigma3, SampleAmount);
        Up_BSamples=GenerateSmaplesBasedOnWeights(Iris_Old_RSamples.*2, Iris_Samples_Old_Weight./sum(Iris_Samples_Old_Weight), Resample_Sigma4, SampleAmount);

        % Low parabola samples
        Low_XeSamples=Up_XeSamples;
        Low_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
        Low_ThetaSamples=Up_ThetaSamples;
        Low_CSamples=GenerateSmaplesBasedOnWeights(Low_Old_CSamples,Low_Samples_Old_Weight./sum(Low_Samples_Old_Weight), Resample_Sigma3, SampleAmount);
        Low_BSamples=Up_BSamples;

        % Iris circle samples
        Iris_XcSamples=double(zeros(2,SampleAmount));
        Iris_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
        Iris_XcSamples=GenerateSmaplesBasedOnWeights( Up_Old_XeSamples, Up_Samples_Old_Weight./sum(Up_Samples_Old_Weight)/2+Low_Samples_Old_Weight./sum(Low_Samples_Old_Weight)/2, Resample_Sigma1, SampleAmount);
        Iris_RSamples=GenerateSmaplesBasedOnWeights( Up_Old_BSamples./2,Up_Samples_Old_Weight./sum(Up_Samples_Old_Weight)/2+Low_Samples_Old_Weight./sum(Low_Samples_Old_Weight)/2, Resample_Sigma5, SampleAmount);
    end

    if iter==1
        % Assign old values

        % Up parabola samples
        Up_Old_XeSamples=Up_XeSamples;
        Up_Samples_Old_Weight=Up_Samples_NewWeight;
        Up_Old_ThetaSamples=Up_ThetaSamples;
        Up_Old_ASamples=Up_ASamples;
        Up_Old_BSamples=Up_BSamples;

        % Low parabola samples
        Low_Old_XeSamples=Low_XeSamples;
        Low_Samples_Old_Weight=Low_Samples_NewWeight;
        Low_Old_ThetaSamples=Low_ThetaSamples;
        Low_Old_CSamples=Low_CSamples;
        Low_Old_BSamples=Low_BSamples;

        % Iris circle samples
        Iris_Old_XcSamples=Iris_XcSamples;
        Iris_Samples_Old_Weight=Iris_Samples_NewWeight;
        Iris_Old_RSamples=Iris_RSamples;
    end
    % Re-weight: calculate weight, based on observation, messages and
    % importance value.

    for i=1:SampleAmount
        % Up parabola
        Message=0;
        for n=1:SampleAmount
            Message=Message+Iris_Samples_Old_Weight(n)*log(1/(2*pi)/Sigma4/Sigma1*exp(-(Up_BSamples(i)-2*Iris_Old_RSamples(n))^2/2/(Sigma1^2)-norm(Up_XeSamples(:,i)-Iris_Old_XcSamples(:,n),2)^2/2/(Sigma4^2)));
        end
        Message=exp(Message);
        Up_Samples_NewWeight(i)=ObservationValue_UpParabola( EdgeMag, EdgeTheta, Up_XeSamples(:,i), Up_ThetaSamples(i), Up_ASamples(i), Up_BSamples(i))*Message/(1/(2*pi)/Sigma4/Sigma1*exp(-(Up_BSamples(i)-2*R)^2/2/(Sigma1^2)-norm(Up_XeSamples(:,i)-Xc,2)^2/2/(Sigma4^2)));
        if isnan(Up_Samples_NewWeight(i))
            disp('nan');
            ObservationValue_UpParabola( EdgeMag, EdgeTheta, Up_XeSamples(:,i), Up_ThetaSamples(i), Up_ASamples(i), Up_BSamples(i));
        end
        
        % Low parabola
        Message=0;
        for n=1:SampleAmount
            Message=Message+Iris_Samples_Old_Weight(n)*log(1/(2*pi)/Sigma4/Sigma1*exp(-(Low_BSamples(i)-2*Iris_Old_RSamples(n))^2/2/(Sigma1^2)-norm(Low_XeSamples(:,i)-Iris_Old_XcSamples(:,n),2)^2/2/(Sigma4^2)));
        end
        Message=exp(Message);
        Low_Samples_NewWeight(i)=ObservationValue_LowParabola( EdgeMag, EdgeTheta, Low_XeSamples(:,i), Low_ThetaSamples(i), Low_CSamples(i), Low_BSamples(i))*Message/(1/(2*pi)/Sigma4/Sigma1*exp(-(Low_BSamples(i)-2*R)^2/2/(Sigma1^2)-norm(Low_XeSamples(:,i)-Xc,2)^2/2/(Sigma4^2)));
        if isnan(Low_Samples_NewWeight(i))
            disp('nan');
            ObservationValue_LowParabola( EdgeMag, EdgeTheta, Low_XeSamples(:,i), Low_ThetaSamples(i), Low_CSamples(i), Low_BSamples(i));
        end
        
        % Iris circle
        Message=0;
        for n=1:SampleAmount
            Message=Message+Up_Samples_Old_Weight(n)*log(1/(2*pi)/Sigma4/Sigma1*exp(-(Up_Old_BSamples(n)-2*Iris_RSamples(i))^2/2/(Sigma1^2)-norm(Up_Old_XeSamples(:,n)-Iris_XcSamples(:,i),2)^2/2/(Sigma4^2)));
            Message=Message+Low_Samples_Old_Weight(n)*log(1/(2*pi)/Sigma4/Sigma1*exp(-(Low_Old_BSamples(n)-2*Iris_RSamples(n))^2/2/(Sigma1^2)-norm(Low_Old_XeSamples(:,n)-Iris_Old_XcSamples(:,i),2)^2/2/(Sigma4^2)));
        end
        Message=exp(Message);
        Iris_Samples_NewWeight(i)=ObservationValue_Iris( EdgeMag, EdgeTheta, ImgCor2NewCor(Iris_XcSamples(:,i),Xe,Theta), Xe, Theta, Iris_RSamples(i))*Message/(1/(2*pi)/Sigma4/Sigma1*exp(-(B-2*Iris_RSamples(i))^2/2/(Sigma1^2)-norm(Xe-Iris_XcSamples(:,i),2)^2/2/(Sigma4^2)));
        if isnan(Iris_Samples_NewWeight(i))
            disp('nan');
            ObservationValue_Iris( EdgeMag, EdgeTheta, Iris_XcSamples(:,i), Xe, Theta, Iris_RSamples(i));
        end
    end
    Xe=(Up_XeSamples*Up_Samples_NewWeight'+Low_XeSamples*Low_Samples_NewWeight')/(sum(Up_Samples_NewWeight)+sum(Low_Samples_NewWeight));
    Theta=(Up_ThetaSamples*Up_Samples_NewWeight'+Low_ThetaSamples*Low_Samples_NewWeight')/(sum(Up_Samples_NewWeight)+sum(Low_Samples_NewWeight));
    B=(Up_BSamples*Up_Samples_NewWeight'+Low_BSamples*Low_Samples_NewWeight')/(sum(Up_Samples_NewWeight)+sum(Low_Samples_NewWeight));
    % Normalize weight
    Up_Samples_NewWeight=Up_Samples_NewWeight./sum(Up_Samples_NewWeight);
    Low_Samples_NewWeight=Low_Samples_NewWeight./sum(Low_Samples_NewWeight);
    Iris_Samples_NewWeight=Iris_Samples_NewWeight./sum(Iris_Samples_NewWeight);

    % Get new expectation
    Up_Xe_Exp=Up_XeSamples*Up_Samples_NewWeight';
    Up_Theta_Exp=Up_ThetaSamples*Up_Samples_NewWeight';
    Up_A_Exp=Up_ASamples*Up_Samples_NewWeight';
    Up_B_Exp=Up_BSamples*Up_Samples_NewWeight';

    Low_Xe_Exp=Low_XeSamples*Low_Samples_NewWeight';
    Low_Theta_Exp=Low_ThetaSamples*Low_Samples_NewWeight';
    Low_C_Exp=Low_CSamples*Low_Samples_NewWeight';
    Low_B_Exp=Low_BSamples*Low_Samples_NewWeight';

    Iris_Xc_Exp=Iris_XcSamples*Iris_Samples_NewWeight';
    Iris_R_Exp=Iris_RSamples*Iris_Samples_NewWeight';

    A=Up_A_Exp;
    C=Low_C_Exp;
    Xc=Iris_Xc_Exp;
    R=Iris_R_Exp;

    % Assign old values

    % Up parabola samples
    Up_Old_XeSamples=Up_XeSamples;
    Up_Samples_Old_Weight=Up_Samples_NewWeight;
    Up_Old_ThetaSamples=Up_ThetaSamples;
    Up_Old_ASamples=Up_ASamples;
    Up_Old_BSamples=Up_BSamples;

    % Low parabola samples
    Low_Old_XeSamples=Low_XeSamples;
    Low_Samples_Old_Weight=Low_Samples_NewWeight;
    Low_Old_ThetaSamples=Low_ThetaSamples;
    Low_Old_CSamples=Low_CSamples;
    Low_Old_BSamples=Low_BSamples;

    % Iris circle samples
    Iris_Old_XcSamples=Iris_XcSamples;
    Iris_Samples_Old_Weight=Iris_Samples_NewWeight;
    Iris_Old_RSamples=Iris_RSamples;
    
    % Display result
    ResultImg=uint8(zeros(size(Img,1),size(Img,2),3));
    ResultImg(:,:,1)=Img;
    ResultImg(:,:,2)=Img;
    ResultImg(:,:,3)=Img;
    ResultImg=WriteResultOnImg( ResultImg, Xe, ImgCor2NewCor(Xc,Xe,Theta), Theta, A, C, B, R );
    ResultOnEdge=uint8(zeros(size(EdgeMag,1),size(EdgeMag,2),3));
    ResultOnEdge(:,:,1)=uint8(EdgeMag./max(max(EdgeMag))*255);
    ResultOnEdge(:,:,2)=uint8(EdgeMag./max(max(EdgeMag))*255);
    ResultOnEdge(:,:,3)=uint8(EdgeMag./max(max(EdgeMag))*255);
    ResultOnEdge=WriteResultOnImg( ResultOnEdge, Xe, ImgCor2NewCor(Xc,Xe,Theta), Theta, A, C, B, R );

    % Display results
    figure(iter);
    subplot(2,2,1);
    imshow(IniResultImg);
    subplot(2,2,2);
    imshow(ResultImg);
    subplot(2,2,3);
    imshow(EdgeMag./max(max(EdgeMag)));
    subplot(2,2,4);
    imshow(ResultOnEdge);
end
% End of loop body

% % Display result
% ResultImg=uint8(zeros(size(Img,1),size(Img,2),3));
% ResultImg(:,:,1)=Img;
% ResultImg(:,:,2)=Img;
% ResultImg(:,:,3)=Img;
% ResultImg=WriteResultOnImg( ResultImg, Xe, ImgCor2NewCor(Xc,Xe,Theta), Theta, A, C, B, R );
% ResultOnEdge=uint8(zeros(size(EdgeMag,1),size(EdgeMag,2),3));
% ResultOnEdge(:,:,1)=uint8(EdgeMag./max(max(EdgeMag))*255);
% ResultOnEdge(:,:,2)=uint8(EdgeMag./max(max(EdgeMag))*255);
% ResultOnEdge(:,:,3)=uint8(EdgeMag./max(max(EdgeMag))*255);
% ResultOnEdge=WriteResultOnImg( ResultOnEdge, Xe, ImgCor2NewCor(Xc,Xe,Theta), Theta, A, C, B, R );
% 
% % Display results
% figure(1);
% subplot(2,2,1);
% imshow(IniResultImg);
% subplot(2,2,2);
% imshow(ResultImg);
% subplot(2,2,3);
% imshow(EdgeMag./max(max(EdgeMag)));
% subplot(2,2,4);
% imshow(ResultOnEdge);


