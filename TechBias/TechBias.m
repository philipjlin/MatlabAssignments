% HW 2 - Tech Bias Calculator
% Given a data file with 5 columns representing:
% PatientID | Arrival Time | Begin Time | Complete Time | TechID
% Find the TechID with the highest bias
% Bias is defined as percentage of exams with Begin Time last digit = 0

clear
clc

%Import file whos -file Data.mat
data_struct = load('Data.mat');


format long g


%Define columns
patient_id = data_struct.Data(:,1);
arrival_time = data_struct.Data(:,2);
begin_time = data_struct.Data(:,3);
complete_time = data_struct.Data(:,4);
tech_id = data_struct.Data(:,5);

%Split up big matrix into smaller matricies based on tech id
highest_biased_percentage = 0;
most_biased_tech = -1;

for current_tech = 1:max(tech_id)
    
    %extract techs with id = current_tech and put them in a matrix
    tech_index = data_struct.Data(:,5) == current_tech;
    T = data_struct.Data(tech_index,:);
    
    %skip over techs with less than 10 entries
    if( size(T,1) < 10 )
        continue
    else
        %calculate bias value for this tech by checking each begin time
        %to see if it ends in 0, incrementing a counter if so
        begin_times = T(:,3);
        biased_count = 0;
        
        for time = 1:max(begin_times)
            
            %timeinmins = minute(datetime(time,'ConvertFrom','datenum'));
            
            if mod(time, 10) == 0
                biased_count = biased_count + 1;
            end
        end
        
        %calculate percentage biased observations for current tech
        biased_percentage = biased_count/max(begin_times);
        
        %if the percentage is higher than any previous tech, this tech
        %becomes the most biased
        if biased_percentage > highest_biased_percentage
            
            most_biased_tech = current_tech;
            highest_biased_percentage = biased_percentage;
        end
        
    end %end if else
    
end %end loop through all 

display(most_biased_tech)


%calculate all wait times, put into a vector
X = zeros(max(patient_id));

for n = 1:max(patient_id)
    
    %get all the arrival times
    at = arrival_time(n);
    
    %get all the exam start times
    bt = begin_time(n);
    
    %calculate the wait times, add to column of wait times
    wt = bt-at;
    X(n) = wt;    
end

%sort vector of wait times, calculate 90th percentile
percentile = prctile( sort(X(:,1)), 90);

display(minute(datetime(percentile,'ConvertFrom','datenum')))


