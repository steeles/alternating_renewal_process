function KeyRecorder(object,evnt,Direction)
% records times of leftarrow, rightarrow, up/down times
key=evnt.Key; %key=28 leftarrow; key=29 rightarrow
%k=getkey;
%kk=str2num('evnt.Key')
global prevleft; global prevright;
%prevleft =1 or 0 if prev leftarrow key (#28) was down or up
%prevleft
global KeyPresses;

if isempty(KeyPresses)
    KeyPresses = cell(2,1); 
    KeyPresses{1} = struct('Down',[],'Up',[]);
    KeyPresses{2} = struct('Down',[],'Up',[]);
end
Time = clock;
switch key
    case 'leftarrow'
    switch Direction
        case 'Down'
        if prevleft==0
        disp([evnt.Key, '  Down',datestr(Time,' HH:MM:SS.FFF')]) 
        KeyPresses{1}.(Direction)(end+1,:) = Time;
        prevleft=1;
        else
        end    
        case 'Up'
        if prevleft==1
        disp([evnt.Key, '  Up',datestr(Time,' HH:MM:SS.FFF')]) 
        KeyPresses{1}.(Direction)(end+1,:) = Time;
        prevleft=0;
        else
        end  
    end
    case 'rightarrow'
    switch Direction
        case 'Down'
        if prevright==0
        disp([evnt.Key, '  Down',datestr(Time,' HH:MM:SS.FFF')]) 
        KeyPresses{2}.(Direction)(end+1,:) = Time;
        prevright=1;
        else
        end    
        case 'Up'
        if prevright==1
        disp([evnt.Key, '  Up',datestr(Time,' HH:MM:SS.FFF')]) 
        KeyPresses{2}.(Direction)(end+1,:) = Time;
        prevright=0;
        else
        end    
      end
end

       
