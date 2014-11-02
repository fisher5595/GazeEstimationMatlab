clear;
for y=1:6
    for x=1:6
        TestingPositionMatrix(1,(y-1)*6+x)=floor(480/7*y);
        TestingPositionMatrix(2,(y-1)*6+x)=floor(640/7*x);
    end
end
TRI=delaunay(TestingPositionMatrix(2,:),TestingPositionMatrix(1,:));
triplot(TRI,TestingPositionMatrix(2,:),TestingPositionMatrix(1,:));