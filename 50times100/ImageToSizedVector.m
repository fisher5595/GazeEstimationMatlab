%
% From image to feature vector with designated size
%
clear all;
clc;
ImageName='resizedEyes_left_';
ImageNumber=1;
RightCornerImageNumber=1;
ImageExtension='.jpg';
QueryImageNumber=1;
Resize=[3 5];

for QueryImageNumber=1:36
    AlignedQueryImage=imread(['alignedEyes_left_',int2str(QueryImageNumber),'.jpg']);
    AlignedResizedImage=imresize(AlignedQueryImage, Resize);
    ImageVector=[];
    for i=1:size(AlignedResizedImage,1)
        ImageVector=[ImageVector AlignedResizedImage(i,:)];
    end
    x.x=double(ImageVector')./255;
    save(['AlignedFeature_left35_', int2str(QueryImageNumber-1), '.mat'],'-struct','x');
end