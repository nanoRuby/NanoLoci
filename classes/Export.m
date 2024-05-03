classdef Export
    methods(Static)
        function toWorkspace(app)
            %% Exports the images and detected locations to the workspace
            assignin('base','images',app.images)
            try
                assignin('base','detections',app.det.Fit)
                assignin('base','intensities',app.intensities)
                assignin('base','filename',app.paths)
                assignin('base','detectionsPx',app.det.Loc)
            catch
            end
            
        end
        %% =============== Save detections to a file=====================%%
        % ---------------- INPUT------------------------------------------%
        %imAll:     Raw images--------------------------------------------%
        %LocsFit:   Localizations in all frames and images----------------%
        %filename:  image directory, where the detection matrix will be---%
        %saved -----------------------------------------------------------%
        %avgOn:     if off (case 0), the localizations and intensities are
        %           written for each frame in each image in batch---------%
        %avgOn:     if on (case 1), 2 tables are written: 1) localizations%
        %are obtained from averaged image, but intensity values are-------%
        %calculated for every image frame 2) localizations and intensity--%
        %values are obtained from only time averaged image----------------%

        function toFile(imAll,LocsFit,filename,sigma,avgOn)
           numIm = size(imAll,4);
           numFr = size(imAll,3);
           det_batch = zeros(numIm,4);
           
           switch avgOn
               case 0 % if image is not time averaged
                  for j = 1:numIm
                      detAll = cell(numFr,1);
                      det_t_avg = zeros(numFr,5);
                      for i = 1:numFr
                          im = imAll(:,:,i,j);
                          [det, bgInt] = toTable(im,LocsFit{i,j},sigma,i);
                          if ~isempty(det)
                          det_t_avg(i,:) = [length(~isnan(det.int_av)),sum(det.int_av,'omitnan'),...
                              mean(det.int_av,'omitnan'),bgInt,i];
                           det_t_avg_v(i,:) = [length(~isnan(det.int_av(det.outlier_vor ==1))),sum(det.int_av(det.outlier_vor ==1),'omitnan'),...
                              mean(det.int_av(det.outlier_vor ==1),'omitnan'),bgInt,i];
                          end
                          detAll{i,1} = det;
                      end
                      detAll = vertcat(detAll{:});
                      det_t_avg = table(det_t_avg(:,1),det_t_avg(:,2),...
                          det_t_avg(:,3),det_t_avg(:,4), det_t_avg(:,5));
                      det_t_avg_v = table(det_t_avg_v);
                      det_t_avg.Properties.VariableNames = {'Number','Sum Intensity','Mean Intensity',...
                          'Image background','Frame'};
                      %%
                      [filepath,name,~] = fileparts(filename{j});
                      tableNm = fullfile(filepath,name);
                      writetable(detAll,strcat(tableNm,'.xlsx'),'Sheet',1);
                      writetable(det_t_avg,strcat(tableNm,'.xlsx'),'Sheet',2);
                      writetable(det_t_avg_v,strcat(tableNm,'.xlsx'),'Sheet',3);
                      %writetable(detAll,strcat(tableNm,'.csv'));
                      %writetable(det_t_avg,strcat(tableNm,'avg_per_frame','.csv'));
                      if size(imAll,3) == 1
                          det_batch(j,:)=[length(detAll.int_av),sum(detAll.int_av),...
                              mean(detAll.int_av),bgInt];  
                      end
                      detAvg     = table(det_batch(:,1),det_batch(:,2),det_batch(:,3),det_batch(:,4));
                      detAvg.Properties.VariableNames = {'Number','Sum Intensity','Mean Intensity',...
                       'Image background'};
                      if det_batch~=0
                         writetable(detAvg,strcat(tableNm,'_avg_batch','.csv'))
                      end
                  end
                 
                  
               case 1
                   for j = 1:numIm
                       imAvg = mean(imAll(:,:,:,j),3);
                       [detAll, bgInt] = toTable(imAvg,LocsFit{1,j},sigma,1); 
                       int_av_all  = zeros(length(detAll.x),numFr);
                       int_max_all = zeros(length(detAll.x),numFr);
                       for i=1:numFr
                           im = imAll(:,:,i,j);
                           [int_av_all(:,i), int_max_all(:,i),~,~]  = ...
                               amp_calc(im,detAll.x,detAll.y,sigma,sigma);
                       end
                       [filepath,name,~] = fileparts(filename{j});
                       tableNm = fullfile(filepath,name);
                       writetable(detAll,strcat(tableNm,'_time_series','.xlsx'),'Sheet',1);
                       frame = (1:numFr)'; average_intensity = int_av_all';
                       av_int = table(frame,average_intensity);
                       writetable(av_int,strcat(tableNm,'_time_series','.xlsx'),'Sheet',2)

                       det_batch(j,:)=...
                          [length(detAll.int_av),sum(detAll.int_av),mean(detAll.int_av),bgInt];
                       detAvg     = table(det_batch(:,1),det_batch(:,2),det_batch(:,3),det_batch(:,4),string(name));
                       detAvg.Properties.VariableNames = {'Number','Sum Intensity','Mean Intensity',...
                          'Image background','Name'};
                   end
                   writetable(detAvg,strcat(tableNm,'_time_averaged_batch','.csv'))

           end
        end
        function toROIfl(im,det,wind,fname,frame)
        %% ============== Input ======================================== %%
        % im:   the current raw image ------------------------------------%
        % det:  detections in the given frame ----------------------------%
        % wind: the window size of the detection filter ------------------%
        % fname: image name ----------------------------------------------%
        % frame: the current frame of the image
        [~,~,imF,~] = amp_calc(im,det(:,1),det(:,2),wind,wind);
        [filepath,name,~] = fileparts(fname);
        bwName = fullfile(filepath,strcat(name,'_frame',num2str(frame),'.tif'));
        imwrite((imF),bwName);
        end

    end
end


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