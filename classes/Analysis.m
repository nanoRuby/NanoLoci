classdef Analysis
    methods(Static)
        %% Filters the current image using user specified filtering method %
        function imFilt = filterTheImage(loc,imCurr)
            imFilt = zeros(size(imCurr));
            switch loc.filterMethod
                case 0
                    % do nothing
                    imFilt = imCurr;
                case 1 % do wavelet filtering
                    for f = 1:size(imFilt,4)
                        imFilt(:,:,:,f) = wavelet_filter(imCurr(:,:,:,f),loc.filterSize);
                    end
                case 2 % do fourier filtering
                    for f = 1:size(imFilt,4)
                        [imFilt(:,:,:,f),~,~] = fourier_filt(imCurr(:,:,:,f),loc.filterSize,0);
                    end
            end
        end
        
        %% Localize and fit
        function [LocsFit, LocsDet,LocsFinal] = LocAndFit(loc,state,images)
            nFrames = size(images.imFilt,3);
            nBatch  = size(images.imFilt,4);
            LocsFit = cell(nFrames,nBatch);
            LocsDet = LocsFit; LocsFinal = LocsFit;
            for j = 1:nBatch
                for i = 1:nFrames
                    im    = images.imFilt(:,:,i,j);
                    imRaw = images.imRawCurr(:,:,i,j);
                    if state.roi == 0
                        [xId,yId,~] = local_gradient(im,loc.gradWindow,loc.gradThresh);
                    elseif (state.roi == 1 && isfield(images,'imROI'))
                        [xId,yId,~] =...
                            local_gradient(im,loc.gradWindow,loc.gradThresh,images.imROI);
                    end
                    LocsDet{i,j} = [xId,yId];
                    if (~isempty(xId))
                        if loc.fitMethod == 0
                            results = psfFit_Image(im,[xId';yId'],[1,1,1,1,1,1,1],...
                            false,false,(loc.gradWindow-1)/2);
                            LocsFit{i,j} = results';
                        else
                            LocsFit{i,j} = weightedCentroid(im,[xId,yId],...
                                (loc.gradWindow-1)/2);
                        end
                        LocsFinal{i,j}(:,1:6) = LocsFit{i,j}(:,1:6);
                        [ampS,ampM,~,~]= amp_calc(imRaw,LocsFit{i,j}(:,1),...
                        LocsFit{i,j}(:,2),loc.gradWindow,loc.gradWindow);
                        LocsFinal{i,j}(:,7) = ampS; LocsFinal{i,j}(:,8) = ampM;
                    else
                        LocsFit{i,j} = [];
                        LocsFinal{i,j} = LocsFit{i,j} ;
                    end
                    
                    
                end
            end
        end
        
        function intensities = findIntensity(localizations,images,state,params)
            roi = state.roi;
            wind = (params.gradWindow-1)/2;
            nFrames = size(images.imRawCurr,3);
            nBatch  = size(images.imRawCurr,4);
            for j=1:nBatch
                for i = 1:nFrames
                 im = images.imRawCurr(:,:,i,j);
                 if ~isempty(localizations{i,j})
                 xLoc = localizations{i,j}(:,1);
                 yLoc = localizations{i,j}(:,2);
                 [ampS,~,~,bg]= amp_calc(im,xLoc,yLoc,wind,wind);
                 intensities.sumIntensity(i,j)  = sum(rmmissing(ampS));
                 intensities.numDetections(i,j) = length(rmmissing(ampS));
                 intensities.bgIntensity(i,j)   = bg;
                 if intensities.numDetections(i,j) ==0
                     intensities.avgIntensity(i,j) = bg;
                 else
                    intensities.avgIntensity(i,j)  = ...
                        intensities.sumIntensity(i,j)/intensities.numDetections(i,j);
                 end
                 if roi == 1 && isfield(images,'imROI')
                    roiIm = images.imROI.*im;
                    intensities.roi(i,j) = mean(roiIm(roiIm ~=0));
                 end
                 end
                end
            end
        end
    
    end
end