% HW 6 - Patient Tracking
% Given an excel file with 4 columns of numeric data representing:
% Beacon/Patient Number | DateTime | X Position | Y Position

clear
clc

%Import file 
data_matrix = xlsread('TrackingData.xlsx');

%Define relevant columns
beacons = data_matrix(:,1);
dates = data_matrix(:,2);
xPos = data_matrix(:,3);
yPos = data_matrix(:,4);

%Find indexes of beacons
beacon16 = find(beacons==16);
beacon17 = find(beacons==17);
beacon18 = find(beacons==18);
beacon19 = find(beacons==19);



%
%Find start time of patient 18 procedure
%
%Find indexes of beacon 18 in procedure area
beacon17_start_procedure = find(beacons==18 & (400<=xPos&xPos<=600), 1, 'first');





%
%Find workup time of patient 17
%
%Find indexes of beacon 17 in workup area
beacon17_workups = find(beacons==17 & (150<=xPos&xPos<=300) & (0<=yPos&yPos<=800));


%Find index of time beacon 17 enters workup area (1st instance in workup)
start_workup = min(beacon17_workups);


%Find index of time beacon 17 leaves workup area (1st instance after workup)
last_workup = max(beacon17_workups);

beacon_after_workup = beacon17(beacon17>last_workup);

end_workup = beacon_after_workup(1);

%Find workup time of beacon 17
workup_time = dates(end_workup) - dates(start_workup);

datetime(workup_time, 'ConvertFrom', 'datenum');





%
%Find location of patient 19 after procedure
%
%
%Find indexes of all times where beacon 19 is in procedure area
beacon19_procedures = find(beacons==19 & (400<=xPos&xPos<=600) & (0<=yPos&yPos<=1000));

%Find index of time beacon 19 leaves procedure area (1st instance after procedure)
last_procedure = max(beacon19_procedures);

beacon_after_procedure = beacon19(beacon19>last_procedure);

end_procedure = beacon_after_procedure(1);
xPos(end_procedure);
yPos(end_procedure);





%
%Compute length of average workup
%
%
totalWorkupTime = 0;

%Loop through all beacon numbers
for n = 1:max(beacons)
           
        beacons_n = find(beacons==n);
        
        %Find workup time
        %Find indexes of beacon n in workup area
        beacon_workups = find(beacons==n & (150<=xPos&xPos<=300) & (0<=yPos&yPos<=800));

        %Find index of time beacon n enters workup area (1st instance in workup)
        start_workup = min(beacon_workups);
        
        %Find index of time beacon n leaves workup area (1st instance after workup)
        last_workup = max(beacon_workups);
        beacon_after_workup = beacons_n(beacons_n>last_workup);
        end_workup = beacon_after_workup(1);

        %Find workup time of beacon n
        workup_time = dates(end_workup) - dates(start_workup);        
        
        totalWorkupTime = totalWorkupTime + workup_time;
end

datetime(totalWorkupTime/max(beacons), 'ConvertFrom', 'datenum');




%
%Find percentage of patients who go to ICA after procedure
%
%
count = 0;

%Loop through all beacon numbers
for n = 1:max(beacons)
    
    beacon_n = find(beacons==n);
    
    %Find indexes of all times where beacon n is in procedure area
    beacon_procedures = find(beacons==n & (400<=xPos&xPos<=600) & (0<=yPos&yPos<=1000));

    %Find index of time beacon n leaves procedure area (1st instance after procedure)
    last_procedure = max(beacon_procedures);

    beacon_after_procedure = beacon_n(beacon_n>last_procedure);

    end_procedure = beacon_after_procedure(1);
    x = xPos(end_procedure);
    y = yPos(end_procedure);
    
    if( x>=0 & x<=300 & y>=0 & y<=800 )
        count = count+1;
    end
    
end

count/max(beacons);





%
%Find the maximum number of patients in recovery area
%
%
recovery_enter_times = zeros(1, max(beacons));
recovery_leave_times = zeros(1, max(beacons));


%Find times that each patient enters and leaves recovery area, put into 2 lists
for n = 1:max(beacons)
    
    
    %Get matrix of indexes that match the current beacon number n
    beacon_indexes = find(beacons==n);
    
        
    %Find indexes of beacon n in recovery area
    beacon_recoveries = find(beacons==n & (0<=xPos&xPos<=150) & (0<=yPos&yPos<=800))
    
    
    %Skip to else if beacon n did not enter recovery area
    if length(beacon_recoveries) ~= 0
        
        %Find index of time beacon n enters recovery area (1st instance in recovery)
        enter_recovery = min(beacon_recoveries);

        %Find index of time beacon n leaves recovery area (1st instance after recovery)
        last_recovery = max(beacon_recoveries);
        beacon_after_recovery = beacon_indexes(beacon_indexes>last_recovery);
        leave_recovery = beacon_after_recovery(1);

        %Add workup times to lists
        recovery_enter_times(n) = dates(enter_recovery);     
        recovery_leave_times(n) = dates(leave_recovery);    
    else
        recovery_enter_times(n) = -1;
        recovery_leave_times(n) = -1;
    end
end


%Go through all minutes of the work day, check each patient to see if in area
max_inarea = 0;


for t=1:length(dates)
         
    inarea=0;
    
    %Check each patient to see if they are in recovery area at this time
    for n=1:max(beacons)         
        
        if recovery_enter_times(n)<=dates(t) & recovery_leave_times(n)>=dates(t)
            inarea = inarea + 1;
        end
        
        if inarea > max_inarea 
            max_inarea = inarea;
        end
    end
    
end

max_inarea