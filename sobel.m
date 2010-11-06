 function edge_image = sobel(sample)

% Need to convolve original with two different kernels
Kx = [[-1 0 1];[-2 0 2];[-1 0 1]];
Ky = [[-1 -2 -1];[0 0 0];[1 2 1]];
    
Gx = convn(sample, Kx, 'same');
Gy = convn(sample, Ky, 'same');

edge_image = sqrt(Gx.*Gx + Gy.*Gy);
max_val = max(edge_image(:));
edge_image = edge_image ./ max_val;

end