classdef Statistics
    methods (Static)
        function p = initializeParams(loc)
            num = size(loc,1);
            p.sigX   = loc(:,5); % Gaussian std in x direction
            p.sigY   = loc(:,6); % Gaussian std in y direction
            p.sigAvg = (p.sigX + p.sigY)/2; % Gaussian mean direction
            p.avgI   = loc(:,7); % average pixel intensity
            p.maxI   = loc(:,8); % maximum pixel intensity per detection
            ratio  = ones(num,2); % a/b ratio for eccentricity
            for k = 1:num
                big   = max(p.sigX(k), p.sigY(k));
                sml   = min(p.sigX(k), p.sigY(k));
                ratio(k,1) = sml/big;
                if p.sigX(k) > p.sigY(k)
                    ratio(k,2) = -1;
                end
            end
            p.ecc   =  sqrt(1 - ratio(:,1).^2);
        end

        function [plt,var] = updateScatter(app)
            names = app.XAxis.Items;
            [var.x, xnm] = switchVar(app.XAxis.Value,names,app.params);
            [var.y, ynm] = switchVar(app.YAxis.Value,names,app.params);
            [var.z, znm] = switchVar(app.ZAxis.Value,names,app.params);
            if isempty(var.z)
                hold(app.UIAxes,'off');
                plt = scatter(app.UIAxes,var.x,var.y);
                view(app.UIAxes,[0 90])
                xlabel(app.UIAxes,xnm)
                ylabel(app.UIAxes,ynm)
                hold(app.UIAxes,'off');
            else
                hold(app.UIAxes,'off');
                plt = scatter3(app.UIAxes,var.x,var.y,var.z);
                xlabel(app.UIAxes,xnm)
                ylabel(app.UIAxes,ynm)
                zlabel(app.UIAxes,znm)
                hold(app.UIAxes,'off');
            end
        end

        function updateHists(app)
            names = app.XAxis.Items;
            [var.x, xnm] = switchVar(app.XAxis.Value,names,app.params);
            [var.y, ynm] = switchVar(app.YAxis.Value,names,app.params);
            [var.z, znm] = switchVar(app.ZAxis.Value,names,app.params);
            plotHist(app.UIAxesH1,var.x, xnm, app.indBr,app.numBins.Value)
            plotHist(app.UIAxesH2,var.y, ynm, app.indBr,app.numBins.Value)
            try
               plotHist(app.UIAxesH3,var.z, znm, app.indBr,app.numBins.Value) 
            catch
            end
        end
     
        function idOutliers = dbScanButton(app)
            x = rescale(app.curVar.x);
            y = rescale(app.curVar.y);
            if ~isempty(app.curVar.z)
                z = rescale(app.curVar.z);
                idOutliers = dbscan([x,y,z],app.epsilon.Value,app.minPoints.Value);
                ind = idOutliers==-1;
                scatter3(app.UIAxes,...
                    app.curVar.x,app.curVar.x,app.curVar.z);
                hold(app.UIAxes,'on');
                scatter3(app.UIAxes,...
                    app.curVar.x(ind),app.curVar.x(ind),app.curVar.z(ind));
                 legend(app.UIAxes,'Inliers','Outliers','Location','southeast',"AutoUpdate","off");
                hold(app.UIAxes,'off');
            else
                idOutliers = dbscan([x,y],app.epsilon.Value,app.minPoints.Value);
                ind = idOutliers==-1;
                scatter(app.UIAxes,app.curVar.x,app.curVar.y);
                 hold(app.UIAxes,'on');
                scatter(app.UIAxes,app.curVar.x(ind),app.curVar.y(ind));
                 legend(app.UIAxes,'Inliers','Outliers','Location','southeast',"AutoUpdate","off");
                hold(app.UIAxes,'off');
            end
        end
    end
end

function [var, nm] = switchVar(axisValue,varNames,param)
    if axisValue == 0
        var = []; nm = [];
    else
        fn  = fieldnames(param);
        var = param.(fn{axisValue});
        nm  = varNames{axisValue};
    end
end

function plotHist(Axes,var, vnm, ind,num)
    hold(Axes,'off');
    xlabel(Axes,vnm)
    if num ==0
        histogram(Axes,var);
        hold(Axes,'on');
        histogram(Axes,var(ind),'FaceColor','cyan','FaceAlpha',0.4);
    else
        histogram(Axes,var,num);
        hold(Axes,'on');
        histogram(Axes,var(ind),num,'FaceColor','cyan','FaceAlpha',0.4);
    end
    hold(Axes,'off');
end