%Plot distance 3D pic
TestCase=1;
FeatureVector=FeatureMatrix(:,TestCase);
OldFeatureVector=OldFeatureMatrix(:,TestCase);
PositionVector=PositionMatrix(:,TestCase);
PreservedDistanceMatrix=zeros(6,6);
DistanceMatrix=zeros(6,6);
OldDistanceMatrix=zeros(6,6);
PositionDistanceMatrix=zeros(6,6);
HeterPositionDistanceMatrix=zeros(6,6);
for i = 1:6
    for j=1:6
        PreservedDistanceMatrix(i,j)=(FeatureVector-FeatureMatrix(:,(i-1)*6+j))'*S*(FeatureVector-FeatureMatrix(:,(i-1)*6+j));
        DistanceMatrix(i,j)=(FeatureVector-FeatureMatrix(:,(i-1)*6+j))'*(FeatureVector-FeatureMatrix(:,(i-1)*6+j));
        PositionDistanceMatrix(i,j)=(PositionVector-PositionMatrix(:,(i-1)*6+j))'*(PositionVector-PositionMatrix(:,(i-1)*6+j));
        OldDistanceMatrix(i,j)=(OldFeatureVector-OldFeatureMatrix(:,(i-1)*6+j))'*(OldFeatureVector-OldFeatureMatrix(:,(i-1)*6+j));
    end
end
%
% Heterogenous distance, gradient from border to center to border is 1 to 2
% to 1
%
for i = 1:6
    for j=1:6
        if PositionVector(1)<240
            y1=2*PositionVector(1)+PositionVector(1)^2/480-PositionVector(1);
        else
            y1=2*PositionVector(1)-PositionVector(1)^2/480+PositionVector(1);
        end
        if PositionMatrix(1,(i-1)*6+j)<240
            y2=2*PositionMatrix(1,(i-1)*6+j)+PositionMatrix(1,(i-1)*6+j)^2/480-PositionMatrix(1,(i-1)*6+j);
        else
            y2=2*PositionMatrix(1,(i-1)*6+j)-PositionMatrix(1,(i-1)*6+j)^2/480+PositionMatrix(1,(i-1)*6+j);
        end
        if PositionVector(2)<320
            x1=2*PositionVector(2)+PositionVector(2)^2/640-PositionVector(2);
        else
            x1=2*PositionVector(2)-PositionVector(2)^2/640+PositionVector(2);
        end
        if PositionMatrix(2,(i-1)*6+j)<320
            x2=2*PositionMatrix(2,(i-1)*6+j)+PositionMatrix(2,(i-1)*6+j)^2/640-PositionMatrix(2,(i-1)*6+j);
        else
            x2=2*PositionMatrix(2,(i-1)*6+j)-PositionMatrix(2,(i-1)*6+j)^2/640+PositionMatrix(2,(i-1)*6+j);
        end
        HeterPositionDistanceMatrix(i,j)=(x1-x2)^2+(y1-y2)^2;
    end
end

%
% Heterogenous distance, gradient from border to center to border is 2 to 1
% to 2
%
% for i = 1:6
%     for j=1:6
%         if PositionVector(1)<240
%             y1=2*PositionVector(1)-PositionVector(1)^2/480;
%         else
%             y1=PositionVector(1)^2/480;
%         end
%         if PositionMatrix(1,(i-1)*6+j)<240
%             y2=2*PositionMatrix(1,(i-1)*6+j)-PositionMatrix(1,(i-1)*6+j)^2/480;
%         else
%             y2=PositionMatrix(1,(i-1)*6+j)^2/480;
%         end
%         if PositionVector(2)<320
%             x1=2*PositionVector(2)-PositionVector(2)^2/640;
%         else
%             x1=PositionVector(2)^2/640;
%         end
%         if PositionMatrix(2,(i-1)*6+j)<320
%             x2=2*PositionMatrix(2,(i-1)*6+j)-PositionMatrix(2,(i-1)*6+j)^2/640;
%         else
%             x2=PositionMatrix(2,(i-1)*6+j)^2/640;
%         end
%         HeterPositionDistanceMatrix(i,j)=(x1-x2)^2+(y1-y2)^2;
%     end
% end

for i = 1:6
    for j = 1:6
        for ii=1:6
            for jj=1:6
                TotalPositionDistanceMatrix((i-1)*6+j,(ii-1)*6+jj)=(PositionMatrix(:,(i-1)*6+j)-PositionMatrix(:,(ii-1)*6+jj))'*(PositionMatrix(:,(i-1)*6+j)-PositionMatrix(:,(ii-1)*6+jj));
                TotalFeatureDistanceMatrix((i-1)*6+j,(ii-1)*6+jj)=(FeatureMatrix(:,(i-1)*6+j)-FeatureMatrix(:,(ii-1)*6+jj))'*(FeatureMatrix(:,(i-1)*6+j)-FeatureMatrix(:,(ii-1)*6+jj));
            end
        end
    end
end
figure(1)
mesh(PositionMatrix(2,1:6),PositionMatrix(1,1:6:36),PreservedDistanceMatrix);
figure(2)
mesh(PositionMatrix(2,1:6),PositionMatrix(1,1:6:36),DistanceMatrix);
figure(3)
mesh(PositionMatrix(2,1:6),PositionMatrix(1,1:6:36),OldDistanceMatrix);
figure(4)
mesh(PositionMatrix(2,1:6),PositionMatrix(1,1:6:36),PositionDistanceMatrix);
figure(5)
mesh(PositionMatrix(2,1:6),PositionMatrix(1,1:6:36),HeterPositionDistanceMatrix);