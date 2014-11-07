%Refer to Professor Wu's new method pdf, new solution 1.

%Load features
clear;
k_knn=30;
%lamda=1;
steplength=1E-4;
Sigma1=32328;
Sigma2=0.0469;
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

% two eye feature
%S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix,Sigma1,Sigma2);
%figure(1);
%AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix, Sigma2);
%figure(2);
%AffinityMatrix2=DisplayAffinityMatrix(PositionMatrix,Sigma1);
%figure(3);
%AffinityMatrix3=DisplayAffinityMatrix(FeatureMatrix,Sigma2,S);
%x.x=S;
%save(['s_10-9' '.mat'],'-struct','x');
%Load S matrix from previous result
S=load(['S_10-10_SplitTrainTest' '.mat']);
S=S.x;
BestLambda=0;
BestError=0;
BestErrors=zeros(25*5,1);
Errors=zeros(floor((0.050-0.035)/0.001)+1,1);
disp(size(Errors));
for lamda=0.036:0.001:0.036
    TotalError=0;
    OneLambdaErrors=zeros(25*5,1);
    Estimations=zeros(2,25*5);
    for QueryNumber=1:25*5
        QueryFeature=TestingFeatureMatrix(:,QueryNumber);
        TrainingFeatureMatrix=FeatureMatrix;
        TrainingPositionMatrix=PositionMatrix;
        %Calculate the estimate gaze position and display it
        FeatureVector=QueryFeature;
        for ii = 1:36*5
            DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
        end
        [SortedDistanceMatrix,index]=sort(DistanceMatrix);
        fprintf('Lambda[%4.3f] QueryNumber[%d]\n', lamda,QueryNumber);
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
        [Newweight,fval,exitflag]=fminunc(@(x) Solution3TargetFuncVal_SplitTrainTest(x, S, AMatrix, B, lamda, FeatureVector, TrainingFeatureMatrix, TrainingPositionMatrix, QueryFeature, Sigma1, Sigma2),weight,options);
        %% Gradient descent for new solution 3 target function
%          LoopCounter=1000;
%          while LoopCounter>=0
%              Gradient=-2*A'*S*(FeatureVector-A*weight);
%              W=double(zeros(36*5,1));
%              P=double(zeros(36*5,1));
%              Us=double(zeros(36*5,1));
%              Qs=double(zeros(36*5,1));
%              for i=1:36*5
%                  W(i)=exp(-(B*weight-TrainingPositionMatrix(:,i))'*(B*weight-TrainingPositionMatrix(:,i))/2/Sigma1);
%                  Us(i)=exp(-(QueryFeature-TrainingFeatureMatrix(:,i))'*S*(QueryFeature-TrainingFeatureMatrix(:,i))/2/Sigma2);
%              end
%              SumW=sum(W);
%              SumUs=sum(Us);
%              for i=1:36*5
%                  P(i)=W(i)/SumW;
%                  Qs(i)=Us(i)/SumUs;
%              end
%              for i=1:36*5
%                  Gradient=Gradient+lamda/Sigma1*P(i)*log(P(i)/Qs(i))*B'*TrainingPositionMatrix(:,i);
%                  for j=1:36*5
%                      Gradient=Gradient-lamda/Sigma1*P(i)*log(P(i)/Qs(i))*P(j)*B'*TrainingPositionMatrix(:,j);
%                  end
%              end
%              Newweight=weight-steplength*Gradient;
%              if norm(Newweight-weight)>0.0000001
%                  TragetfuncitonValue=(FeatureVector-AMatrix*weight)'*S*(FeatureVector-AMatrix*weight)+lamda*(sum(P.*log(P))-sum(P.*log(Qs)));
%                  disp(['TargetFunctionValue' ':' int2str(QueryNumber)]);
%                  fprintf(' %.10f\n ',TragetfuncitonValue);
%                  %disp(TragetfuncitonValue);
%                  weight=Newweight;
%                  LoopCounter=LoopCounter-1;
%              else
%                  break;
%              end
%          end
        %% Calculate estimation from weight
        EstimatePosition=TrainingWeightMatrix*Newweight;
        Estimations(:,QueryNumber)=EstimatePosition;
        TotalError=TotalError+norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
        OneLambdaErrors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
        %figure(2);
    end
    AvgError=TotalError/25/5;
    disp('AvgError');
    disp(AvgError);
    Errors(floor((lamda-0.035)/0.001)+1)=AvgError;
    if lamda==0.036
        BestLambda=lamda;
        BestError=AvgError;
        BestErrors=OneLambdaErrors;
    else
        if AvgError<=BestError
            BestError=AvgError;
            BestLambda=lamda;
            BestErrors=OneLambdaErrors;
        else
            continue;
        end
    end
end
fprintf('Best lambda[%4.3f] Best error[%8.6f]\n',BestLambda,BestError);
x.x=BestErrors;
%save(['Errors_SplitTrainTest_Sol3_','.mat'],'-struct','x');
x.x=Estimations;
save(['Estimations_SplitTrainTest_Sol3_','.mat'],'-struct','x');
