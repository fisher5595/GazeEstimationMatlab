%SSD template matching. Input template image, matching image, output is matching position. [y,x] 
function [MatchingPosition] = SSDTemplateMaching(TemplateImage,QueryImage)
[TemplateHeight,TemplateWidth]=size(TemplateImage);
[QueryImageHeight,QueryImageWidth]=size(QueryImage);
for i=1:QueryImageHeight-TemplateHeight+1
    for j=1:QueryImageWidth-TemplateWidth+1
        SSDMatrix(i,j)=sum(sum((double(QueryImage(i:i+TemplateHeight-1,j:j+TemplateWidth-1))-double(TemplateImage)).^2));
    end
end
MinSSD=0;
for i=1:QueryImageHeight-TemplateHeight+1
    for j=1:QueryImageWidth-TemplateWidth+1
        if (i == 1) && (j==1)
            MinSSD=SSDMatrix(i,j);
        else
            if SSDMatrix(i,j)<MinSSD
                MatchingPosition=[i;j];
                MinSSD=SSDMatrix(i,j);
            elseif (SSDMatrix(i,j) == MinSSD) && (j<MatchingPosition(2))
                MatchingPosition=[i;j];
                MinSSD=SSDMatrix(i,j);
            end
        end
        
    end
end
end