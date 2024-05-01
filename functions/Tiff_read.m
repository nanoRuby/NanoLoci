%% A function to read a multiframe tiff file and save it in an image array %%
function imArray = Tiff_read(filename)
    warning off;
    tstack  = Tiff(filename);
    [i,j] = size(tstack.read());
    l = length(imfinfo(filename));
    imArray = zeros(i,j,l);
    imArray(:,:,1)  = tstack.read();
for n = 2:l
    tstack.nextDirectory()
    imArray(:,:,n) = tstack.read();
end
end