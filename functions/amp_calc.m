%% amp_calc: Calculate the amplitudes and background intensity of spots in an image.
%   This function calculates the average and maximum amplitudes of spots in
%   the image based on the specified spot dimensions (sigX, sigY). It also
%   generates a binary mask (imF) indicating the location of spots and
%   calculates the mean background intensity (bgInt) of the image.
function [ampS,ampMax,imF,bgInt]= amp_calc(im,xLoc,yLoc,sigX,sigY)
%% Inputs and Outputs:
%   Inputs:
%       - im: Input image containing spots.
%       - xLoc: X-coordinates of the spots.
%       - yLoc: Y-coordinates of the spots.
%       - sigX: Standard deviation or radius of the spot in the X-direction.
%       - sigY: Standard deviation or radius of the spot in the Y-direction.
%
%   Outputs:
%       - ampS: Average amplitude per spot.
%       - ampMax: Maximum amplitude per spot.
%       - imF: Binary mask representing the spots in the image.
%       - bgInt: Mean background intensity of the image.
%
    ampS   = nan(length(xLoc),1); ampMax = ampS;
    imF    = zeros(size(im));
    x = round(xLoc); y = round(yLoc); nDet = length(x);
    if length(sigX) == 1
        bRadX = sigX; bRadY = sigY;
    end
    %% Creating a mask for each spot
    % this is defined in order to export a ROI where the spots are
    % localized. The radius needs to be bigger in order not to leave
    % any fluorescence in the background
    deltaPx =3;
    if bRadX == bRadY
       se       = strel('disk',bRadX+deltaPx);
       spotMask = se.Neighborhood;
       roiX = (size(spotMask,1) -1)/2;
       roiY = roiX;
    else
       roiX = bRadX+deltaPx;
       roiY = bRadY+deltaPx;
       spotMask = ones(roiY,roiX);
    end

    for i = 1:nDet
          if (y(i)< size(im,1)-roiY && y(i)> roiY && x(i)<size(im,2)-roiX && x(i)> roiX)
            % obtain the spot with given dimensions to calculate average
            % intensity, etc
            spotIm = im(y(i)- bRadY:y(i)+bRadY, x(i)- bRadX:x(i)+bRadX);
            ampS(i,1) = mean(spotIm(:));  % the average amplitude per spot
            ampMax(i,1) = max(spotIm(:)); % the maximum amplitude
            imF(y(i)-roiY:y(i)+roiY,x(i)-roiX:x(i)+roiY) = spotMask; 
          end 
    end
   imBg = (1 - imF).*im;
   bgInt = mean(imBg(imBg~=0)); 
end