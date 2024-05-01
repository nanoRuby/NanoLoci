function [filtered] = wavelet_filter(original,bordObj)

%bordObj = 7; % the amount of pixels on the border which need to be set to 0.

filtered = zeros(size(original,1),size(original,2),size(original,3),'double');

% initialize wavelet coefficients (undecimated wavelet transform using cubic
% B-spline function)
H0 = 3/8;
H1 = 1/4;
H2 = 1/16;

% the filter matrices are obtained from wavelet coefficients
filter_1 = [H2,H1,H0, H1, H2]' * [H2,H1,H0, H1, H2];
filter_2 = [H2,0,H1, 0, H0,0,H1, 0, H2]' * [H2,0,H1,0,H0,0 H1,0, H2];

for j = 1:size(original,3)
    I = double(original(:,:,j));
    %I = medfilt2(I,[2 2]);
    Coef1 = conv2(I,filter_1,'same');       % the first coefficient map
    Coef2 = conv2(Coef1,filter_2,'same');   % the second coefficient map 
    
    % the second wavelet map is the filtered image and is obtained as the
    % difference of coefficient maps.
    Wavelet2 = (Coef1 - Coef2); 
    
    % the borders need to be set to zeros to exclude the resulting weird
    % effects near image borders.
    Wavelet2(1:bordObj,:) = 0;
    Wavelet2((end - bordObj + 1):end,:) = 0;
    Wavelet2(:,1:bordObj) = 0;
    Wavelet2(:,(end - bordObj + 1):end) = 0;
    Wavelet2(Wavelet2 < 0) = 0;
    filtered(:,:,j) = Wavelet2;
end
end