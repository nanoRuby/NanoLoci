%% Converts detected localizations into a table format
function [detCurr, bgInt] = toTable(im, LocsFit, sigma, i)
%% Inputs and Outputs:
    % Inputs:
    %   - im: Image data
    %   - LocsFit: Detected localization data
    %   - sigma: the window size, according to which amplitudes are
    %   calculated
    %   - i: Frame number
    %
    % Outputs:
    %   - detCurr: Table containing the current frame's localization data
    %   - bgInt: Background intensity

    %% Check if there are detected localizations and get values
    if ~isempty(LocsFit)
        % x and y locations
        x = LocsFit(:, 1);          y = LocsFit(:, 2);
        % standard deviations in x and y
        sigma_x = LocsFit(:, 5);    sigma_y = LocsFit(:, 6);
        % number of photons and background photons of the detection
        n_ph = LocsFit(:, 3);       n_bg = LocsFit(:, 4);
        % Calculate average and maximum intensity and background intensity
        [int_av, int_max, ~, bgInt] = amp_calc(im, x, y, sigma, sigma);
        frame = repmat(i, size(x));
        % Handle outliers from DBSCAN
        try
            outlier_db = LocsFit(:, 9);
        catch
            outlier_db = ones(size(x));
        end
        % Handle outliers from Voronoi
        try
            outlier_vor = LocsFit(:, 10);
        catch
            outlier_vor = ones(size(x));
        end
        
        % Create table of localization data for the current frame
        detCurr = table(frame, x, y, sigma_x, sigma_y, n_ph, n_bg, ...
                         int_av, int_max, outlier_db, outlier_vor);
    else
        % Return empty arrays if there are no localizations
        detCurr = [];
        bgInt = [];
    end
end
