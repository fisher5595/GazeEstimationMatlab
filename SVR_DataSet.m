clear;
k_knn=8;
addpath(genpath('libsvm'));
SaveDir='./DataSet/';
% Setup email your account and password.
myaddress = 'fisher5595@gmail.com';
mypassword = 'yp19871014';

setpref('Internet','E_mail',myaddress);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',myaddress);
setpref('Internet','SMTP_Password',mypassword);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

for SubjectNumber=5:7
    x=load([SaveDir,num2str(SubjectNumber),'/','TotalFeatureMatrix', '.mat']);
    TotalFeatureMatrix=x.x;
    x=load([SaveDir,num2str(SubjectNumber),'/','TotalGazePositionMatrix', '.mat']);
    TotalGazePositionMatrix=x.x;
    FeatureDimension=size(TotalFeatureMatrix,1);
    FeatureAmount=size(TotalFeatureMatrix,2);
    NumOfDifferentX=size(find(TotalGazePositionMatrix(1,:)==TotalGazePositionMatrix(1,1)),2);
    NumOfDifferentY=FeatureAmount/NumOfDifferentX;
    TrainingFeatureMatrix=[];
    TestingFeatureMatrix=[];
    TrainingPositionMatrix=[];
    TestingPositionMatrix=[];

    for y=1:NumOfDifferentY
        for x=1:NumOfDifferentX-1
            if mod(x+y,2)==0
                TrainingFeatureMatrix=[TrainingFeatureMatrix TotalFeatureMatrix(:,(y-1)*NumOfDifferentX+x)];
                TrainingPositionMatrix=[TrainingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
            else
                TestingFeatureMatrix=[TestingFeatureMatrix TotalFeatureMatrix(:,(y-1)*NumOfDifferentX+x)];
                TestingPositionMatrix=[TestingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
            end
        end
    end

    NumOfFeaturesInTraining=size(TrainingFeatureMatrix,2);
    NumOfFeaturesInTesting=size(TestingFeatureMatrix,2);
    Errors=double(zeros(NumOfFeaturesInTesting,1));
    EstimatedC1=EstimateCOfSVR( 100000, 10, 1e4, 1, TrainingPositionMatrix(1,:)', TrainingFeatureMatrix' );
    EstimatedC2=EstimateCOfSVR( 100000, 10, 1e4, 1, TrainingPositionMatrix(2,:)', TrainingFeatureMatrix' );
    SVR_C=(EstimatedC1+EstimatedC2)/2;

    % Train SVM regressors based on estimated C
    SVMRegressorY=svmtrain(TrainingPositionMatrix(1,:)',TrainingFeatureMatrix',['-s 3 -t 0 -c ' num2str(EstimatedC1) ' -p 1']);
    SVMRegressorX=svmtrain(TrainingPositionMatrix(2,:)',TrainingFeatureMatrix',['-s 3 -t 0 -c ' num2str(EstimatedC2) ' -p 1']);
    [PredictedY, accuracy, decision_values] = svmpredict(TestingPositionMatrix(1,:)', TestingFeatureMatrix', SVMRegressorY, 'libsvm_options');
    [PredictedX, accuracy, decision_values] = svmpredict(TestingPositionMatrix(2,:)', TestingFeatureMatrix', SVMRegressorX, 'libsvm_options');
    PredictedGaze=[PredictedY';PredictedX'];

    % Calculate the average error
    EstimationGroundTruthGapMatrix=PredictedGaze-TestingPositionMatrix;
    NumOfFeaturesInTesting=size(EstimationGroundTruthGapMatrix,2);
    TotalError=0;
    for i=1:NumOfFeaturesInTesting
        Errors(i)=norm(EstimationGroundTruthGapMatrix(:,i));
    end
    AvgError=sum(Errors)/NumOfFeaturesInTesting;
    x.x=Errors;
    save([SaveDir,num2str(SubjectNumber),'/','Errors_SVR','.mat'],'-struct','x');
    fprintf('EstimatedC[%d] AvgError[%8.4f]\n', SVR_C, AvgError);
    sendmail(myaddress, sprintf('SVR Subject[%02d]',SubjectNumber), [sprintf('AverageError[%8.5f]',AvgError) 10 ...
                 sprintf('EstimatedC1[%d]',EstimatedC1) 10 sprintf('EstimatedC2[%d]',EstimatedC2)]);
end
