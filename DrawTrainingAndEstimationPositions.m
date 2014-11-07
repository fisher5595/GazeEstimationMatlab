clear;
set(0,'defaultAxesFontName', 'Times');
set(0,'defaultTextFontName', 'Times');
set(0,'defaultAxesFontSize', 15);
set(0,'defaultTextFontSize', 15);
%% 1
% for y=1:6
%     for x=1:6
%         PositionMatrix(1,(y-1)*6+x)=floor(480/7*y);
%         PositionMatrix(2,(y-1)*6+x)=floor(640/7*x);
%     end
% end

%%2
xspace=floor(640/7);
yspace=floor(480/7);
halfxspace=floor(double(xspace/2));
halfyspace=floor(double(yspace/2));
PositionMatrix=[];
TestingPositionMatrix=[];
for RoundNumber=1:5
    for y=1:6
        for x=1:6
            PositionMatrix=[PositionMatrix [yspace*y;xspace*x]];
        end
        if y~=6
            for xx=1:5
                TestingPositionMatrix=[TestingPositionMatrix [yspace*y+halfyspace;halfxspace+xx*xspace]];
            end
        end
    end
end

%%3
%Load data and split training and testing data.
% SubjectNumber=0;
% SaveDir='./DataSet/';
% x=load([SaveDir,num2str(SubjectNumber),'/','TotalFeatureMatrix', '.mat']);
% TotalFeatureMatrix=x.x;
% x=load([SaveDir,num2str(SubjectNumber),'/','TotalGazePositionMatrix', '.mat']);
% TotalGazePositionMatrix=x.x;
% FeatureDimension=size(TotalFeatureMatrix,1);
% FeatureAmount=size(TotalFeatureMatrix,2);
% NumOfDifferentX=size(find(TotalGazePositionMatrix(1,:)==TotalGazePositionMatrix(1,1)),2);
% NumOfDifferentY=FeatureAmount/NumOfDifferentX;
% TrainingFeatureMatrix=[];
% TestingFeatureMatrix=[];
% TrainingPositionMatrix=[];
% TestingPositionMatrix=[];
% OmittedPositionMatrix=[];
% for y=1:NumOfDifferentY
%     for x=1:NumOfDifferentX-1
%         if mod(x+y,2)==0
%             TrainingPositionMatrix=[TrainingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
%         else
%             TestingPositionMatrix=[TestingPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];
%         end
%     end
%     x=NumOfDifferentX;
%     OmittedPositionMatrix=[OmittedPositionMatrix TotalGazePositionMatrix(:,(y-1)*NumOfDifferentX+x)];    
% end

%% Load estimations
Estimations_SplitTrainTest_ALR=load(['Estimations_SplitTrainTest_ALR_','.mat']);
Estimations_SplitTrainTest_ALR=Estimations_SplitTrainTest_ALR.x;
Estimations_SplitTrainTest_LLR=load(['Estimations_SplitTrainTest_LLR_','.mat']);
Estimations_SplitTrainTest_LLR=Estimations_SplitTrainTest_LLR.x;
Estimations_SplitTrainTest_Sol3=load(['Estimations_SplitTrainTest_Sol3_','.mat']);
Estimations_SplitTrainTest_Sol3=Estimations_SplitTrainTest_Sol3.x;
Estimations_SplitTrainTest_LLR_Tri=load(['Estimations_SplitTrainTest_LLR_Tri','.mat']);
Estimations_SplitTrainTest_LLR_Tri=Estimations_SplitTrainTest_LLR_Tri.x;
Estimations_SplitTrainTest_SVR=load(['Estimations_SplitTrainTest_SVR_','.mat']);
Estimations_SplitTrainTest_SVR=Estimations_SplitTrainTest_SVR.x;
Estimations_SplitTrainTest_Sol1=load(['Estimations_SplitTrainTest_Sol1_','.mat']);
Estimations_SplitTrainTest_Sol1=Estimations_SplitTrainTest_Sol1.x;

%% plot
% h=figure(1);
% a=20;
% % scatter(TrainingPositionMatrix(2,:)',TrainingPositionMatrix(1,:)',a,'x','LineWidth',15);
% hold on;
% scatter(TestingPositionMatrix(2,:)',TestingPositionMatrix(1,:)',70,'ro','LineWidth',0.5);
% scatter(Estimations_SplitTrainTest_ALR(2,:)',Estimations_SplitTrainTest_ALR(1,:)','b+','LineWidth',0.5);
% scatter(Estimations_SplitTrainTest_LLR(2,:)',Estimations_SplitTrainTest_LLR(1,:)','m+','LineWidth',0.5);
% scatter(Estimations_SplitTrainTest_Sol3(2,:)',Estimations_SplitTrainTest_Sol3(1,:)','g+','LineWidth',0.5);
% scatter(Estimations_SplitTrainTest_LLR_Tri(2,:)',Estimations_SplitTrainTest_LLR_Tri(1,:)','k+','LineWidth',0.5);
% %scatter(OmittedPositionMatrix(2,:)',OmittedPositionMatrix(1,:)',a,'gx','LineWidth',15);
% set(gca,'xaxislocation','top','ydir','reverse','Box','on','XTickMode','manual','YTickMode','manual','LineWidth',1.5);
% legend('Ground truth','ALR','LLR','Ours','LLR\_Tri');
% axis([1 640 1 480]);
% hold off;
h=figure(1);
a=20;
% scatter(TrainingPositionMatrix(2,:)',TrainingPositionMatrix(1,:)',a,'x','LineWidth',15);
hold on;
scatter(TestingPositionMatrix(2,1:25)',TestingPositionMatrix(1,1:25)',200,'ro','LineWidth',1.5);
scatter(Estimations_SplitTrainTest_SVR(2,:)',Estimations_SplitTrainTest_SVR(1,:)',70,'b+','LineWidth',1.5);
scatter(Estimations_SplitTrainTest_Sol3(2,:)',Estimations_SplitTrainTest_Sol3(1,:)',70,'g+','LineWidth',1.5);
%scatter(OmittedPositionMatrix(2,:)',OmittedPositionMatrix(1,:)',a,'gx','LineWidth',15);
set(gca,'xaxislocation','top','ydir','reverse','Box','on','LineWidth',1.5);
axis([1 640 1 480]);
hleg=legend({'Ground-truth','SVR','Ours-R'},'FontSize',15,'FontWeight','bold');
set(hleg,'position',[100,100,100,100]);
legend('show');
hold off;
saveas(h,'SVR-Ours-R.eps','epsc');
h=figure(2);
a=20;
% scatter(TrainingPositionMatrix(2,:)',TrainingPositionMatrix(1,:)',a,'x','LineWidth',15);
hold on;
scatter(TestingPositionMatrix(2,1:25)',TestingPositionMatrix(1,1:25)',70,'ro','LineWidth',0.5);
scatter(Estimations_SplitTrainTest_LLR(2,:)',Estimations_SplitTrainTest_LLR(1,:)','b+','LineWidth',0.5);
scatter(Estimations_SplitTrainTest_Sol3(2,:)',Estimations_SplitTrainTest_Sol3(1,:)','g+','LineWidth',0.5);
%scatter(OmittedPositionMatrix(2,:)',OmittedPositionMatrix(1,:)',a,'gx','LineWidth',15);
set(gca,'xaxislocation','top','ydir','reverse','Box','on','LineWidth',1.5);
legend({'Ground truth','LLE','Ours-R'},'location','northwest','FontSize',15,'FontWeight','bold');
axis([1 640 1 480]);
hold off;
saveas(h,'LLE-Ours-R.eps','epsc');
h=figure(3);
a=20;
% scatter(TrainingPositionMatrix(2,:)',TrainingPositionMatrix(1,:)',a,'x','LineWidth',15);
hold on;
scatter(TestingPositionMatrix(2,1:25)',TestingPositionMatrix(1,1:25)',70,'ro','LineWidth',0.5);
scatter(Estimations_SplitTrainTest_LLR_Tri(2,:)',Estimations_SplitTrainTest_LLR_Tri(1,:)','b+','LineWidth',0.5);
scatter(Estimations_SplitTrainTest_Sol3(2,:)',Estimations_SplitTrainTest_Sol3(1,:)','g+','LineWidth',0.5);
%scatter(OmittedPositionMatrix(2,:)',OmittedPositionMatrix(1,:)',a,'gx','LineWidth',15);
set(gca,'xaxislocation','top','ydir','reverse','Box','on','LineWidth',1.5);
legend({'Ground truth','LLE\_TRI','Ours-R'},'location','northwest','FontSize',15,'FontWeight','bold');
axis([1 640 1 480]);
hold off;
saveas(h,'LLE_TRI-Ours-R.eps','epsc');
h=figure(4);
a=20;
% scatter(TrainingPositionMatrix(2,:)',TrainingPositionMatrix(1,:)',a,'x','LineWidth',15);
hold on;
scatter(TestingPositionMatrix(2,1:25)',TestingPositionMatrix(1,1:25)',70,'ro','LineWidth',0.5);
scatter(Estimations_SplitTrainTest_ALR(2,:)',Estimations_SplitTrainTest_ALR(1,:)','b+','LineWidth',0.5);
scatter(Estimations_SplitTrainTest_Sol3(2,:)',Estimations_SplitTrainTest_Sol3(1,:)','g+','LineWidth',0.5);
%scatter(OmittedPositionMatrix(2,:)',OmittedPositionMatrix(1,:)',a,'gx','LineWidth',15);
set(gca,'xaxislocation','top','ydir','reverse','Box','on','LineWidth',1.5);
legend({'Ground truth','ALR','Ours-R'},'location','northwest','FontSize',15,'FontWeight','bold');
axis([1 640 1 480]);
hold off;
saveas(h,'ALR-Ours-R.eps','epsc');
h=figure(5);
a=20;
% scatter(TrainingPositionMatrix(2,:)',TrainingPositionMatrix(1,:)',a,'x','LineWidth',15);
hold on;
scatter(TestingPositionMatrix(2,1:25)',TestingPositionMatrix(1,1:25)',70,'ro','LineWidth',0.5);
scatter(Estimations_SplitTrainTest_Sol1(2,:)',Estimations_SplitTrainTest_Sol1(1,:)','b+','LineWidth',0.5);
scatter(Estimations_SplitTrainTest_Sol3(2,:)',Estimations_SplitTrainTest_Sol3(1,:)','g+','LineWidth',0.5);
%scatter(OmittedPositionMatrix(2,:)',OmittedPositionMatrix(1,:)',a,'gx','LineWidth',15);
set(gca,'xaxislocation','top','ydir','reverse','Box','on','LineWidth',1.5);
legend({'Ground truth','Ours','Ours-R'},'location','northwest','FontSize',15,'FontWeight','bold');
axis([1 640 1 480]);
hold off;
saveas(h,'Ours-Ours-R.eps','epsc');
