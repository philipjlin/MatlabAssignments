% HW 3 - Regression Model for Patient Examinations
% Given an excel file with 6 columns of numeric data representing:
% stMRN | Accession | dtArrive | dtBegin | dtCompleted | dtScheduled | stModality |

clear
clc

%Import file 
data_matrix = xlsread('DataforHW4.xlsx');

%Define relevant columns
dtArrive = data_matrix(:,3);
dtBegin = data_matrix(:,4);

wait_times = minute(dtBegin - dtArrive);
n_patients = size(data_matrix, 1);


%*****
%*****
%Use a regression model to predict wait time using only the intercept
%*****
%*****
%Construct predictive matrix, run regression
X = ones(n_patients, 1);
[b,bint,r,rint,stats] = regress(wait_times, X);


%Find count of patients with wait times within 5 minutes of predicted
count = 0;
for n = 1:size(r)
    
    if r(n) < 5 && r(n) > -5
        count = count + 1;
    end
end
display(count/n_patients)
display(b)



%*****
%*****
%Use a regression model to predict wait time using intercept
%and line size (# of patients) at time of arrival
%*****
%*****
%Calculate line sizes at the time each patient arrives, put into vector
line_sizes = zeros(n_patients, 1);


%Loop through all patient's arrive times
for i = 1:size(dtArrive, 1)
        
    line_size = 0;
    
    %Loop to check if each patient is in line at current arrive time
    for p = 1:n_patients
        
        if dtArrive(p) < dtArrive(i) && dtBegin(p) > dtArrive(i)
            line_size = line_size + 1;
        end
    end
    
    line_sizes(i) = line_size;
end


%Construct predictive matrix, run regression
X = [X line_sizes];
[b,bint,r,rint,stats] = regress(wait_times, X);


%Find count of patients with wait times within 5 minutes of predicted
count = 0;
for n = 1:size(r)
    if r(n) < 5 && r(n) > -5
        count = count + 1;
    end
end
display(count/n_patients)
display(b)



%*****
%*****
%Use a regression model to predict wait time using intercept, 
%line size (# of patients) at time of arrival, and line size 5 minutes before
%time of arrival
%*****
%*****
%Calculate line sizes at 5 minutes before each patient arrives, put into vector
prev_line_sizes = zeros(n_patients, 1);

%Loop through all patient's arrive times
for i = 1:size(dtArrive, 1)
        
    line_size = 0;
    
    %Calculate time 5 mins previous to arrival time
    x = dtArrive(i);
    %datetime(x,'ConvertFrom','datenum');
    y = addtodate(x, -5, 'minute');
    
    %Loop to check if each patient is in line at previous arrive time
    for p = 1:n_patients
        
        if dtArrive(p) < y && dtBegin(p) > y
            line_size = line_size + 1;
        end
    end
    
    prev_line_sizes(i) = line_size;
end


%Construct predictive matrix, run regression
X = [X prev_line_sizes];
[b,bint,r,rint,stats] = regress(wait_times, X);

%Find count of patients with wait times within 5 minutes of predicted
count = 0;
for n = 1:size(r)
    if r(n) < 5 && r(n) > -5
        count = count + 1;
    end
end
display(count/n_patients)
display(b)

