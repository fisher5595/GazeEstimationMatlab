%Refer to Professor Wu's new method pdf, new solution 2.
%Use gradient descent, 
%Load features
clear;
k_knn=20;
lamda=0.0001;
steplength=0.0000001;
featureName='enlarged_RegisteredFeature_Aug27_left_';
rightfeatureName='enlarged_RegisteredFeature_Aug27_right_';

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

TotalError=0;
for QueryNumber=1:36
    QueryFeature=TestingFeatureMatrix(:,QueryNumber);
    TrainingFeatureMatrix=FeatureMatrix;
    %TrainingFeatureMatrix(:,QueryNumber)=[];
    TrainingPositionMatrix=PositionMatrix;
    %TrainingPositionMatrix(:,QueryNumber)=[];
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
%    S=FindMetricPreservationMatrix(TrainingFeatureMatrix,TrainingPositionMatrix);
%     figure(1);
%     AffinityMatrix1=DisplayAffinityMatrix(TrainingFeatureMatrix, 0.1199);
%     figure(2);
%     AffinityMatrix2=DisplayAffinityMatrix(TrainingPositionMatrix,64723);
%     figure(3);
%     AffinityMatrix3=DisplayAffinityMatrix(TrainingFeatureMatrix,0.1199,S);
    for ii = 1:36*3
        DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*(FeatureVector-TrainingFeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    disp('QueryNumber');
    disp(QueryNumber);
    disp('index:');
    disp(index);
    %index(find(index==QueryNumber))=[];

    for k=1:k_knn
        AMatrix(:,k)=TrainingFeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=TrainingPositionMatrix(:,index(k));
    end
    BMatrix=TrainingWeightMatrix;
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);
    while 1
        Gradient=-2*AMatrix'*(FeatureVector-AMatrix*weight);
        for RoundNumber=1:4
            for i=1:36
                Gradient=Gradient+lamda*(sum((FeatureVector-TrainingFeatureMatrix(:,i+(RoundNumber-1)*36)).^2)-sum((BMatrix*weight-TrainingPositionMatrix(:,i+(RoundNumber-1)*36)).^2))*(-BMatrix'*(BMatrix*weight-TrainingPositionMatrix(:,i+(RoundNumber-1)*36)));
            end
        end
        Newweight=weight-steplength*Gradient;
        if norm(Newweight-weight)>0.001
            TragetfuncitonValue=norm(FeatureVector-AMatrix*weight)^2;
            for RoundNumber=1:4
                for i=1:36
                    TragetfuncitonValue=TragetfuncitonValue+lamda*(norm(FeatureVector-TrainingFeatureMatrix(:,i+(RoundNumber-1)*36))-norm(BMatrix*weight-TrainingPositionMatrix(:,i+(RoundNumber-1)*36)))^2;
                end
            end
            disp('TargetFunctionValue');
            disp(TragetfuncitonValue);
            weight=Newweight;
        else
            break;
        end
    end
    EstimatePosition=TrainingWeightMatrix*weight;
    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    %figure(2);
end

disp('AvgError');
AvgError=TotalError/36;
disp(AvgError);