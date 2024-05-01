%% This function prompots user selection window for either one or multiple images%%
% output: image or imagedataset path and filename
function filename = image_import(imageNum)
    switch imageNum
        case 'one'
            filespec = {'*.jpg;*.tif;*.png;*.gif','All Image Files'};
            [f,p] = uigetfile(filespec);
        case 'multi'
            [f,p] = uigetfile('*.tif', 'Chose images to load:'...
                ,'MultiSelect','on');
    end

    % check the pathname to be sure that the user didn't cancel the
    % dialog window
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