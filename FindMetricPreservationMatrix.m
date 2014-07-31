function [ S ] = FindMetricPreservationMatrix( InputFeatureSpace, TargetFeatureSpace )
%This function finds a transformation between InputFeatureSpace and
%TargetFeatureSpace, output this transformation as Matrix S as the
%mahalanobis distance, x^T S x.
%   The affinity of a space uses simplest one as x^Tx.
epsilon=10000;%epsilon for new solution 1
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
    for i=1:FeatureDimension
        NewNewS=NewNewS+max(0,Lampda(i,i))*U(:,i)*U(:,i)';
    end
    if sum(sum((NewNewS-S).^2))<=1
        disp(sum(sum((NewNewS-S).^2)));
        break;
    else
        %disp('NewNewS:');
        %disp(NewNewS)
        disp(NewNewS);
        disp(sum(sum((NewNewS-S).^2)));
        S=NewNewS;
    end
end

end

