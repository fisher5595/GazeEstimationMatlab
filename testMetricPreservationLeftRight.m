%test case from i=1 to 36;
clear all;
clc;
%featureName='feature_';
%matrixAName='amatrix_';
featureNameLeft='enlarged_AlignedFeature_left_';
featureNameRight='enlarged_AlignedFeature_right_';
groundTruthName='queryGroundTruth_';
knnPositionsName='knnPositions_';
r=12;%number of principal components
k_knn=21;
%sigma1=64723;
sigma1=376989.5;
sigma2=1.6348;
%sigma2=0.3304;
epsilon=0.1;

for i = 1:36
    leftfeature=load([featureNameLeft,int2str(i-1),'.mat']);
    rightfeature=load([featureNameRight,int2str(i-1),'.mat']);
    %A=load([matrixAName,int2str(i-1),'.mat']);
    trainingPositions=load([knnPositionsName,int2str(i-1),'.mat']);
    groundTruth=load([groundTruthName,int2str(i-1),'.mat']);
    leftfeaturevector=leftfeature.x;
    rightfeaturevector=rightfeature.x;
    %matrixA=A.A;
    trainingPositionMatrix=trainingPositions.A;
    groundTruthVector=groundTruth.x;
    OldFeatureMatrix(:,i)=[leftfeaturevector;rightfeaturevector];
    PositionMatrix(:,i)=groundTruthVector';    
end
% Do PCA
[COEFF,score,latent]=princomp(OldFeatureMatrix');
FeatureMatrix=(OldFeatureMatrix'*COEFF(:,1:r))';
FeatureMatrix=OldFeatureMatrix;
featuredimension=size(FeatureMatrix,1);
NumOfFeatures=size(FeatureMatrix,2);
y=PositionMatrix;
x=FeatureMatrix;
S=eye(featuredimension);
% for i=1:NumOfFeatures
%     for j=1:NumOfFeatures
%         w(i,j)=exp(-(y(:,i)-y(:,j))'*(y(:,i)-y(:,j))/2/sigma1);
%     end
% end

%
% Change distance of X from homo to heter, gradient of X change from 1 to 2 to
% 1, from border to center to border.
%
% for i=1:NumOfFeatures
%     for j=1:NumOfFeatures
%         if y(1,i)<240
%             y1=2*y(1,i)+y(1,i)^2/480-y(1,i);
%         else
%             y1=2*y(1,i)-y(1,i)^2/480+y(1,i);
%         end
%         if y(1,j)<240
%             y2=2*y(1,j)+y(1,j)^2/480-y(1,j);
%         else
%             y2=2*y(1,j)-y(1,j)^2/480+y(1,j);
%         end
%         if y(2,i)<320
%             x1=2*y(2,i)+y(2,i)^2/640-y(1,i);
%         else
%             x1=2*y(2,i)-y(2,i)^2/640+y(1,i);
%         end
%         if y(2,j)<320
%             x2=2*y(2,j)+y(2,j)^2/640-y(1,j);
%         else
%             x2=2*y(2,j)-y(2,j)^2/640+y(1,j);
%         end
%         w(i,j)=exp(-((x1-x2)^2+(y1-y2)^2)/2/sigma1);
%         dd(i,j)=(x1-x2)^2+(y1-y2)^2;
%     end
% end

%
% Change distance of X from homo to heter, gradient of X change from 2 to
% 1 to 2, from border to center to border
%
for i=1:NumOfFeatures
    for j=1:NumOfFeatures
        if y(1,i)<240
            y1=2*y(1,i)-y(1,i)^2/480;
        else
            y1=y(1,i)^2/480;
        end
        if y(1,j)<240
            y2=2*y(1,j)-y(1,j)^2/480;
        else
            y2=y(1,j)^2/480;
        end
        if y(2,i)<320
            x1=2*y(2,i)-y(2,i)^2/640;
        else
            x1=y(2,i)^2/640;
        end
        if y(2,j)<320
            x2=2*y(2,j)-y(2,j)^2/640;
        else
            x2=y(2,j)^2/640;
        end
        w(i,j)=exp(-((x1-x2)^2+(y1-y2)^2)/2/sigma1);
        dd(i,j)=(x1-x2)^2+(y1-y2)^2;
    end
end

for i=1:NumOfFeatures
    for j=1:NumOfFeatures
        p(i,j)=w(i,j)/(sum(w(i,:))-w(i,i));
    end
    p(i,i)=0;
end

while 1
    for i=1:NumOfFeatures
        for j=1:NumOfFeatures
            us(i,j)=exp(-(x(:,i)-x(:,j))'*S*(x(:,i)-x(:,j))/2/sigma2);
        end
    end
    %disp(us);

    for i=1:NumOfFeatures
        for j=1:NumOfFeatures
            qs(i,j)=us(i,j)/(sum(us(i,:))-us(i,i));
        end
        qs(i,i)=0;
    end
    deltaS=zeros(featuredimension);
    for i=1:NumOfFeatures
        for j=1:NumOfFeatures
            deltaS=deltaS+1/(2*sigma2)*(p(i,j)-qs(i,j))*(x(:,i)-x(:,j))*(x(:,i)-x(:,j))';
        end
    end
    %disp('deltaS:');
    %disp(deltaS);
    NewS=S-deltaS*epsilon;
    %disp('NewS:');
    %disp(NewS);
    [U,Lampda]=eig(NewS);
    NewNewS=zeros(featuredimension);
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
    disp('Qs-P');
    disp(qs-p);
end
disp('S:');
disp(S);
%S=eye(featuredimension);
for i = 1:36
    FeatureVector=FeatureMatrix(:,i);
    for ii = 1:36
        DistanceMatrix(ii)=(FeatureVector-FeatureMatrix(:,ii))'*S*(FeatureVector-FeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    disp('i');
    disp(i);
    disp('index:');
    disp(index);
    index(find(index==i))=[];
    KNNIndex=index(1:k_knn);
    TotalIndex(i,:)=KNNIndex;
    for k=1:k_knn
        AMatrix(:,k)=FeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=PositionMatrix(:,index(k));
    end
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=CMatrix\ones(k_knn,1);
    weight=weight./sum(weight);
    Weight(:,i)=weight;
    EstimatePosition=TrainingWeightMatrix*weight;
    error(i)=sum((EstimatePosition-PositionMatrix(:,i)).^2);
    
end
avgerror=sum(sqrt(error))/size(error,2);


