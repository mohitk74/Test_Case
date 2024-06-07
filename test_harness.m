clc;clear;close all;

% reading excel file
data = readtable("Inputs.xlsx");
%--------------------------------------------------------------------------
% reading time data 
t=0:height(data)-1;
% height returns the number of rows in the data 
time = t'; % Transpose of the array gives the table
% -------------------------------------------------------------------------
% valA and valB are two variables that contains the data extracted from
% excel file's column 2 and 3 respectively

% Input for First Variable
valA = data(:,2);
% 2 represents column two

% Input for Second Variable
valB = data(:,3);
% 3 represents column three
% -------------------------------------------------------------------------
% Converting time data in Seconds
time = seconds(time);

% Creating Timetable for the both variables & loading them to the workspace
% Note : Use the same Input variable name as given in the model
A = timetable(time,valA);
B = timetable(time,valB);
%--------------------------------------------------------------------------
% Loading the simulink Model
load_system('and_gate_model');

% Creating the test harness having source as 'From Workspace' and Sink 'Outport'
% sltest.harness.delete('and_gate_model', 'and_gate_model_Harness1');
sltest.harness.create('and_gate_model', 'Name', 'and_gate_model_Harness1', 'Source', 'From Workspace', 'Sink', 'Outport');

% Opening the test Harness model
sltest.harness.open('and_gate_model','and_gate_model_Harness1');
%--------------------------------------------------------------------------
% test Manager
tf = sltest.testmanager.TestFile('and_gate_model_Results.mldatx');
ts = getTestSuites(tf);
tc = getTestCases(ts);

% To provide the Sample Model & Test Harness Model to the Test Manager
setProperty(tc,'Model','and_gate_model')
setProperty(tc, 'HarnessName', 'and_gate_model_Harness1', 'HarnessOwner', 'and_gate_model');

% Capturing the Baseline
baseline = captureBaselineCriteria(tc,'and_gate_model_Baseline.xlsx',true);
sc = getSignalCriteria(baseline);
sc(1).AbsTol = 9;

% Opening the test Manager & Running the test cases
sltest.testmanager.view;
result = sltest.testmanager.run(); % Executing the test manager

% Provide the same filename created to store the test results
exampleFile = 'and_gate_model_Results.mldatx';
sltest.testmanager.load(exampleFile);
%-------------------------------------------------------------------------
% Report Generation
sltest.testmanager.report(result,'C:\Users\40674\Downloads\SF_TESTHARNESS\test_repot.pdf',...
    'IncludeTestResults',0,'IncludeComparisonSignalPlots',true,...
    'IncludeSimulationSignalPlots',true,'NumPlotRowsPerPage',3);
%-------------------------------------------------------------------------
%----------------------END OF THE SCRIPT----------------------------------
