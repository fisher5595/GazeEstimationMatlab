%test case from i=1 to 36;
clear all;
clc;
featureName='feature_';
matrixAName='amatrix_';
groundTruthName='queryGroundTruth_';
knnPositionsName='knnPositions_';
r=5;
k_knn=5;
for i = 1:36
    feature=load([featureName,int2str(i-1),'.mat']);
    A=load([matrixAName,int2str(i-1),'.mat']);
    trainingPositions=load([knnPositionsName,int2str(i-1),'.mat']);
    groundTruth=load([groundTruthName,int2str(i-1),'.mat']);
    featurevector=feature.x;
    matrixA=A.A;
    trainingPositionMatrix=trainingPositions.A;
    groundTruthVector=groundTruth.x;
    matrixD=[featurevector,matrixA];
    [U,S,V]=svd(matrixD);
    P=U(:,1:r);
    C1=(featurevector*(ones(5,1)')-matrixA)'*(featurevector*(ones(5,1)')-matrixA);
    for ii=1:k_knn
        for jj=1:k_knn
            C2(ii,jj)=(featurevector-matrixA(:,ii))'*P*P'*(featurevector-matrixA(:,jj));
        end
    end
    weight=C2\ones(k_knn,1);
    weight=weight./sum(weight);
    estimatePosition=weight'*trainingPositionMatrix;
    error(i,1)=sum((groundTruthVector-estimatePosition').^2);
    error(i,2)=sum((featurevector-matrixA*weight).^2);
    
end