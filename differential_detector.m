% Doesn't work properly yet...
function [edge_image] = differential_detector(original_image)

if length(size(original_image)) == 3
    original_image = rgb2gray(original_image);
end

% Smoothen first
Gaussian_Kernel = (1/159)*[2 4 5 4 2;4 9 12 9 4;5 12 15 12 5;4 9 12 9 4;2 4 5 4 2];
%original_image = convn(original_image, Gaussian_Kernel, 'same');

global smoothed_image;
original_image = smoothed_image;
Kx = [-1/2 0 1/2];
Ky = Kx';
Kxx = [1/4 -1/2 1/4]*4.0;
Kxy = [-1 0 1;0 0 0;1 0 -1]/4.0;
Kyy = Kxx';
Kxxy = conv2(Kx,Kxy);
Kxyy = conv2(Kx,Kyy);
Kxxx = conv2(Kx,Kxx);
Kyyy = conv2(Ky,Kyy);

Lx = convn(original_image, Kx, 'same');
Ly = convn(original_image, Ky, 'same');
Lxx = convn(original_image, Kxx, 'same');
Lxy = convn(original_image, Kxy, 'same');
Lyy = convn(original_image, Kyy, 'same');
Lxxy = convn(original_image, Kxxy, 'same');
Lxyy = convn(original_image, Kxyy, 'same');
Lxxx = convn(original_image, Kxxx, 'same');
Lyyy = convn(original_image, Kyyy, 'same');

% Closer this is to zero -> better chance of being an edge
d1 = (Lx.^2) .* Lxx + 2*Lx.*Ly.*Lxy + (Ly.^2) .* Lyy;

d2 = (Lx.^3) .* Lxxx + 3*(Lx.^2).*Ly.*Lxxy + 3*Lx.*(Ly.^2).*Lxyy + (Ly.^3).*Lyyy;
[m,n] = size(original_image);
edge_image = zeros(m,n);
for i=1:size(original_image(:))
    if d2(i) < 0 && abs(d1(i)) <= 0.0001
        edge_image(i) = 1.0;
    elseif d2(i) < 0
        edge_image(i) = 0;
    elseif abs(d1(i)) <= 0.1
        edge_image(i) = 0;
    else
        edge_image(i) = 0.0;
    end
end
%edge_image = convn(original_image, Gaussian_Kernel, 'same');

end