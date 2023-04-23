fid = fopen('bitstream.txt','wt');
for ii = 1:size(bitstream,1)
    fprintf(fid,'%x',bitstream(ii,:));
end
fclose(fid);