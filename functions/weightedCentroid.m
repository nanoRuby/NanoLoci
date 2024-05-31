
function LocsFit = weightedCentroid(im,Locs,winSize)
    
    threshold = multithresh(im,2); % otsu thresholding to binarize the image
    numSpots = size(Locs,1);
    LocsFit = zeros(numSpots,8); % the size of this matrix is defined to have the same
    im1 = padarray(im,[winSize winSize],'replicate');
    % size as the Gaussian Fit
    for i = 1:numSpots
        im0 = im1(Locs(i,2):Locs(i,2)+2*winSize,Locs(i,1):Locs(i,1)+2*winSize);
        results = regionprops(im0>threshold(2),im0,'WeightedCentroid','MajorAxisLength','MinorAxisLength','Area');
        if ~isempty(results)
            [~,ind] = (max([(results.Area)]));
            LocsFit(i,1:2) = results(ind).WeightedCentroid+Locs(i,:)-winSize-1;
            LocsFit(i,3) = max(im0(:));
            LocsFit(i,5) = results(ind).MajorAxisLength/2;
            LocsFit(i,6) = results(ind).MinorAxisLength/2;
        end
    end
end