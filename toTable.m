function [detCurr, bgInt] = toTable(im,LocsFit,sigma,i)
if ~isempty(LocsFit)
     x    = LocsFit(:,1);   sigma_x = LocsFit(:,5);      
     y    = LocsFit(:,2);   sigma_y = LocsFit(:,6);
     n_ph = LocsFit(:,3);   n_bg    = LocsFit(:,4);
     [int_av, int_max,~,bgInt]  = amp_calc(im,x,y,sigma,sigma);
     frame = repmat(i,size(x));
     %% dbscan outliers
     try
        outlier_db = LocsFit(:,9);
     catch
        outlier_db = ones(size(x));
     end
     %% voronoi outliers
     try
        outlier_vor = LocsFit(:,10);
     catch
        outlier_vor = ones(size(x));
     end
     detCurr = table(frame,x,y,sigma_x,sigma_y,n_ph,n_bg,...
                              int_av,int_max,outlier_db, outlier_vor);
      else
        detCurr = []; bgInt = [];
    end
end