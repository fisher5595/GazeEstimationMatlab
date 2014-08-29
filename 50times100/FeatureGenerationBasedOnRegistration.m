% Use image with labeled contour parameter, use two outer eye corners as
% anchor points to register image, use registered one to generate
% appearance feature

clear;
ImageName='new_data/test_enlarged_ResizedEyes_right_';
ImageNumber=1;
FixpointRoundNumber=1;
RoundNumber=5;
RightCornerImageNumber=1;
ImageExtension='.jpg';
QueryImageNumber=1;
Resize=[5 10];

%extract eye contour parameters and get fixed points, which are the left
%and right corner x and y coordinates of the first eye image
Train_A=load(['Training_Aug27_right_A' '__' int2str(FixpointRoundNumber) '.mat']);
Train_A=Train_A.x;
Train_A2=load(['Training_Aug27_right_A2' '__' int2str(FixpointRoundNumber) '.mat']);
Train_A2=Train_A2.x;
Train_B=load(['Training_Aug27_right_B' '__' int2str(FixpointRoundNumber) '.mat']);
Train_B=Train_B.x;
Train_B2=load(['Training_Aug27_right_B2' '__' int2str(FixpointRoundNumber) '.mat']);
Train_B2=Train_B2.x;
Train_C=load(['Training_Aug27_right_C' '__' int2str(FixpointRoundNumber) '.mat']);
Train_C=Train_C.x;
Train_R=load(['Training_Aug27_right_R' '__' int2str(FixpointRoundNumber) '.mat']);
Train_R=Train_R.x;
Train_Theta=load(['Training_Aug27_right_Theta' '__' int2str(FixpointRoundNumber) '.mat']);
Train_Theta=Train_Theta.x;
Train_Xe=load(['Training_Aug27_right_Xe' '__' int2str(FixpointRoundNumber) '.mat']);
Train_Xe=Train_Xe.x;
Train_Xc=load(['Training_Aug27_right_Xc' '__' int2str(FixpointRoundNumber) '.mat']);
Train_Xc=Train_Xc.x;
FixedPoints=[Train_Xe(2,1)-cos(Train_Theta(1))*Train_B2(1), Train_Xe(1,1)+sin(Train_Theta(1))*Train_B2(1); Train_Xe(2,1)+cos(Train_Theta(1))*Train_B2(1),Train_Xe(1,1)-sin(Train_Theta(1))*Train_B2(1)];
FixedPoints=round(FixedPoints);
YRange=[Train_Xe(1,1)-Train_A2(1)+3;Train_Xe(1,1)+Train_C(1)];
YRange=floor(YRange);
TemplateImage=imread([ImageName,int2str(ImageNumber),'__', int2str(FixpointRoundNumber),ImageExtension]);
CroppedImage=TemplateImage(YRange(1):YRange(2),FixedPoints(1,1):FixedPoints(2,1));
figure(1);
imshow(CroppedImage);
imwrite(CroppedImage,['new_data/enlarged_registeredEyes_Aug27_right_',int2str(1),'__', int2str(FixpointRoundNumber),'.jpg']);
RegisteredResizedImage=imresize(CroppedImage, Resize);
ImageVector=[];
for i=1:size(RegisteredResizedImage,1)
    ImageVector=[ImageVector RegisteredResizedImage(i,:)];
end
x.x=double(ImageVector')./255;
%save(['enlarged_RegisteredFeature_left_', int2str(1-1), '.mat'],'-struct','x');

%Load labeled parameters of new round captured images. Register new round
%images with the first eye image of the original captured eye image.
Train_A=load(['Training_Aug27_right_A' '__' int2str(RoundNumber) '.mat']);
Train_A=Train_A.x;
Train_A2=load(['Training_Aug27_right_A2' '__' int2str(RoundNumber) '.mat']);
Train_A2=Train_A2.x;
Train_B=load(['Training_Aug27_right_B' '__' int2str(RoundNumber) '.mat']);
Train_B=Train_B.x;
Train_B2=load(['Training_Aug27_right_B2' '__' int2str(RoundNumber) '.mat']);
Train_B2=Train_B2.x;
Train_C=load(['Training_Aug27_right_C' '__' int2str(RoundNumber) '.mat']);
Train_C=Train_C.x;
Train_R=load(['Training_Aug27_right_R' '__' int2str(RoundNumber) '.mat']);
Train_R=Train_R.x;
Train_Theta=load(['Training_Aug27_right_Theta' '__' int2str(RoundNumber) '.mat']);
Train_Theta=Train_Theta.x;
Train_Xe=load(['Training_Aug27_right_Xe' '__' int2str(RoundNumber) '.mat']);
Train_Xe=Train_Xe.x;
Train_Xc=load(['Training_Aug27_right_Xc' '__' int2str(RoundNumber) '.mat']);
Train_Xc=Train_Xc.x;

%Register 2-36 eye image with 1st eye image, resize and save feature
for QueryImageNumber=1:36
    MovingPoints=[Train_Xe(2,QueryImageNumber)-cos(Train_Theta(QueryImageNumber))*Train_B2(QueryImageNumber), Train_Xe(1,QueryImageNumber)+sin(Train_Theta(QueryImageNumber))*Train_B2(QueryImageNumber); Train_Xe(2,QueryImageNumber)+cos(Train_Theta(QueryImageNumber))*Train_B2(QueryImageNumber),Train_Xe(1,QueryImageNumber)-sin(Train_Theta(QueryImageNumber))*Train_B2(QueryImageNumber)];
    MovingPoints=round(MovingPoints);
    QueryImage=imread([ImageName,int2str(QueryImageNumber),'__', int2str(RoundNumber), ImageExtension]);
    tform = fitgeotrans(MovingPoints,FixedPoints,'nonreflectivesimilarity');
    QueryRegisteredImage=imwarp(QueryImage,tform,'OutputView',imref2d(size(TemplateImage)));
    figure(2);
    imshowpair(QueryImage,QueryRegisteredImage,'montage');
    %imshow(QueryRegisteredImage);
    figure(3);
    imshowpair(TemplateImage,QueryRegisteredImage,'montage');
    QueryCroppedImage=QueryRegisteredImage(YRange(1):YRange(2),FixedPoints(1,1):FixedPoints(2,1));
    figure(4);
    imshowpair(CroppedImage,QueryCroppedImage,'montage');
    imwrite(QueryCroppedImage,['new_data/enlarged_registeredEyes_Aug27_right_',int2str(QueryImageNumber),'__', int2str(RoundNumber),'.jpg']);
    RegisteredResizedImage=imresize(QueryCroppedImage, Resize);
    ImageVector=[];
    for i=1:size(RegisteredResizedImage,1)
        ImageVector=[ImageVector RegisteredResizedImage(i,:)];
    end
    x.x=double(ImageVector')./255;
    save(['new_data/enlarged_RegisteredFeature_Aug27_right_', int2str(QueryImageNumber-1),'__', int2str(RoundNumber), '.mat'],'-struct','x');
    pause;
end
