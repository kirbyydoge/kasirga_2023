function [ac_code] = calc_ac_code(zero_count,bin_value_size)
%UNTİTLED2 Summary of this function goes here
%   Detailed explanation goes here

if (zero_count == 0)
    
    if (bin_value_size == 0)
        ac_code = [1,0,1,0]; %EOB
    elseif(bin_value_size == 1)  
        ac_code = [0,0];
    elseif(bin_value_size == 2)  
        ac_code = [0,1];
    elseif(bin_value_size == 3)  
        ac_code = [1,0,0];
    elseif(bin_value_size == 4)  
        ac_code = [1,0,1,1];
    elseif(bin_value_size == 5)  
        ac_code = [1,1,0,1,0];    
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,0,0,0]; 
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,0,0,0];
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,0,1,1,0];
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,0];
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1];    
    
    end 
        
   
        
  
elseif (zero_count == 1)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,0,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,0,1,1];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,0,0,1];
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,0,1,1,0];
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,0,1,1,0];    
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,0,1,0,0]; 
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,0,1,0,1];
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,0];
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1];
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,1,0,0,0];    
    end  
        


elseif (zero_count == 2)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,0,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,0,0,1];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,0,1,1,1];
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,0,1,0,0];
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,1,0,0,1];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,1,0,1,0];  
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,1,0,1,1];  
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,1,1,0,0];  
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,1,1,0,1];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,0];    
    end 


elseif (zero_count == 3)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,0,1,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,0,1,1,1];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,0,1,0,1];
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1];
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,0,0,0,0];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,0,0,0,1];    
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,0,0,1,0];  
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,0,0,1,1];  
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,0,1,0,0]; 
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,0,1,0,1];   
    end 


elseif (zero_count == 4)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,0,1,1];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,0,0,0];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,0,1,1,0]; 
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,0,1,1,1]; 
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,1];    
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,1,0,1,0];   
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,1,0,1,1];  
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,1,1,0,0];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,1,1,0,1];   
    end 


elseif (zero_count == 5)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,0,1,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,0,1,1,1];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,0]; 
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1]; 
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,0,0,0,0];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,0,0,0,1];    
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,0,0,1,0];   
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,0,0,1,1];  
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,0,1,0,0];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,0,1,0,1];   
    end 


elseif (zero_count == 6)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,0,1,1];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,0,1,1,0];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,0,1,1,0]; 
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,0,1,1,1]; 
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,1,0,0,0];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,1,0,0,1];    
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,1,0,1,0];   
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,1,0,1,1];  
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,1,1,0,0];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,1,1,0,1];   
    end  



elseif (zero_count == 7)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,0,1,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,0,1,1,1];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,1,1,1,0];
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1];
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,0,0,0,0];    
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,0,0,0,1];    
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,0,0,1,0];  
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,0,0,1,1];  
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,0,1,0,0]; 
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,0,1,0,1];   
    end  



elseif (zero_count == 8)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,1,0,0,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,0,0,0,0,0];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,0,1,1,0]; 
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,0,1,1,1]; 
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,1,0,0,0];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,1,0,0,1];     
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,0];  
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1];   
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,0];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,1];   
    end 



elseif (zero_count == 9)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,1,0,0,1];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0];
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1]; 
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0]; 
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,0];     
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1];  
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,1,0,0];   
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,1,0,1];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,0];   
    end 


elseif (zero_count == 10)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,1,0,1,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1];  
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,1,0,0,0];  
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,1,0,0,1]; 
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,0];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,1,0,1,1];     
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0];  
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,1];   
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,0];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1];   
    end 



elseif (zero_count == 11)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,1,1,0,0,1];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,0];  
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,1];  
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,0,0,1,0]; 
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,0,0,1,1];     
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,0,1,0,0];     
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,0,1,0,1];  
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,0,1,1,0];   
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,0,1,1,1];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,1,0,0,0];   
    end 


elseif (zero_count == 12)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,1,1,0,1,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,1,0,0,1];  
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,1,0,1,0];    
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,1,0,1,1];   
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,0];        
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,1];       
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0];     
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1];     
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1];   
    end 


elseif (zero_count == 13)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,1,1,1,0,0,0];
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,0];  
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1];    
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,0,1,0,0];  
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,0,1,0,1];        
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0];       
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1];     
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,1,0,0,0];     
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,1,0,0,1];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,0];   
    end 


elseif (zero_count == 14)
    
    if(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1]; 
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,1,1,0,0];  
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,1,1,0,1];    
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0];  
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1];        
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0];       
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1];     
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,0];     
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,0];   
    end 



elseif (zero_count == 15)
    
    if(bin_value_size == 0)  
        ac_code = [1,1,1,1,1,1,1,1,0,0,1];   % if sixteeen consecutive 0 
    elseif(bin_value_size == 1)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1];  
    elseif(bin_value_size == 2)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,0];   
    elseif(bin_value_size == 3)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1];     
    elseif(bin_value_size == 4)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0];   
    elseif(bin_value_size == 5)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1];         
    elseif(bin_value_size == 6)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0];       
    elseif(bin_value_size == 7)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1];     
    elseif(bin_value_size == 8)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0];     
    elseif(bin_value_size == 9)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1];  
    elseif(bin_value_size == 10)  
        ac_code = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0];   
    end 




end



