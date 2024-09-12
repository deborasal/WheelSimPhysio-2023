function [new_e4_timetable] = filteringTable(e4_timetable,tags_timetable)



[rows,cols]=size(e4_timetable);

counter=1;
e4_table=table2array(timetable2table(e4_timetable));

for i=1:rows

    if e4_table(i,1)< end_test && e4_table(i,1)> start_test

        new_e4_timetable(counter,:)=e4_table(i,:);
        counter=counter+1;

    end

end

new_e4_timetable = table(new_e4_timetable);


end