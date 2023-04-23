function [size] = calc_AC_bin_value_size(ac_value)
%UNTİTLED3 Summary of this function goes here
%   Detailed explanation goes here

if ac_value == 0 
    size = 0;
elseif (ac_value == -1) || (ac_value == 1)
    size = 1;
elseif ((ac_value >= -3) && (ac_value <= -2)) || ((ac_value >= 2) && (ac_value <= 3))
    size = 2;
elseif ((ac_value >= -7) && (ac_value <= -4)) || ((ac_value >= 4) && (ac_value <= 7))
    size = 3;
elseif ((ac_value >= -15) && (ac_value <= -8)) || ((ac_value >= 8) && (ac_value <= 15))
    size = 4;
elseif ((ac_value >= -31) && (ac_value <= -16)) || ((ac_value >= 16) && (ac_value <= 31))
    size = 5;
elseif ((ac_value >= -63) && (ac_value <= -32)) || ((ac_value >= 32) && (ac_value <= 63))
    size = 6;
elseif ((ac_value >= -127) && (ac_value <= -64)) || ((ac_value >= 64) && (ac_value <= 127))
    size = 7;
elseif ((ac_value >= -255) && (ac_value <= -128)) || ((ac_value >= 128) && (ac_value <= 255))
    size = 8;
elseif ((ac_value >= -511) && (ac_value <= -256)) || ((ac_value >= 256) && (ac_value <= 511))
    size = 9;    
elseif ((ac_value >= -1023) && (ac_value <= -512)) || ((ac_value >= 512) && (ac_value <= 1023))
    size = 10;
elseif ((ac_value >= -2047) && (ac_value <= -1024)) || ((ac_value >= 1024) && (ac_value <= 2047))
    size = 11;
end


end

