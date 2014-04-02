% MFMC code for deformable shape tracking. In order to get the shape parameters.
% In this situation, we have tree parts for one eye. Upper parabola, lower
% one and middle circle for iris.
clc;
clear all;
Img=imread('enlarged_ResizedEyes_left_5.jpg');
Maskx=[-1 0 1; -2 0 2; -1 0 1];
Masky=[1 2 1; 0 0 0; -1 -2 -1];
Gx=conv2(double(Img), double(Maskx), 'same');
Gy=conv2(double(Img), double(Masky), 'same');
EdgeMag=sqrt(Gy.^2+Gx.^2);

% Parameters
[Height,Width]=size(Img);
Xe=[Height/2;Width/2];
Xc=[Height/2;Width/2];
Theta=0;
A=Height/4;
C=Height/4;
B=Width/4;
R=Width/8;
MaxIter=5;
SampleAmount=30;
Sigma1=10;
Sigma2=pi/4;
Sigma3=5;
Sigma4=10;
Sigma5=5;
% Loop body
for iter=1:MaxIter
    % Importance sampling: Importance function can use the potential function.
    % Do the sampling using the expectation of parameters.

    % Up parabola samples
    Up_XeSamples=double(zeros(2,SampleAmount));
    Up_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
    Up_XeSamples(1,:)=normrnd(Xc(1),Sigma1,1,SampleAmount);
    Up_XeSamples(2,:)=normrnd(Xc(2),Sigma1,1,SampleAmount);
    Up_ThetaSamples=normrnd(Theta,Sigma2,1,SampleAmount);
    Up_ASamples=normrnd(A,Sigma3,1,SampleAmount);
    Up_BSamples=normrnd(2*R,Sigma4,1,SampleAmount);

    % Low parabola samples
    Low_XeSamples=double(zeros(2,SampleAmount));
    Low_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
    Low_XeSamples(1,:)=normrnd(Xc(1),Sigma1,1,SampleAmount);
    Low_XeSamples(2,:)=normrnd(Xc(2),Sigma1,1,SampleAmount);
    Low_ThetaSamples=normrnd(Theta,Sigma2,1,SampleAmount);
    Low_CSamples=normrnd(C,Sigma3,1,SampleAmount);
    Low_BSamples=normrnd(2*R,Sigma4,1,SampleAmount);

    % Iris circle samples
    Iris_XcSamples=double(zeros(2,SampleAmount));
    Iris_Samples_NewWeight=double(ones(1,SampleAmount))./SampleAmount;
    Iris_XcSamples(1,:)=normrnd(Xe(1),Sigma1,1,SampleAmount);
    Iris_XcSamples(2,:)=normrnd(Xe(2),Sigma1,1,SampleAmount);
    Iris_RSamples=normrnd(B/2,Sigma5,1,SampleAmount);

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
        Up_Samples_NewWeight(i)=ObservationValue_UpParabola( EdgeMag, Up_XeSamples(:,i), Up_ThetaSamples(i), Up_ASamples(i), Up_BSamples(i))*Message/(1/(2*pi)/Sigma4/Sigma1*exp(-(Up_BSamples(i)-2*R)^2/2/(Sigma1^2)-norm(Up_XeSamples(:,i)-Xc,2)^2/2/(Sigma4^2)));
        if isnan(Up_Samples_NewWeight(i))
            disp('nan');
        end
        
        % Low parabola
        Message=0;
        for n=1:SampleAmount
            Message=Message+Iris_Samples_Old_Weight(n)*log(1/(2*pi)/Sigma4/Sigma1*exp(-(Low_BSamples(i)-2*Iris_Old_RSamples(n))^2/2/(Sigma1^2)-norm(Low_XeSamples(:,i)-Iris_Old_XcSamples(:,n),2)^2/2/(Sigma4^2)));
        end
        Message=exp(Message);
        Low_Samples_NewWeight(i)=ObservationValue_LowParabola( EdgeMag, Low_XeSamples(:,i), Low_ThetaSamples(i), Low_CSamples(i), Low_BSamples(i))*Message/(1/(2*pi)/Sigma4/Sigma1*exp(-(Low_BSamples(i)-2*R)^2/2/(Sigma1^2)-norm(Low_XeSamples(:,i)-Xc,2)^2/2/(Sigma4^2)));
        if isnan(Low_Samples_NewWeight(i))
            disp('nan');
        end
        
        % Iris circle
        Message=0;
        for n=1:SampleAmount
            Message=Message+Up_Samples_Old_Weight(n)*log(1/(2*pi)/Sigma4/Sigma1*exp(-(Up_Old_BSamples(n)-2*Iris_RSamples(i))^2/2/(Sigma1^2)-norm(Up_Old_XeSamples(:,n)-Iris_XcSamples(:,i),2)^2/2/(Sigma4^2)));
            Message=Message+Low_Samples_Old_Weight(n)*log(1/(2*pi)/Sigma4/Sigma1*exp(-(Low_Old_BSamples(n)-2*Iris_RSamples(n))^2/2/(Sigma1^2)-norm(Low_Old_XeSamples(:,n)-Iris_Old_XcSamples(:,i),2)^2/2/(Sigma4^2)));
        end
        Message=exp(Message);
        Iris_Samples_NewWeight(i)=ObservationValue_Iris( EdgeMag, Iris_XcSamples(:,i), Xe, Theta, Iris_RSamples(i))*Message/(1/(2*pi)/Sigma4/Sigma1*exp(-(B-2*Iris_RSamples(i))^2/2/(Sigma1^2)-norm(Xe-Iris_XcSamples(:,i),2)^2/2/(Sigma4^2)));
        if isnan(Iris_Samples_NewWeight(i))
            disp('nan');
        end
    end
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

    Xe=(Up_Xe_Exp+Low_Xe_Exp)./2;
    Theta=(Up_Theta_Exp+Low_Theta_Exp)/2;
    A=Up_A_Exp;
    C=Low_C_Exp;
    B=(Up_B_Exp+Low_B_Exp)/2;
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
end
% End of loop body