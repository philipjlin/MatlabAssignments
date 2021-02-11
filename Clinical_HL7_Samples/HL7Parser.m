% HW 1 - HL7 Parser
% Given a folder with multiple .out files, import and parse the data
% Find the oldest patient and the total number of patients in the data

clear
clc


%Import files
files = dir('*.out');
nfiles = length(files);


%Define variables
oldest_birthyear = 2016;
unique_patients = 0;
my_map = containers.Map();
files_parsed = 0;


%loop the number of files times
for f = 1:nfiles


    %Read contents of file into a string
    file_string = fileread(files(f).name);


    %Find the start and end indexes of the patient identification (PID) string
    pid_index = strfind(file_string, 'PID');
    pv1_index = strfind(file_string, 'PV1');

    
    
    %Check if PID string actually exists in the file
    if( pid_index ~= 0 & pv1_index ~= 0 )

        files_parsed = files_parsed + 1;
        
        %Extract the PID string from the rest of the file
        pid_string = file_string(pid_index:pv1_index-1);

        
        %Split the PID string into it's component parts
        split_pid_string = strsplit(pid_string, '|');


        %obtain the name from the PID string
        name = char(split_pid_string(4));


        %add name to the peoples cell
        my_map(name) = 0;
        
        
        %Use the map see how many unique names there are
        unique_patients = size(my_map, 1);

        %obtain the birthyear from the PID string
        birthdate = char(split_pid_string(5));
        birthyear = str2double(birthdate(1:4));


        %check if the birthyear is older than the current oldest birthyear
        if( birthyear < oldest_birthyear ) 
            oldest_birthyear = birthyear;
        end
        

    else
        display(files(f).name)
    end %end if check for presence of PID string


end %end outer for loop

display(files_parsed)
display(oldest_birthyear)
display(unique_patients)

    



