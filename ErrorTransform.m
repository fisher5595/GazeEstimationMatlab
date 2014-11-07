clear;
SaveDir='./DataSet/';
%Distance=600;
StoppingCriterion=1e-10;
MonitorPositions=[509.13201593 -120.17664071  138.67884402;...
               511.16378242 -120.54972862  129.22216777;...
               507.41369389 -119.90263223  131.40218482;...
               511.16378242 -120.54972862  129.22216777;...
               511.16378242 -120.54972862  129.22216777;...
               503.26231078 -120.58026221  145.62949751;...
               500.74554146 -122.82959153  155.30911976;...
               512.77856422 -120.79484941  124.62116829;...
               507.41369389 -119.90263223  131.40218482;...
               509.13201593 -120.17664071  138.67884402];
HeadPosition=[0 0 600];
Distances=ones(10,1)*HeadPosition-MonitorPositions;
StepSize=0.01;
MeanAndStds=zeros(2,10);
for SubjectNumber=9:9
    Distance=norm(Distances(SubjectNumber+1,:));
    %Errors=load([SaveDir,num2str(SubjectNumber),'/','Errors-48_ALR', '.mat']);
    %Errors=load([SaveDir,num2str(SubjectNumber),'/','Errors_S-48-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize), '.mat']);
    %Errors=load([SaveDir,num2str(SubjectNumber),'/','Errors_Best_Sol3_',sprintf('S-%g',StoppingCriterion),'.mat']);
    Errors=load([SaveDir,num2str(SubjectNumber),'/','Errors-48_Best_Sol3_SumOne_',sprintf('S-%g',StoppingCriterion),'.mat']);
    Errors=Errors.x;
    DegreeErrors=atand(Errors./Distance);
    NumOfQuery=size(Errors,1);
    MeanAndStds(1,SubjectNumber+1)=sum(DegreeErrors)/NumOfQuery;
    MeanAndStds(2,SubjectNumber+1)=std(DegreeErrors);
end