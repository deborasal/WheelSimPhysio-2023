function [IBI_Features,HR_Features] = extractingIBIFeatures(IBI_timetable)
%Extracting IBI features:
% 
IBI_table=(timetable2table(IBI_timetable(:,3)));
IBI=table2array(IBI_table(:,2));

HR_table=(timetable2table(IBI_timetable(:,4)));
HR=table2array(HR_table(:,2));

ID=timetable2table(IBI_timetable(1,1));

ID=table2array(ID(1,2));



% Time-Domain Analysis
meanIBI = mean(IBI);
sdnn = std(IBI);
differences = diff(IBI);
rmssd = sqrt(mean(differences.^2));
nn50 = sum(abs(differences) > milliseconds(50));
pnn50 = (nn50 / (length(IBI) - 1)) * 100;

% Calculate HR Metrics
meanHR = mean(HR);
maxHR = max(HR);
minHR = min(HR);
hrRange = maxHR - minHR;
sdHR = std(HR);

IBI_Features=[meanIBI,sdnn,rmssd,nn50,pnn50];
HR_Features=[meanHR, maxHR, minHR, hrRange,sdHR];

end