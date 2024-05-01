function [notchNorm, notchGauss, notchButt] = notch_filters(peakL, D0,szF)
    
    %% notch_filters: Generate notch filters of three types - normal, Butterworth, and Gaussian.
    % Gonzalez, R. C., & Woods, R. E. (2018). Digital Image Processing, 
    % Fourth Edition, Global Edition. Pearson Education Limited.
    % Chapter 4.10 Selective Filtering 297
    %% Inputs and Outputs
    %   Inputs:
    %       - peakL: Peak locations extracted from the Fourier transform of brightfield.
    %       - D0: Cutoff frequency for the notch filters.
    %       - szF: Size of the Fourier transform matrix.
    %
    %   Outputs:
    %       - notchNorm: Notch filter matrix using normal filter.
    %       - notchGauss: Notch filter matrix using Gaussian filter.
    %       - notchButt: Notch filter matrix using Butterworth filter.
    %
    %   This function generates notch filters based on peak locations and a cutoff frequency.
    %   It applies different filter formulas for each type and returns the filtered matrices.
    %% matrix relocation
    D1 = zeros(szF); D2 = zeros(szF);
    M = szF(1); N = szF(2);
    notchNorm  = ones(M,N);
    notchButt  = ones(M,N); 
    notchGauss = ones(M,N);
  
    n = 3; %butterworth filter order
    for nP = 1:3
        %size(peakL,1)
        u0 = round(peakL(nP,1)); 
        v0 = round(peakL(nP,2));
        for i = 1:M
            for j = 1:N
                D1(i,j) = sqrt((i-v0)^2 + (j - u0)^2);
                D2(i,j) = sqrt((i-M+v0-2)^2 +(j - N+ u0-2)^2);
                %D2(i,j) = sqrt((i-M+v0-1)^2 +(j - N+ u0-1)^2);
                if ((D1(i,j) < D0) || (D2(i,j) < D0))
                    notchNorm(i,j)  = 0;
                    notchButt(i,j)  = 1/(1+(D0^2/(D1(i,j)*D2(i,j)))^n);
                    notchGauss(i,j) = 1-exp(-0.5*((D1(i,j)*D2(i,j))/D0^2));
                end
            end
        end
    end
end