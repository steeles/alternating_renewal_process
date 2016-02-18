% combine data across trials, chopping off first duration

function [Durs d1 d2] = catDursStStTrials(DursCell,i,j)

[tDurs{1} tDurs{2} tDurs{3}] = DursCell{i,j,:};

Durs = []; d1 = []; d2 = [];

for ind = 1:length(tDurs)
    
   % chop off first duration if there's more than one, and add it to the
   % array
   try
       Durs = tDurs{ind}(2:end,:);
       
   % if there's just one dur, don't bother with it
   catch me
       continue
   end
end
d1 = Durs(Durs(:,2)==1,1);
d2 = Durs(Durs(:,2)==2,1);