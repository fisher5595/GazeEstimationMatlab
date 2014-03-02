function ResultVector = HowManyFirstKofAAreInFirstKofB(A,B)
dimension=size(A,2);
ResultVector=zeros(1,dimension);
for i=1:dimension
    for j=1:i
        if size(find(B(1:i)==A(j)),2)~=0
            ResultVector(i)=ResultVector(i)+1;
        end
    end
end
end