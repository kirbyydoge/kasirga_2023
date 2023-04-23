function [size] = calc_dc_size(dc_val)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if dc_val == 0 
    size = 0;
elseif (dc_val == -1) || (dc_val == 1)
    size = 1;
elseif ((dc_val >= -3) && (dc_val <= -2)) || ((dc_val >= 2) && (dc_val <= 3))
    size = 2;
elseif ((dc_val >= -7) && (dc_val <= -4)) || ((dc_val >= 4) && (dc_val <= 7))
    size = 3;
elseif ((dc_val >= -15) && (dc_val <= -8)) || ((dc_val >= 8) && (dc_val <= 15))
    size = 4;
elseif ((dc_val >= -31) && (dc_val <= -16)) || ((dc_val >= 16) && (dc_val <= 31))
    size = 5;
elseif ((dc_val >= -63) && (dc_val <= -32)) || ((dc_val >= 32) && (dc_val <= 63))
    size = 6;
elseif ((dc_val >= -127) && (dc_val <= -64)) || ((dc_val >= 64) && (dc_val <= 127))
    size = 7;
elseif ((dc_val >= -255) && (dc_val <= -128)) || ((dc_val >= 128) && (dc_val <= 255))
    size = 8;
elseif ((dc_val >= -511) && (dc_val <= -256)) || ((dc_val >= 256) && (dc_val <= 511))
    size = 9;    
elseif ((dc_val >= -1023) && (dc_val <= -512)) || ((dc_val >= 512) && (dc_val <= 1023))
    size = 10;
elseif ((dc_val >= -2047) && (dc_val <= -1024)) || ((dc_val >= 1024) && (dc_val <= 2047))
    size = 11;
end

end

