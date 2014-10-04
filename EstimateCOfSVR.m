function [ EstimatedC ] = EstimateCOfSVR( InitialC, nfold, InitialScale, EndingScale,LabelVector,InstanceMatrix )
%Coarse to fine estimate C parameter of SVR, using cross-validation. Scale
%is decreased in one magnitude.
%   Detailed explanation goes here

BestC=InitialC;
BestError=svmtrain(LabelVector,InstanceMatrix,['-s 3 -t 0 -c ' num2str(InitialC) ' -p 1 -v ' num2str(nfold)]);

Scale=InitialScale;
LastScale=InitialScale*10;
while Scale>=EndingScale
    StartingC=BestC-LastScale;
    EndingC=BestC+LastScale;
    for C=StartingC:Scale:EndingC
        Error=svmtrain(LabelVector,InstanceMatrix,['-s 3 -t 0 -c ' num2str(C) ' -p 1 -v ' num2str(nfold)]);
        if Error<=BestError
            BestError=Error;
            BestC=C;
        end
        
    end
    LastScale=Scale;
    Scale=Scale/10;
end
EstimatedC=BestC;
end

