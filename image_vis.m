function image_vis(imagefile, currIm, UIAxes1, imAll)
    if nargin == 4
        im1 = imAll(:,:,1,1);
        colormap(UIAxes1,'gray')
        imagesc(UIAxes1,im1)
        axis(UIAxes1,[1 size(im1,1) 1 size(im1,2)])
        splitPath = regexp(imagefile{1},filesep,'split'); 
    elseif nargin == 3
        splitPath = regexp(imagefile{currIm},filesep,'split');
    end      
    % Display title
    imTitle = splitPath{end};
    UIAxes1.Title.Interpreter = 'none';
    UIAxes1.Title.String = imTitle;
end