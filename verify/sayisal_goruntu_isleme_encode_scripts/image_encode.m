%% Image Compression Algorithm
% FileName      : image_encode.m
% ReleaseDate   : 30.12.2022 05:16   PM 
% LastUpdate    : 12.01.2023 10:15   AM 
% Authors       : Mehmet Burak Aykenar, Abdulkadir Arslan  
% Version       : 1.0.1
% Changes             
% 1.0.0 : First release
% 1.0.1 : Add loop for checking if last AC value of each block is zero or not for observation
%       : Add (AC_component(t) == 0) check in case last component of a block is non-zero
%       : Change append function with [,] for string appending for older
%       MATLAB versions
%       : Change endianness from default to big-endian in fopen function

%% load image 
clear all;
clc;

% this script works on 320x240 grayscale images
%filename = 'football_Qvga.tif';
%I = imread(filename);

 I = imread('splash.jpg');
 I = rgb2gray(I);

% I = imread('image2.png');
% I = rgb2gray(I);

imshow(I);

% load quantization table
load('QTable.mat');

%% create dct 
I_dc_offset = cast(I,'int16');
% Subtract DC offset
I_dc_offset = I_dc_offset-128;
% take 8x8 DCT
I_dct = I_dc_offset;
for i = 1:8:233
    for j = 1:8:313
        I_dct(i:i+7,j:j+7) = dct2(I_dc_offset(i:i+7,j:j+7));
    end
end

%% Quantization
I_qntz = I_dct;
for i = 1:8:233
    for j = 1:8:313
        I_qntz(i:i+7,j:j+7) = round(I_dct(i:i+7,j:j+7)./cast(QT,'int16'));
    end
end

%% zigzag scanning
I_zz = zeros(1,320*240);
zz_count = 1;
for i = 1:8:233
    for j = 1:8:313
        I_zz(zz_count:zz_count+63) = zigzag(I_qntz(i:i+7,j:j+7));
        zz_count = zz_count+64;
    end
end

%% create DC indexes with DPCM

DC_component = zeros(1,320*240/64);
count = 1;
for tif=1:64:(length(I_zz) -63)  
    DC_component(count) = I_zz(tif);
    count = count + 1;   
end

% subtract DC values from each other to be able to store them with less bits
% stop at index 2 since the first DC component has no previous DC to
for i=length(DC_component):-1:2
    DC_component(i) = DC_component(i)-DC_component(i-1); 
end

%calculate DC_size (SIZE,Value)
%Evaluate from how many bits DC values going to be consist of  
DC_size = zeros(1,length(DC_component));
for i=1:length(DC_component)
    DC_size(i) = calc_dc_size(DC_component(i)); 
end

%calculate DC_code according to size of DC value(Code,Value)
DC_code = {};
for i=1:length(DC_component)
    DC_code{i} = calc_dc_code(DC_size(i));
end

%calculate DC_value (Code,Value)
%Calculate bit representation for DC values 
DC_value = {};
for i=1:length(DC_component)
    DC_value{i} = calc_dc_value(DC_component(i));
end

% DPCM for DC values are finished: (DC_code,DC_value). 

% Concatenate DC code and DC value
encoded_DC_components = {};
for i = 1:length(DC_code)
     encoded_DC_components{i} = [DC_code{i},DC_value{i}] ; 
end 

%% Create and Store AC values  
AC_component = zeros(1,(320*240)-1200); % there are 1200 DC component so subtract that 
AC_counter = 1;

for i=1:length(I_zz)         
    if ( mod((i-1),64) == 0) 
      % Pass the DC value      
    else 
      % Capture AC value
       AC_component(AC_counter) = I_zz(i);
       AC_counter = AC_counter + 1;
    end    
end 

%% Check if last AC value of each block is zero or not
% This section does not have any functional effect on the image compression algorithm. 
% This section was added to check if any of the 63rd AC components in each block is non-zero. 
test_index = 1;
test_array = [];
for i = 63:63:length(AC_component)
    test_array(test_index) = AC_component(i);
    test_index = test_index +1;
end 

 if(all(test_array(:) == 0)) 
     test_array_all_zero = 1;
 else 
     test_array_all_zero = 0;
 end 

%% Calculate AC Codes
encoded_AC_component = {};
zero_count = 0;
j=0;
t=1; % index to check every AC component  
count_63_AC = 1; 

for i=1:length(AC_component)/63 % there are 1200 block 
    count_63_AC = 1;
    while count_63_AC <= 63 % in each DCT block 63 AC component           
         
        % IF it is not the last AC component in the block and if component value is zero 
          if ((AC_component(t) == 0 && zero_count < 15) && count_63_AC ~= 63  ) 
                
             zero_count = zero_count +1;
             t = t +1;           
             count_63_AC = count_63_AC + 1;          

          % when it is sixteen zero in a row or last AC component in the block
          elseif ( (AC_component(t) == 0 && zero_count == 15)|| (count_63_AC == 63  &&  AC_component(t) == 0 )) 
           
             % if it is last component EOB 
               if(count_63_AC == 63)
                   j = j +1;
                   encoded_AC_component{j} = [1,0,1,0];    
                   count_63_AC = 64;
                   t = t +1;
               else
                 zero_count = 0; % reset zero count anyways 

                 load_rest_of_ac_values_to_check_if_zero = zeros (1,63-count_63_AC);
                 f = t +1;
                 for k = 1:(63-count_63_AC)
                    load_rest_of_ac_values_to_check_if_zero(k) = AC_component(f);
                    f = f+1;
                 end 

                 if (all(load_rest_of_ac_values_to_check_if_zero(:) == 0)) % it is EOB 
                     j = j +1;
                     encoded_AC_component{j} = [1,0,1,0];
                     % go to next AC blocks first index
                     t = t + (63 - count_63_AC) +1 ;
                     %break the while loop
                     count_63_AC = 64;
                 else 
                     j = j +1;
                     % if there is a non-zero element in the AC block use code for 16 zero in a row and continue in the same block  
                     encoded_AC_component{j} = [1,1,1,1,1,1,1,1,0,0,1];
                     count_63_AC = count_63_AC +1;
                     t = t +1;
                 end 
               end    
             
          else              
              
             size_of_binary_AC_value = calc_AC_bin_value_size(AC_component(t));

             ac_code                 = calc_ac_code (zero_count,size_of_binary_AC_value);      
 
             bin_value               = calc_ac_bin_value(AC_component(t));
             
             j=j+1;
             encoded_AC_component{j} = [ac_code,bin_value];
             
             count_63_AC = count_63_AC +1;
             zero_count = 0; 
             t = t+1;
             
         end 
        
     end 
end 


%% concatenate DC and AC 
 
ac = 1; 
dc_ac_code = {};
g = 1;

for dc = 1: 1200
    % after each while break we will load dc value
    dc_ac_code{g} = cell2mat(encoded_DC_components(dc));
    g = g +1;
    
    break_while = 0 ;
    while break_while == 0 
        
        % convert ac value type
        AC_code_matrix = cell2mat(encoded_AC_component(ac));
        
        ac = ac +1;
        if ((length(AC_code_matrix) == 4 ) & (AC_code_matrix == [1 0 1 0]) )  % end of block detect 
            dc_ac_code{g} = AC_code_matrix;
            g = g+1;
            break_while = 1;
        else  
            dc_ac_code{g} = AC_code_matrix;
            g = g+1;
            break_while = 0;
        end 
    end   
 
    
end 

%% create bitstream and save

bitstream = cell2mat(dc_ac_code);

% write to bin file

wrfilename = 'football_bitstream2';
wrextension = '.bin';
%fileID = fopen(append(wrfilename,wrextension),'w','b'); % MATLAB 2020a
fileID = fopen([wrfilename,wrextension],'w','b'); % MATLAB 2018b
fwrite(fileID,bitstream,'ubit1');
fclose(fileID);

% read from bin file 

rdfilename = 'football_bitstream2';
rdextension = '.bin';
%fileID= fopen(append(rdfilename,rdextension),'r','b'); % MATLAB 2020a
fileID = fopen([rdfilename,rdextension],'r','b'); % MATLAB 2018b
readbitstream = fread(fileID,'ubit1');
readbitstream = readbitstream';
fclose(fileID);