%test case from i=1 to 36;
clear all;
clc;
featureName='feature_';
%featureName='AlignedFeature_';
%matrixAName='amatrix_';
groundTruthName='queryGroundTruth_';
knnPositionsName='knnPositions_';
r=5;
k_knn=5;
sigma1=80000;
sigma2=2;
epsilon=0.1;

for i = 1:36
    feature=load([featureName,int2str(i-1),'.mat']);
    %A=load([matrixAName,int2str(i-1),'.mat']);
    trainingPositions=load([knnPositionsName,int2str(i-1),'.mat']);
    groundTruth=load([groundTruthName,int2str(i-1),'.mat']);
    featurevector=feature.x;
    %matrixA=A.A;
    trainingPositionMatrix=trainingPositions.A;
    groundTruthVector=groundTruth.x;
    FeatureMatrix(:,i)=featurevector;
    PositionMatrix(:,i)=groundTruthVector';    
end
featuredimension=size(FeatureMatrix,1);
NumOfFeatures=size(FeatureMatrix,2);
y=PositionMatrix;
x=FeatureMatrix;
S=eye(featuredimension);
for i=1:NumOfFeatures
    for j=1:NumOfFeatures
        w(i,j)=exp(-(y(:,i)-y(:,j))'*(y(:,i)-y(:,j))/2/sigma1);
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
avgerror=sum(error)/size(error,2);

