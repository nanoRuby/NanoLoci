classdef Fourier
    methods(Static)
        function [im1, im2] = GetImage(imageData)
            if isstruct(imageData)
                fieldnames = {'imCurrent','BrCurrent'};
                im1 = imData.(fieldnames{1,1});
                im2 = imData.(fieldnames{1,2});
            else
                im1 = imageData;
                im2 = [];
            end
        end
        %% ==== Update the image and the corresponding Fourier image ==== %
        %im:     input image ---------------------------------------------%
        %imF:    corresponding fourier image (calculate if doesn't exist)-%
        %Axes1:  the figure on which the image is visualized -------------%
        %domain: 0 if spatial image, 1 if frequency ----------------------%
        %peaks:  show precalculated pattern peaks, if they exist ---------%
        function imF = Update(imFl,imComp,Axes1,domain,imF,peaks)

            if isempty(imComp)
                im = imFl;
            else
                im = imComp;
            end

            colormap(Axes1,'gray')
            axis(Axes1,[1 size(im,1) 1 size(im,2)])
            if nargin == 4
                imF = fftshift(fft2(im));
            end
           switch domain
               case 0
                   imagesc(Axes1,im)
               case 1
                   imagesc(Axes1,log(abs(imF)+1))
                   if nargin > 4
                        if ~isempty(peaks)
                            hold(Axes1,'on');
                            plot(Axes1,peaks(:,1),peaks(:,2),'ro');
                            hold(Axes1,'off')
                        end
                   end
           end
        end

        %% Find the peaks in Fourier Domain, which corresponds to the=====% 
        %  structured pattern in images==================================-%
        %---------------------INPUT---------------------------------------%
        % imRaw:     raw image in lateral domain -------------------------%
        % threshIn:  initial threshold------------------------------------%
        %--------------------OUTPUT---------------------------------------%
        % peakL: (x,y) positions of the obtained peaks from Fourier image %
        % threshCurrent: Automatically calculated threshold intensity ----%

        % GridBr: filtered image in the Fourier  Domain ------------------%

        function [peakL, threshCurrent,Grid] = FindPeaks(imData, threshIn,inv)
            if ~isempty(imData.imComp)
                if inv == 1
                    imRaw = max(imData.imComp(:))-imData.imComp;
                else
                    imRaw = imData.imComp;
                end
            else
                imRaw = imData.imRaw;
            end
            %% Filter and obtain the initial threshold
%             if (rem(size(imRaw),2))==0
%                 imRaw =padarray(imRaw,[1 1],'post');
%             end
            imFFT = (fftshift(fft2(imRaw)));
            D0 = 0; %rF = 20;
            %2024-10-29: make the size of rf dynamic
            rF = round(size(imRaw,1)/15);
            % this creates the first filter to get rid of the signal in the middle%
            [~, fR1, ~] = band_fourier(D0,2*rF+1,size(imRaw));
%            fR2 = ones(size(imRaw)); cent = ceil(size(imFFT,1)/2);
%             fR2(:,cent(1)-1:cent(1)+1)=0; fR2(cent(1)-1:cent(1)+1,:)=0;
            fftB1 = abs(imFFT.*fR1);
            % gaussian filtering which will enhance the peaks in the fourier domain
            %fftBfilt = fftB1;
            fftBfilt = imgaussfilt(fftB1,1.5);
            % use Otsu thresholding to estimate a possible threshold
            thr1 = multithresh(log(fftBfilt+1),2);
            if threshIn ==0
                threshCurrent = thr1(2);
            else
                threshCurrent = threshIn;
            end

            %% Find the peaks in the frequency domain %%
            imDil = imdilate(fftBfilt, strel('disk',5));
            imLoc = imDil == fftBfilt.*(log(fftBfilt+1) > threshCurrent);
            %imLoc = log(fftBfilt+1) > threshCurrent;
            reg = regionprops(imLoc, fftB1,'WeightedCentroid');
            peakL = cat(1,reg.WeightedCentroid);


            %% Parameters for Voronoi outlier exclusion
            %rN = 15;
            rN = round(size(imRaw,1)/30);
            if ~isempty(peakL)
                
                imFFT1 = imFFT.*fR1;
                %imFFT1 = (fftshift(fft2(imData.imRaw)));
                GridFFT = imFFT1.*(1-fR2);
                Grid = (ifft2(ifftshift(GridFFT)));
            end
        end
    

        function imageEnhanced = Enhance(imData,peakL,p,inv)
            imRaw = imData.imRaw;
            imBr  = imData.imComp;
%             if (rem(size(imRaw),2))==0
%                 imRaw =padarray(imRaw,[1 1],'post');
%                 if ~isempty(imBr)
%                 imBr = padarray(imBr,[1 1],'post');
%                 end
%             end
            if ~isempty(imBr)
                imageEnhanced = image_enhance(imRaw,peakL,p,inv,imBr);
            else
                imageEnhanced = image_enhance(imRaw,peakL,p,inv);
            end
        end
        
    end
end