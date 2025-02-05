% Canny Edge Detector

% Input:
%   -the image: an m by n [by d] matrix. If it is RBG (ie d=3) it will
%   be converted to grayscale (m by n)
%   -minimum threshold value: choose low threshold such that irrelevant
%   information can be discarded
%   -maximum threshold value: choose high threshold such that important information is not lost
% Output:
%   -m by n matrix of binary values
function [edge_image] = Canny_detector(smoothed_image, kernel_size, min_thresh, max_thresh)

if length(size(smoothed_image)) == 3
    smoothed_image = rgb2gray(smoothed_image);
end
[h,w] = size (smoothed_image);                      % save height and width
d_x = zeros(h,w);                                   % location for derivatives of x and y
d_y = zeros(h,w);

kernel_size = kernel_size - 2;

% maximum non-suppressiom
gradient = kernel_operator(smoothed_image, 'Sobel', 'full');
non_max = gradient;
for r = 1+ceil(kernel_size/2):h-ceil(kernel_size/2)
    for c = 1+ceil(kernel_size/2):w-ceil(kernel_size/2)
        % quantize
        if(d_x(r,c) == 0)
            tangent = 5;
        else
            tangent = d_y(r,c)/d_x(r,c);
        end
        if (-0.4142<tangent && tangent <= 0.4142)
            if (gradient(r,c)<gradient(r,c+1)||gradient(r,c)<gradient(r,c-1))
                non_max(r,c) = 0;
            end
        end
        if (0.4142<tangent && tangent <= 2.4142)
            if (gradient(r,c)<gradient(r-1,c+1)||gradient(r,c)<gradient(r+1,c-1))
                non_max(r,c) = 0;
            end
        end
        if (abs(tangent)>2.4142)
            if (gradient(r,c)<gradient(r-1,c)||gradient(r,c)<gradient(r+1,c))
                non_max(r,c) = 0;
            end
        end
        if (-2.4142<tangent && tangent <= -0.4142)
            if (gradient(r,c)<gradient(r+1,c+1)||gradient(r,c)<gradient(r-1,c-1))
                non_max(r,c) = 0;
            end
        end
    end
end
post_hysteresis = non_max;
for r = 1+ceil(kernel_size/2):h-ceil(kernel_size/2)
    for c = 1+ceil(kernel_size/2):w-ceil(kernel_size/2)
        if (post_hysteresis(r,c)>=max_thresh)
            post_hysteresis(r,c) = 1;
        end
        if (post_hysteresis(r,c)<max_thresh && post_hysteresis(r,c)>=min_thresh)
            post_hysteresis(r,c) = 2;
        end
        if (post_hysteresis(r,c)<min_thresh)
            post_hysteresis(r,c) = 0;
        end
    end
end
v = 1;
while (v == 1)
    v = 0;
    for r = 1+ceil(kernel_size/2):h-ceil(kernel_size/2)
        for c = 1+ceil(kernel_size/2):w-ceil(kernel_size/2)
            if (post_hysteresis(r,c)>0)
                if (post_hysteresis(r,c)==2)
                    if (post_hysteresis(r-1,c-1)==1||post_hysteresis(r-1,c)==1||post_hysteresis(r-1,c+1)==1||post_hysteresis(r,c-1)==1||post_hysteresis(r,c+1)==1||post_hysteresis(r+1,c-1)==1||post_hysteresis(r+1,c)==1||post_hysteresis(r+1,c+1)==1)
                        post_hysteresis(r,c)=1.0;
                        v = 1;
                    end
                end
            end
        end
    end
end
for r = 1+ceil(kernel_size/2):h-ceil(kernel_size/2)
    for c = 1+ceil(kernel_size/2):w-ceil(kernel_size/2)
        if (post_hysteresis(r,c) ~= 1.0)
            post_hysteresis(r,c) = 0.0;
        end
    end
end

kernel_size = kernel_size + 2;

offset = ceil(kernel_size/2);
edge_image = post_hysteresis(offset:end-offset-1,offset:end-offset-1);




