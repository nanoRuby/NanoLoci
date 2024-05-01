classdef SliderControl
    methods(Static)
        function updateLimits(num,Slider)
            % when new image is imported, update slider limits
            if num > 1
                Slider.Enable = 'on';
                Slider.Limits(2) = num;
                Slider.MajorTicks = 1:1:num;
            else
                Slider.MajorTicks = [];
                Slider.Enable = 'off';
            end
        end

        function currentValue = tickValues(Source)
            % discretize slider controls
            currentValue = Source.Value;
            % determine which discrete option the current value is closest to.
            [~, minIdx] = min(abs(currentValue - Source.MajorTicks(:)));
            % move the slider to that option
            Source.Value = Source.MajorTicks(minIdx);
            % Override the selected value if you plan on using it within this function
            currentValue = Source.MajorTicks(minIdx);
        end

        function TimeAveragedOn(Slider,num,timeAvg)
                if timeAvg == 0
                    SliderControl.updateLimits(num,Slider)
                elseif timeAvg == 1
                    Slider.MajorTicks = [];
                    Slider.Enable = "off";
                end
        end

        function pageUpdate(app, var)
            switch var
                case 0
                    app.Domain.Visible = 1;
                    if isfield(app.images,'BrAll')
                        if size(app.images.BrCurrent,3) == size(app.images.imCurrent,3)
                            num = size(app.images.imCurrent,3);
                            SliderControl.updateLimits(num,app.SliderFr);
                        else
                            SliderControl.updateLimits(1,app.SliderFr);
                        end
                    end
                case 1
                    app.Domain.Visible = 0;
                    if isfield(app.images,"imCurrent")
                        num = size(app.images.imCurrent,3);
                    else
                        num = size(app.images.imAll,3);
                    end
                    SliderControl.updateLimits(num,app.SliderFr);
            end
        end
    end
end