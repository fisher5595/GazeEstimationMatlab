%Refer to Professor Wu's new method pdf, new solution 1.

%Load features
clear;
k_knn=20;
featureName='enlarged_RegisteredFeature_left_';

%Load training feature matrix.
for RoundNumber=1
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*36)=featurevector; 
    end
end

%Generate all training position information, stored in a PositionMatrix.
for RoundNumber=1
    for y=1:6
        for x=1:6
            PositionMatrix(1,(y-1)*6+x+(RoundNumber-1)*36)=floor(480/7*y);
            PositionMatrix(2,(y-1)*6+x+(RoundNumber-1)*36)=floor(640/7*x);
        end
    end
end

S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix);
figure(1);
AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix, 0.1199);
figure(2);
AffinityMatrix2=DisplayAffinityMatrix(PositionMatrix,64723);
figure(3);
AffinityMatrix3=DisplayAffinityMatrix(FeatureMatrix,0.1199,S);

TotalError=0;
for QueryNumber=1:36
    QueryFeature=FeatureMatrix(:,QueryNumber);
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
    for ii = 1:36
        DistanceMatrix(ii)=(FeatureVector-FeatureMatrix(:,ii))'*S*(FeatureVector-FeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    disp('QueryNumber');
    disp(QueryNumber);
    disp('index:');
    disp(index);
    index(find(index==QueryNumber))=[];

    for k=1:k_knn
        AMatrix(:,k)=FeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=PositionMatrix(:,index(k));
    end
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);
    EstimatePosition=TrainingWeightMatrix*weight;
    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    %figure(2);
end
AvgError=TotalError/36;