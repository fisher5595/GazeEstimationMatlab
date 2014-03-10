%
% Deformable template matching to get corresponding parameters of eyes.
%
clc;
clear all;
%
% Read Images. Setup corresponding parameters
%
Img=imread('resizedEyes_right_35.jpg');

%
% Initialize three fields, representation fields.
%
ValleyField=-double(Img);
Maskx=[-1 0 1; -2 0 2; -1 0 1];
Masky=[1 2 1; 0 0 0; -1 -2 -1];
Gx=conv2(double(Img), double(Maskx), 'same');
Gy=conv2(double(Img), double(Masky), 'same');
EdgeField=sqrt(Gy.^2+Gx.^2);
PeakField=Img;
[ImgHeight,ImgWidth]=size(Img);

%
% Generate template masks. xe=[y;x]
%
xe=[ImgHeight/2;ImgWidth/2];
xc=[ImgHeight/2;ImgWidth/2];
r=ImgHeight/2;

%
% Compute Integrals.
%


%
% Compute the energy function
%

Newr=r;
NewXe=xe;
Energy=ComputeEnergy(Img,NewXe,Newr);
DeltaEnergyR=ComputeEnergy(Img,NewXe,Newr+1)-Energy;
DeltaEnergyXeX=ComputeEnergy(Img,[NewXe(1);NewXe(2)+1],Newr)-Energy;
DeltaEnergyXeY=ComputeEnergy(Img,[NewXe(1)+1;NewXe(2)],Newr)-Energy;
if DeltaEnergyR>0
    Newr=r+1;
elseif DeltaEnergyR<0
    Newr=r-1;
else
    Newr=r;
end

if DeltaEnergyXeX>0
    NewXe=[NewXe(1);NewXe(2)+1];
elseif DeltaEnergyXeX<0
    NewXe=[NewXe(1);NewXe(2)-1];
else
    NewXe=NewXe;
end

if DeltaEnergyXeY>0
    NewXe=[NewXe(1)+1;NewXe(2)];
elseif DeltaEnergyXeY<0
    NewXe=[NewXe(1)-1;NewXe(2)];
else
    NewXe=NewXe;
end
figure(1);
imshow(DisplayTempalte(Img,r,xe));
NewEnergy=ComputeEnergy(Img,NewXe,Newr);
while(NewEnergy-Energy>0)
    Energy=NewEnergy;
    DeltaEnergyR=ComputeEnergy(Img,NewXe,Newr+1)-Energy;
    DeltaEnergyXeX=ComputeEnergy(Img,[NewXe(1);NewXe(2)+1],Newr)-Energy;
    DeltaEnergyXeY=ComputeEnergy(Img,[NewXe(1)+1;NewXe(2)],Newr)-Energy;
    if DeltaEnergyR>0
        Newr=Newr+1;
    elseif DeltaEnergyR<0
        Newr=Newr-1;
    else
        Newr=Newr;
    end

    if DeltaEnergyXeX>0
        NewXe=[NewXe(1);NewXe(2)+1];
    elseif DeltaEnergyXeX<0
        NewXe=[NewXe(1);NewXe(2)-1];
    else
        NewXe=NewXe;
    end

    if DeltaEnergyXeY>0
        NewXe=[NewXe(1)+1;NewXe(2)];
    elseif DeltaEnergyXeY<0
        NewXe=[NewXe(1)-1;NewXe(2)];
    else
        NewXe=NewXe;
    end
    NewEnergy=ComputeEnergy(Img,NewXe,Newr);
    disp('Energy');
    disp(NewEnergy);
    disp(Newr); 
    disp(NewXe);
    imshow(DisplayTempalte(Img,Newr,NewXe));
end
%
% Compute partial derivitives.
%

%
% Loop to find optimal parameters
%
