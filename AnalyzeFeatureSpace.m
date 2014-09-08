%Display and show the KL divergence of different feature space of different
%capturing rounds.
%Load features
clear;
k_knn=20;
featureName='enlarged_RegisteredFeature_Aug27_left_';
rightfeatureName='enlarged_RegisteredFeature_Aug27_right_';

%Load training feature matrix.
for RoundNumber=1:4
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        rightfeature=load([rightfeatureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        rightfeaturevector=rightfeature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*36)=[featurevector;rightfeaturevector]; 
    end
end

for i=1:4
    figure(i);
    AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix(:,1+(i-1)*36:36+(i-1)*36), 0.5383);
end

KLD=zeros(4);
for i=1:4
    for j=i+1:4
        KLD(i,j)=CalKLDivergence(FeatureMatrix(:,1+(i-1)*36:36+(i-1)*36),FeatureMatrix(:,1+(j-1)*36:36+(j-1)*36),0.5383);
    end
end