function Energy = ComputeEnergy(Img,center,radius)
[ImgHeight,ImgWidth]=size(Img);
IntegralInCircle=0;
ValleyField=-double(Img);
for y=1:ImgHeight
    for x=1:ImgWidth
        if (double(center)-double([y;x]))'*(double(center)-double([y;x]))<=radius^2
            IntegralInCircle=IntegralInCircle+ValleyField(y,x);
        end
    end
end
Energy=double(IntegralInCircle)/(2*pi*radius^2);
end