clear;
k_knn=8;
Kappa=1e-1;
SaveDir='./DataSet/';
addpath(genpath('l1magic'));
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

for SubjectNumber=0:9
    x=load([SaveDir,num2str(SubjectNumber),'/','TotalFeatureMatrix48', '.mat']);
    TotalFeatureMatrix=x.x;
    x=load([SaveDir,num2str(SubjectNumber),'/','TotalGazePositionMatrix48', '.mat']);
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
    CenterPosition=(TrainingPositionMatrix(:,1)+TestingPositionMatrix(:,NumOfFeaturesInTesting))./2;
    Errors=double(zeros(NumOfFeaturesInTesting,1));
    
    %%Extimate the espilon by leave one out experiment on training samples
    Epsilons=zeros(NumOfFeaturesInTraining,1);
    Alphas=double(zeros(NumOfFeaturesInTraining,1));

    for QueryNumber=1:NumOfFeaturesInTraining
        QueryFeature=TrainingFeatureMatrix(:,QueryNumber);
        QueryPosition=TrainingPositionMatrix(:,QueryNumber);
        TmpTrainingFeatureMatrix=TrainingFeatureMatrix;
        TmpTrainingPositionMatrix=TrainingPositionMatrix;
        TmpTrainingPositionMatrix(:,QueryNumber)=[];
        TmpTrainingFeatureMatrix(:,QueryNumber)=[];
        BestError=0;
        BestEpsilon=0.001;
%         StartingWeight=zeros(NumOfFeaturesInTraining,1);
%         StartingWeight(max(QueryNumber-1,1))=0.5;
%         StartingWeight(min(QueryNumber+1,NumOfFeaturesInTraining))=0.5;
%         StartingWeight(QueryNumber)=[];
        StartingWeight=pinv(TmpTrainingFeatureMatrix)*QueryFeature;
        
        %Try epsilon
        for epsilon=0.001:0.001:0.1
            if epsilon==0.001
                weight=l1qc_logbarrier(StartingWeight, TmpTrainingFeatureMatrix, [], QueryFeature, epsilon);
                BestError=norm(TmpTrainingPositionMatrix*weight-QueryPosition);
            else
                weight=l1qc_logbarrier(StartingWeight, TmpTrainingFeatureMatrix, [], QueryFeature, epsilon);
                Error=norm(TmpTrainingPositionMatrix*weight-QueryPosition);
                fprintf('l1 norm[%5.3f]\n',norm(weight,1));
                if abs(norm(weight,1)-1)<1e-2
                    break;
                end
                if Error<=BestError
                    BestError=Error;
                    BestEpsilon=epsilon;
                else
                    %break;
                end
                if norm(weight,1)<1
                    break;
                end
            end
        end
        fprintf('Query[%4.0f],BestEpsilon[%g],BestError[%8.4f]\n',QueryNumber,BestEpsilon,BestError);
        Epsilons(QueryNumber)=BestEpsilon;
        Alphas(QueryNumber)=exp(-Kappa*norm(QueryPosition-CenterPosition));
    end
    x.x=Epsilons;
    save([SaveDir,num2str(SubjectNumber),'/','ALR_Epsilons','.mat'],'-struct','x');
    x.x=Alphas;
    save([SaveDir,num2str(SubjectNumber),'/','ALR_Alphas','.mat'],'-struct','x');
    EstimatedEpsilon=(Epsilons'*Alphas)/sum(Alphas);
    fprintf('EstimatedEpsilon[%11.8f]\n',EstimatedEpsilon);
    
    %Testing
    Errors=double(zeros(NumOfFeaturesInTesting,1));
    for QueryNumber=1:NumOfFeaturesInTesting
        QueryFeature=TestingFeatureMatrix(:,QueryNumber);
        %Calculate the estimate gaze position and display it
        FeatureVector=QueryFeature;
        % Estimate start weight using knn solution
        DistanceMatrix=zeros(NumOfFeaturesInTraining,1);
        for ii = 1:NumOfFeaturesInTraining
            DistanceMatrix(ii)=(QueryFeature-TrainingFeatureMatrix(:,ii))'*(QueryFeature-TrainingFeatureMatrix(:,ii));
        end
        [SortedDistanceMatrix,index]=sort(DistanceMatrix);
        %index(find(index==QueryNumber))=[];

        for k=1:NumOfFeaturesInTraining
            AMatrix(:,k)=TrainingFeatureMatrix(:,index(k));
            TrainingWeightMatrix(:,k)=TrainingPositionMatrix(:,index(k));
        end
        CMatrix=(QueryFeature*ones(NumOfFeaturesInTraining,1)'-AMatrix)'*(QueryFeature*ones(NumOfFeaturesInTraining,1)'-AMatrix);
        weight=pinv(CMatrix)*ones(NumOfFeaturesInTraining,1);
        weight=weight./sum(weight);
    %     %Estimation for absolute gaze position
        StartingWeight=weight;
        StartPoint=ones(NumOfFeaturesInTraining,1);
        Newweight=l1qc_logbarrier(StartingWeight, TrainingFeatureMatrix, [], QueryFeature, EstimatedEpsilon);

        %Calculate estimation from weight
        EstimatePosition=TrainingPositionMatrix*Newweight;
        Errors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
        %figure(2);
    end
    
    AvgError=sum(Errors)/NumOfFeaturesInTesting;
    x.x=Errors;
    save([SaveDir,num2str(SubjectNumber),'/','Errors-48_ALR','.mat'],'-struct','x');
    fprintf('EstimatedEpsilon[%11.8f] AvgError[%8.4f]\n', EstimatedEpsilon, AvgError);
    sendmail(myaddress, sprintf('ALR -48 Subject[%02d]',SubjectNumber), [sprintf('AverageError[%8.5f]',AvgError) 10 ...
                 sprintf('EstimatedEpsilon[%11.8f]',EstimatedEpsilon)]);
end
