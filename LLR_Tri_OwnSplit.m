%Refer to Professor Wu's new method pdf, new solution 1.

%Load features
clear;
featureName='50times100/new_data_Sep_26/enlarged_RegisteredFeature_Sep26_left_';
rightfeatureName='50times100/new_data_Sep_26/enlarged_RegisteredFeature_Sep26_right_';
xspace=floor(640/7);
yspace=floor(480/7);
halfxspace=floor(double(xspace/2));
halfyspace=floor(double(yspace/2));
%Load all feature matrix.
for RoundNumber=1:5
    for i = 1:61
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        rightfeature=load([rightfeatureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        rightfeaturevector=rightfeature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*61)=[featurevector;rightfeaturevector]; 
    end
end

%Split feature matrix into training feature matrix and testing feature
%matrix, also add the position matrices
TrainingMatrix=[];
TestingFeatureMatrix=[];
PositionMatrix=[];
TestingPositionMatrix=[];
for RoundNumber=1:5
    for y=1:6
        for x=1:6
            TrainingMatrix=[TrainingMatrix FeatureMatrix(:,(RoundNumber-1)*61+(y-1)*11+x)];
            PositionMatrix=[PositionMatrix [yspace*y;xspace*x]];
        end
        if y~=6
            for xx=1:5
                TestingFeatureMatrix=[TestingFeatureMatrix FeatureMatrix(:,(RoundNumber-1)*61+(y-1)*11+x+xx)];
                TestingPositionMatrix=[TestingPositionMatrix [yspace*y+halfyspace;halfxspace+xx*xspace]];
            end
        end
    end
end
FeatureMatrix=TrainingMatrix;
% %Load testing feature matrix
% for RoundNumber=5
%     for i = 1:36
%         feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
%         featurevector=feature.x;
%         rightfeature=load([rightfeatureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
%         rightfeaturevector=rightfeature.x;
%         TestingFeatureMatrix(:,i)=[featurevector;rightfeaturevector]; 
%     end
% end
% 
% %Split traning feature matrix into training matrix and testing matrix;
% % for i = 1:18
% %         TrainingFeatureMatrix(:,i)=FeatureMatrix(:,2*(i-1)+1);
% %         TestingFeatureMatrix(:,i)=FeatureMatrix(:,2*(i-1)+2);
% % end
% 
% %Generate all training position information, stored in a PositionMatrix.
% for RoundNumber=1:4
%     for y=1:6
%         for x=1:6
%             PositionMatrix(1,(y-1)*6+x+(RoundNumber-1)*36)=floor(480/7*y);
%             PositionMatrix(2,(y-1)*6+x+(RoundNumber-1)*36)=floor(640/7*x);
%         end
%     end
% end
% 
% %Generate training relative gaze position matrix
% for RoundNumber=1:4
%     for y=1:6
%         for x=1:6
%             for i=1:36
%                 RelativePositionMatrix(i,(y-1)*6+x+(RoundNumber-1)*36)=norm(PositionMatrix(:,i)-PositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
%             end
%             RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)=RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)./norm(RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
%         end
%     end
% end
% 
% %Generate testing positon information
% for RoundNumber=5
%     for y=1:6
%         for x=1:6
%             TestingPositionMatrix(1,(y-1)*6+x)=floor(480/7*y);
%             TestingPositionMatrix(2,(y-1)*6+x)=floor(640/7*x);
%         end
%     end
% end

%Split traning position matrix into training matrix and testing matrix;
% for i = 1:18
%         TrainingPositionMatrix(:,i)=PositionMatrix(:,2*(i-1)+1);
%         TestingPositionMatrix(:,i)=PositionMatrix(:,2*(i-1)+2);
% end

% one eye feature, sigma is default in Find... function
%S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix);
% two eye feature
%S=NewFindMetricPreservationMatrix(FeatureMatrix,PositionMatrix,32328,0.0469);
S=load(['S_10-10_SplitTrainTest','.mat']);
S=S.x;
% figure(1);
% AffinityMatrix1=DisplayAffinityMatrix(TestingFeatureMatrix, 0.0469);
% figure(2);
% AffinityMatrix2=DisplayAffinityMatrix(TestingPositionMatrix,32328);
% figure(3);
% AffinityMatrix3=DisplayAffinityMatrix(TestingFeatureMatrix,0.0469,S);
% x.x=S;
%save(['S_10-10_SplitTrainTest','.mat'],'-struct','x');
%S=load(['S_10-8','.mat']);
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
TotalError=0;
Errors=zeros(25*5,1);
TRI=delaunay(PositionMatrix(2,1:36),PositionMatrix(1,1:36));
Estimations=zeros(2,25*5);
for RoundNumber=1:5
    for QueryNumber=1:25
        QueryFeature=TestingFeatureMatrix(:,QueryNumber+(RoundNumber-1)*25);
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
        index=FindClosedTriangleAndNeighbors( QueryFeature, TrainingFeatureMatrix, TRI, 5 );
        k_knn=5*size(index,2);
        AMatrix=[];
        TrainingWeightMatrix=[];
        for Round=1:5
            for k=1:size(index,2)
                AMatrix(:,k+(Round-1)*size(index,2))=TrainingFeatureMatrix(:,index(k)+(Round-1)*36);
                TrainingWeightMatrix(:,k+(Round-1)*size(index,2))=TrainingPositionMatrix(:,index(k)+(Round-1)*36);
            end
        end
        CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
        weight=pinv(CMatrix)*ones(k_knn,1);
        weight=weight./sum(weight);
    %     %Estimation for absolute gaze position
         EstimatePosition=TrainingWeightMatrix*weight;
         Estimations(:,(RoundNumber-1)*25+QueryNumber)=EstimatePosition;
         TotalError=TotalError+norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber+(RoundNumber-1)*25)));
         Errors(QueryNumber+(RoundNumber-1)*25)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber+(RoundNumber-1)*25)));
    %    EstimateRelativePosition=TrainingWeightMatrix*weight;
    %    Result=fsolve(@(x) RelativePositonToAbsolute(x,EstimateRelativePosition),[1,1,100],optimset('Display','off','TolFun',1e-16));
    %    EstimatePosition(:,1)=Result(1:2);
    %    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
        %figure(2);
    end
end
disp('AvgError');
AvgError=TotalError/25/5;
disp(AvgError);
x.x=Errors;
%save(['Errors_SplitTrainTest_LLR_Tri','.mat'],'-struct','x');
x.x=Estimations;
save(['Estimations_SplitTrainTest_LLR_Tri','.mat'],'-struct','x');