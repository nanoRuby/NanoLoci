%% Wavelet filtering
% Performs wavelet filtering on an input image to remove noise and enhance 
% features, using undecimated wavelet transform with cubic B-spline 
% function-based coefficients.
%% Reference:
% Izeddin, I., Boulanger, J., Racine, V., Specht, C.G., Kechkar, A., Nair, 
% D., Triller, A., Choquet, D., Dahan, M., & Sibarita, J.B. (2012). 
% Wavelet analysis for single molecule localization microscopy. 
% Opt. Express, 20(3), 2081-2095. https://doi.org/10.1364/OE.20.002081

function [imageFilt] = wavelet_filter(imageRaw,borderSize)
%% Inputs and Outputs:
% Inputs:
%   - imageRaw: Input image to be filtered. It can be a single or multiframe image. 
%     The dimensions of the input image should be (height x width x time).
%   - borderSize: Size of the border to be added to the input image before
%     applying wavelet filtering. This helps prevent loss of detections
%     near the image borders. It should be a non-negative integer.
%
% Output:
%   - imageFilt: Filtered image obtained after applying the wavelet
%     filtering process. It has the same dimensions as the input image.

imageFilt= zeros(size(imageRaw));

% initialize the wavelet coefficients 
% (based on undecimated wavelet transform using cubic B-spline function)
% The pre-calculated values are provided in Izeddin 2012  
H0 = 3/8;
H1 = 1/4;
H2 = 1/16;

% the first wavelet filter matrix
filter1 = [H2,H1,H0, H1, H2]' * [H2,H1,H0, H1, H2];

% the second wavalet filter matrix is obtained with the same coefficients
% but zeros are inserted in between (a-trous wavelet with 'holes')
filter2 = [H2,0,H1, 0, H0,0,H1, 0, H2]' * [H2,0,H1,0,H0,0 H1,0, H2];

for j = 1:size(imageRaw,3)
    im = double(imageRaw(:,:,j));
    % add padding to increase image size so the detections on the borders
    % are not lost
    im = padarray(im, [borderSize, borderSize], 'replicate');
    % I = medfilt2(im,[2 2]);
    C1 = conv2(im,filter1,'same'); % the first coefficient map
    C2 = conv2(C1,filter2,'same'); % the second coefficient map 
    
    % the second wavelet map is the filtered image and is obtained as the
    % difference of coefficient maps.
    imF = (C1 - C2); % filtered image, 1 frame
    
    % Remove the padding
    imF = imF(borderSize+1:end-borderSize, borderSize+1:end-borderSize, :);

    % Ensure non-negative values
    imF = max(imF, 0); % might be better not to have this
    imageFilt(:,:,j) = imF;
end
end