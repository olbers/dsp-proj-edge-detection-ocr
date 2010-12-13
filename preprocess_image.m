% Given an image, finds the skeleton and returns it in a 32x32 binary image
function [newim] = preprocess_image(source_im)
clc;

crop_size = [32 32];


% Strategy: find extrema in each direction, crop, then resize
resized_im = imresize(crop(source_im),crop_size,'nearest');

% Now thin the image out (ie find the skeleton)
newim = skel(resized_im);

    function cropped_im = crop(im)
        [m,n] = size(im);
        first_i = m;
        last_i = m;
        first_j = n;
        last_j = n;
        for k=1:m
            if sum(im(k,:)) > 0.0
                first_i = min(first_i, k);
                last_i = k;
            end
        end
        for j=1:n
            if sum(im(:,j)) > 0.0
                first_j = min(first_j, j);
                last_j = j;
            end
        end
        
        cropped_im = im(first_i:last_i,first_j:last_j);
    end
end