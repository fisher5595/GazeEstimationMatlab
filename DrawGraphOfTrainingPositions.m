clear;
set(0,'defaultAxesFontName', 'Times');
set(0,'defaultTextFontName', 'Times');
set(0,'defaultAxesFontSize', 20);
set(0,'defaultLegendFontSize', 15);
%% 1
% for y=1:6
%     for x=1:6
%         PositionMatrix(1,(y-1)*6+x)=floor(480/7*y);
%         PositionMatrix(2,(y-1)*6+x)=floor(640/7*x);
%     end
% end

%%2
% xspace=floor(640/7);
% yspace=floor(480/7);
% halfxspace=floor(double(xspace/2));
% halfyspace=floor(double(yspace/2));
% PositionMatrix=[];
% TestingPositionMatrix=[];
% for RoundNumber=1:5
%     for y=1:6
%         for x=1:6
%             PositionMatrix=[PositionMatrix [yspace*y;xspace*x]];
%         end
%         if y~=6
%             for xx=1:5
%                 TestingPositionMatrix=[TestingPositionMatrix [yspace*y+halfyspace;halfxspace+xx*xspace]];
%             end
%         end
%     end
% end

%%3
%Load data and split training and testing data.
SubjectNumber=0;
SaveDir='./DataSet/';
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
OmittedPositionMatrix=[];
for y=1:NumOfDifferentY
    for x=1:NumOfDifferentX-1
        if mod(x+y,2)==0
            TrainingPositionMatrix=[TrainingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
        else
            TestingPositionMatrix=[TestingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
        end
    end
    x=NumOfDifferentX;
    OmittedPositionMatrix=[OmittedPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];    
end
%% plot
h=figure(1);
a=20;
scatter(TrainingPositionMatrix(2,:)',TrainingPositionMatrix(1,:)',a,'x','LineWidth',15);
hold on;
scatter(TestingPositionMatrix(2,:)',TestingPositionMatrix(1,:)',a,'rx','LineWidth',15);
scatter(OmittedPositionMatrix(2,:)',OmittedPositionMatrix(1,:)',a,'gx','LineWidth',15);
set(gca,'xaxislocation','top','ydir','reverse','Box','on','XTickMode','manual','YTickMode','manual','LineWidth',1.5);
axis([1 474 1 296]);
hold off;

