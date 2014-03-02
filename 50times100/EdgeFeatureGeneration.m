%
% Generate and compare the gradient, edge matrix.
%

ImageName='enlarged_alignedEyes_left_';
RightImageName='enlarged_alignedEyes_right_';
CorrectRanking_PreservedDistance=0;
CorrectRanking_EdgeScore=0;
ContainFirstKIndexIn_PreservedDistance=zeros(36,36);
ContainFirstKIndexIn_EdgeScore=zeros(36,36);
for ImageNumber=1:36
    ImageExtension='.jpg';
    ReferenceImageGradient=GetNormalizedEdgeWithoutWeak(ImageName, ImageNumber, ImageExtension);
    RightReferenceImageGradient=GetNormalizedEdgeWithoutWeak(RightImageName, ImageNumber, ImageExtension);
    ScoreResult=zeros(1,36);
    for QueryImageNumber=1:36
        QueryImageGradient=GetNormalizedEdgeWithoutWeak (ImageName, QueryImageNumber, ImageExtension);
        RightQueryImageGradient=GetNormalizedEdgeWithoutWeak (RightImageName, QueryImageNumber, ImageExtension);
        [height, width]=size(imread([ImageName,int2str(ImageNumber),ImageExtension]));
        MatchingScore=QueryImageGradient(:,:,1).*ReferenceImageGradient(:,:,1)+QueryImageGradient(:,:,2).*ReferenceImageGradient(:,:,2);
        RightMatchingScore=RightQueryImageGradient(:,:,1).*RightReferenceImageGradient(:,:,1)+RightQueryImageGradient(:,:,2).*RightReferenceImageGradient(:,:,2);
        ScoreResult(QueryImageNumber)=sum(sum(MatchingScore))+sum(sum(RightMatchingScore));
    end
    [SortedResult,index]=sort(ScoreResult,'descend');


    disp('Position distance:');
    [PositionSortedResult,PositionIndex]=sort(TotalPositionDistanceMatrix(ImageNumber,:));
    disp(PositionIndex);

    PreservedDistance=zeros(1,36);
    PreservedFeatureVector=FeatureMatrix(:,ImageNumber);
    for i = 1:6
        for j=1:6
            PreservedDistance((i-1)*6+j)=(PreservedFeatureVector-FeatureMatrix(:,(i-1)*6+j))'*S*(PreservedFeatureVector-FeatureMatrix(:,(i-1)*6+j));        
        end
    end
    [PreservedFeatureDisanceSortResult,FeatureIndex]=sort(PreservedDistance);
    disp('Pixel feature matching index:')
    disp(FeatureIndex);
    disp('Pixel feature matching index correct:')
    disp(sum(FeatureIndex==PositionIndex));
    CorrectRanking_PreservedDistance=CorrectRanking_PreservedDistance+sum(FeatureIndex==PositionIndex);
    ContainFirstKIndexIn_PreservedDistance(ImageNumber,:)=HowManyFirstKofAAreInFirstKofB(PositionIndex,FeatureIndex);

    disp('Edge matching index:');
    disp(index);
    disp('Edge matching index corrct:');
    disp(sum(index==PositionIndex));
    CorrectRanking_EdgeScore=CorrectRanking_EdgeScore+sum(index==PositionIndex);
    ContainFirstKIndexIn_EdgeScore(ImageNumber,:)=HowManyFirstKofAAreInFirstKofB(PositionIndex,index);
end