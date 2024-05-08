%% Fourier Domain Image Filtering %%
% This function applies image filtering in the Fourier domain.
% By default, it performs band rejection filtering, but it can be modified
% to perform band pass filtering as well.
% see band_fourier.m more more

function [imFilt, fR, imFFTav] = fourier_filt(imAll, W0, D0)
    % Input:
    %   - imAll: Input image or set of images.
    %   - W0: Width parameter for band rejection.
    %   - D0: Distance parameter for band rejection.
    % Output:
    %   - imFilt: Filtered image or set of images.
    %   - fR: Frequency domain filter applied.
    %   - imFFTav: Average Fourier transform of the filtered images.
    
    %% Initialize filtered image array and Fourier transform array
    imFilt =  zeros(size(imAll));
    imFFTar = zeros(size(imAll));
    
    % Extract lateral dimensions of the image
    sz = size(imFilt, 1:2);
    
    % Calculate the band reject filter
    [fNorm, fGauss, fButt] = band_fourier(D0, W0, sz);
    fR = fGauss;    % Assign Gaussian filter for band rejection
    
    % Loop through each image
    for k = 1:size(imFilt, 3)
        % Convert image to double
        im = double(imAll(:, :, k));
        
        % Compute 2D Fourier transform and shift zero frequency to center
        imFFT = fftshift(fft2(im));
        
        % Apply Fourier domain filter
        imFilt(:, :, k) = ifft2(ifftshift(imFFT .* fR));
        
        % Store Fourier transform of the image
        imFFTar(:, :, k) = imFFT;
    end
    
    % Calculate the average Fourier transform
    imFFTav = mean(imFFTar, 3);
end
