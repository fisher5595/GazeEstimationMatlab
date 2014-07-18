%Calculate the knn of input feature, plot the corresponding first knn
%coordinates rectangels.
QueryNumber=10;
DisplayKnn=6;
featureName='enlarged_AlignedFeature_left_';
feature=load([featureName,int2str(QueryNumber-1),'.mat']);
QueryFeature=feature.x;

%Load training feature matrix.
for i = 1:36
    feature=load([featureName,int2str(i-1),'.mat']);
    %A=load([matrixAName,int2str(i-1),'.mat']);
    trainingPositions=load([knnPositionsName,int2str(i-1),'.mat']);
    groundTruth=load([groundTruthName,int2str(i-1),'.mat']);
    featurevector=feature.x;
    %matrixA=A.A;
    trainingPositionMatrix=trainingPositions.A;
    groundTruthVector=groundTruth.x;
    FeatureMatrix(:,i)=featurevector; 
end

for QueryNumber=1:36
    feature=load([featureName,int2str(QueryNumber-1),'.mat']);
    QueryFeature=feature.x;
    %Calculate SSD of the 
    SSDOfFeature=[];
    for i=1:36
        SSDOfFeature(i)=sum((double(QueryFeature)-double(FeatureMatrix(:,i))).^2);
    end
    [SortedSSD,SortedIndex]=sort(SSDOfFeature);
    close all;
    %Draw the grid
    figure(1);
    % line([0,0],[0,480]);
    % line([640,640],[0,480]);
    % line([0,640],[0,0]);
    % line([0,640],[480,480]);
    for i=1:6
        line([640/7*i,640/7*i],[0,480]);
        line([0,640],[480/7*i,480/7*i]);
    end

    %Draw rectangel with text displaying number
    XCor=(mod(QueryNumber-1,6)+1)*640/7;
    YCor=480-(floor((QueryNumber-1)/6)+1)*480/7;
    rectangle('Position',[XCor-10,YCor-10,20,20],'EdgeColor','r','LineWidth',2);

    for i=1:DisplayKnn
        if SortedIndex(i)==QueryNumber;
            continue;
        end
        XCor=(mod(SortedIndex(i)-1,6)+1)*640/7;
        YCor=480-(floor((SortedIndex(i)-1)/6)+1)*480/7;
        rectangle('Position',[XCor-10,YCor-10,20,20],'EdgeColor','g','LineWidth',2);
        text(XCor,YCor,int2str(i-1));
    end
    pause;
    %figure(2);
end

