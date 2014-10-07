% Feng ALR method, important part of epsilon estimation

%Load features
clear;
k_knn=20;
lamda=2;
steplength=1E-4;
featureName='enlarged_RegisteredFeature_Aug27_left_';
rightfeatureName='enlarged_RegisteredFeature_Aug27_right_';
addpath(genpath('l1magic'));
CenterPosition=[480/2;640/2];
Kappa=1e-1;
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
%%Extimate the espilon by leave one out experiment on training samples
Epsilons=zeros(36*4,1);
Alphas=double(zeros(36*4,1));

for QueryNumber=1:36*4
    QueryFeature=FeatureMatrix(:,QueryNumber);
    QueryPosition=PositionMatrix(:,QueryNumber);
    TrainingFeatureMatrix=FeatureMatrix;
    TrainingPositionMatrix=PositionMatrix;
    TrainingPositionMatrix(:,QueryNumber)=[];
    TrainingFeatureMatrix(:,QueryNumber)=[];
    BestError=0;
    BestEpsilon=0.001;
    for epsilon=0.001:0.001:1
        if epsilon==0.001
            weight=l1qc_logbarrier(ones(36*4-1,1), TrainingFeatureMatrix, [], QueryFeature, epsilon);
            BestError=norm(TrainingPositionMatrix*weight-QueryPosition);
        else
            weight=l1qc_logbarrier(ones(36*4-1,1), TrainingFeatureMatrix, [], QueryFeature, epsilon);
            Error=norm(TrainingPositionMatrix*weight-QueryPosition);
            fprintf('L1 norm of weight[%4.2f]\n',norm(weight,1));
            if abs(norm(weight,1)-1)<=1e-2
                BestError=Error;
                BestEpsilon=epsilon;
                BestWeight=weight;
                break;
                %break;
            end
        end
    end
    fprintf('Query[%4.0f],Epsilon[%6.4f],BestError[%8.4f],L1 norm of weight[%4.2f]\n',QueryNumber,BestEpsilon,BestError,norm(BestWeight,1));
    Epsilons(QueryNumber)=BestEpsilon;
    Alphas(QueryNumber)=exp(-Kappa*norm(QueryPosition-CenterPosition));
end
x.x=Epsilons;
save(['Epsilons','.mat'],'-struct','x');
x.x=Alphas;
save(['Alphas','.mat'],'-struct','x');
EstimatedEpsilon=(Epsilons'*Alphas)/sum(Alphas);
fprintf('EstimatedEpsilon[%11.8f]\n',EstimatedEpsilon);

%% Do testing
TotalError=0;
for QueryNumber=1:36
    QueryFeature=TestingFeatureMatrix(:,QueryNumber);
    TrainingFeatureMatrix=FeatureMatrix;
    TrainingPositionMatrix=PositionMatrix;
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
    StartPoint=ones(36*4,1);
    Newweight=l1qc_logbarrier(StartPoint, TrainingFeatureMatrix, [], QueryFeature, EstimatedEpsilon);

    %% Calculate estimation from weight
    EstimatePosition=TrainingPositionMatrix*Newweight;
    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    %figure(2);
end
AvgError=TotalError/36;
disp('AvgError');
disp(AvgError);
