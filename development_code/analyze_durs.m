% outline for bottom level code to test basic idea of the thesis, mainly
% that ARP fit is good with empirical BUF

% results should contain BUFx, BUFfit, rSquared, g1_pars, g2_pars,
% nWindows, durs1, durs2, tax;

function results = analyze_durs(durs,window,bSwitch)
    
if ~exist('window','var')
    window = 10;
end
if ~exist('bSwitch','var')
    bSwitch = 1;        % tells whether to calculate BUF as switch triggered or trial averaged
end

durs1 = durs(durs(:,2)==1,1);
durs2 = durs(durs(:,2)==2,1);

g1_pars = find_gamma_pars(durs1);
g2_pars = find_gamma_pars(durs2);

if bSwitch
    [BUF tax nWindows] = make_switchTriggeredBUF(durs,.001,window);
end

[error rSquared BUFfit] = compare_buildup_functions2([g1_pars;g2_pars], ...
    BUF, tax);

results = v2struct(BUF, BUFfit, tax, rSquared, g1_pars, g2_pars, ...
    nWindows, durs1, durs2);
    
    
    
    
