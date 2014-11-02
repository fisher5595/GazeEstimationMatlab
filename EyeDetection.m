clear;
Img=imread('VideoFrames/TrainingFrames/1__1.jpg');
GreyImg=rgb2gray(Img);
LeftEyeDetect=vision.CascadeObjectDetector('EyePairBig');
BB=step(LeftEyeDetect,Img);
figure(1);
imshow(Img);
hold on;
for i=1:size(BB,1)
    rectangle('Position',BB(i,:),'LineWidth',4,'LineStyle','-','EdgeColor','r');
end
hold off;
figure(2)
Img=imread('VideoFrames/TrainingFrames/36__1.jpg');
GreyImg=rgb2gray(Img);
LeftEyeDetect=vision.CascadeObjectDetector('EyePairBig');
BB=step(LeftEyeDetect,Img);
imshow(Img);
hold on;
for i=1:size(BB,1)
    rectangle('Position',BB(i,:),'LineWidth',4,'LineStyle','-','EdgeColor','r');
end
hold off;