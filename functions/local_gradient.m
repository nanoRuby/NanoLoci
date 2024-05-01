function [x_f,y_f,gr_f] = local_gradient(im,boxS,gradTr, ROI)
    
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
        if (yk-1-boxR>0 && yk+1+boxR<size(im,1) && xk-1-boxR>0 && xk+1+boxR< size(im,2))
            y = yk-boxR:yk+boxR; x = xk -boxR:xk+boxR;
            gy = im(y+1,x) - im(y-1,x);
            gx = im(y,x+1) - im(y,x-1);
            gr = gx.*ux + gy.*uy;
            grAll(k,1) = sum(gr(:));
            intAll(k,1)= im(yk,xk);
        end
   end

    f_ind = grAll > gradTr;
    x_f = xId(f_ind); 
    y_f = yId(f_ind);
    gr_f = grAll(f_ind);
    
    %
end