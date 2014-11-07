%SVR prediction on gaze estimation with splitted training and testing dataset.

%Load features
clear;
addpath(genpath('libsvm'));
k_knn=30;
featureName='50times100/new_data_Sep_26/enlarged_RegisteredFeature_Sep26_left_';
rightfeatureName='50times100/new_data_Sep_26/enlarged_RegisteredFeature_Sep26_right_';
xspace=floor(640/7);
yspace=floor(480/7);
halfxspace=floor(double(xspace/2));
halfyspace=floor(double(yspace/2));
%Load all feature matrix.
for RoundNumber=1:5
    for i = 1:61
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        rightfeature=load([rightfeatureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        rightfeaturevector=rightfeature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*61)=[featurevector;rightfeaturevector]; 
    end
end

%Split feature matrix into training feature matrix and testing feature
%matrix, also add the position matrices
TrainingMatrix=[];
TestingFeatureMatrix=[];
PositionMatrix=[];
TestingPositionMatrix=[];
for RoundNumber=1:5
    for y=1:6
        for x=1:6
            TrainingMatrix=[TrainingMatrix FeatureMatrix(:,(RoundNumber-1)*61+(y-1)*11+x)];
            PositionMatrix=[PositionMatrix [yspace*y;xspace*x]];
        end
        if y~=6
            for xx=1:5
                TestingFeatureMatrix=[TestingFeatureMatrix FeatureMatrix(:,(RoundNumber-1)*61+(y-1)*11+x+xx)];
                TestingPositionMatrix=[TestingPositionMatrix [yspace*y+halfyspace;halfxspace+xx*xspace]];
            end
        end
    end
end
% Corse to fine to estimate parameter of C;
FeatureMatrix=TrainingMatrix;
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
%save(['Errors_SplitTrainTest_SVR_','.mat'],'-struct','x');
x.x=PredictedGaze;
save(['Estimations_SplitTrainTest_SVR_','.mat'],'-struct','x');
AvgError=TotalError/NumOfQuery;
fprintf('EstimatedC[%d] AvgError[%8.4f]\n', SVR_C, AvgError);
