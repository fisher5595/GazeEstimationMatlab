%Refer to Professor Wu's new method pdf, new solution 1.

%Load features
clear;
k_knn=20;
lamda=0.0001;
featureName='enlarged_RegisteredFeature_left_';

%Load training feature matrix.
for RoundNumber=1
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*36)=featurevector; 
    end
end

%Normalize appearance feature space.
for i = 1:36
        FeatureMatrix(:,i+(RoundNumber-1)*36)=FeatureMatrix(:,i+(RoundNumber-1)*36)./norm(FeatureMatrix(:,i+(RoundNumber-1)*36)); 
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

%Generate new position matrix as a vector, each element is the distance to
%four corners of the gaze space. Then normalize it.
for RoundNumber=1
    for y=1:6
        for x=1:6
            RelativePositionMatrix(1,(y-1)*6+x+(RoundNumber-1)*36)=norm(PositionMatrix(:,1)-PositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
            RelativePositionMatrix(2,(y-1)*6+x+(RoundNumber-1)*36)=norm(PositionMatrix(:,6)-PositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
            RelativePositionMatrix(3,(y-1)*6+x+(RoundNumber-1)*36)=norm(PositionMatrix(:,31)-PositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
            RelativePositionMatrix(4,(y-1)*6+x+(RoundNumber-1)*36)=norm(PositionMatrix(:,36)-PositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
            RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)=RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)./norm(RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
        end
    end
end

TotalError=0;
for QueryNumber=1:36
    QueryFeature=FeatureMatrix(:,QueryNumber);
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
    for ii = 1:36
        DistanceMatrix(ii)=(FeatureVector-FeatureMatrix(:,ii))'*(FeatureVector-FeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    disp('QueryNumber');
    disp(QueryNumber);
    disp('index:');
    disp(index);
    index(find(index==QueryNumber))=[];

    for k=1:k_knn
        AMatrix(:,k)=FeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=RelativePositionMatrix(:,index(k));
    end
    weight=pinv([AMatrix;lamda*TrainingWeightMatrix'*TrainingWeightMatrix])*[eye(size(FeatureVector,1));lamda*AMatrix']*QueryFeature;
    EstimateRelativePosition=TrainingWeightMatrix*weight;
    Result=fsolve(@(x) RelativePositonToAbsolute(x,EstimateRelativePosition),[1,1,100],optimset('Display','off'));
    EstimatePosition(:,1)=Result(1:2);
    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    %figure(2);
end
AvgError=TotalError/36;