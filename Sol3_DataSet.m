%Refer to Professor Wu's new method pdf, new solution 3.

%Load features
clear;
%lamda=1;
k_knn=8;
SaveDir='./DataSet/';
InputFileDir='/media/peiyu/OS/Users/PeiYu/Downloads/s00-09';
SubjectNumber=9;
StoppingCriterion=1e-9;
StepSize=0.01;
BestLambda=10;
InitialScale=1;
EndingScale=0.001;
Tolerance=EndingScale/100;

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

%sendmail(myaddress, 'Start of all work', 'Watch out');

%Load data and split training and testing data.
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
Tmp=double(zeros(NumOfFeaturesInTraining,NumOfFeaturesInTraining));
for i=1:NumOfFeaturesInTraining
    for j=1:NumOfFeaturesInTraining
        Tmp(i,j)=(TrainingFeatureMatrix(:,i)-TrainingFeatureMatrix(:,j))'*(TrainingFeatureMatrix(:,i)-TrainingFeatureMatrix(:,j));
    end
end
Sigma2=std(Tmp(:));

for i=1:NumOfFeaturesInTraining
    for j=1:NumOfFeaturesInTraining
        Tmp(i,j)=(TrainingPositionMatrix(:,i)-TrainingPositionMatrix(:,j))'*(TrainingPositionMatrix(:,i)-TrainingPositionMatrix(:,j));
    end
end
Sigma1=std(Tmp(:));
x=load([SaveDir,num2str(SubjectNumber),'/','S-48-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'.mat']);
S=x.x;

%% Estimate the best lambda
LastScale=InitialScale*10;
Scale=InitialScale;
Errors=zeros(NumOfFeaturesInTesting,1);
BestErrors=zeros(NumOfFeaturesInTesting,1);
AvgErrorsAndLambdas=zeros(2,round((BestLambda+LastScale-max(0,BestLambda-LastScale))/EndingScale)+1);
for i=max(0,BestLambda-LastScale):EndingScale:BestLambda+LastScale
    AvgErrorsAndLambdas(1,round((i-max(0,BestLambda-LastScale))/EndingScale)+1)=i;
end
% Give the initial best avg error
for QueryNumber=1:NumOfFeaturesInTesting
    fprintf('Querynum[%d]',QueryNumber);
    QueryFeature=TestingFeatureMatrix(:,QueryNumber);
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
    DistanceMatrix=zeros(1,NumOfFeaturesInTraining);
    for ii = 1:NumOfFeaturesInTraining
        DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    %disp('index:');
    %disp(index);
    %index(find(index==QueryNumber))=[];

    for k=1:k_knn
        AMatrix(:,k)=TrainingFeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=TrainingPositionMatrix(:,index(k));
    end
    BMatrix=TrainingWeightMatrix;
    A=AMatrix;
    B=BMatrix;
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);

    %% Use matlab funciton do optimizaiton for new solution 3 target func
    options = optimoptions('fminunc','Display','off','GradObj','on','DerivativeCheck','off');
    [Newweight,fval,exitflag]=fminunc(@(x) Solution3TargetFuncVal_DataSet(x, S, AMatrix, B, BestLambda, FeatureVector, TrainingFeatureMatrix, TrainingPositionMatrix, QueryFeature,Sigma1,Sigma2),weight,options);
    %options = optimoptions('fmincon','Display','off','GradObj','on','DerivativeCheck','off');
    %[Newweight,fval,exitflag]=fmincon(@(x) Solution3TargetFuncVal_DataSet(x, S, AMatrix, B, BestLambda, FeatureVector, TrainingFeatureMatrix, TrainingPositionMatrix, QueryFeature,Sigma1,Sigma2),weight,[],[],ones(1,k_knn),1,[],[],[],options);
    %% Calculate estimation from weight
    EstimatePosition=TrainingWeightMatrix*Newweight;
    Errors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
    %figure(2);
end
AvgError=sum(Errors)/NumOfFeaturesInTesting;
index=find(AvgErrorsAndLambdas(1,:)==BestLambda);
AvgErrorsAndLambdas(2,index)=AvgError;
fprintf('\nLambda[%g] AvgError[%g]\n',BestLambda,AvgError);
BestAvgError=AvgError;

% Iterate throughout all scales
while Scale>=EndingScale
    StartingLambda=max(0,BestLambda-LastScale);
    EndingLambda=BestLambda+LastScale;
    for lamda=StartingLambda:Scale:EndingLambda
        fprintf('\nLambda[%g]\n',lamda);
        Errors=zeros(NumOfFeaturesInTesting,1);
        for QueryNumber=1:NumOfFeaturesInTesting
            fprintf('Querynum[%d]',QueryNumber);
            QueryFeature=TestingFeatureMatrix(:,QueryNumber);
            %Calculate the estimate gaze position and display it
            FeatureVector=QueryFeature;
            DistanceMatrix=zeros(1,NumOfFeaturesInTraining);
            for ii = 1:NumOfFeaturesInTraining
                DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
            end
            [SortedDistanceMatrix,index]=sort(DistanceMatrix);
            %disp('index:');
            %disp(index);
            %index(find(index==QueryNumber))=[];

            for k=1:k_knn
                AMatrix(:,k)=TrainingFeatureMatrix(:,index(k));
                TrainingWeightMatrix(:,k)=TrainingPositionMatrix(:,index(k));
            end
            BMatrix=TrainingWeightMatrix;
            A=AMatrix;
            B=BMatrix;
            CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
            weight=pinv(CMatrix)*ones(k_knn,1);
            weight=weight./sum(weight);

            %% Use matlab funciton do optimizaiton for new solution 3 target func
            options = optimoptions('fminunc','Display','off','GradObj','on','DerivativeCheck','off');
            [Newweight,fval,exitflag]=fminunc(@(x) Solution3TargetFuncVal_DataSet(x, S, AMatrix, B, lamda, FeatureVector, TrainingFeatureMatrix, TrainingPositionMatrix, QueryFeature,Sigma1,Sigma2),weight,options);
            %options = optimoptions('fmincon','Display','off','GradObj','on','DerivativeCheck','off');
            %[Newweight,fval,exitflag]=fmincon(@(x) Solution3TargetFuncVal_DataSet(x, S, AMatrix, B, lamda, FeatureVector, TrainingFeatureMatrix, TrainingPositionMatrix, QueryFeature,Sigma1,Sigma2),weight,[],[],ones(1,k_knn),1,[],[],[],options);
            %% Calculate estimation from weight
            EstimatePosition=TrainingWeightMatrix*Newweight;
            Errors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
            %figure(2);
        end
        AvgError=sum(Errors)/NumOfFeaturesInTesting;
        index=find(abs(AvgErrorsAndLambdas(1,:)-lamda)<Tolerance);
        AvgErrorsAndLambdas(2,index)=AvgError;
        fprintf('\nLambda[%g] AvgError[%g]\n',lamda,AvgError);
        if AvgError<=BestAvgError
            BestLambda=lamda;
            BestErrors=Errors;
            BestAvgError=AvgError;
        end
    end
    LastScale=Scale;
    Scale=Scale/10;
end
fprintf('Best lambda[%6.3f] Best error[%8.6f]\n',BestLambda,BestAvgError);
x.x=AvgErrorsAndLambdas;
save([SaveDir,num2str(SubjectNumber),'/','ErrorsAndLambdas-48_Sol3_',sprintf('S-%g',StoppingCriterion),'.mat'],'-struct','x');
x.x=BestErrors;
save([SaveDir,num2str(SubjectNumber),'/','Errors-48_Best_Sol3_',sprintf('S-%g',StoppingCriterion),'.mat'],'-struct','x');
sendmail(myaddress, sprintf('Sol3 -48 Subject[%02d],StoppingCriterion[%g],BestLambda[%6.3f] AvgError[%8.6f]',SubjectNumber,StoppingCriterion,BestLambda,BestAvgError));
