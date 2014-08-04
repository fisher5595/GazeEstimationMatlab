function [ AffinityMatrix ] = DisplayAffinityMatrix( InputSpace, TransformMatrix )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
FeatureDimension=size(InputSpace,1);
NumOfFeature=size(InputSpace,2);
if nargin<2
    TransformMatrix=eye(FeatureDimension);
end
AffinityMatrix=double(zeros(NumOfFeature));
for i=1:NumOfFeature
    for j=1:NumOfFeature
        AffinityMatrix(i,j)=InputSpace(:,i)'*TransformMatrix*InputSpace(:,j);
    end
end
imagesc(AffinityMatrix);
colorbar();
end

