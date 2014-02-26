%
% Generate and compare the gradient, edge matrix.
%
clear all;
clc;
ImageName='alignedEyes_right_';
ImageNumber=1;
QueryImageNumber=1;
ImageExtension='.jpg';
ReferenceImageGradient=GetNormalizedEdgeWithoutWeak(ImageName, ImageNumber, ImageExtension);
QueryImageGradient=GetNormalizedEdgeWithoutWeak (ImageName, QueryImageNumber, ImageExtension);
[height, width]=size(imread([ImageName,int2str(ImageNumber),ImageExtension]));
MatchingScore=zeros(height,width);

