function testTimecourse2durs

initTestSuite;

function testSinusoids

x = 0:.01:3.5; % i'm aiming to create 3 full cycles

cosx = cos(2*pi*x); sinx = sin(2*pi*x);

[T1 T2 durs] = timecourse2durs(cosx,sinx,x,1);

assertEqual(length(T1),4); assertElementsEqual(length(T2,3));