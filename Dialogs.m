classdef Dialogs
    methods(Static)
        %% Fourier Enhancement Dialog App
        function [imOut, imOut1] = ChooseDomain(images)
            fieldnames = {'imCurrent','BrCurrent'};
            namelist = {'Fluorescence Image', 'Brightfield Image'};
            if (all(isfield(images,fieldnames)) && ~isempty(images.BrCurrent))
                [indx,~] = listdlg('PromptString',{'Select the domain to analyze:.',...
                    'Only one image can be selected at a time.',''},...
                    'SelectionMode','single','ListString',namelist);
            elseif (all(isfield(images,fieldnames)) && isempty(images.BrCurrent))
                indx = 1;
            elseif isfield(images,fieldnames{1,1}) && ~isfield(images,fieldnames{1,2})
                indx = 1;
            end
            %  if fluorescence image is selected, output only that
            if indx == 1
                imOut  = images.(fieldnames{1,indx});
                %  if brightfield is selected fluorescence is still needed
                imOut1 = [];
            else
                imOut  = images.(fieldnames{1,1});
                imOut1 = images.(fieldnames{1,2});
            end
        end

        %% Db Scan Dialog App
        function [spots, indx] = DbScan(app)
            try
                if size(app.images.imCurrent,3) > 1
                    nbFr = app.SliderFr.Limits(2);
                else
                    nbFr = 1;
                end
                [indx,~] = listdlg('PromptString',{'Select frames from the ' ...
                    'current batch:'},...
                    'ListString',string([1:nbFr]));
                spots.stat = [];
                spots.fr = [];
                spots.idx = indx'; % selected 
                for i = 1:length(indx)
                    sFr = app.det.LocFinal{indx(i),app.SliderBatch.Value};
                    spots.stat = cat(1,spots.stat,sFr);
                    spots.fr   = cat(1,spots.fr,repmat(indx(i),size(sFr,1),1));
                end
            catch
                uialert(app.UIFigure, ['Localization and fitting not performed...' ...
                    ' Please execute Localize and Fit beforehand. '], 'Error');
            end

        end

    function [spots, indx] = spotStatistics(app)
            try
                if size(app.images.imCurrent,3) > 1
                    nbFr = app.SliderFr.Limits(2);
                else
                    nbFr = 1;
                end
                [indx,~] = listdlg('PromptString',{'Select frames from the ' ...
                    'current batch:'},...
                    'ListString',string([1:nbFr]));
                spots.stat = [];
                spots.fr = [];
                spots.idx = indx'; % selected frames to do statistics
                for i = 1:length(indx)
                    sFr = app.det.LocFinal{indx(i),app.SliderBatch.Value};
                    spots.stat = cat(1,spots.stat,sFr);
                    spots.fr   = cat(1,spots.fr,repmat(indx(i),size(sFr,1),1));
                end
                spots.batch = app.SliderBatch.Value;
            catch
                uialert(app.UIFigure, ['Localization and fitting not performed...' ...
                    ' Please execute Localize and Fit beforehand. '], 'Error');
            end

        end

        function [idOutliers, h1,h2] = dbscanButton(xSig,ySig,fl,eps,num,UIAxes)
            idOutliers = dbscan([rescale(xSig),rescale(ySig),rescale(fl)],eps,num);
            h1 = scatter3(UIAxes,xSig,ySig,fl);
            hold(UIAxes,'on')
            ind = idOutliers==-1;
            h2 = scatter3(UIAxes,xSig(ind),ySig(ind),fl(ind));
            legend(UIAxes,'Inliers','Outliers','Location','southeast',"AutoUpdate","off");
            hold(UIAxes,'off')
        end

        function removeOutliers(idOutliers,frame,batch,fit,app)
            spotsCell = matrixToCell(idOutliers,frame,batch,fit);
            for i = 1:length(frame)
                app.mainApp.det.Fit{frame(i), batch}(:,9) = spotsCell{i};
            end
        end

        %% Voronoi Dialog App
        function removeOutliersVoronoi(idOutliers,frame,batch,app)
            app.mainApp.det.Fit{frame,batch}(:,10) = idOutliers;
        end
        
        %% Reorder the selected spots over frames
        function spotsCell = updateSelected(idOutliers,frame,batch,fit)
            spotsCell = cell(size(fit));
            spots = matrixToCell(idOutliers,frame,batch,fit);
            for i = 1:length(frame)
                spotsCell{frame(i), batch} = spots{i};
            end
        end
    end
end

  function spotsCell = matrixToCell(idOutliers,frame,batch,fit)
    nbFr = length(frame);
    sizeDet = zeros(1,nbFr);
        for i = 1:nbFr
            sizeDet(i) = size(fit{frame(i),batch},1);
        end
   spotsCell = mat2cell(idOutliers,sizeDet);
 end