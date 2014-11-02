function [ Indexes ] = FindClosedTriangle( QueryFeature, TrainingFeatureMatrix, TRI, NumberOfRounds )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
NumOfFeaturesInTraining=size(TrainingFeatureMatrix,2);
NumInOneRound=NumOfFeaturesInTraining/NumberOfRounds;
for ii = 1:NumOfFeaturesInTraining
    DistanceMatrix(ii)=(QueryFeature-TrainingFeatureMatrix(:,ii))'*(QueryFeature-TrainingFeatureMatrix(:,ii));
end
NumOfTriangles=size(TRI,1);
TRIAndTotalDistance=zeros(NumOfTriangles,4);
TRIAndTotalDistance(:,1:3)=TRI;
for i=1:NumOfTriangles
    for ii=1:NumberOfRounds
        TRIAndTotalDistance(i,4)=TRIAndTotalDistance(i,4)+DistanceMatrix(TRI(i,1)+(ii-1)*NumInOneRound)+DistanceMatrix(TRI(i,2)+(ii-1)*NumInOneRound)+DistanceMatrix(TRI(i,3)+(ii-1)*NumInOneRound);
    end
end
[SortedTRIAndTotalDistance SortIndex]=sortrows(TRIAndTotalDistance,4);
Indexes=SortedTRIAndTotalDistance(1,1:3);
end

