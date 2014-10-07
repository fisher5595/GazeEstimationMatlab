%Refer to Professor Wu's new method pdf, new solution 1.
% S matrix will stored as S_S00_1e-6.mat, Errors will be saved as
% Error_S00_1e-6.mat also the feature matrix and gaze positionmatrix will
% be saved.
% Load features
clear;
k_knn=8;
SaveDir='./DataSet/';
InputFileDir='/media/peiyu/OS/Users/PeiYu/Downloads/s00-09';
StartingCriterion=1e-7;
EndingCrierion=1e-10;
StepSize=0.01;

% Setup email your account and password.
myaddress = 'fisher5595@gmail.com';
mypassword = 'yp19871014';

setpref('Internet','E_mail',myaddress);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',myaddress);
setpref('Internet','SMTP_Password',mypassword);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

%sendmail(myaddress, 'Start of all work', 'Watch out');

for SubjectNumber=0:9
    StoppingCriterion=StartingCriterion;
    % Extract feature and gaze position matrix, and save them
    [ TotalFeatureMatrix, TotalGazePositionMatrix] = ExtractMatricesFromSatoDataset( InputFileDir, [SaveDir,num2str(SubjectNumber)], SubjectNumber);
    x.x=TotalFeatureMatrix;
    save([SaveDir,num2str(SubjectNumber),'/','TotalFeatureMatrix', '.mat'],'-struct','x');
    x.x=TotalGazePositionMatrix;
    save([SaveDir,num2str(SubjectNumber),'/','TotalGazePositionMatrix', '.mat'],'-struct','x');
    %Split feature matrix into training feature matrix and testing feature
    %matrix, also add the position matrices
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
    
    % Estimate the parameters of sigma1 and sigma2.
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
    
    % Loop through all Stopping Criterion, calculate S, save intermediate
    % result of S and Error
    StartingS=eye(FeatureDimension);
    while StoppingCriterion>=EndingCrierion
        % Extract feature and gaze position matrix, and save them
        close all;
        S=NewFindMetricPreservationMatrix(TrainingFeatureMatrix,TrainingPositionMatrix,Sigma1,Sigma2,StartingS,StoppingCriterion,StepSize);
        h=figure(1);
        AffinityMatrix1=DisplayAffinityMatrix(TrainingFeatureMatrix, Sigma2);
        saveas(h,[SaveDir,num2str(SubjectNumber),'/S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'_figure1.jpg']);
        h=figure(2);
        AffinityMatrix2=DisplayAffinityMatrix(TrainingPositionMatrix,Sigma1);
        saveas(h,[SaveDir,num2str(SubjectNumber),'/S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'_figure2.jpg']);
        h=figure(3);
        AffinityMatrix3=DisplayAffinityMatrix(TrainingFeatureMatrix,Sigma2,S);
        saveas(h,[SaveDir,num2str(SubjectNumber),'/S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'_figure3.jpg']);
        x.x=S;
        save([SaveDir,num2str(SubjectNumber),'/','S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'.mat'],'-struct','x');
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

        %S=eye(size(FeatureMatrix,1));
        Errors=double(zeros(NumOfFeaturesInTesting,1));
        for QueryNumber=1:NumOfFeaturesInTesting
            QueryFeature=TestingFeatureMatrix(:,QueryNumber);
            FeatureVector=QueryFeature;
        %    S=FindMetricPreservationMatrix(TrainingFeatureMatrix,TrainingPositionMatrix);
        %     figure(1);
        %     AffinityMatrix1=DisplayAffinityMatrix(TrainingFeatureMatrix, 0.1199);
        %     figure(2);
        %     AffinityMatrix2=DisplayAffinityMatrix(TrainingPositionMatrix,64723);
        %     figure(3);
        %     AffinityMatrix3=DisplayAffinityMatrix(TrainingFeatureMatrix,0.1199,S);
            for ii = 1:NumOfFeaturesInTraining
                DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
            end
            [SortedDistanceMatrix,index]=sort(DistanceMatrix);
            disp('QueryNumber');
            disp(QueryNumber);
            disp('index:');
            disp(index);
            %index(find(index==QueryNumber))=[];

            for k=1:k_knn
                AMatrix(:,k)=TrainingFeatureMatrix(:,index(k));
                TrainingWeightMatrix(:,k)=TrainingPositionMatrix(:,index(k));
            end
            CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
            weight=pinv(CMatrix)*ones(k_knn,1);
            weight=weight./sum(weight);
        %     %Estimation for absolute gaze position
             EstimatePosition=TrainingWeightMatrix*weight;
             Errors(QueryNumber)=norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
        %    EstimateRelativePosition=TrainingWeightMatrix*weight;
        %    Result=fsolve(@(x) RelativePositonToAbsolute(x,EstimateRelativePosition),[1,1,100],optimset('Display','off','TolFun',1e-16));
        %    EstimatePosition(:,1)=Result(1:2);
        %    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
            %figure(2);
        end
        disp('AvgError');
        AvgError=sum(Errors)/NumOfFeaturesInTesting;
        disp(AvgError);
        x.x=Errors;
        save([SaveDir,num2str(SubjectNumber),'/','Errors_S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize), '.mat'],'-struct','x');
        StartingS=S;
        % Send notification via email
        sendmail(myaddress, sprintf('Subject[%02d], Stopping[%e], Epsilon[%g]',SubjectNumber, StoppingCriterion,StepSize), [sprintf('AverageError[%8.5f]',AvgError) 10 ...
                 sprintf('Sigma1[%10.2f]',Sigma1) 10 sprintf('Sigma2[%8.7f]',Sigma2)],...
                 {[SaveDir,num2str(SubjectNumber),'/S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'_figure1.jpg'],...
                 [SaveDir,num2str(SubjectNumber),'/S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'_figure2.jpg'],...
                 [SaveDir,num2str(SubjectNumber),'/S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize),'_figure3.jpg']});
        StoppingCriterion=StoppingCriterion/10;
    end
end
