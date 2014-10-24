clear;
set(0,'defaultTextFontSize', 15);
set(0,'defaultAxesFontSize', 15);
set(0,'defaultAxesFontName', 'Times');
set(0,'defaultTextFontName', 'Times');
SaveDir='./DataSet/';
Distance=600;
StoppingCriterion=1e-10;
StepSize=0.01;
MeanAndStds=zeros(2,10);
SubjectNumber=2;
ErrorsAndLambdas=load([SaveDir,num2str(SubjectNumber),'/','ErrorsAndLambdas_Sol3_',sprintf('S-%g',StoppingCriterion),'.mat']);
ErrorsAndLambdas=ErrorsAndLambdas.x;
NumberOfAllLambdas=size(ErrorsAndLambdas,2);
NonZeroLambdasAndAvgErrorsInDegreeAndStd=[];
for i=1:NumberOfAllLambdas
    Lambda=ErrorsAndLambdas(1,i);
    AvgErrorInMM=ErrorsAndLambdas(2,i);
    if (AvgErrorInMM~=0)%&&(Lambda<=2)
        %Calculate the avg error in degree of non zero Lambda
        Errors=load([SaveDir,num2str(SubjectNumber),'/','Errors_Sol3_',sprintf('Lambda-%g',Lambda),sprintf('_S-%g',StoppingCriterion),'.mat']);
        Errors=Errors.x;
        DegreeErrors=atand(Errors./Distance);
        NumOfQuery=size(Errors,1);
        Mean=sum(DegreeErrors)/NumOfQuery;
        Std=std(DegreeErrors);
        NonZeroLambdasAndAvgErrorsInDegreeAndStd=[NonZeroLambdasAndAvgErrorsInDegreeAndStd [Lambda;Mean;Std]];
    end
end
figure(1);
plot(NonZeroLambdasAndAvgErrorsInDegreeAndStd(1,:),NonZeroLambdasAndAvgErrorsInDegreeAndStd(2,:),'LineWidth',2);
ylabel('Average estimation error(degree)');
xlabel('$\lambda$','interpreter','latex');