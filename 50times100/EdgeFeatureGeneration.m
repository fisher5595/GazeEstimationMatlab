%
% Generate and compare the gradient, edge matrix.
%
clear all;
clc;
ImageName='enlarged_alignedEyes_left_';
RightImageName='enlarged_alignedEyes_right_';
ImageNumber=2;
ImageExtension='.jpg';
ReferenceImageGradient=GetNormalizedEdgeWithoutWeak(ImageName, ImageNumber, ImageExtension);
RightReferenceImageGradient=GetNormalizedEdgeWithoutWeak(RightImageName, ImageNumber, ImageExtension);
ScoreResult=zeros(1,36);
for QueryImageNumber=1:36
    QueryImageGradient=GetNormalizedEdgeWithoutWeak (ImageName, QueryImageNumber, ImageExtension);
    RightQueryImageGradient=GetNormalizedEdgeWithoutWeak (RightImageName, QueryImageNumber, ImageExtension);
    [height, width]=size(imread([ImageName,int2str(ImageNumber),ImageExtension]));
    MatchingScore=QueryImageGradient(:,:,1).*ReferenceImageGradient(:,:,1)+QueryImageGradient(:,:,2).*ReferenceImageGradient(:,:,2);
    RightMatchingScore=RightQueryImageGradient(:,:,1).*RightReferenceImageGradient(:,:,1)+RightQueryImageGradient(:,:,2).*RightReferenceImageGradient(:,:,2);
    ScoreResult(QueryImageNumber)=sum(sum(MatchingScore))+sum(sum(RightMatchingScore));
end
[SortedResult,index]=sort(ScoreResult,'descend');