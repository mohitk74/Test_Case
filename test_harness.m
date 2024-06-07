clc;clear;close all;
% reading excel file
data=readtable("DEF_TestSheet.xlsx");
%--------------------------------------------------------------------------
% reading time data
% t=0:height(data)-1;
% height returns the number of rows in the data
% time = t'; % Transpose of the array gives the table
% -------------------------------------------------------------------------
time=data.Time;
% -------------------------------------------------------------------------
% valA and valB are two variables that contains the data extracted from
% excel file's column 2 and 3 respectively
% Input for First Variable
valA = data.IH_ClimLinkDefrostAndClearnesPush;
% 2 represents column two
% Input for Second Variable
valB = data.ac_canIgnON_OFF;
% 3 represents column three
% -------------------------------------------------------------------------
% Converting time data in Seconds
time = seconds(time);
% Creating Timetable for the both variables & loading them to the workspace
% Note : Use the same Input variable name as given in the model
IH_ClimLinkDefrostAndClearnesPush = timetable(time,valA);
ac_canIgnON_OFF = timetable(time,valB);
%--------------------------------------------------------------------------
% Loading the simulink Model
run('DEF_RAM');
run('DEF_ROM');
load_system('DEF_Link');
% Creating the test harness having source as 'From Workspace' and Sink 'Outport'
sltest.harness.create('DEF_Link', 'Name', 'DEF_Link_Harness', 'Source', 'From Workspace', 'Sink', 'Outport');
% Opening the test Harness model
sltest.harness.open('DEF_Link','DEF_Link_Harness');
%--------------------------------------------------------------------------
% test Manager
test_suitename='DEF_Link_Results.mldatx';
tf = sltest.testmanager.TestFile(test_suitename);
ts = getTestSuites(tf);
tc = getTestCases(ts);
% To provide the Sample Model & Test Harness Model to the Test Manager
setProperty(tc,'Model','DEF_Link')
setProperty(tc, 'HarnessName', 'DEF_Link_Harness', 'HarnessOwner', 'DEF_Link');
% Capturing the Baseline
baseline = captureBaselineCriteria(tc,'DEF_Link_Baseline.xlsx',true);
sc = getSignalCriteria(baseline);
sc(1).AbsTol = 9;
% Opening the test Manager & Running the test cases
% sltest.testmanager.view;
sltest.testmanager.load(test_suitename);
result=sltest.testmanager.run();
sltest.testmanager.report(result,'C:\Users\39216\Desktop\SF_TESTHARNESS\test_report.pdf',...
    'IncludeTestResults',0,'IncludeComparisonSignalPlots',true,...
    'IncludeSimulationSignalPlots',true,'NumPlotRowsPerPage',3);
