function [ FeatureMatrix, GazePositionMatrix] = ExtractMatricesFromSatoDataset( InputFilePath, OutputFilePath, SubjectNumber)
%Extract test eye image from zip file to output path, and generate
%corresponding feature matrix and gaze position matrix
%   Detailed explanation goes here
SubjectStr=['s' sprintf('%02d',SubjectNumber)];
% [number, gx, gy] 
GazePositionMatrix=csvread([OutputFilePath,'/','gazedata.csv']);
GazePositionMatrix(:,1)=[];
CamraNumber=5;
Resize=[5,10];
FeatureMatrix=[];

for GazeNumber=0:159
    unzip([InputFilePath,'/',SubjectStr,'/','test/', sprintf('%03d',GazeNumber),'_left.zip'],[OutputFilePath,'/',sprintf('%03d',GazeNumber),'_left/']);
    unzip([InputFilePath,'/',SubjectStr,'/','test/', sprintf('%03d',GazeNumber),'_right.zip'],[OutputFilePath,'/',sprintf('%03d',GazeNumber),'_right/']);
    LeftEyeImg=imread([OutputFilePath,'/',sprintf('%03d',GazeNumber),'_left/',sprintf('%08d',CamraNumber),'.bmp']);
    RightEyeImg=imread([OutputFilePath,'/',sprintf('%03d',GazeNumber),'_right/',sprintf('%08d',CamraNumber),'.bmp']);
    ImHeight=size(LeftEyeImg,1);
    TrunckedHeight=round(double(ImHeight)/5*4);
    LeftEyeImg=LeftEyeImg(1:TrunckedHeight,:);
    RightEyeImg=RightEyeImg(1:TrunckedHeight,:);
    ResizedLeftEyeImg=imresize(LeftEyeImg, Resize);
    ResizedLeftEyeImg=im2double(ResizedLeftEyeImg);
    ResizedLeftEyeImg=ResizedLeftEyeImg./norm(ResizedLeftEyeImg);
    ResizedRightEyeImg=imresize(RightEyeImg, Resize);
    ResizedRightEyeImg=im2double(ResizedRightEyeImg);
    ResizedRightEyeImg=ResizedRightEyeImg./norm(ResizedRightEyeImg);
    ResizedLeftEyeImg=ResizedLeftEyeImg';
    ResizedRightEyeImg=ResizedRightEyeImg';
    FeatureVector=[ResizedLeftEyeImg(:);ResizedRightEyeImg(:)];
    %[a1, a2, ...]
    FeatureMatrix=[FeatureMatrix, FeatureVector];
end

%Combine gaze position matrix and appearance matrix, sort y first and then
%sort x
CombinationMatrix=[GazePositionMatrix, FeatureMatrix'];
CombinationMatrix=sortrows(CombinationMatrix,1);
CombinationMatrix=sortrows(CombinationMatrix,2);
GazePositionMatrix=CombinationMatrix(:,1:2);
FeatureMatrix=CombinationMatrix(:,2+1:2+Resize(1)*Resize(2)*2);
GazePositionMatrix=GazePositionMatrix';
FeatureMatrix=FeatureMatrix';
TmpVector=GazePositionMatrix(1,:);
GazePositionMatrix(1,:)=GazePositionMatrix(2,:);
GazePositionMatrix(2,:)=TmpVector;

end

