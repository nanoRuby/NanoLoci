%% do image filtering in fourier domain %%
% it is doing band reject in this case, change also to do band pass %
function [imFilt,fR,imFFTav] = fourier_filt(imAll,W0,D0)
    imFilt =  zeros(size(imAll));
    imFFTar = zeros(size(imAll));
    sz = size(imFilt,1:2);  % get the lateral dimenstion of the image
    % calculate the bandreject
    [fNorm, fGauss, fButt] = band_fourier(D0,W0,sz);
    fR = fGauss;
    
    for k = 1:size(imFilt,3)
        im = double(imAll(:,:,k));
        imFFT   = (fftshift(fft2(im))); 
        imFilt(:,:,k) = ifft2(ifftshift(imFFT.*fR));
        imFFTar(:,:,k) = imFFT;
    end
    
    imFFTav = mean(imFFTar,3);
end