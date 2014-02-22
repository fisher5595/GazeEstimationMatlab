%Plot positions
MetricPreservationPositionMatrix=zeros(2,k_knn);
TestCase=25;
for i=1:k_knn
    MetricPreservationPositionMatrix(:,i)=PositionMatrix(:,TotalIndex(TestCase,i));
end
knn=load(['knnPositions_',int2str(TestCase-1),'.mat']);
knnPositions=knn.A;
figure(1)
plot(PositionMatrix(2,TestCase)/(640/7),7-PositionMatrix(1,TestCase)/(480/7),'ro');
hold on
plot(MetricPreservationPositionMatrix(2,:)./(640/7),7*ones(1,k_knn)-MetricPreservationPositionMatrix(1,:)./(480/7),'bs');
plot(knnPositions(:,2)'./(640/7),7*ones(1,k_knn)-knnPositions(:,1)'./(480/7),'gv');
hold off