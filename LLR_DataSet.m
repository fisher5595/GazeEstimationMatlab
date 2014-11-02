% Local linear reconstruction method, without metric preservation.
clear;
k_knn=8;
SaveDir='./DataSet/';
InputFileDir='/media/peiyu/OS/Users/PeiYu/Downloads/s00-09';
StartingCriterion=1e-7;
EndingCrierion=1e-10;
StepSize=0.01;

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
    

    S=eye(FeatureDimension);
    Errors=double(zeros(NumOfFeaturesInTesting,1));
    for QueryNumber=1:NumOfFeaturesInTesting
        QueryFeature=TestingFeatureMatrix(:,QueryNumber);
        FeatureVector=QueryFeature;
    %    S=FindMetricPreservationMatrix(TrainingFeatureMatrix,TrainingPositionMatrix);
    %     figure(1);
    %     AffinityMatrix1=DisplayAffinityMatrix(TrainingFeatureMatrix, 0.1199);
    %     figure(2);
    %     AffinityMatrix2=DisplayAffinityMatrix(TrainingPositionMatrix,64723);
    %     figure(3);
    %     AffinityMatrix3=DisplayAffinityMatrix(TrainingFeatureMatrix,0.1199,S);
        for ii = 1:NumOfFeaturesInTraining
            DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
        end
        [SortedDistanceMatrix,index]=sort(DistanceMatrix);
        disp('QueryNumber');
        disp(QueryNumber);
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
    save([SaveDir,num2str(SubjectNumber),'/','Errors-48_LLR', '.mat'],'-struct','x');
end
