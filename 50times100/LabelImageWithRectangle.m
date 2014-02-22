function [ImageWithLabel]=LabelImageWithRectangle(InputImage,Position,Size)
for i =1:3
    ImageWithLabel(:,:,i)=InputImage;
end
for i=Position(1):Position(1)+Size(1)-1
    for j=Position(2):Position(2)+Size(2)-1
        if (i == Position(1)) || (i == Position(1)+Size(1)-1)
            ImageWithLabel(i,j,1)=255;
            ImageWithLabel(i,j,2)=0;
            ImageWithLabel(i,j,3)=0;
        elseif (j==Position(2))||(j==Position(2)+Size(2)-1)
            ImageWithLabel(i,j,1)=255;
            ImageWithLabel(i,j,2)=0;
            ImageWithLabel(i,j,3)=0;
        end
    end
end
end