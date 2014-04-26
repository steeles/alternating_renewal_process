function [d c] = quickDprime(answer,response)

% i'm treating 2's like yesses and 1's like nos

posfilter = (response == 2);

HR = sum(answer(posfilter)==2)/(sum(answer == 2)+.01);

FAR = sum(answer(posfilter)==1)/(sum(answer == 1)+.01);

if HR == 0 
    HR = .01;
end
if HR == 1
    HR = .99;
end
if FAR == 0
   FAR = .01; 
end
if FAR == 1
    FAR = .99;
end

zHR = norminv(HR, 0.5);
zFAR = norminv(FAR, 0.5);


d = zHR - zFAR;
c = -0.5 * (zHR + zFAR);