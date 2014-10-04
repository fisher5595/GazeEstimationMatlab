clear;
k_knn=8;
SubjectNumber=0;
SaveDir='./DataSet/';
x=load([SaveDir,num2str(SubjectNumber),'/','TotalFeatureMatrix', '.mat']);
TotalFeatureMatrix=x.x;
x=load([SaveDir,num2str(SubjectNumber),'/','TotalGazePositionMatrix', '.mat']);
TotalGazePositionMatrix=x.x;
StoppingCriterion=1e-7;
FeatureDimension=size(TotalFeatureMatrix,1);
FeatureAmount=size(TotalFeatureMatrix,2);
NumOfDifferentX=size(find(TotalGazePositionMatrix(1,:)==TotalGazePositionMatrix(1,1)),2);
NumOfDifferentY=FeatureAmount/NumOfDifferentX;
TrainingFeatureMatrix=[];
TestingFeatureMatrix=[];
TrainingPositionMatrix=[];
TestingPositionMatrix=[];

for y=1:NumOfDifferentY
    for x=1:NumOfDifferentX
        if (x==NumOfDifferentX)
            continue;
        end
        if mod(x+y,2)==0
            TrainingFeatureMatrix=[TrainingFeatureMatrix TotalFeatureMatrix(:,(y-1)*NumOfDifferentX+x)];
            TrainingPositionMatrix=[TrainingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
        else
            TestingFeatureMatrix=[TestingFeatureMatrix TotalFeatureMatrix(:,(y-1)*NumOfDifferentX+x)];
            TestingPositionMatrix=[TestingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
        end
    end
end

% Estimate the parameters of sigma1 and sigma2.
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

% Loop through all Stopping Criterion, calculate S, save intermediate
% result of S and Error
S=load('Tmp_S-6.mat');
S=S.x;
%StartingS=eye(FeatureDimension);
StartingS=S;
% Extract feature and gaze position matrix, and save them
S=NewFindMetricPreservationMatrix(TrainingFeatureMatrix,TrainingPositionMatrix,Sigma1,Sigma2,StartingS,StoppingCriterion);
%S=load([SaveDir,num2str(SubjectNumber),'/','S-',sprintf('%g',StoppingCriterion),'.mat']);
%S=load('Tmp_S-6.mat');
%S=S.x;

%S=eye(FeatureDimension);

%S=eye(size(FeatureMatrix,1));
Errors=double(zeros(NumOfFeaturesInTesting,1));
for QueryNumber=1:NumOfFeaturesInTesting
    QueryFeature=TestingFeatureMatrix(:,QueryNumber);
    FeatureVector=QueryFeature;
    for ii = 1:NumOfFeaturesInTraining
        DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    fprintf('QueryNumber[%d]\n',QueryNumber);
    %disp('index:');
    %disp(index);
    %index(find(index==QueryNumber))=[];

    for k=1:k_knn
        AMatrix(:,k)=TrainingFeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=TrainingPositionMatrix(:,index(k));
    end
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);
%     %Estimation for absolute gaze position
     EstimatePosition=TrainingWeightMatrix*weight;
     Errors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
%    EstimateRelativePosition=TrainingWeightMatrix*weight;
%    Result=fsolve(@(x) RelativePositonToAbsolute(x,EstimateRelativePosition),[1,1,100],optimset('Display','off','TolFun',1e-16));
%    EstimatePosition(:,1)=Result(1:2);
%    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    %figure(2);
end
disp('AvgError');
AvgError=sum(Errors)/NumOfFeaturesInTesting;
disp(AvgError);
x.x=Errors;
StartingS=S;
