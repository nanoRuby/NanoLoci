%% Performes image enhancement by image fusion or comination based on Fourier 
%% domain notch filtering
% This function enhances an input image using frequency domain manipulation techniques. 
% It applies a notch filter to the Fourier domain based on the detected peaks. 
function imageEnhanced = image_enhance(imRaw,peakL,p,inv,imBr)
    %% Inputs and Outputs:
    % Inputs:
    %   - imRaw: Image in the fluorescence domain
    %   - peakL: Detected peaks in Fourier domain
    %   - p: The percentage of enhancement [0,100]
    %   - inv: Flag for inverting the image (0 or 1)
    %   - imBr: Brightfield complementary if given
    % Output:
    %   - imageEnhanced: Enhanced image
    %% Description
    % If imBr is provided:
    %   - The function applies a notch filter to the Fourier transform of the imBr image.
    %   - imRaw is enhanced based on imBr.
    %
    % If imBr is not provided:
    %   - The function applies a notch filter to the Fourier transform of the imRaw image.
    %   - imRaw is enhanced solely based on its own peaks.

    p = p/100;       % Convert p percentage  to a ration  
    wN = 20;         % Set notch filter window size
    
    % Generate notch filter (Gaussian Notch filter is chosen here)
    [~, notchG, ~] = notch_filters(peakL, wN,size(imRaw));

    % if imBr is not provided, do the enhancement based on frequency peaks
    % in imRaw. Thos works only if detectable peaks exist in imRaw.
    if nargin < 5
        imComp = imRaw;
    elseif nargin ==5
        imComp = imBr;
    end
    imFB =  fftshift(fft2(imComp)); % Apply Fourier transform to the raw image
    GridFFT = imFB.*(1-notchG);    % Apply bandpass notch filter to the Fourier domain
    Grid = (ifft2(ifftshift(GridFFT))); % Inverse Fourier transform to obtain the grid
    % Scale and invert the enhanced image if required
    if inv == 1
       imGr = 1 - rescale(Grid);
    else
       imGr = rescale(Grid);
    end
    % Perform image enhancement by enhancing the raw image imRaw using the
    % obtained grid imGr based on fourier domain peaks
    imageEnhanced = (1-p)*imRaw + p*imGr.*imRaw;

    % Trim the enhanced image if its size is odd
    % TODO: check if this is necessary
    if (rem(size(imageEnhanced),2))==1
        imageEnhanced = imageEnhanced(1:end-1,1:end-1);
    end
end