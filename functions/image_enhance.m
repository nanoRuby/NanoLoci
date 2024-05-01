% ------------------------INPUT------------------------------------------%
% imRaw:    image in fluorescence domain --------------------------------%
% peakL:    detected peaks in Fourier domain ----------------------------%
% p:        enhancement percentage --------------------------------------%
% imBr:     the brightfield complementary if given ----------------------%

function imageEnhanced = image_enhance(imRaw,peakL,p,inv,imBr)
    p = p/100;
    wN = 20;
    [~, notchG, ~] = notch_filters(peakL, wN,size(imRaw));
    %imF  = fftshift(fft2(imRaw));
    if nargin < 5
        imFB =  fftshift(fft2(imRaw));
        GridFFT = imFB.*(1-notchG);
        Grid = (ifft2(ifftshift(GridFFT)));
        if inv == 1
            imGr = 1 - rescale(Grid);
        else
            imGr = rescale(Grid);
        end
        imageEnhanced = (1-p)*imRaw + p*imGr.*imRaw;
    elseif nargin ==5
        imFB =  fftshift(fft2(imBr));
        GridFFT = imFB.*(1-notchG);
        Grid = (ifft2(ifftshift(GridFFT)));
        %scl =p*prctile(imRaw(:),95);
        scl = p*mean(imRaw(:));
        if inv == 1
            imGr = 1 - rescale(Grid);
        else
            imGr = rescale(Grid);
        end
        %imageEnhanced = imRaw + scl*imGr;
        %scl  =  p* max(abs(imF(:)))/max(abs(imFB(:)));
        %imF1 = imF + scl*(imFB.*(1-notchG));
        imageEnhanced = (1-p)*imRaw + p*imGr.*imRaw;
    end
    %imageEnhanced = (ifft2(ifftshift(imF1)));
    if (rem(size(imageEnhanced),2))==1
        imageEnhanced = imageEnhanced(1:end-1,1:end-1);
    end
end