%% Reads a multiframe TIFF file and saves it in an image array
function imArray = Tiff_read(filename)
%% Inputs and Outputs:
    % Inputs:
    %   - filename: Path of the multiframe TIFF file
    %
    % Outputs:
    %   - imArray: Array containing the frames of the TIFF file
    
    warning off;
    tstack = Tiff(filename);            % Open the TIFF file
    [i, j] = size(tstack.read());       % Get x and y dimensions
    l = length(imfinfo(filename));      % Get the number of frames in the TIFF file
    imArray = zeros(i, j, l);           % Initialize image array
    imArray(:, :, 1) = tstack.read();   % Read and save first frame
    
    % Read the remaining frames and save them in the image array
    for n = 2:l
        tstack.nextDirectory();
        imArray(:, :, n) = tstack.read();
    end
end
