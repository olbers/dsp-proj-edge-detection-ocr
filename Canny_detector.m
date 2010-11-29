% Canny Edge Detector
function [edge_image] = Canny_detector(smoothed_image, sigma, min_thresh, max_thresh)
% These parameters now passed to function from gui
%sigma = 1.4;        % default sigma
%max_thresh = 1;     % default maximum threshold
%min_thresh = 0.04;  % default minimum threshold

 if length(size(smoothed_image)) == 3
    smoothed_image = rgb2gray(smoothed_image);
end
    [h,w] = size (smoothed_image);                      % save height and width
    d_x = zeros(h,w);                                   % location for derivatives of x and y
    d_y = zeros(h,w);
    
    % Gausian kernel
  %  kernel_size = 6*sigma+1;
  %  adjust = ceil(kernel_size/2);
  %  Gaus_x = zeros(kernel_size, kernel_size);
  %  Gaus_y = zeros(kernel_size, kernel_size);
    
    % create Gaussian based on sigma
  %  for i = 1:kernel_size
  %      for j = 1:kernel_size
  %          Gaus_x(i,j) = -((j-((kernel_size-1)/2)-1)/(2*pi*sigma^3))*exp(-((i-((kernel_size-1)/2)-1)^2 + (j-((kernel_size-1)/2)-1)^2)/(2*sigma^2));
  %      end
  %  end
  %  for i = 1:kernel_size
  %      for j = 1:kernel_size
  %          Gaus_y(i,j) = -((i-((kernel_size-1)/2)-1)/(2*pi*sigma^3))*exp(-((i-((kernel_size-1)/2)-1)^2 + (j-((kernel_size-1)/2)-1)^2)/(2*sigma^2));
  %      end
  %  end
    
    gradient = zeros(h,w);
    non_max = zeros(h,w);
    post_hysteresis = zeros(h,w);
    
    kernel_size = 6*sigma+1;
    kernel_size = 1; % Note: using this because kernel_operator() is already clipping the outer pixels...will want to change this
    % image derivatives
    for r = 1+ceil(kernel_size/2):h-ceil(kernel_size/2)
        for c = 1+ceil(kernel_size/2):w-ceil(kernel_size/2)
            ref_r = r-ceil(kernel_size/2);
            ref_c = c-ceil(kernel_size/2);
            for row = 1:kernel_size
                for col = 1:kernel_size
                    d_x (r,c) = d_x(r,c) + smoothed_image(ref_r+row-1, ref_c+col-1);
                end
            end
        end
    end
    for r = 1+ceil(kernel_size/2):h-ceil(kernel_size/2)
        for c = 1+ceil(kernel_size/2):w-ceil(kernel_size/2)
            ref_r = r-ceil(kernel_size/2);
            ref_c = c-ceil(kernel_size/2);
            for row = 1:kernel_size
                for col = 1:kernel_size
                    d_y (r,c) = d_y(r,c) + smoothed_image(ref_r+row-1, ref_c+col-1);
                end
            end
        end
    end
    % find gradient based on the x and y derivatives
    for r = 1+ceil(kernel_size/2):h-ceil(kernel_size/2)
        for c = 1+ceil(kernel_size/2):w-ceil(kernel_size/2)
            ref_r = r-ceil(kernel_size/2);
            ref_c = c-ceil(kernel_size/2);
            gradient(r,c) = sqrt((d_x(r,c)^2)+d_y(r,c)^2);
        end
    end
    % maximum non-suppression
    
    % Above gradient code doesn't work correctly. For now find gradient
    % with sobel operator
    gradient = kernel_operator(smoothed_image, 'Sobel');
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
            if (-2.4142<tangent && tangent <= 0.4142)
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
                             post_hysteresis(r,c)=1;
                             v = 1;
                         end
                     end
                 end
             end
         end
     end
      for r = 1+ceil(kernel_size/2):h-ceil(kernel_size/2)
             for c = 1+ceil(kernel_size/2):w-ceil(kernel_size/2)
                 if (post_hysteresis(r,c) == 2)
                     post_hysteresis(r,c) = 0;
                 end
             end
      end
      
edge_image = sign(round(post_hysteresis));



            
    