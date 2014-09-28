% Use image with labeled three point, use two inner corner positions and
% one outter corner far from nose.

clear;
ImageName='new_data_Sep_26/test_enlarged_ResizedEyes_left_';
ImageNumber=1;
FixpointRoundNumber=1;
RoundNumber=5;
RightCornerImageNumber=1;
ImageExtension='.jpg';
QueryImageNumber=1;
Resize=[5 10];

%extract eye corner position information
Train_CloserInnerCorner=load(['Training_Sep26_left_CloserInnerCorner' '__' int2str(FixpointRoundNumber) '.mat']);
Train_CloserInnerCorner=Train_CloserInnerCorner.x;
Train_FarInnerCorner=load(['Training_Sep26_left_FarInnerCorner' '__' int2str(FixpointRoundNumber) '.mat']);
Train_FarInnerCorner=Train_FarInnerCorner.x;
Train_FarOuterCorner=load(['Training_Sep26_left_FarOuterCorner' '__' int2str(FixpointRoundNumber) '.mat']);
Train_FarOuterCorner=Train_FarOuterCorner.x;
FixedPoints=[Train_CloserInnerCorner(:,1),Train_FarInnerCorner(:,1),Train_FarOuterCorner(:,1)];
Tmp=FixedPoints(2,:);
FixedPoints(2,:)=FixedPoints(1,:);
FixedPoints(1,:)=Tmp;
FixedPoints=round(FixedPoints);
FixedPoints=FixedPoints';
XRange=double(abs(FixedPoints(1,1)-FixedPoints(3,1)));
YRange=[Train_CloserInnerCorner(1,2)-XRange/2.5*0.8;Train_CloserInnerCorner(1,2)+XRange/2.5*0.2];
YRange=floor(YRange);
TemplateImage=imread([ImageName,int2str(ImageNumber),'__', int2str(FixpointRoundNumber),ImageExtension]);
CroppedImage=TemplateImage(YRange(1):YRange(2),FixedPoints(3,1):FixedPoints(1,1));
figure(1);
imshow(CroppedImage);
imwrite(CroppedImage,['new_data_Sep_26/enlarged_registeredEyes_Sep26_left_',int2str(1),'__', int2str(FixpointRoundNumber),'.jpg']);
RegisteredResizedImage=imresize(CroppedImage, Resize);
ImageVector=[];
for i=1:size(RegisteredResizedImage,1)
    ImageVector=[ImageVector RegisteredResizedImage(i,:)];
end
x.x=double(ImageVector')./255;
%save(['enlarged_RegisteredFeature_left_', int2str(1-1), '.mat'],'-struct','x');

%Load labeled parameters of new round captured images. Register new round
%images with the first eye image of the original captured eye image.
Train_CloserInnerCorner=load(['Training_Sep26_left_CloserInnerCorner' '__' int2str(RoundNumber) '.mat']);
Train_CloserInnerCorner=Train_CloserInnerCorner.x;
Train_FarInnerCorner=load(['Training_Sep26_left_FarInnerCorner' '__' int2str(RoundNumber) '.mat']);
Train_FarInnerCorner=Train_FarInnerCorner.x;
Train_FarOuterCorner=load(['Training_Sep26_left_FarOuterCorner' '__' int2str(RoundNumber) '.mat']);
Train_FarOuterCorner=Train_FarOuterCorner.x;

%Register 2-36 eye image with 1st eye image, resize and save feature
for QueryImageNumber=1:61
    MovingPoints=[Train_CloserInnerCorner(:,QueryImageNumber),Train_FarInnerCorner(:,QueryImageNumber),Train_FarOuterCorner(:,QueryImageNumber)];
    Tmp=MovingPoints(2,:);
    MovingPoints(2,:)=MovingPoints(1,:);
    MovingPoints(1,:)=Tmp;
    MovingPoints=round(MovingPoints);
    MovingPoints=MovingPoints';
    QueryImage=imread([ImageName,int2str(QueryImageNumber),'__', int2str(RoundNumber), ImageExtension]);
    tform = fitgeotrans(MovingPoints,FixedPoints,'nonreflectivesimilarity');
    QueryRegisteredImage=imwarp(QueryImage,tform,'OutputView',imref2d(size(TemplateImage)));
    figure(2);
    imshowpair(QueryImage,QueryRegisteredImage,'montage');
    %imshow(QueryRegisteredImage);
    figure(3);
    imshowpair(TemplateImage,QueryRegisteredImage,'montage');
    QueryCroppedImage=QueryRegisteredImage(YRange(1):YRange(2),FixedPoints(3,1):FixedPoints(1,1));
    figure(4);
    imshowpair(CroppedImage,QueryCroppedImage,'montage');
    imwrite(QueryCroppedImage,['new_data_Sep_26/enlarged_registeredEyes_Sep26_left_',int2str(QueryImageNumber),'__', int2str(RoundNumber),'.jpg']);
    RegisteredResizedImage=imresize(QueryCroppedImage, Resize);
    ImageVector=[];
    for i=1:size(RegisteredResizedImage,1)
        ImageVector=[ImageVector RegisteredResizedImage(i,:)];
    end
    ImageNorm=norm(double(ImageVector')./255);
    x.x=double(ImageVector')./255./ImageNorm;

    save(['new_data_Sep_26/enlarged_RegisteredFeature_Sep26_left_', int2str(QueryImageNumber-1),'__', int2str(RoundNumber), '.mat'],'-struct','x');
    %pause;
end
