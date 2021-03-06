function ARP_datastruct = ARP_durs_BUF(Durs, pars)

%if Durs(1,1) == 0, Durs = Durs(2:end,:); end

if exist('pars','var'), v2struct(pars);
else window = 15; step = .1;
end

if any(diff(Durs(:,2))==0), 
    disp('Non-alternating percept found');
	ARP_datastruct = [];
    return
end

if length(Durs) < 4
    disp('Not enough data')
    ARP_datastruct = struct('durs1',{[]}, 'durs2',{[]}, 'tax', {[]},...
        'BUF',{[]},'BUF_adj',{[]},'g1',{[]},'g2',{[]},'rows',{[]});
    return
end
if Durs(1,2) ~=1 
    disp('Coherent percept not first');
    ARP_datastruct = struct('durs1',{[]}, 'durs2',{[]}, 'tax', {[]},...
        'BUF',{[]},'BUF_adj',{[]},'g1',{[]},'g2',{[]},'rows',{[]});
    return
end

durs1 = Durs(Durs(:,2)==1,1); durs2 = Durs(Durs(:,2)==2,1);
g1 = gamfit(durs1); g2 = gamfit(durs2);

[BUF tax rows] = make_switchTriggeredBUF(Durs,step,window);

[BUF_pred tax_pred] = make_fourier_buildup_function([g1 g2]);

BUF_adj = interp1(tax_pred,BUF_pred,tax,'pchip','extrap');

ARP_datastruct = v2struct(durs1, durs2, tax, BUF, BUF_adj, g1, g2, rows);

end