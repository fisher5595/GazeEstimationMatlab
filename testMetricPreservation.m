%test case from i=1 to 36;
clear;
clc;
%featureName='feature_';
%matrixAName='amatrix_';
featureName='enlarged_RegisteredFeature_left_';
%%
%svd parameter
r=2;
%extract eye contour parameters
Train_A=load('Training_A.mat');
Train_A=Train_A.x;
Train_A2=load('Training_A2.mat');
Train_A2=Train_A2.x;
Train_B=load('Training_B.mat');
Train_B=Train_B.x;
Train_B2=load('Training_B2.mat');
Train_B2=Train_B2.x;
Train_C=load('Training_C.mat');
Train_C=Train_C.x;
Train_R=load('Training_R.mat');
Train_R=Train_R.x;
Train_Theta=load('Training_Theta.mat');
Train_Theta=Train_Theta.x;
Train_Xe=load('Training_Xe.mat');
Train_Xe=Train_Xe.x;
Train_Xc=load('Training_Xc.mat');
Train_Xc=Train_Xc.x;
Train_Parameters_Matrix=[Train_A;Train_A2;Train_B;Train_B2;Train_C;Train_R;Train_Theta;Train_Xe;Train_Xc];
%Generate new features of from model parameters, new feature is sample
%point coordinates of each model instance.
Train_Model_Instance_Coordinates_Matrix=[];
for i=1:size(Train_Parameters_Matrix,2)
    Train_A=Train_Parameters_Matrix(1,i);
    Train_A2=Train_Parameters_Matrix(2,i);
    Train_B=Train_Parameters_Matrix(3,i);
    Train_B2=Train_Parameters_Matrix(4,i);
    Train_C=Train_Parameters_Matrix(5,i);
    Train_R=Train_Parameters_Matrix(6,i);
    Train_Theta=Train_Parameters_Matrix(7,i);
    Train_Xe=Train_Parameters_Matrix(8:9,i);
    Train_Xc=Train_Parameters_Matrix(10:11,i);
    Train_Model_Instance_Coordinates_Vector=GenerateSamplePointCoordinatesOfOneInstance( Train_Xe, Train_Xc, Train_Theta, Train_A, Train_A2, Train_C, Train_B, Train_B2, Train_R );
    Train_Model_Instance_Coordinates_Matrix=[Train_Model_Instance_Coordinates_Matrix Train_Model_Instance_Coordinates_Vector];
end
[U,S,V]=svd(Train_Parameters_Matrix);
P=U(:,1:r);
%Train_Parameters_Matrix=P'*Train_Parameters_Matrix;
%%
groundTruthName='queryGroundTruth_';
knnPositionsName='knnPositions_';
r=3;
k_knn=35;
sigma1=64723;
%sigma1=376989.5;
%sigma1 for feature with contour parameters
sigma2=1674;
%sigma2=1.0874;
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
%Add labeled eye contour parameters to feature matrix
FeatureMatrix=FeatureMatrix;
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

%
% Change distance of X from homo to heter, gradient of X change from 2 to
% 1
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
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);
    Weight(:,i)=weight;
    EstimatePosition=TrainingWeightMatrix*weight;
    error(i)=sum((EstimatePosition-PositionMatrix(:,i)).^2);
    
end
avgerror=sum(sqrt(error))/size(error,2);


