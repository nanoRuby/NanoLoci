%% band fourier: in this functi on, regular band reject functions are implemented,
% Gonzalez, R. C., & Woods, R. E. (2018). Digital Image Processing, 
% Fourth Edition, Global Edition. Pearson Education Limited.
% Chapter 3.7 HIGHPASS, BANDREJECT, AND BANDPASS FILTERS FROM LOWPASS FILTERS 

function[fNorm, fGauss, fButt] = band_fourier(D0,W0,sz)
    %% Inputs and Outputs
    %   Inputs:
    %       - D0: the distance from the origin to the center of the reject ring: 
    %            always 0 if instead of a ring filter, we are creating simple circular filter
    %       - W0: the width of filter in pixels, even number, is sigma for gaussian
    %       - sz: filter size [y,x]
    %   Outputs:
    %       - fNorm: regular reject/pass filter
    %       - fGauss: Gaussian reject/pass
    %       - fButt: Butterworth reject/pass
    %% Matrix implementation for computational efficiency
    fNorm  = zeros(sz);
    nB     = 2; % the order of Butterworth filter
    cent   =  floor(sz/2) + 1;
    [i,j]  = meshgrid(1-cent(1):cent(1)-2,1-cent(2):cent(2)-2);
    Db     = sqrt(i.^2 + j.^2);
    fNorm (Db <  D0 - W0/2) = 1;
    fNorm (Db >= D0 + W0/2) = 1;
    fButt  = 1./(1 + ((Db.*W0)./(Db.^2 - D0.^2)).^(2*nB));
    fGauss = 1- exp(-0.5.*(((Db.^2 -D0^2)./(Db.*W0)).^2));
    % for the case of D0 = 0; the central pixel is not calculated
    % => set the NaN values to 0:
    fButt(isnan(fButt))   = 0;
    fGauss(isnan(fGauss)) = 0;
end