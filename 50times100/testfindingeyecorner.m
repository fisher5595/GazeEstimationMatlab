%
% Test finding eye corner
%
img=imread('enlarged_ResizedEyes_right_1.jpg');
corners=corner(img,'QualityLevel',0.4,'SensitivityFactor',0.23);
imshow(img);
hold on
plot(corners(:,1),corners(:,2),'r*');
hold off