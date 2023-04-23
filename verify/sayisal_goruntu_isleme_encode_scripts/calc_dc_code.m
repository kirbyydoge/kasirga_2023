function [code] = calc_dc_code(dc_size)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if dc_size == 0 
    code = [0,0];
elseif (dc_size == 1)
    code = [0,1,0];
elseif (dc_size == 2)
    code = [0,1,1];
elseif (dc_size == 3)
    code = [1,0,0];
elseif (dc_size == 4)
    code = [1,0,1];
elseif (dc_size == 5)
    code = [1,1,0];
elseif (dc_size == 6)
    code = [1,1,1,0];    
elseif (dc_size == 7)
    code = [1,1,1,1,0];  
elseif (dc_size == 8)
    code = [1,1,1,1,1,0];  
elseif (dc_size == 9)
    code = [1,1,1,1,1,1,0];      
elseif (dc_size == 10)
    code = [1,1,1,1,1,1,1,0];   
elseif (dc_size == 11)
    code = [1,1,1,1,1,1,1,1,0];      
end

end