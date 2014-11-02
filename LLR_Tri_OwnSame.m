%Refer to Professor Wu's new method pdf, new solution 1.

%Load features
clear;
k_knn=12;
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

%Split traning feature matrix into training matrix and testing matrix;
% for i = 1:18
%         TrainingFeatureMatrix(:,i)=FeatureMatrix(:,2*(i-1)+1);
%         TestingFeatureMatrix(:,i)=FeatureMatrix(:,2*(i-1)+2);
% end

%Generate all training position information, stored in a PositionMatrix.
for RoundNumber=1:4
    for y=1:6
        for x=1:6
            PositionMatrix(1,(y-1)*6+x+(RoundNumber-1)*36)=floor(480/7*y);
            PositionMatrix(2,(y-1)*6+x+(RoundNumber-1)*36)=floor(640/7*x);
        end
    end
end

%Generate training relative gaze position matrix
for RoundNumber=1:4
    for y=1:6
        for x=1:6
            for i=1:36
                RelativePositionMatrix(i,(y-1)*6+x+(RoundNumber-1)*36)=norm(PositionMatrix(:,i)-PositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
            end
            RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)=RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)./norm(RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
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

%Split traning position matrix into training matrix and testing matrix;
% for i = 1:18
%         TrainingPositionMatrix(:,i)=PositionMatrix(:,2*(i-1)+1);
%         TestingPositionMatrix(:,i)=PositionMatrix(:,2*(i-1)+2);
% end

% one eye feature, sigma is default in Find... function
%S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix);
% two eye feature
%  S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix,64723,0.5383);
 S=load(['S_10-10','.mat']);
 S=S.x;
% figure(1);
% AffinityMatrix1=DisplayAffinityMatrix(TestingFeatureMatrix, 0.5383);
% figure(2);
% AffinityMatrix2=DisplayAffinityMatrix(TestingPositionMatrix,64723);
% figure(3);
% AffinityMatrix3=DisplayAffinityMatrix(TestingFeatureMatrix,0.5383,S);
%  x.x=S;
%  save(['S_10-10','.mat'],'-struct','x');
%S=load(['S_10-10','.mat']);
%S=S.x;
%Normalized relative gaze position
%Absolute gaze sigma
%S=FindMetricPreservationMatrix(FeatureMatrix,RelativePositionMatrix,0.0686,0.5383);
%36 point relative gaze sigma
% S=FindMetricPreservationMatrix(FeatureMatrix,RelativePositionMatrix,0.0452,0.5383);
% figure(1);
% AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix, 0.5383);
% figure(2);
% AffinityMatrix2=DisplayAffinityMatrix(RelativePositionMatrix,0.0686);
% figure(3);
% AffinityMatrix3=DisplayAffinityMatrix(FeatureMatrix,0.5383,S);

S=eye(size(FeatureMatrix,1));
TRI=delaunay(PositionMatrix(2,1:36),PositionMatrix(1,1:36));
TotalError=0;
Errors=zeros(36,1);
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
    index=FindClosedTriangleAndNeighbors( QueryFeature, TrainingFeatureMatrix, TRI, 4 );
    %index(find(index==QueryNumber))=[];
    k_knn=4*size(index,2);
    AMatrix=[];
    TrainingWeightMatrix=[];
    for RoundNumber=1:4
        for k=1:size(index,2)
            AMatrix(:,k+(RoundNumber-1)*size(index,2))=TrainingFeatureMatrix(:,index(k)+(RoundNumber-1)*36);
            TrainingWeightMatrix(:,k+(RoundNumber-1)*size(index,2))=TrainingPositionMatrix(:,index(k)+(RoundNumber-1)*36);
        end
    end
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);
%     %Estimation for absolute gaze position
     EstimatePosition=TrainingWeightMatrix*weight;
     Errors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
     TotalError=TotalError+norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
%    EstimateRelativePosition=TrainingWeightMatrix*weight;
%    Result=fsolve(@(x) RelativePositonToAbsolute(x,EstimateRelativePosition),[1,1,100],optimset('Display','off','TolFun',1e-16));
%    EstimatePosition(:,1)=Result(1:2);
%    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    %figure(2);
end
x.x=Errors;
save(['Errors_LLR_Tri','.mat'],'-struct','x');
disp('AvgError');
AvgError=TotalError/36;
disp(AvgError);