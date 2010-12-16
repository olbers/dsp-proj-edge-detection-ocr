% Only 4 very primitive features at the moment. Needs a bunch more before
% it's of any use

% Returns a column of feature outputs for a single image
function data = compute_features(source_im)

[im skeleton] = preprocess_image(source_im);
data = [sum(skeleton(:));
    length(bwboundaries(im));
    longest_vert_line(skeleton);
    longest_horiz_line(skeleton);
    num_horiz_lines(skeleton);
    num_vert_lines(skeleton);
    template1(skeleton);
    template2(skeleton);
    num_lines(skeleton);
    x_symmetry(im)];

    function num_pts = x_symmetry(im)
        [m,n] = size(im);
        values = zeros(1,n);
        for avg=1:n
            tries = int32(max(0, min(avg-1, n - avg)));
            num_pts = 0;
            for i=1:m
                for j=1:tries
                    if sign(im(i,avg+j)) == sign(im(i,avg-j)) == 1.0
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

    function count = num_horiz_lines(curimage)
        pix_needed = 8;
        mat = [0 -5 -5 -5 -5 -5 -5 0;
            1 1 1 1 1 1 1 1;
            0 -5 -5 -5 -5 -5 -5 0];
        xc = xcorr2(curimage, mat);
        xc = sign(xc - pix_needed + 0.1)*0.5 + 0.5;
        count = sum(sign(sum(xc')));
    end

    function count = num_vert_lines(curimage)
%         pix_needed = 12;
%         mat = ones(20,2);
%         xc = xcorr2(curimage, mat);
%         xc = sign(xc - pix_needed + 0.1)*0.5 + 0.5;
%         count = sum(xc(:));
        count = num_horiz_lines(curimage');
    end

    % Specifically for differentiating C's and G's
    function count = template1(curimage)
        mat = [1 1 1 1 1 1 1 0 0;
            -5 -5 -5 -5 -2 0 1 -5 -5;
            -5 -5 -5 -5 -5 -5 10 -5 -5;
            -5 -5 -5 -5 -5 -5 10 -5 -5;
            -5 -5 -5 -5 -5 -5 10 -5 -5];
        count = 30.0*max(max(xcorr2(curimage(12:end,12:end), mat)));
    end

    % Separate L's from shapes with T like structure
    function count = template2(curimage)
        mat = [0 0 0 0 1 0 0 0 0;
            0 0 0 0 1 0 0 0 0;
            0 0 0 0 1 0 0 0 0;
            -5 -5 -5 -5 1 1 1 1 1];
        count = max(max(xcorr2(curimage(12:end,12:end), mat)));
    end

    % TODO doesn't work that reliably
    function count = num_lines(curimage)
        [H,theta,rho] = hough(curimage,'Theta',-90:5:89);
        
        P = houghpeaks(H,5,'NHoodSize', [5 5], 'threshold',ceil(0.6*max(H(:))));
        lines = houghlines(curimage,theta,rho,P,'FillGap',10,'MinLength',8);
        
        count = 0;
        for k = 1:length(lines)
            if isfield(lines(k),'point1')
                count = count + 1;
            end
        end
    end

end