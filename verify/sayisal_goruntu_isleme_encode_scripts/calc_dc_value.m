function [value] = calc_dc_value(dc_val)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%  dc_val = 12;
if (dc_val == 0)
    value = [];
elseif (dc_val > 0)
    value = decimalToBinaryVector(dc_val);
elseif (dc_val < 0)
    value = decimalToBinaryVector(-dc_val);
    ones = length(value);
    value = double(xor(value,ones));
end

end