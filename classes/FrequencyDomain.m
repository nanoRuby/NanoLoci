classdef FrequencyDomain
    properties
        imRaw       % raw image in lateral domain
        imBr        % brightfield image
    end
    methods
        function obj = FrequencyDomain(imFl,imBr,state)
            if nargin == 1
                obj.imRaw = imFl;
            end

            if nargin == 3
                switch state
                    case 0
                        obj.imRaw = imFl;
                    case 1
                        obj.imRaw = imBr;
                end
            end
        end
        %% find peaks 
        function [peakL, threshInitial] = findPeaks(obj, threshIn)
            %% Filter and obtain the initial threshold
            imFFT = (fftshift(fft2(obj.imRaw)));
            D0 = 0; rF = 15;
            % this creates the first filter to get rid of the signal in the middle%
            [~, fR1, ~] = band_fourier(D0,2*rF+1,size(obj.imRaw));
            fftB1 = abs(imFFT.*fR1);
            % gaussian filtering which will enhance the peaks in the fourier domain
            fftBfilt = imgaussfilt(fftB1,1.5);
            % use Otsu thresholding to estimate a possible threshold
            thr1 = multithresh(log(fftBfilt+1),2);
            if threshIn ==0
                threshInitial = thr1(2);
            else
                threshInitial = threshIn;
            end

            %% Find the peaks in the frequency domain %%
            imDil = imdilate(fftBfilt, strel('disk',3));
            imLoc = imDil == fftBfilt.*(log(fftBfilt+1) > threshInitial);
            reg = regionprops(imLoc, log(fftB1+1),'WeightedCentroid');
            peakL = cat(1,reg.WeightedCentroid);
        end
    end
end