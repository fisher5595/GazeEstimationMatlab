function [ Divergence ] = CalKLDivergence( InputSpace, TargetSpace, sigma )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
FeatureDimension=size(InputSpace,1);
NumOfFeature=size(InputSpace,2);

AffinityMatrix=double(zeros(NumOfFeature));

%Use simple product as the affinity
% for i=1:NumOfFeature
%     for j=1:NumOfFeature
%         AffinityMatrix(i,j)=InputSpace(:,i)'*TransformMatrix*InputSpace(:,j);
%     end
% end

%Use diffusion map as affinity matrix
for i=1:NumOfFeature
    for j=1:NumOfFeature
        w(i,j)=exp(-(InputSpace(:,i)-InputSpace(:,j))'*(InputSpace(:,i)-InputSpace(:,j))/2/sigma);
    end
end
for i=1:NumOfFeature
    for j=1:NumOfFeature
        AffinityMatrix(i,j)=w(i,j)/(sum(w(i,:))-w(i,i));
    end
    AffinityMatrix(i,i)=1;
end

TargetAffinityMatrix=double(zeros(NumOfFeature));

%Use simple product as the affinity
% for i=1:NumOfFeature
%     for j=1:NumOfFeature
%         AffinityMatrix(i,j)=InputSpace(:,i)'*TransformMatrix*InputSpace(:,j);
%     end
% end

%Use diffusion map as affinity matrix
for i=1:NumOfFeature
    for j=1:NumOfFeature
        u(i,j)=exp(-(TargetSpace(:,i)-TargetSpace(:,j))'*(TargetSpace(:,i)-TargetSpace(:,j))/2/sigma);
    end
end
for i=1:NumOfFeature
    for j=1:NumOfFeature
        TargetAffinityMatrix(i,j)=u(i,j)/(sum(u(i,:))-u(i,i));
    end
    TargetAffinityMatrix(i,i)=1;
end
KL=sum(sum(AffinityMatrix.*log(AffinityMatrix)))-sum(sum(AffinityMatrix.*log(TargetAffinityMatrix)));
Divergence=KL;
end

