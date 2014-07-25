%Calculate the knn of input feature, plot the corresponding first knn
%coordinates rectangels.
clear;
QueryNumber=10;
DisplayKnn=6;
%RoundNumber=1;
featureName='enlarged_RegisteredFeature_left_';
%feature=load([featureName,int2str(QueryNumber-1),'__',int2str(RoundNumber),'.mat']);
%QueryFeature=feature.x;

%Parameters for estimating gaze
k_knn=20;
sigma1=64723;
%sigma1=376989.5;
%sigma1 for feature with contour parameters
sigma2=1674;
%sigma2=1.0874;
epsilon=0.1;

%Load first set of features.
for i = 1:36
    feature=load([featureName,int2str(i-1),'.mat']);
    %A=load([matrixAName,int2str(i-1),'.mat']);
    %trainingPositions=load([knnPositionsName,int2str(i-1),'.mat']);
    %groundTruth=load([groundTruthName,int2str(i-1),'.mat']);
    featurevector=feature.x;
    %matrixA=A.A;
    %trainingPositionMatrix=trainingPositions.A;
    %groundTruthVector=groundTruth.x;
    FeatureMatrix(:,i)=featurevector; 
end

%Load training feature matrix.
for RoundNumber=1:4
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        %A=load([matrixAName,int2str(i-1),'.mat']);
        %trainingPositions=load([knnPositionsName,int2str(i-1),'.mat']);
        %groundTruth=load([groundTruthName,int2str(i-1),'.mat']);
        featurevector=feature.x;
        %matrixA=A.A;
        %trainingPositionMatrix=trainingPositions.A;
        %groundTruthVector=groundTruth.x;
        FeatureMatrix(:,i+RoundNumber*36)=featurevector; 
    end
end

%Generate all training position information, stored in a PositionMatrix.
for RoundNumber=1:5
    for y=1:6
        for x=1:6
            PositionMatrix(1,(y-1)*6+x+(RoundNumber-1)*36)=floor(480/7*y);
            PositionMatrix(2,(y-1)*6+x+(RoundNumber-1)*36)=floor(640/7*x);
        end
    end
end

RoundNumber=1;
TotalError=0;
for QueryNumber=(1+RoundNumber*36):(36+RoundNumber*36)
    QueryFeature=FeatureMatrix(:,QueryNumber);
    %Calculate SSD of the 
    SSDOfFeature=[];
    for i=1:36*5
        SSDOfFeature(i)=sum((double(QueryFeature)-double(FeatureMatrix(:,i))).^2);
    end
    [SortedSSD,SortedIndex]=sort(SSDOfFeature);
    close all;
    %Draw the grid
    figure(1);
    % line([0,0],[0,480]);
    % line([640,640],[0,480]);
    % line([0,640],[0,0]);
    % line([0,640],[480,480]);
    for i=1:6
        line([640/7*i,640/7*i],[0,480]);
        line([0,640],[480/7*i,480/7*i]);
    end

    %Draw rectangel with text displaying number
    XCor=PositionMatrix(2,QueryNumber);
    YCor=480-PositionMatrix(1,QueryNumber);
    rectangle('Position',[XCor-15,YCor-15,30,30],'EdgeColor','r','LineWidth',2);

    for i=1:DisplayKnn
        if SortedIndex(i)==QueryNumber;
            continue;
        end
        XCor=PositionMatrix(2,SortedIndex(i));
        YCor=480-PositionMatrix(1,SortedIndex(i));
        rectangle('Position',[XCor-10,YCor-10,20,20],'EdgeColor','g','LineWidth',2);
        text(XCor,YCor,int2str(i-1));
    end
    
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
    for ii = 1:36*5
        DistanceMatrix(ii)=(FeatureVector-FeatureMatrix(:,ii))'*(FeatureVector-FeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    disp('QueryNumber');
    disp(QueryNumber);
    disp('index:');
    disp(index);
    index(find(index==QueryNumber))=[];

    KNNIndex=index(1:k_knn);
    TotalIndex(QueryNumber,:)=KNNIndex;
    for k=1:k_knn
        AMatrix(:,k)=FeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=PositionMatrix(:,index(k));
    end
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);
    Weight(:,QueryNumber)=weight;
    EstimatePosition=TrainingWeightMatrix*weight;
    rectangle('Position',[EstimatePosition(2)-10,480-EstimatePosition(1)-10,20,20],'EdgeColor','c','LineWidth',2);
    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    pause;
    %figure(2);
end

AvgError=TotalError/36;

