%% Initializing
warning('off','all');
clear all;
clc;
root_dir = 'F:\MITACS GRI 2022\STK\PGP\PGP.sc';
log_dir = 'F:/MITACS GRI 2022/MATLAB scripts/Reports/';
sim_name = 'PGP';
Mother = '3U';
Daughter = '1U';

%% STK Interface
app = actxserver('STK11.application');
root = app.Personality2;
root.LoadScenario(root_dir);
scenario = root.CurrentScenario;

scenario.SetTimePeriod('01 Jan 2019 00:00:00.000','31 Dec 2019 00:00:00.000');
scenario.StartTime = '01 Jan 2019 00:00:00.000';
scenario.StopTime = '01 Jan 2019 06:00:00.000';

%% Access Satellites
U1 = scenario.Children.Item(Mother);
U2 = scenario.Children.Item(Daughter);

basic1 = U1.Attitude.Basic;
basic1.SetProfileType('eProfileAlignedandConstrained');
basic2 = U2.Attitude.Basic;
basic2.SetProfileType('eProfileAlignedandConstrained');

%% Solar Panel Computations
dir = 'F:/MITACS GRI 2022/MATLAB scripts';
report_dir = strcat(dir,'/Reports');
delete(strcat(report_dir,'\*.csv'));

f = waitbar(0,'Initializing');
for i = 1:19
    
    angle = (i-1)*5;
    waitbar(i/19,f,strcat('Anti-Track angle of ',num2str(angle)));

    basic1.Profile.AlignedVector.Body.AssignXYZ(sind(angle),0,cosd(angle));
    basic2.Profile.AlignedVector.Body.AssignXYZ(sind(angle),0,-cosd(angle));

    reportString1 = strcat(log_dir,Mother,'_',num2str(angle),'.csv');
    commandString1 = strcat('VO Scenario/',sim_name,'/Satellite/',Mother,' SolarPanel Compute',...
        ' "',scenario.StartTime,'"',' "',scenario.StopTime,'"',' 60',' Power "',reportString1,'"');
    
    reportString2 = strcat(log_dir,Daughter,'_',num2str(angle),'.csv');
    commandString2 = strcat('VO Scenario/',sim_name,'/Satellite/',Daughter,' SolarPanel Compute',...
        ' "',scenario.StartTime,'"',' "',scenario.StopTime,'"',' 60',' Power "',reportString2,'"');
    
    res1 = root.ExecuteCommand(commandString1);
    pause(5);
    res2 = root.ExecuteCommand(commandString2);
end
close(f);
%% Data Parsing

for i = 1:19
    angle = (i-1)*5;
    reportString1 = strcat(log_dir,Mother,'_',num2str(angle),'.csv');
    reportString2 = strcat(log_dir,Daughter,'_',num2str(angle),'.csv');
    [PGP(i,:),PGP_1(i,:)] = PowerProfile(reportString1,reportString2);
    plot(PGP(i,1:200),'DisplayName',strcat(num2str(angle)," degrees anti-track"));
    hold on;
end
legend;
hold off;

function [PGP,PGP_1] = PowerProfile(file1, file2)
    data_1 = table2array(readtable(file1,'HeaderLines',10,'Delimiter','      ','Range','B:B'));
    data_2 = table2array(readtable(file2,'HeaderLines',10,'Delimiter','      ','Range','B:B'));

    PGP_1 = data_1(end-361:end);
    PGP_2 = data_2(end-361:end);
    
    PGP = PGP_1 + PGP_2;
end