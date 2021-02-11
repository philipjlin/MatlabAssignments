%HW 1 - HL7 Parser
% Given a folder with multiple .out files, import and parse the data
% Find the oldest patient and the total number of patients in the data


%Import files
files = dir('*.out');

numfids = length(files)