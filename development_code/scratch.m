w = 2 * pi * f;
w = w(2:end);

fT0_transform = (1 + 1i*w*th0).^-a0;
fT1_transform = (1 + 1i*w*th1).^-a1;
FT1_CCDF_transform = 1./(1i*w) .* (1 - (1+1i.*w.*th1).^-a1);

tmp_num = fT0_transform.*fT1_transform;
tmp_den = 1-tmp_num;

tmp_coeff = (1/1i*w).*(1-(1+1i*w*th0).^a0).*fT0_transform;

p_transform_1given0 = tmp_coeff .* (1 + tmp_num./tmp_den);

% p_transform_1given0 = fT0_transform .* FT1_CCDF_transform + ...
%     1./(1i*w).*((FT1_CCDF_transform.*fT0_transform.^2 .* fT1_transform * 1i.*w)./...
%     (1-fT0_transform.*fT1_transform));

p_transform_1given0 = [mean1/(mean1+mean0) p_transform_1given0];
