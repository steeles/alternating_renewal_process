function test_suite = testFind_gamma_pars

initTestSuite


function testBySimulation

pars = rand(2,1)*3;
distr = gamrnd(pars(1),pars(2),1000,1);

recoveredPars = find_gamma_pars(distr);

assertElementsAlmostEqual(pars, recoveredPars,'absolute',1)
