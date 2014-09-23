function [ TragetfuncitonValue, Gradient] = Solution3TargetFuncVal(weight, S, AMatrix, B, lamda, FeatureVector, TrainingFeatureMatrix, TrainingPositionMatrix, QueryFeature )
%Give target function value of new solution 3, used for fminunc
%   Detailed explanation goes here

W=double(zeros(36*4,1));
P=double(zeros(36*4,1));
Us=double(zeros(36*4,1));
Qs=double(zeros(36*4,1));
for i=1:36*4
   W(i)=exp(-(B*weight-TrainingPositionMatrix(:,i))'*(B*weight-TrainingPositionMatrix(:,i))/2/64723);
   Us(i)=exp(-(QueryFeature-TrainingFeatureMatrix(:,i))'*S*(QueryFeature-TrainingFeatureMatrix(:,i))/2/0.5383);
end
SumW=sum(W);
SumUs=sum(Us);
for i=1:36*4
   P(i)=W(i)/SumW;
   Qs(i)=Us(i)/SumUs;
end
TragetfuncitonValue=(FeatureVector-AMatrix*weight)'*S*(FeatureVector-AMatrix*weight)+lamda*(sum(P.*log(P))-sum(P.*log(Qs)));
Gradient=-2*AMatrix'*S*(FeatureVector-AMatrix*weight);
for i=1:36*4
    Gradient=Gradient+lamda/64723*P(i)*log(P(i)/Qs(i))*B'*TrainingPositionMatrix(:,i);
    for j=1:36*4
        Gradient=Gradient-lamda/64723*P(i)*log(P(i)/Qs(i))*P(j)*B'*TrainingPositionMatrix(:,j);
    end
end

end

