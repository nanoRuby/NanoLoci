classdef Image
    methods(Static)
        %% This function prompots user selection window for either one or 
        % multiple images-----------------------------------------------%%
        % output: image or imagedataset path and filename ---------------%
        function filename = ReadPath(imageNum)
            switch imageNum
                case 'one'
                    filespec = {'*.jpg;*.tif;*.png;*.gif','All Image Files'};
                    [f,p] = uigetfile(filespec);
                case 'multi'
                    [f,p] = uigetfile('*.tif', 'Chose images to load:'...
                    ,'MultiSelect','on');
            end

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
        %% ============= Imports TIFF image/images to a 4D array ======== %
        % the dimensions are stored in the following order: x,y,t, batch nr
        % input:    image path and filename(s) ---------------------------%
        %------------------------Outputs----------------------------------%
        % imFl:     image array ------------------------------------------%
        % imAv:     time averaged image array ----------------------------%
        %=================================================================%
        function [imFl, imAv] = Import(imagefile)
            if size(imagefile,1) > 1     
                image1 = Tiff_read(imagefile{1});
                nbBatch = length(imagefile);
                nbFrames = size(image1,3);
                imageStack = zeros([size(image1,1) size(image1,2) nbFrames nbBatch]);
                    
                if size(image1,3) > 1 
                    imageStack(:,:,:,1) = image1;
                else
                    imageStack(:,:,1,1) = image1;
                end
                    
                for k = 2 : nbBatch
                    im = Tiff_read(imagefile{k});
                    if size(im,3) > 1 
                        imageStack(:,:,:,k) = im;
                    else
                        imageStack(:,:,1,k) = im;
                    end
                end
                    
            else
                imageStack = Tiff_read(imagefile{1});
            end
            imFl = double(imageStack);
            imAv = mean(imFl,3);
        end
        %% ============= Visualize first or current frame of the image == %
        function Update(imagefile, currIm, UIAxes1, imAll)
             if nargin == 4
                im1 = imAll(:,:,1,1);
                colormap(UIAxes1,'gray')
                imagesc(UIAxes1,im1)
                axis(UIAxes1,[1 size(im1,2) 1 size(im1,1)])
                splitPath = regexp(imagefile{1},filesep,'split'); 
            elseif nargin == 3
                splitPath = regexp(imagefile{currIm},filesep,'split');
            end      

            imTitle = splitPath{end};
            UIAxes1.Title.Interpreter = 'none';
            UIAxes1.Title.String = imTitle;
        end
    end
end