% Feng ALR method, important part of epsilon estimation

%Load features
clear;
k_knn=30;
lamda=2;
steplength=1E-4;
featureName='50times100/new_data_Sep_26/enlarged_RegisteredFeature_Sep26_left_';
rightfeatureName='50times100/new_data_Sep_26/enlarged_RegisteredFeature_Sep26_right_';
xspace=floor(640/7);
yspace=floor(480/7);
halfxspace=floor(double(xspace/2));
halfyspace=floor(double(yspace/2));
addpath(genpath('l1magic'));
CenterPosition=[480/2;640/2];
Kappa=1e-1;
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


%%Extimate the espilon by leave one out experiment on training samples
Epsilons=zeros(36*5,1);
Alphas=double(zeros(36*5,1));

for QueryNumber=1:36*5
    QueryFeature=FeatureMatrix(:,QueryNumber);
    QueryPosition=PositionMatrix(:,QueryNumber);
    TrainingFeatureMatrix=FeatureMatrix;
    TrainingPositionMatrix=PositionMatrix;
    TrainingPositionMatrix(:,QueryNumber)=[];
    TrainingFeatureMatrix(:,QueryNumber)=[];
    BestError=0;
    BestEpsilon=0.001;
    for epsilon=0.001:0.001:0.1
        if epsilon==0.001
            weight=l1qc_logbarrier(ones(36*5-1,1), TrainingFeatureMatrix, [], QueryFeature, epsilon);
            BestError=norm(TrainingPositionMatrix*weight-QueryPosition);
        else
            weight=l1qc_logbarrier(ones(36*5-1,1), TrainingFeatureMatrix, [], QueryFeature, epsilon);
            Error=norm(TrainingPositionMatrix*weight-QueryPosition);
            fprintf('L1 norm of weight[%4.2f]\n',norm(weight,1));
            if Error<=BestError
                BestError=Error;
                BestEpsilon=epsilon;
            else
                %break;
            end
        end
    end
    fprintf('Query[%4.0f],Epsilon[%6.3f],Error[%6.3f]\n',QueryNumber,BestEpsilon,BestError);
    Epsilons(QueryNumber)=BestEpsilon;
    Alphas(QueryNumber)=exp(-Kappa*norm(QueryPosition-CenterPosition));
end
x.x=Epsilons;
save(['Epsilons_SplitTrainTest','.mat'],'-struct','x');
x.x=Alphas;
save(['Alphas_SplitTrainTest','.mat'],'-struct','x');
EstimatedEpsilon=(Epsilons'*Alphas)/sum(Alphas);
fprintf('EstimatedEpsilon[%11.8f]\n',EstimatedEpsilon);

%EstimatedEpsilon=0.0182;
%% Do testing
TotalError=0;
Errors=double(zeros(25*5,1));
for QueryNumber=1:25*5
    QueryFeature=TestingFeatureMatrix(:,QueryNumber);
    TrainingFeatureMatrix=FeatureMatrix;
    TrainingPositionMatrix=PositionMatrix;
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
    StartPoint=ones(36*5,1);
    Newweight=l1qc_logbarrier(StartPoint, TrainingFeatureMatrix, [], QueryFeature, EstimatedEpsilon);

    %% Calculate estimation from weight
    EstimatePosition=TrainingPositionMatrix*Newweight;
    Errors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
    TotalError=TotalError+norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
    %figure(2);
end
AvgError=TotalError/25/5;
disp('AvgError');
disp(AvgError);
x.x=Errors;
save(['Errors_SplitTrainTest_ALR_','.mat'],'-struct','x');