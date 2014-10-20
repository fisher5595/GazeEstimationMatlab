%Sol 3 when training and testing gaze are same

%Load features
clear;
k_knn=30;
BestLambda=10;
InitialScale=1;
EndingScale=0.001;
%lamda=1;
steplength=1E-4;
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

% two eye feature
%S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix,64723,0.5383);
%figure(1);
%AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix, 0.5383);
%figure(2);
%AffinityMatrix2=DisplayAffinityMatrix(PositionMatrix,64723);
%figure(3);
%AffinityMatrix3=DisplayAffinityMatrix(FeatureMatrix,0.5383,S);
%x.x=S;
%save(['s_10-9' '.mat'],'-struct','x');
%Load S matrix from previous result
S=load(['S_10-10' '.mat']);
S=S.x;
BestError=0;
Errors=zeros(36,1);
disp(size(Errors));
TotalError=0;
NumOfFeaturesInTesting=36;
NumOfFeaturesInTraining=36*4;
% Iterate throughout all scales

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
    TrainingFeatureMatrix=FeatureMatrix;
    TrainingPositionMatrix=PositionMatrix;
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
    [Newweight,fval,exitflag]=fminunc(@(x) Solution3TargetFuncVal(x, S, AMatrix, B, BestLambda, FeatureVector, TrainingFeatureMatrix, TrainingPositionMatrix, QueryFeature),weight,options);
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

while Scale>=EndingScale
    StartingLambda=max(0,BestLambda-LastScale);
    EndingLambda=BestLambda+LastScale;
    for lamda=StartingLambda:Scale:EndingLambda
        fprintf('\nLambda[%g]\n',lamda);
        Errors=zeros(NumOfFeaturesInTesting,1);
        for QueryNumber=1:NumOfFeaturesInTesting
            QueryFeature=TestingFeatureMatrix(:,QueryNumber);
            TrainingFeatureMatrix=FeatureMatrix;
            TrainingPositionMatrix=PositionMatrix;
            %Calculate the estimate gaze position and display it
            FeatureVector=QueryFeature;
            for ii = 1:36*4
                DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
            end
            [SortedDistanceMatrix,index]=sort(DistanceMatrix);
            fprintf('Lambda[%2.1f] QueryNumber[%d]\n', lamda,QueryNumber);
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
            options = optimoptions('fminunc','Display','iter','GradObj','on','DerivativeCheck','off');
            [Newweight,fval,exitflag]=fminunc(@(x) Solution3TargetFuncVal(x, S, AMatrix, B, lamda, FeatureVector, TrainingFeatureMatrix, TrainingPositionMatrix, QueryFeature),weight,options);
            %% Gradient descent for new solution 3 target function
        %      LoopCounter=1000;
        %      while LoopCounter>=0
        %          Gradient=-2*A'*S*(FeatureVector-A*weight);
        %          W=double(zeros(36*4,1));
        %          P=double(zeros(36*4,1));
        %          Us=double(zeros(36*4,1));
        %          Qs=double(zeros(36*4,1));
        %          for i=1:36*4
        %              W(i)=exp(-(B*weight-TrainingPositionMatrix(:,i))'*(B*weight-TrainingPositionMatrix(:,i))/2/64723);
        %              Us(i)=exp(-(QueryFeature-TrainingFeatureMatrix(:,i))'*S*(QueryFeature-TrainingFeatureMatrix(:,i))/2/0.5383);
        %          end
        %          SumW=sum(W);
        %          SumUs=sum(Us);
        %          for i=1:36*4
        %              P(i)=W(i)/SumW;
        %              Qs(i)=Us(i)/SumUs;
        %          end
        %          for i=1:36*4
        %              Gradient=Gradient+lamda/64723*P(i)*log(P(i)/Qs(i))*B'*TrainingPositionMatrix(:,i);
        %              for j=1:36*4
        %                  Gradient=Gradient-lamda/64723*P(i)*log(P(i)/Qs(i))*P(j)*B'*TrainingPositionMatrix(:,j);
        %              end
        %          end
        %          Newweight=weight-steplength*Gradient;
        %          if norm(Newweight-weight)>0.0000001
        %              TragetfuncitonValue=(FeatureVector-AMatrix*weight)'*S*(FeatureVector-AMatrix*weight)+lamda*(sum(P.*log(P))-sum(P.*log(Qs)));
        %              disp(['TargetFunctionValue' ':' int2str(QueryNumber)]);
        %              fprintf(' %.10f\n ',TragetfuncitonValue);
        %              %disp(TragetfuncitonValue);
        %              weight=Newweight;
        %              LoopCounter=LoopCounter-1;
        %          else
        %              break;
        %          end
        %      end
            %% Calculate estimation from weight
            EstimatePosition=TrainingWeightMatrix*Newweight;
            Errors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
            TotalError=TotalError+norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
            %figure(2);
        end
        AvgError=sum(Errors)/NumOfFeaturesInTesting;
        index=find(AvgErrorsAndLambdas(1,:)==lamda);
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
x.x=BestErrors;
save(['Errors_Sol3','.mat'],'-struct','x');