function ARP_data_tot = combine_ARP_data(ARP_data)


ARP_data_tot.tax = ARP_data(1).tax;
BUF = mean(vertcat(ARP_data(:).BUF),1); if isscalar(BUF), keyboard; end
ARP_data_tot.BUF = BUF;
ARP_data_tot.BUF_adj = mean(vertcat(ARP_data(:).BUF_adj));

ARP_data_tot.durs1 = vertcat(ARP_data(:).durs1);
ARP_data_tot.durs2 = vertcat(ARP_data(:).durs2);

ARP_data_tot.g1 = gamfit(ARP_data_tot.durs1); ARP_data_tot.g2 = gamfit(ARP_data_tot.durs2);

ARP_data_tot.rows = sum([ARP_data.rows]);