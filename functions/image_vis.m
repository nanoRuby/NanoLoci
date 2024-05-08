%% Visualizes an image in a specified UIAxes

function image_vis(imagefile, currIm, UIAxes1, imAll)
% Inputs:
%   - imagefile: Path(s) of the image(s)
%   - currIm: Current image index if multiple images are provided
%   - UIAxes1: Handle to the UIAxes for displaying the image
%   - imAll: Array containing all images (optional)
%
% Output:
%   - None

    %% Visualize images
    % Check the number of input arguments
    if nargin == 4
        im1 = imAll(:, :, 1, 1);    % If all images are provided, display the first image
        colormap(UIAxes1, 'gray')   % Set colormap to gray
        imagesc(UIAxes1, im1)       % Display image in the specified UIAxes
        axis(UIAxes1, [1 size(im1, 1) 1 size(im1, 2)])  % Set axis limits
        splitPath = regexp(imagefile{1}, filesep, 'split'); 
    elseif nargin == 3
        % If only one image is provided, display the specified image
        splitPath = regexp(imagefile{currIm}, filesep, 'split');
    end
    
    % Display title
    imTitle = splitPath{end};
    UIAxes1.Title.Interpreter = 'none';
    UIAxes1.Title.String = imTitle;
end
