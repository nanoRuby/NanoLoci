% Initialize: Class containing static methods for managing application
    % initialization, state, parameters, and image processing.
    %
    %   Static Methods:
    %       - getCurrentState: Get the current state of the application.
    %       - getCurrentParams: Get the current parameters.
    %       - resetParams: Reset image and detection data structures.
    %       - resetAll: Reset all application parameters.
    %       - getCurrentImage: Get the current image for processing.
    %       - getCurrentFrame: Get the current frame and batch of the image.
    %
    %   Each method provides functionality for specific tasks related to
    %   initializing and managing the application's state, parameters, and
    %   image processing.
classdef Initialize
    methods(Static)
        function state = getCurrentState(app)
            if app.UseTheEnhancedImage.Enable
                state.enhanced = app.UseTheEnhancedImage.Value;
            else
                state.enhanced = 0;
            end

            if app.ImporttheROI.Enable
                state.roi = app.ImporttheROI.Value;
            else
                state.roi = 0;
            end

            state.showLoc      = app.ShowTheDetections.Value;
            state.showFilt     = app.ShowTheFiltered.Value;
            state.averagedTime = app.UseTimeAveragedImage.Value;
            state.vor          = 0; % initialize this as 0, change to one when performed voronoi
            state.db           = 0; % dbscan performance
        end
        %% gets the current state of the parameters
        function loc = getCurrentParams(app, loc)
            if nargin < 2
                loc.gradThresh   = app.GradientThreshold.Value;
                loc.gradWindow   = app.GradientWindow.Value;
                loc.filterMethod = app.Denoising.Value;
                loc.filterSize   = app.BorderSize.Value; 
                loc.fitMethod    = app.Fit.Value;
            else
                loc.gradThresh   = app.GradientThreshold.Value;
                loc.gradWindow   = app.GradientWindow.Value;
            end
        end

        %% === Resets the image and detections datastructures === %%
        function [images,detections] = resetParams(images,detections,var)
            switch nargin
                case 0
                   images = [];
                   detections = []; 
                case 3
                    if var == 1
                        detections = [];
                    end
            end
        end
        function resetAll(app)
            app.ImporttheROI.Enable =0;
            app.UseTheEnhancedImage.Enable = 0;
            app.ImporttheROI.Enable = 0;
            app.images = [];
            app.det = [];
            app.results = [];
            app.SliderFr.Value = 1;
            app.SliderBatch.Value = 1;
        end
        %% update the current images to be processed based on the selected
        % parameters ==================================================== %
        function [imCurr, imCurrBr] = getCurrentImage(loc, images,var)
            %% ----- Assign the current main (fluorescence) image ----- %%
            switch loc.enhanced
                case 0
                    if loc.averagedTime == 0
                        imCurr = images.imAll; % the original raw image
                    elseif loc.averagedTime == 1
                        imCurr = mean(images.imAll,3);
                    end
                case 1
                  if var == 1
                    if loc.averagedTime == 0
                        imCurr = images.imAll; % the original raw image
                    elseif loc.averagedTime == 1
                        imCurr = mean(images.imAll,3);
                    end
                  else
                    if loc.averagedTime == 0
                        imCurr = images.imEnhanced; % the enhanced image
                    elseif loc.averagedTime == 1
                        imCurr = mean(images.imEnhanced,3);
                    end
                 end
            
            end

%            if loc.roi == 1
%                imCurr = imfuse(imCurr,images.imROI,'blend','Scaling','independent');
%            end

            %% ==== Assign the current brightfield image to compare ==== %%
            if isfield(images,'BrAll')
                if loc.averagedTime == 0
                    if size(images.BrAll,3) == size(images.imAll,3)
                        imCurrBr = images.BrAll;
                    else
                        imCurrBr = mean(images.BrAll,3);
                    end
                else
                    imCurrBr = mean(images.BrAll,3);
                end
            else
                imCurrBr = [];
            end
        end
        %% Get current frame and batch of the image to transfer between 
        %  functions and apps -------------------------------------------%
        function [currentFr,fr,bt] = getCurrentFrame(imAll,Slider1,Slider2)
            % get the correct frame
            if Slider1.Enable
                fr    = Slider1.Value;
            else
                fr = 1;
            end
            % get the correct batch number
            if Slider2.Enable
                bt    = Slider2.Value;
            else
                bt = 1;
            end
            
            if ~isempty(imAll)
                if numel(size(imAll))>2
                    currentFr = imAll(:,:,fr,bt);
                else
                    currentFr = imAll(:,:,fr,1);
                end
            else
                currentFr = [];
            end

        end
    end
end