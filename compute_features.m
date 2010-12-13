% Only 4 very primitive features at the moment. Needs a bunch more before
% it's of any use

% Returns a column of feature outputs for a single image
function data = compute_features(im)

    data = [x_symmetry(im) y_symmetry(im) longest_vert_line(im) longest_horiz_line(im)]';

    function num_pts = x_symmetry(im)
        [m,n] = size(im);
        values = zeros(1,n);
        for avg=1:n
            tries = int32(max(0, min(avg-1, n - avg)));
            num_pts = 0;
            for i=1:m
                for j=1:tries
                    if sign(im(i,avg+j)) == sign(im(i,avg-j))
                        num_pts = num_pts + 1;
                    end
                end
            end
            values(avg) = num_pts;
        end
        
        num_pts = max(values);
    end

    function num_pts = y_symmetry(im)
        num_pts = x_symmetry(im');
    end

    function longest = longest_vert_line(curimage)
        [m,n] = size(curimage);
        imsign = sign(curimage);
        longest = 0;
        for j=1:n
            start = 0;
            last = 0;
            cursign = 0;
            for i=1:m
                if imsign(i,j) == cursign
                    last = i;
                else
                    if cursign == 1
                        longest = max(longest, last - start);
                    end
                    start = i;
                    cursign = imsign(i,j);
                end
            end
            if imsign(i,j) == cursign
                last = i;
            end
            if cursign == 1
                longest = max(longest, last - start);
            end
        end
    end

    function longest = longest_horiz_line(curimage)
        longest = longest_vert_line(curimage');
    end

end