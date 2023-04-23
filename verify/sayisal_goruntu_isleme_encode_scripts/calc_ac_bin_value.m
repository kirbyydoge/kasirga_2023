function [bin_value] = calc_ac_bin_value(dec_value)
%UNTİTLED4 Summary of this function goes here
%   Detailed explanation goes here
% dec_value = -1;
if (dec_value == 0)
    bin_value = [];
elseif (dec_value > 0)
    bin_value = decimalToBinaryVector(dec_value);
elseif (dec_value < 0)
    bin_value = decimalToBinaryVector(-dec_value);
    ones = length(bin_value);
    bin_value = double(xor(bin_value,ones));
    
end 

end

