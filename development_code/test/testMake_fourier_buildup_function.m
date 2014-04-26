% all subfunctions must begin with "test"

function test_suite = testMake_fourier_buildup_function
initTestSuite;
%findSubfunctionTests;

function testCorrectSteadyState
bufpars = [2,.5,5,.5];
mn0 = 2*.5; mn1=5*.5; SS = mn1/(mn0+mn1);

BUF=make_fourier_buildup_function(bufpars);
assertElementsAlmostEqual(BUF(end),SS,'absolute',.001)

function testIsAbove0

bufpars = [2,.5,5,.5];
BUF=make_fourier_buildup_function(bufpars);

assertElementsAlmostEqual(min(BUF),0,'absolute',.001)
