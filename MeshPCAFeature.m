clear;
SaveDir='./DataSet/';
InputFileDir='/media/peiyu/OS/Users/PeiYu/Downloads/s00-09';
StartingCriterion=1e-7;
EndingCrierion=1e-10;
StoppingCriterion=1e-6;
StepSize=0.01;
SubjectNumber=0;
x=load([SaveDir,num2str(SubjectNumber),'/','TotalFeatureMatrix48', '.mat']);
TotalFeatureMatrix=x.x;
x=load([SaveDir,num2str(SubjectNumber),'/','TotalGazePositionMatrix48', '.mat']);
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
TRI=delaunay(TrainingPositionMatrix(2,:),TrainingPositionMatrix(1,:));
S=load([SaveDir,num2str(SubjectNumber),'/','S-48-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'.mat']);
S=S.x;
r = rank(S);
[U X V]=svd(S);
B=sqrt(X(1:r,1:r))*U(:,1:r)';
[COEFF,SCORE] = princomp(TrainingFeatureMatrix');
PincipleMatrix= TrainingFeatureMatrix'*COEFF;
PrincipleMatrix=PincipleMatrix(:,1:3);
figure(1)
x=PincipleMatrix(:,1);
y=PincipleMatrix(:,2);
v=PincipleMatrix(:,3);
d1 = -0.4:0.005:0.4;
d2 = -0.3:0.005:0.3;
[xq,yq] = meshgrid(d1,d2);
vq = griddata(x,y,-v,xq,yq,'v4');
mesh(xq,yq,vq);
hold on, hold on, scatter3(x(1:8),y(1:8),-v(1:8),'ob','fill'),scatter3(x(9:15),y(9:15),-v(9:15),'oc','fill'),
figure(2)
TrainingFeatureMatrix=B*TrainingFeatureMatrix;
[COEFF,SCORE] = princomp(TrainingFeatureMatrix');
PincipleMatrix= TrainingFeatureMatrix'*COEFF;
PrincipleMatrix=PincipleMatrix(:,1:3);
x=PincipleMatrix(:,1);
y=PincipleMatrix(:,2);
v=PincipleMatrix(:,3);
d1 = -0.3:0.005:0.5;
d2 = -0.5:0.005:0.1;
[xq,yq] = meshgrid(d1,d2);
vq = griddata(x,y,v,xq,yq,'v4');
mesh(xq,yq,vq);
hold on, scatter3(x(1:8),y(1:8),v(1:8),'ob','fill'),scatter3(x(9:15),y(9:15),v(9:15),'oc','fill'),
hold off
