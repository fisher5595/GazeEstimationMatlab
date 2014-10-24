clear;
SaveDir='./DataSet/';
Distance=600;
StoppingCriterion=1e-9;
StepSize=0.01;
MeanAndStds=zeros(2,10);
for SubjectNumber=5:5
    Errors=load([SaveDir,num2str(SubjectNumber),'/','Errors_S-',sprintf('%g',StoppingCriterion),'_Epsilon-',sprintf('%g',StepSize), '.mat']);
    %Errors=load([SaveDir,num2str(SubjectNumber),'/','Errors_Best_Sol3_',sprintf('S-%g',StoppingCriterion),'.mat']);
    Errors=Errors.x;
    DegreeErrors=atand(Errors./Distance);
    NumOfQuery=size(Errors,1);
    MeanAndStds(1,SubjectNumber+1)=sum(DegreeErrors)/NumOfQuery;
    MeanAndStds(2,SubjectNumber+1)=std(DegreeErrors);
end