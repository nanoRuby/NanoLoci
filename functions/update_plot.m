function update_plot(app)
    %% first update Sliders based on the current image

    SliderControl.updateLimits(size(app.images.imCurrent,3),app.SliderFr);

    %% make sure correct frame number is used
    currFr = currentValue(app.SliderFr);

    %% make sure correct image number is used
    currBatch = currentValue(app.SliderBatch);

    %% Select the image to show
    if app.ShowTheFiltered.Value == 1
        im = app.images.imFilt(:,:,currFr,currBatch);
    else
        try
            im = app.images.imCurrent(:,:,currFr,currBatch);
        catch
            im = app.images.imAll(:,:,currFr,currBatch);
        end
    end

     %% obtain the image limits to visualize and change according to contrast
     % value change
     ndev = app.SliderContrast.Value;
     im_mean = mean(im(:)); im_std = std(im(:));
     im_min = min(im(:));   im_max = max(im(:));
     cmin = max( im_min, im_mean - ndev * im_std );
     cmax = min( im_max, im_mean + ndev * im_std );
     
    %% Check the brightfield image %%
    if isfield(app.images,'BrAll')
        if numel(size(app.images.BrAll))>2
            imB = app.images.BrCurrent(:,:,currFr,currBatch);
        else
          imB = app.images.BrCurrent;
        end
    end
    
    colormap(app.FlAxes1,'gray');
    caxis(app.FlAxes1,[cmin, cmax]);
    imagesc(app.FlAxes1,im);
    if app.state.roi == 1 && isfield(app.images,'imROI')
        A = bwboundaries(app.images.imROI); % calculate the boundaries of the BW image
        hold(app.FlAxes1,'on')
        for i = 1:length(A)
            bwBound = A{i};
            plot(app.FlAxes1,bwBound(:,2),bwBound(:,1),'w');
        end
        app.TotalROIintensity.Visible = 1;
        app.AverageROIintensityLabel.Visible = 1;
    elseif app.state.roi == 0
        app.TotalROIintensity.Visible = 0;
        app.AverageROIintensityLabel.Visible = 0;
    end
    %% ==== Check whether to show lateral or fourier domain image ======== %
    if app.Domain.Value == 0
        imagesc(app.FlAxes,im);
        try
            imagesc(app.BrAxes,imB);
        catch

        end
    else
        imF  = abs(fftshift(fft2(im)));
        imagesc(app.FlAxes,log(imF+1))
        try
            imBF = abs(fftshift(fft2(imB)));
            imagesc(app.BrAxes,log(imBF+1))
        catch
        end
    end
    
    %% make sure that locations are visualized or no error 
    try
        [xLoc,yLoc] = getDetections(app.det.Loc,currFr,currBatch);
        [xFit,yFit] = getDetections(app.det.Fit,currFr,currBatch);
    catch
        xLoc = nan; yLoc = nan; xFit = nan; yFit = nan;
    end


    %% get outliers from Voronoi 
    %TODO this is mixed with DBscan
    if app.state.vor == 1
        try 
            [r_db,~] = find(app.det.Fit{currFr, currBatch}(:,9)~=-1);
        catch
            r_db = ones(length(xFit),1);
        end

        try 
            [r_vor,~] = find(app.det.Fit{currFr, currBatch}(:,10)~=-1);
        catch
            r_vor = ones(length(xFit),1);
        end
        r = r_vor(ismember(r_vor,r_db)==1);
    else
        r = 1:length(xFit);
    end

    %% Outliers from DBscan
    if app.state.db == 1
        try 
            [r_db,~] = find(app.det.Fit{currFr, currBatch}(:,9)~=-1);
        catch
            r_db = 1:length(xFit);
        end
        r = r(r_db);
    else
        r = 1:length(xFit);
    end

    %% update the results
    imRaw = app.images.imAll(:,:,currFr,currBatch); % use the original image for analysis
    sigX = (app.GradientWindow.Value-1)/2; sigY = sigX;
    [ampS,~,~,bg]= amp_calc(imRaw,xFit(r),yFit(r),sigX,sigY);
    
    app.SumIntensityField.Value = sum(rmmissing(ampS)); 
    app.NbNwField.Value = length(rmmissing(ampS));
    app.BackgroundIntensity.Value = bg; 
    if app.NbNwField.Value ~=0
        app.AvgIntensityField.Value = sum(rmmissing(ampS))/length(rmmissing(ampS)); 
    end
    if app.TotalROIintensity.Visible
        roiIm = app.images.imROI.*imRaw;
        app.TotalROIintensity.Value = mean(roiIm(roiIm ~=0));
    end
                      
    %% Visualize the detections
    if app.ShowTheDetections.Value == 1
        hold(app.FlAxes1,'on');
        plot(app.FlAxes1,xLoc(r),yLoc(r),'ys');
        hold(app.FlAxes1,'on');
        plot(app.FlAxes1,xFit(r),yFit(r),'rx');
        hold(app.FlAxes1,'off');
    else
        hold(app.FlAxes1,'off');
    end
    if isfield(app.results,'slct')
        ind = find(app.results.slct{currFr,currBatch} ~= 0);
        if ~isempty(ind)
            hold(app.FlAxes1,'on')
            sz = 60;
            scatter(app.FlAxes1,xLoc(ind),yLoc(ind),sz,'cyan','filled','o',...
                'MarkerFaceAlpha',0.5,'MarkerEdgeAlpha',1)
            hold(app.FlAxes1,'off')
        end
    end
end

function [x,y] = getDetections(Localizations, currFr, currBatch)
     if size(Localizations,1)>1
        x = Localizations{currFr,currBatch}(:,1);
        y = Localizations{currFr,currBatch}(:,2);
    elseif size(Localizations,1)==1
        x = Localizations{1,currBatch}(:,1);
        y = Localizations{1,currBatch}(:,2);
     end
end

function currIm = currentValue(Slider)
    if Slider.Enable
        currIm    = Slider.Value;
    else
        currIm = 1;
    end
end