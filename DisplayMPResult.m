clear;
set(0,'defaultAxesFontName', 'Times');
set(0,'defaultTextFontName', 'Times');
set(0,'defaultAxesFontSize', 20);
set(0,'defaultLegendFontSize', 15);
SaveDir='./DataSet/';
InputFileDir='/media/peiyu/OS/Users/PeiYu/Downloads/s00-09';
SubjectNumber=0;
StoppingCriterion=1e-5;
StepSize=0.01;

%Load data and split training and testing data.
x=load([SaveDir,num2str(SubjectNumber),'/','TotalFeatureMatrix', '.mat']);
TotalFeatureMatrix=x.x;
x=load([SaveDir,num2str(SubjectNumber),'/','TotalGazePositionMatrix', '.mat']);
TotalGazePositionMatrix=x.x;
FeatureDimension=size(TotalFeatureMatrix,1);
FeatureAmount=size(TotalFeatureMatrix,2);
NumOfDifferentX=size(find(TotalGazePositionMatrix(1,:)==TotalGazePositionMatrix(1,1)),2);
NumOfDifferentY=FeatureAmount/NumOfDifferentX;
TrainingFeatureMatrix=[];
TestingFeatureMatrix=[];
TrainingPositionMatrix=[];
TestingPositionMatrix=[];
for y=1:NumOfDifferentY
    for x=1:NumOfDifferentX-1
        if mod(x+y,2)==0
            TrainingFeatureMatrix=[TrainingFeatureMatrix TotalFeatureMatrix(:,(y-1)*NumOfDifferentX+x)];
            TrainingPositionMatrix=[TrainingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
        else
            TestingFeatureMatrix=[TestingFeatureMatrix TotalFeatureMatrix(:,(y-1)*NumOfDifferentX+x)];
            TestingPositionMatrix=[TestingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
        end
    end
end

NumOfFeaturesInTraining=size(TrainingFeatureMatrix,2);
NumOfFeaturesInTesting=size(TestingFeatureMatrix,2);
Tmp=double(zeros(NumOfFeaturesInTraining,NumOfFeaturesInTraining));
for i=1:NumOfFeaturesInTraining
    for j=1:NumOfFeaturesInTraining
        Tmp(i,j)=(TrainingFeatureMatrix(:,i)-TrainingFeatureMatrix(:,j))'*(TrainingFeatureMatrix(:,i)-TrainingFeatureMatrix(:,j));
    end
end
Sigma2=std(Tmp(:));

for i=1:NumOfFeaturesInTraining
    for j=1:NumOfFeaturesInTraining
        Tmp(i,j)=(TrainingPositionMatrix(:,i)-TrainingPositionMatrix(:,j))'*(TrainingPositionMatrix(:,i)-TrainingPositionMatrix(:,j));
    end
end
Sigma1=std(Tmp(:));
x=load([SaveDir,num2str(SubjectNumber),'/','S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'.mat']);
S=x.x;

h1=figure(1);
AffinityMatrix1=DisplayAffinityMatrix(TrainingFeatureMatrix, Sigma2);
set(gca,'Box','on','XTickMode','manual','YTickMode','manual');
h2=figure(2);
AffinityMatrix2=DisplayAffinityMatrix(TrainingPositionMatrix,Sigma1);
set(gca,'Box','on','XTickMode','manual','YTickMode','manual');
h3=figure(3);
AffinityMatrix3=DisplayAffinityMatrix(TrainingFeatureMatrix,Sigma2,S);
set(gca,'Box','on','XTickMode','manual','YTickMode','manual');