function ImageGradient = GetNormalizedEdgeWithoutWeak (ImageName, ImageNumber, ImageExtension)
Image=imread([ImageName,int2str(ImageNumber),ImageExtension]);
[height,width]=size(Image);
ImageGradient=zeros(height,width,2);
% Get initial edge
Maskx=[-1 0 1; -2 0 2; -1 0 1];
Masky=[1 2 1; 0 0 0; -1 -2 -1];
Gx=conv2(double(Image), double(Maskx), 'same');
Gy=conv2(double(Image), double(Masky), 'same');
ImageGradient(:,:,1)=Gx;
ImageGradient(:,:,2)=Gy;
Mag=sqrt(Gy.^2+Gx.^2);
% Get rid of weak edge by comparing with average Magnitute.
avgMag=double(sum(sum(Mag)))/(height*width);
for i=1:height
    for j=1:width
        if Mag(i,j)<avgMag
            ImageGradient(i,j,:)=zeros(1,2);
            Mag(i,j)=0;
        else
            ImageGradient(i,j,:)=ImageGradient(i,j,:)./Mag(i,j);
        end
    end
end
end