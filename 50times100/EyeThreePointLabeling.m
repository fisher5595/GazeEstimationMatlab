% Label key points in example images. CloserInnerCorner is the inner corner
% closer to nose, FarInnerCorner is the inner corner far from nose, and
% FarOuterCorner is the outer corner far from nose. Labeling order is as
% the above order. All coordinates are saved as [y;x]
clear;
clc;
img_basename='new_data_Sep_26/test_enlarged_ResizedEyes_right_';
img_extention_name='.jpg';
sample_round=1;
img_amount=61;
TotalX=[];
TotalY=[];
CloserInnerCorner=zeros(2,img_amount);
FarInnerCorner=zeros(2,img_amount);
FarOuterCorner=zeros(2,img_amount);
ImgCount=1;
while ImgCount<=img_amount
    img_name=[img_basename int2str(ImgCount) '__' int2str(sample_round) img_extention_name];
    img=imread(img_name);
    figure(1);
    imshow(img);
    set(gcf, 'Name', ['Labeling No.' int2str(ImgCount)]);
    [x,y]=ginput(3);
    TmpCloserInnerCorner=zeros(2,1);
    TmpFarInnerCorner=zeros(2,1);
    TmpFarOuterCorner=zeros(2,1);
    TmpCloserInnerCorner(1)=y(1);
    TmpCloserInnerCorner(2)=x(1);
    TmpFarInnerCorner(1)=y(2);
    TmpFarInnerCorner(2)=x(2);
    TmpFarOuterCorner(1)=y(3);
    TmpFarOuterCorner(2)=x(3);
    ResultImg=uint8(zeros(size(img,1),size(img,2),3));
    ResultImg(:,:,1)=img;
    ResultImg(:,:,2)=img;
    ResultImg(:,:,3)=img;
    ResultImg=WriteThreeCornerOnImg( ResultImg, TmpCloserInnerCorner, TmpFarInnerCorner, TmpFarOuterCorner );
    imshow(ResultImg);
    Satisfied=input('Ok with current label result?>','s');
    if Satisfied=='y' || Satisfied=='Y'
        CloserInnerCorner(:,ImgCount)=TmpCloserInnerCorner;
        FarInnerCorner(:,ImgCount)=TmpFarInnerCorner;
        FarOuterCorner(:,ImgCount)=TmpFarOuterCorner;
        ImgCount=ImgCount+1;
    end
end

SaveFileNamePrefix='Training_Sep26_right_';
SaveFileNameSuffix='.mat';
x=CloserInnerCorner;
save([SaveFileNamePrefix,'CloserInnerCorner', '__', int2str(sample_round), SaveFileNameSuffix],'x');
x=FarInnerCorner;
save([SaveFileNamePrefix,'FarInnerCorner', '__', int2str(sample_round), SaveFileNameSuffix],'x');
x=FarOuterCorner;
save([SaveFileNamePrefix,'FarOuterCorner', '__', int2str(sample_round), SaveFileNameSuffix],'x');

