%SVR prediction on gaze estimation with same training and testing dataset.

%Load features
clear;
addpath(genpath('libsvm'));
k_knn=30;
featureName='enlarged_RegisteredFeature_Aug27_left_';
rightfeatureName='enlarged_RegisteredFeature_Aug27_right_';
xspace=floor(640/7);
yspace=floor(480/7);
halfxspace=floor(double(xspace/2));
halfyspace=floor(double(yspace/2));
%Load training feature matrix.
for RoundNumber=1:4
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        rightfeature=load([rightfeatureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        rightfeaturevector=rightfeature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*36)=[featurevector;rightfeaturevector]; 
    end
end

%Load testing feature matrix
for RoundNumber=5
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        rightfeature=load([rightfeatureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        rightfeaturevector=rightfeature.x;
        TestingFeatureMatrix(:,i)=[featurevector;rightfeaturevector]; 
    end
end

%Generate all training position information, stored in a PositionMatrix.
for RoundNumber=1:4
    for y=1:6
        for x=1:6
            PositionMatrix(1,(y-1)*6+x+(RoundNumber-1)*36)=floor(480/7*y);
            PositionMatrix(2,(y-1)*6+x+(RoundNumber-1)*36)=floor(640/7*x);
        end
    end
end

%Generate testing positon information
for RoundNumber=5
    for y=1:6
        for x=1:6
            TestingPositionMatrix(1,(y-1)*6+x)=floor(480/7*y);
            TestingPositionMatrix(2,(y-1)*6+x)=floor(640/7*x);
        end
    end
end

% Corse to fine to estimate parameter of C;
EstimatedC1=EstimateCOfSVR( 100000, 10, 1e4, 1, PositionMatrix(1,:)', FeatureMatrix' );
EstimatedC2=EstimateCOfSVR( 100000, 10, 1e4, 1, PositionMatrix(2,:)', FeatureMatrix' );
SVR_C=(EstimatedC1+EstimatedC2)/2;

% Train SVM regressors based on estimated C
SVMRegressorY=svmtrain(PositionMatrix(1,:)',FeatureMatrix',['-s 3 -t 0 -c ' num2str(EstimatedC1) ' -p 1']);
SVMRegressorX=svmtrain(PositionMatrix(2,:)',FeatureMatrix',['-s 3 -t 0 -c ' num2str(EstimatedC2) ' -p 1']);
[PredictedY, accuracy, decision_values] = svmpredict(TestingPositionMatrix(1,:)', TestingFeatureMatrix', SVMRegressorY, 'libsvm_options');
[PredictedX, accuracy, decision_values] = svmpredict(TestingPositionMatrix(2,:)', TestingFeatureMatrix', SVMRegressorX, 'libsvm_options');
PredictedGaze=[PredictedY';PredictedX'];

% Calculate the average error
EstimationGroundTruthGapMatrix=PredictedGaze-TestingPositionMatrix;
NumOfQuery=size(EstimationGroundTruthGapMatrix,2);
Errors=zeros(NumOfQuery,1);
TotalError=0;
for i=1:NumOfQuery
    TotalError=TotalError+norm(EstimationGroundTruthGapMatrix(:,i));
    Errors(i)=norm(EstimationGroundTruthGapMatrix(:,i));
end

x.x=Errors;
save(['Errors_SVR','.mat'],'-struct','x');
AvgError=TotalError/NumOfQuery;
fprintf('EstimatedC[%d] AvgError[%8.4f]\n', SVR_C, AvgError);
