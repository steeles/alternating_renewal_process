


%clf;

%data=load(datafile);

clear;

timeTrial = 60;
dur_min = 0.300; %minimal duration allowed



data1 = load('times-JeG-3oct06.m'); 
[a,b] = size(data1);
data1bis = [data1, 1.*ones(a,1)];
data=[data1bis]; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determination of the lum_inter, alpha and directions used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x1 = find( diff(sort( data(:,4) )) ~= 0 );
x1 = [1;x1+1];
y = sort( data(:,4) );
vec_lum_inter = y(x1);

x2 = find( diff(sort( data(:,12) )) ~= 0 );
x2 = [1;x2+1];
y = sort( data(:,12) );
vec_duty_1 = y(x2);

x3 = find( diff(sort( data(:,13) )) ~= 0 );
x3 = [1;x3+1];
y = sort( data(:,13) );
vec_duty_2 = y(x3);

x4 = find( diff(sort( data(:,6) )) ~= 0 );
x4 = [1;x4+1];
y = sort( data(:,6) );
vec_velGrating_1 = y(x4);

x5 = find( diff(sort( data(:,7) )) ~= 0 );
x5 = [1;x5+1];
y = sort( data(:,7) );
vec_velGrating_2 = y(x5);

x6 = find( diff(sort( data(:,15) )) ~= 0 );
x6 = [1;x6+1];
y = sort( data(:,15) );
vec_lambda_1 = y(x6);

x7 = find( diff(sort( data(:,16) )) ~= 0 );
x7 = [1;x7+1];
y = sort( data(:,16) );
vec_lambda_2 = y(x7);

x8 = find( diff(sort( data(:,21) )) ~= 0 );
x8 = [1;x8+1];
y = sort( data(:,21) );
vec_subject = y(x8);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% *Calculation of durations R and L* %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[trials,aux]=size( find( data(:,1)==1 ) );
%This calcultates the number of "1" in the file, that is, the number of
%trials
[dim_data,aux]=size(data);
initial=find( data(:,1)==1 );
initial=[initial ; dim_data+1]; %to generalize the vector
%This gives the positions of initiation of the trials


durationsR=[];
durationsL=[];
countTotalR = 1;
countTotalL = 1;

for i=1:trials
    times = data( initial(i):(initial(i+1)-1), 2 );
    keys =  data( initial(i):(initial(i+1)-1), 3 );
    lum_inter = data( initial(i) , 4 );
    velGrating_1 = data( initial(i) , 6 );
    velGrating_2 = data( initial(i) , 7 );
    duty_cycle_1 = data( initial(i) , 12 );
    duty_cycle_2 = data( initial(i) , 13 );
    back = data( initial(i) , 14 );
    lambda_1 = data( initial(i) , 15 );
    lambda_2 = data( initial(i) , 16 );
    subject = data( initial(i) , 21 );
    
    count = 1;
    countR = 1;
    countL = 1;
    
    sumdurR = 0;
    sumdurL = 0;
    
    %who was the first percept?
    first(i) = keys(1);
    
    keyR1 = find( keys(:)==1 );
    keyR2 = find( keys(:)==2 );
    keyL1 = find( keys(:)==-1 );
    keyL2 = find( keys(:)==-2 );
    [size_keyR1,b] = size(keyR1);
    [size_keyR2,b] = size(keyR2);
    [size_keyL1,b] = size(keyL1);
    [size_keyL2,b] = size(keyL2);

    %I am only going to look complete durations (last cut duration not)
    for j=1:min(size_keyR1,size_keyR2)
        durR = times(keyR2(j))-times(keyR1(j));
        if (durR > dur_min )
            durationsR(countTotalR,:) = [i, durR,...
                    times(keyR1(j)), 1, first(i), countR, lum_inter, ...
                    velGrating_1, velGrating_2,...
                    duty_cycle_1, duty_cycle_2, back, lambda_1, lambda_2,...
                    subject];      
            countR = countR + 1;
            countTotalR = countTotalR + 1;  

            sumdurR = sumdurR + durR; 
        end       
    end
    %last R duration
    if (size_keyR1 > size_keyR2)
        durR = timeTrial-times(keyR1(size_keyR1));
        if (durR > dur_min )
            durationsR(countTotalR,:) = [i, durR,...
                    times(keyR1(size_keyR1)), 1, first(i), countR, lum_inter, ...
                    velGrating_1, velGrating_2,...
                    duty_cycle_1, duty_cycle_2, back, lambda_1, lambda_2,...
                    subject];      
            countR = countR + 1;
            countTotalR = countTotalR + 1; 

            sumdurR = sumdurR + durR; 
        end       
    end
    %Left durations
    for j=1:min(size_keyL1,size_keyL2)
        durL = times(keyL2(j))-times(keyL1(j));
        if (durL > dur_min )
            durationsL(countTotalL,:) = [i, durL,...
                    times(keyL1(j)), -1, first(i), countL, lum_inter, ...
                    velGrating_1, velGrating_2,...
                    duty_cycle_1, duty_cycle_2, back, lambda_1, lambda_2,...
                    subject];      
            countL = countL + 1;
            countTotalL = countTotalL + 1;  

            sumdurL = sumdurL + durL;
        end
    end
    %last L duration
    if (size_keyL1 > size_keyL2)
        durL = timeTrial-times(keyL1(size_keyL1));
        if (durL > dur_min )
            durationsL(countTotalL,:) = [i, durL,...
                    times(keyL1(size_keyL1)), -1, first(i), countL, lum_inter, ...
                    velGrating_1, velGrating_2,...
                    duty_cycle_1, duty_cycle_2, back, lambda_1, lambda_2,...
                    subject];      
            countL = countL + 1;
            countTotalL = countTotalL + 1;  

            sumdurL = sumdurL + durL;
        end
    end
    
    if ( abs(countR-countL)>3 )
       'Large difference in number of R and L durations'
       countR-countL
    end
    
    %WARNINGS
    if ( sumdurR + sumdurL > timeTrial )
        'Warning: summed durations more than expected'
        sumdurR + sumdurL - timeTrial
        lambda_1
        lambda_2
        back
    end    
end
        
      


