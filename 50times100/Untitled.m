%eye corner detection and alignment.
%detect eye corners using left and right most points of canny edge. Save
%eye corners in first image as templates and match them in the following
%images, to detect the locaiton of eye corners in following images.

clear all;
clc;
ImageName='enlarged_ResizedEyes_left_';
ImageNumber=1;
RightCornerImageNumber=1;
ImageExtension='.jpg';
QueryImageNumber=1;
Resize=[5 10];

%Find eye corner image template.
TemplateImage=imread([ImageName,int2str(ImageNumber),ImageExtension]);
RightTemplateImage=imread([ImageName,int2str(RightCornerImageNumber),ImageExtension]);

%
% Find eye corner by finding the left most and righ most point in canny
% edge map. This is not so accurate.
%

% EdgeMap=edge(TemplateImage,'canny');
% imshow(EdgeMap);
% RightEdgeMap=edge(RightTemplateImage,'canny');
% [Height,Width]=size(TemplateImage);
% LeftMostCornerPosition=[Height;Width];
% RightMostCornerPosition=[1;1];
% 
% for i=1:Height
%     for j=1:Width
%         if EdgeMap(i,j) == 1
%             if j<=LeftMostCornerPosition(2)
%                 LeftMostCornerPosition=[i;j];
%             end
%         end
%         if RightEdgeMap(i,j) == 1
%             if j>=RightMostCornerPosition(2)
%                 RightMostCornerPosition=[i;j];
%             end
%         end
%     end
% end
% 
% CornerTemplate=TemplateImage(max(LeftMostCornerPosition(1)-20,1):min(LeftMostCornerPosition(1)+5,Height),max(LeftMostCornerPosition(2),1):min(LeftMostCornerPosition(2)+20,Width));
% figure(1);
% imshow(CornerTemplate);
% 
% RightCornerTemplate=RightTemplateImage(max(RightMostCornerPosition(1)-20,1):min(RightMostCornerPosition(1)+5,Height),max(RightMostCornerPosition(2)-5,1):min(RightMostCornerPosition(2)+5,Width));
% figure(2);
% imshow(RightCornerTemplate);
%
%figure(3);
%imshow(LabelImageWithRectangle(RightTemplateImage,[max(RightMostCornerPosition(1)-20,1);max(RightMostCornerPosition(2)-5,1)],size(RightCornerTemplate)));
%
%TemplateImageWithLabel=double(zeros(Height,Width,3));
%for i=1:3
%    TemplateImageWithLabel(:,:,i)=TemplateImage(:,:);
%end
%CornerTemplatePosition=[max(LeftMostCornerPosition(1)-20,1);max(LeftMostCornerPosition(2),1)];
%CornerTemplateSize=size(CornerTemplate);
%figure(4)
%ImageWithLabel=LabelImageWithRectangle(TemplateImage,CornerTemplatePosition,CornerTemplateSize);
%imshow(ImageWithLabel);
[CornerTemplate, CornerPosition]=imcrop(TemplateImage);
pause;
[RightCornerTemplate, RightCornerPosition]=imcrop(RightTemplateImage);
figure(1);
subplot(1,2,1);
imshow(CornerTemplate);
subplot(1,2,2);
imshow(RightCornerTemplate);

figure(2);
subplot(1,2,1);
imshow(LabelImageWithRectangle(TemplateImage,[floor(CornerPosition(2)),floor(CornerPosition(1))],size(CornerTemplate)));
subplot(1,2,2);
imshow(LabelImageWithRectangle(RightTemplateImage,[floor(RightCornerPosition(2)),floor(RightCornerPosition(1))],size(RightCornerTemplate)));

CornerTemplateSize=size(CornerTemplate);


for QueryImageNumber=1:36
    QueryImage=imread([ImageName,int2str(QueryImageNumber),ImageExtension]);
    MatchingPosition=SSDTemplateMaching(CornerTemplate,QueryImage);
    figure(3)
    imshow(LabelImageWithRectangle(QueryImage,MatchingPosition,CornerTemplateSize));

    RightCornerMatchingPosition=SSDTemplateMaching(RightCornerTemplate,QueryImage);
    figure(4)
    imshow(LabelImageWithRectangle(QueryImage,RightCornerMatchingPosition,size(RightCornerTemplate)));

    RightCornerPosition=[int32(RightCornerMatchingPosition(1)+0.5*size(RightCornerTemplate,1));int32(RightCornerMatchingPosition(2)+0.5*size(RightCornerTemplate,2))];
    LeftCornerPosition=[int32(MatchingPosition(1)+0.5*size(CornerTemplate,1));int32(MatchingPosition(2)+0.5*size(CornerTemplate,2))];
    figure(5)
    AlignedSize=[int32((RightCornerPosition(2)-LeftCornerPosition(2))*0.45);RightCornerPosition(2)-LeftCornerPosition(2)];
    LeftUpCorner=[int32(LeftCornerPosition(1)-0.7*AlignedSize(1));LeftCornerPosition(2)];
    imshow(LabelImageWithRectangle(QueryImage,LeftUpCorner,AlignedSize));
    AlignedQueryImage=imresize(QueryImage(LeftUpCorner(1):LeftUpCorner(1)+AlignedSize(1)-1,LeftUpCorner(2):LeftUpCorner(2)+AlignedSize(2)-1),[45 100]);
    imwrite(AlignedQueryImage,['enlarged_alignedEyes_left_',int2str(QueryImageNumber),'.jpg']);
    AlignedResizedImage=imresize(AlignedQueryImage, Resize);
    ImageVector=[];
    for i=1:size(AlignedResizedImage,1)
        ImageVector=[ImageVector AlignedResizedImage(i,:)];
    end
    x.x=double(ImageVector')./255;
    save(['enlarged_AlignedFeature_left_', int2str(QueryImageNumber-1), '.mat'],'-struct','x');
end


