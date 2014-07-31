function [ S ] = FindMetricPreservationMatrix( InputFeatureSpace, TargetFeatureSpace )
%This function finds a transformation between InputFeatureSpace and
%TargetFeatureSpace, output this transformation as Matrix S as the
%mahalanobis distance, x^T S x.
%   The affinity of a space uses simplest one as x^Tx.
epsilon=0.1;
NumberOfFeatures=size(InputFeatureSpace,2);
FeatureDimension=size(InputFeatureSpace,1);

S=eye(FeatureDimension);

while 1
    GradiantOfS=zeros(FeatureDimension,FeatureDimension);
    for i=1:NumberOfFeatures
        for j=1:NumberOfFeatures
            GradiantOfS=GradiantOfS-(TargetFeatureSpace(:,i)'*TargetFeatureSpace(:,j))/(InputFeatureSpace(:,i)'*S*InputFeatureSpace(:,j))*(InputFeatureSpace(:,j)*InputFeatureSpace(:,i)');
        end
    end
    NewS=S-GradiantOfS*epsilon;
    [U,Lampda]=eig(NewS);
    NewNewS=zeros(FeatureDimension);
    for i=1:featuredimension
        NewNewS=NewNewS+max(0,Lampda(i,i))*U(:,i)*U(:,i)';
    end
    if sum(sum((NewNewS-S).^2))<=0.00001
        disp(sum(sum((NewNewS-S).^2)));
        break;
    else
        %disp('NewNewS:');
        %disp(NewNewS)
        S=NewNewS;
    end
end

end

