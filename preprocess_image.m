% Given an image, finds the skeleton and returns it in a 32x32 binary image
function [newim skeleton] = preprocess_image(source_im)
crop_size = [20 20];

% Try to get rid of some serifs -- kill pixels with only 1 white neighbor
[m,n] = size(source_im);
mark_for_delete = zeros(m,n);
for i=1:m
    for j=1:n
        if source_im(i,j) == 1
            if sum(sum(source_im(i-1:i+1,j-1:j+1))) == 2
                mark_for_delete(i,j) = 1.0;
            end
        end
    end
end
source_im = source_im - mark_for_delete;


% Strategy: find extrema in each direction, crop, then resize
newim = imresize(crop(source_im),crop_size,'nearest');

% Now thin the image out (ie find the skeleton)
skeleton = skel(newim);

    function cropped_im = crop(im)
        [m,n] = size(im);
        first_i = m;
        last_i = m;
        first_j = n;
        last_j = n;
        for kk=1:m
            if sum(im(kk,:)) > 0.0
                first_i = min(first_i, kk);
                last_i = kk;
            end
        end
        for jj=1:n
            if sum(im(:,jj)) > 0.0
                first_j = min(first_j, jj);
                last_j = jj;
            end
        end
        
        cropped_im = im(first_i-1:last_i+1,first_j-1:last_j+1);
    end
end