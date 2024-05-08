%% This function prompts the user to select one or multiple images

function filename = image_import(imageNum)
%% Inputs and Outputs:
% Inputs:
%   - imageNum: 'one' for selecting one image, 'multi' for selecting multiple images
%
% Output:
%   - filename: Path(s) of the selected image(s)
% output: image or imagedataset path and filename

%% % Prompt user based on input
    switch imageNum
        case 'one'
            filespec = {'*.jpg;*.tif;*.png;*.gif','All Image Files'};
            [f,p] = uigetfile(filespec);
        case 'multi'
            [f,p] = uigetfile('*.tif', 'Chose images to load:'...
                ,'MultiSelect','on');
    end

    % Check if pathname is valid (user didn't cancel dialog window)
    if ischar(p)
    % if only one image is imported
        if ischar(f)
            filename = {[p,f]};
            % if multiple images are selected
        else
            NbIm = length(f);
            filename = cell(NbIm,1);
            for k = 1:NbIm
                filename{k} = fullfile(p, f{k});
            end 
       end
   end

end