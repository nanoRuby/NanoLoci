function [locF,locN,indexVecVor] = voronoi_tessalation(dMax,xy,grid, imInvert)
    % voronoi_tessalation: Perform Voronoi tessellation and spot localization.
    %
    %   Inputs:
    %       - dMax: Maximum linking distance in pixels.
    %       - xy: Detected x,y locations from the previous step.
    %       - grid: The pattern obtained from brightfield.
    %       - imInvert: Indicates whether the brightfield image needs to be inverted.
    %
    %   Outputs:
    %       - locF: Filtered spot locations after Voronoi tessellation.
    %       - locN: Normalized spot locations after spot finding in the grid.
    %       - indexVecVor: Hot-encoded vector indicating Voronoi results.
    %
    %   This function performs the following steps:
    %   1. Create a pattern for cross-correlation.
    %   2. Find maxima in the grid.
    %   3. Perform Voronoi tessellation and filter spot locations.
    %   
    %   Reference:
    %   https://en.wikipedia.org/wiki/Voronoi_diagram
    
    %% 1. create pattern for cross-correlation
    %This segment of code initializes a Gaussian pattern, performs normalized 
    % cross-correlation between the pattern and an image grid, adjusts the result, 
    % dilates the image to find maxima, and identifies their locations.
    % Define parameters for creating Gaussian pattern
    
    k = 4;  % Kernel size parameter
    sigma = 1;  % Standard deviation of the Gaussian
    % Calculate the grid size based on parameters
    N = round(2*k*sigma);  % Grid size for cross-correlation
    % Create meshgrid for Gaussian pattern
    [x, y]= meshgrid(round(-N/2):round(N/2), round(-N/2):round(N/2));
    % Generate Gaussian pattern
    f = exp(-x.^2/(2*sigma^2)-y.^2/(2*sigma^2));
    % Normalize Gaussian pattern
    patt = f./sum(f(:));  % Normalized Gaussian PSF as cross-correlation pattern
    
    % Invert the grid if specified
    if imInvert == 1
        grid = 2^16 - grid;
    end
    
    % Perform normalized cross-correlation between the pattern and the grid
    CC = normxcorr2(patt,grid); 
    % Remove padding from cross-correlation result
    CC = CC(k+1:end-k, k+1:end-k);
    % Pad the cross-correlation result
    im1 = padarray(CC,[1 1],'replicate');
    im = CC;
    
    % Dilate the image to find maxima
    maskDil = ones(3);  % Define dilation mask
    dilate = imdilate(im,maskDil);  % Dilate the image using the mask defined by detection radius
    
    % Create binary mask for dilated image
    dilated_mask = dilate == im;  % Create binary mask indicating dilated regions
    dilated_mask = dilated_mask & im;  % Apply mask to original image
    
    % Find locations of maxima
    locMax = find(dilated_mask);  % Find the locations of maxima in the dilated image
    [yId,xId] = ind2sub(size(im),locMax);  % Convert linear indices to x and y indices


    %% 2. Maxima finding in the grid
    locN = zeros(length(xId),2);
    for i = 1:length(xId)
        sp = abs(im1(yId(i):yId(i)+2,xId(i):xId(i)+2));
        bwS = sp == sp;
        ms = regionprops(abs(bwS), sp, 'WeightedCentroid');
        cM = ms.WeightedCentroid;
        locN(i,1) = xId(i)+ cM(1)-2;
        locN(i,2) = yId(i)+ cM(2)-2;
    end
    
    %% 3. Voronoi tesselation
    xLoc = xy(:,1); yLoc = xy(:,2);
    [V,C] = voronoin([locN(:,1),locN(:,2)]);
    nSp = length(C); 
    cellP = cell(nSp,2);
    for i = 1:nSp
        curr_polygon = V(C{i},:);
        if ~any(curr_polygon(:)== Inf)
            cent_x = mean(curr_polygon(:,1));
            cent_y = mean(curr_polygon(:,2));
            indAr = inpolygon(xLoc, yLoc, curr_polygon(:,1), curr_polygon(:,2));
            indPol = find(indAr, 1);
            if ~isempty(indPol)
                pol_x = xLoc(indPol);
                pol_y = yLoc(indPol);
                dist_c = sqrt((cent_x - pol_x).^2+(cent_y - pol_y).^2);
                cellP{i,1} = dist_c;
                cellP{i,2} = double(indPol);
            end
        end 
    end
    
    distMat = [];
    distMat(:,1) = [cellP{:,1}];
    distMat(:,2) = [cellP{:,2}];
    
    indF = distMat(distMat(:,1)<dMax,2);
    xF = xLoc(indF); yF = yLoc(indF);
    locF = [xF,yF];
    % we create hot encoded vector as well to export voronoi results and
    % merge it with spot locations and outlier exclusion

    indexVecVor = ones(size(xy,1),1);
    indexVecVor = - indexVecVor;
    indexVecVor(indF) = 1; % hot encoded vector for Voronoi
end