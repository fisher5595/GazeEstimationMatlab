function [ NewSamples ] = GenerateSmaplesBasedOnWeights( OldSamples, OldWeights, Sigma, SampleAmount )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% One dimensional sample case
SampleDimension=size(OldSamples,1);
NewSamples=[];
LeftSampleAmount=SampleAmount;
[SortedOldWeights, Index]=sort(OldWeights,2,'descend');
for i=1:size(SortedOldWeights,2)
    if LeftSampleAmount<=0
        break;
    else
        TmpSampleAmount=min(ceil(SortedOldWeights(i)*SampleAmount),LeftSampleAmount);
        if SampleDimension==1 
            NewSamples=[NewSamples,normrnd(OldSamples(Index(i)),Sigma,1,TmpSampleAmount)];
        else
            NewSamples=[NewSamples,[normrnd(OldSamples(1,Index(i)),Sigma,1,TmpSampleAmount);normrnd(OldSamples(2,Index(i)),Sigma,1,TmpSampleAmount)]];
        end
        LeftSampleAmount=LeftSampleAmount-TmpSampleAmount;
    end
end

end

