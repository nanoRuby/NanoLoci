%% This function computes local gradients and filters out local maxima based
% on a gradient threshold.
%% Reference:
% The code on local gradient thresholding is adapted from 
% the local gradient calculation method described in Picasso:
% Schnitzbauer, J., Strauss, M.T., Schlichthaerle, T., Schueder, F., 
% & Jungmann, R. (2017). Super-resolution microscopy with DNA-PAINT. 
% Nature Protocols, 12(6), 1198-1228. https://doi.org/10.1038/nprot.2017.024

function [x_f,y_f,gr_f] = local_gradient(im,boxS,gradTr, ROI)
    %% Inputs and Outputs:
    % Inputs:
    %   - im: Input image (2D matrix) on which local gradient calculation is
    %     performed.
    %   - boxS: Size of the local window for gradient computation. It defines
    %     the neighborhood around each pixel for gradient estimation.
    %   - gradTr: Gradient threshold used to filter out local maxima. Only
    %     pixels with gradient magnitude above this threshold are considered as
    %     valid local maxima.
    %   - ROI (optional): Region of Interest mask. If provided, only pixels
    %     within this mask are considered for gradient calculation and local
    %     maxima detection.
    %
    % Outputs:
    %   - x_f: X-coordinates of filtered local maxima.
    %   - y_f: Y-coordinates of filtered local maxima.
    %   - gr_f: Gradient magnitudes corresponding to filtered local maxima.
   
   %% Obtain the local maxima specifed by the box size %%
   maskDil         = ones(boxS);
   dilate          = imdilate(im,maskDil);     % dilate the image using a mask defined by detection radius
   dilated_mask    = dilate == im;             % create a binary mask'
   dilated_mask    = dilated_mask & im;
   if nargin == 4
       dilated_mask = dilated_mask.*ROI;
   end
   locMax          = find(dilated_mask);       % find the locations of maxima
   [yId,xId]       = ind2sub(size(im),locMax); % convert to x and y indices
   
   %% Do gradient calculations %%
   % This part is largely based on Picasso's local gradient calculation in
   % order to have a valid comparison %
   boxR = floor(boxS/2); 
   ux = -meshgrid(-boxR:boxR);      % grid in x direction
   uy = ux';                        % grid in y direction
   un  = sqrt(ux.^2 + uy.^2);       % normalize the grid
   ux = ux./un; uy = uy./un;
   ux(1+boxR,1+boxR) = 0;           % set the central px to 0, since 
   uy(1+boxR,1+boxR) = 0;           % it becomes NaN after normalization
   grAll = zeros(length(xId),1);    % array to allocate gradent values
   intAll = grAll;

   for k = 1: length(yId)
        yk = yId(k); xk = xId(k);
        % Check if the gradient calculation is within image bounds
        if (yk-1-boxR>0 && yk+1+boxR<size(im,1) && xk-1-boxR>0 && xk+1+boxR< size(im,2))
            y = yk-boxR:yk+boxR; x = xk -boxR:xk+boxR;
            gy = im(y+1,x) - im(y-1,x);
            gx = im(y,x+1) - im(y,x-1);
            gr = gx.*ux + gy.*uy;
            grAll(k,1) = sum(gr(:));
            intAll(k,1)= im(yk,xk);
        end
   end

    %% Filter out local maxima based on gradient threshold
    f_ind = grAll > gradTr;
    x_f = xId(f_ind); 
    y_f = yId(f_ind);
    gr_f = grAll(f_ind);
end