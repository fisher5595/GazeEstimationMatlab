%Load features
clear;
k_knn=20;
lamda=0.0001;
featureName='enlarged_RegisteredFeature_left_';

%Load training feature matrix.
for RoundNumber=1
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*36)=featurevector; 
    end
end

AvgFeature=double(zeros(size(FeatureMatrix,1),1));
%Normalize appearance feature space.
for i = 1:36
        FeatureMatrix(:,i+(RoundNumber-1)*36)=FeatureMatrix(:,i+(RoundNumber-1)*36)./norm(FeatureMatrix(:,i+(RoundNumber-1)*36));
        AvgFeature=AvgFeature+FeatureMatrix(:,i+(RoundNumber-1)*36)./36;
end
[FeatureEigenVectors, FeatureEigenValues]=eig((FeatureMatrix-AvgFeature*ones(1,36))'*(FeatureMatrix-AvgFeature*ones(1,36)));
FeatureEigenVectors=(FeatureMatrix-AvgFeature*ones(1,36))*FeatureEigenVectors;

%Generate all training position information, stored in a PositionMatrix.
for RoundNumber=1
    for y=1:6
        for x=1:6
            PositionMatrix(1,(y-1)*6+x+(RoundNumber-1)*36)=floor(480/7*y);
            PositionMatrix(2,(y-1)*6+x+(RoundNumber-1)*36)=floor(640/7*x);
        end
    end
end

%Generate new position matrix as a vector, each element is the distance to
%four corners of the gaze space. Then normalize it.
AvgRelativeGaze=double(zeros(36,1));
for RoundNumber=1
    for y=1:6
        for x=1:6
            for yy=1:6
                for xx=1:6
                    RelativePositionMatrix((yy-1)*6+xx+(RoundNumber-1)*36,(y-1)*6+x+(RoundNumber-1)*36)=norm(PositionMatrix(:,(yy-1)*6+xx+(RoundNumber-1)*36)-PositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
                end
            end
            RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)=RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)./norm(RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
            AvgRelativeGaze=RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)./36;
        end
    end
end
[GazeEigenVectors, GazeEigenValues]=eig((RelativePositionMatrix-AvgRelativeGaze*ones(1,36))'*(RelativePositionMatrix-AvgRelativeGaze*ones(1,36)));
GazeEigenVectors=(RelativePositionMatrix-AvgRelativeGaze*ones(1,36))*GazeEigenVectors;
