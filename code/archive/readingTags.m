function [tags_timetable] = readingTags(tags_filename,user_ID)

tags_raw_file=csvread(tags_filename);
tags_datetime=datetime(tags_raw_file(:,1),'ConvertFrom', 'posixtime', 'Format', 'yyyy-MM-dd H:mm:ss.SSS'); % Converting the start time in Unix epoch to datetime
tags_code=tags_raw_file(:,2);

test_start_time=0;
test_end_time=0;

baseline_start_time=0;
baseline_end_time=0;

for i=1:length(tags_code)
    if tags_code(i,1)==3
        test_start_time=tags_datetime(i,1);
    end
     if tags_code(i,1)==4
        test_end_time=tags_datetime(i,1);
     end
        if tags_code(i,1)==1
        baseline_start_time=tags_datetime(i,1);
    end
     if tags_code(i,1)==2
        baseline_end_time=tags_datetime(i,1);
     end
     

end

tags_variables={'Sampe_ID','start_test','end_test','start_baseline','end_baseline',};

tags_timetable=table(user_ID,test_start_time,test_end_time,baseline_start_time, baseline_end_time,'VariableNames',tags_variables);
end