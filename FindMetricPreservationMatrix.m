function [ S ] = FindMetricPreservationMatrix( InputFeatureSpace, TargetFeatureSpace, Sigma1, Sigma2 )
%This function finds a transformation between InputFeatureSpace and
%TargetFeatureSpace, output this transformation as Matrix S as the
%mahalanobis distance, x^T S x.
%   The affinity of a space uses simplest one as x^Tx.
epsilon=0.001;%epsilon for new solution 1
NumberOfFeatures=size(InputFeatureSpace,2);
FeatureDimension=size(InputFeatureSpace,1);
if nargin<3
    sigma1=64723;
    sigma2=0.1199;
else
    sigma1=Sigma1;
    sigma2=Sigma2;
end
S=eye(FeatureDimension);
for i=1:NumberOfFeatures
    for j=1:NumberOfFeatures
        w(i,j)=exp(-(TargetFeatureSpace(:,i)-TargetFeatureSpace(:,j))'*(TargetFeatureSpace(:,i)-TargetFeatureSpace(:,j))/2/sigma1);
    end
end
for i=1:NumberOfFeatures
    for j=1:NumberOfFeatures
        p(i,j)=w(i,j)/(sum(w(i,:))-w(i,i));
    end
    p(i,i)=0;
end
while 1
    %Simply use product of feature vector as affinity.
%     GradiantOfS=zeros(FeatureDimension,FeatureDimension);
%     for i=1:NumberOfFeatures
%         for j=1:NumberOfFeatures
%             GradiantOfS=GradiantOfS-(TargetFeatureSpace(:,i)'*TargetFeatureSpace(:,j))/(InputFeatureSpace(:,i)'*S*InputFeatureSpace(:,j))*(InputFeatureSpace(:,j)*InputFeatureSpace(:,i)');
%         end
%     end
%     NewS=S-GradiantOfS*epsilon;
%     [U,Lampda]=eig(NewS);
%     NewNewS=zeros(FeatureDimension);
%     for i=1:FeatureDimension
%         NewNewS=NewNewS+max(0,real(Lampda(i,i)))*U(:,i)*U(:,i)';
%     end
%     if sum(sum((NewNewS-S).^2))<=1
%         disp(sum(sum((NewNewS-S).^2)));
%         break;
%     else
%         %disp('NewNewS:');
%         %disp(NewNewS)
%         %disp(NewNewS);
%         disp(sum(sum((NewNewS-S).^2)));
%         InputAffinityMatrix=double(zeros(NumberOfFeatures));
%         TargetAffinityMatrix=double(zeros(NumberOfFeatures));
%         for i=1:NumberOfFeatures
%             for j=1:NumberOfFeatures
%                 InputAffinityMatrix(i,j)=InputFeatureSpace(:,i)'*S*InputFeatureSpace(:,j);
%                 TargetAffinityMatrix(i,j)=TargetFeatureSpace(:,i)'*TargetFeatureSpace(:,j);
%             end
%         end
% 
%         KLDivergense=sum(sum(TargetAffinityMatrix.*log(TargetAffinityMatrix)))-sum(sum(TargetAffinityMatrix.*log(InputAffinityMatrix)));
%         disp('KL');
%         disp(KLDivergense);
%         S=NewNewS;
%     end
    %Use diffusion as affinity matrix
    for i=1:NumberOfFeatures
        for j=1:NumberOfFeatures
            us(i,j)=exp(-(InputFeatureSpace(:,i)-InputFeatureSpace(:,j))'*S*(InputFeatureSpace(:,i)-InputFeatureSpace(:,j))/2/sigma2);
        end
    end
    %disp(us);

    for i=1:NumberOfFeatures
        for j=1:NumberOfFeatures
            qs(i,j)=us(i,j)/(sum(us(i,:))-us(i,i));
        end
        qs(i,i)=0;
    end
    deltaS=zeros(FeatureDimension);
    for i=1:NumberOfFeatures
        for j=1:NumberOfFeatures
            deltaS=deltaS+1/(2*sigma2)*(p(i,j)-qs(i,j))*(InputFeatureSpace(:,i)-InputFeatureSpace(:,j))*(InputFeatureSpace(:,i)-InputFeatureSpace(:,j))';
        end
    end
    %disp('deltaS:');
    %disp(deltaS);
    NewS=S-deltaS*epsilon;
    %disp('NewS:');
    %disp(NewS);
    [U,Lampda]=eig(NewS);
    NewNewS=zeros(FeatureDimension);
    for i=1:FeatureDimension
        NewNewS=NewNewS+max(0,real(Lampda(i,i)))*U(:,i)*U(:,i)';
    end
    if sum(sum((NewNewS-S).^2))<=0.00001
        disp(sum(sum((NewNewS-S).^2)));
        break;
    else
        %disp('NewNewS:');
        %disp(NewNewS)
        disp(sum(sum((NewNewS-S).^2)));
        S=NewNewS;
    end
%     disp('Qs-P');
%     disp(qs-p);
end
end

