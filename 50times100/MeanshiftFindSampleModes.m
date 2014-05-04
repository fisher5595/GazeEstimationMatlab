function [ SortedFinalSampleModes, SortedFinalSampleModeWeights ] = MeanshiftFindSampleModes( InputSamples, SamplesWeights )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Use MeanShift method, calculate weighted sample modes.

% Decide the window size of mean shift.
SampleDimension=size(InputSamples, 1);
SamplesAmount=size(InputSamples, 2);
WindowSize=zeros(SampleDimension,1);
WindowSizeFactor=3;
DistinctDistance=5;
ConvergeStopDistance=3;
for i=1:SampleDimension
    WindowSize(i)=max((InputSamples(i,:))-min(InputSamples(i,:)))/WindowSizeFactor;
end

% Initial Mean positions as input samples.
SampleModes=InputSamples;
SampleModesAmount=size(SampleModes,2);
SampleModeWeights=zeros(1,SampleModesAmount);
%PreviousSampleModes=SampleModes;
% For each initial sample mode, shift it till it converges.
for i=1:SampleModesAmount
    while 1
        % Collect samples inside the window
        SamplesInWindow=[];
        SamplesWeightInWindow=[];
        for j=1:SamplesAmount
            InWindow=true;
            for k=1:SampleDimension
                if (abs(InputSamples(k,j)-SampleModes(k,i))>WindowSize(k)) && (WindowSize(k)~=0)
                    InWindow=false;
                    break;
                end
            end
            if InWindow==true
                SamplesInWindow=[SamplesInWindow,InputSamples(:,j)];
                SamplesWeightInWindow=[SamplesWeightInWindow,SamplesWeights(j)];
            end
        end
        % Calculate the weighted centroid inside this window
        NormalizedWeightInWindow=SamplesWeightInWindow./sum(SamplesWeightInWindow);
        NewSampleMode=SamplesInWindow*NormalizedWeightInWindow';
        MeanShiftVector=NewSampleMode-SampleModes(:,i);
        if norm(MeanShiftVector)<ConvergeStopDistance
            SampleModes(:,i)=NewSampleMode;
            SampleModeWeights(i)=sum(SamplesWeightInWindow);
            break;
        end
        SampleModes(:,i)=NewSampleMode;
        SampleModeWeights(i)=sum(SamplesWeightInWindow);
    end
end
% Combine similar sample modes
FinalSampleModes=[];
FinalSampleModeWeights=[];
for i=1:SamplesAmount
    DistinctMode=true;
    for j=1:size(FinalSampleModes,2)
        if norm(SampleModes(:,i)-FinalSampleModes(:,j))<DistinctDistance
            DistinctMode=false;
            break;
        end
    end
    if DistinctMode
        FinalSampleModes=[FinalSampleModes,SampleModes(:,i)];
        FinalSampleModeWeights=[FinalSampleModeWeights,SampleModeWeights(i)];
    end
end
SortedFinalSampleModesAndWeights=sortrows([FinalSampleModes;FinalSampleModeWeights]',-(SampleDimension+1));
SortedFinalSampleModesAndWeights=SortedFinalSampleModesAndWeights';
SortedFinalSampleModes=SortedFinalSampleModesAndWeights(1:SampleDimension,:);
SortedFinalSampleModeWeights=SortedFinalSampleModesAndWeights(SampleDimension+1,:);

end

