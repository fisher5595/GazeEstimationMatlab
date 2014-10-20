% Plot the bar graph for both gaze positon are the same and the testing are different from the training
clear;
set(0,'defaultTextFontSize', 15);
set(0,'defaultAxesFontSize', 15);
set(0,'defaultAxesFontName', 'Times');
set(0,'defaultTextFontName', 'Times');
% X=1:2;
Mean=[0.28 0.23 0.26 0.26 0.22;0.34 0.32 0.31 0.29 0.27];
Std=[0.17 0.13 0.14 0.14 0.13;0.19 0.20 0.19 0.21 0.18];
% barfigure=bar(X,Mean);
% hold on;
% errorbar(Mean,Std,'dk');
% hold off;
% ch=get(barfigure,'children');
% set(gca,'XTickLabel',{'Test train same gaze','Test train different gaze'});
% legend('SVR','LLR','ALR','Ours','Ours-R');
% ylabel('Estimation error, mean and std(degree)');
% grid on;
h = bar(Mean,'LineWidth',1.5);

% set(h,'BarWidth',1);    % The bars will now touch each other

grid on;

set(gca,'XTicklabel','Test train same gaze|Test train different gaze');

set(get(gca,'YLabel'),'String','Estimation error, mean and std(degree)');

lh = legend('SVR','LLR','ALR','Ours','Ours-R');

hold on;

numgroups = size(Mean, 1); 

numbars = size(Mean, 2); 

groupwidth = min(0.8, numbars/(numbars+1.5));

for i = 1:numbars

      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange

      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar

      errorbar(x, Mean(:,i), Std(:,i), 'ok', 'linestyle', 'none','LineWidth',1.5);

end
set(h(5),'LineWidth',2.5,'EdgeColor','red');
errorbar_tick(h, 50);
hold off;
