% Perform one of the kernel operators 
% Input: 
%   -the image: an m by n [by d] matrix. If it is RBG (ie d=3) it will
%   be converted to grayscale (m by n)
%   -the operator type: either 'Prewitt' or 'Sobel' or 'Roberts Cross' or
%   'Scharr'
% Output:
%   -m by n matrix of magnitudes of gradients computed for each pixel
%   -m by n matrix of directions of gradients computer for each pixel
function [edge_image, angle_image] = kernel_operator(original_image, operator_type, outputsizing)

if nargin < 3
    outputsizing = 'same';
end

if length(size(original_image)) == 3
    original_image = rgb2gray(original_image);
end

if strcmp(operator_type, 'Prewitt')
    Kx = [[-1 0 1];[-1 0 1];[-1 0 1]];
    Ky = [[-1 -1 -1];[0 0 0];[1 1 1]];
elseif strcmp(operator_type, 'Sobel')
    Kx = [[-1 0 1];[-2 0 2];[-1 0 1]];
    Ky = [[+1 +2 +1];[0 0 0];[-1 -2 -1]];
elseif strcmp(operator_type, 'Roberts Cross')
    Kx = [[1 0];[0 -1]];
    Ky = [[0 1];[-1 0]];
elseif strcmp(operator_type, 'Scharr')
    % Note: Added constant 1/3 to sort of normalize: because of the
    % difference in values compared to the other kernel operators, the 
    % magnitude of this gradient will be much larger . This is a problem 
    % for when adjusting the threshold in the GUI
    Kx = 1/3*[[3 10 3]; [0 0 0]; [-3, -10, -3]];
    Ky = 1/3*[[3 0 3]; [10 0 -10]; [3 0 -3]];
else
    errordlg(sprintf('Error: %s is not a valid type', operator_type));
    edge_image = 0;
    angle_image = 0;
    return
end

Gx = convn(original_image, Kx, outputsizing);
Gy = convn(original_image, Ky, outputsizing);

edge_image = sqrt(Gx.*Gx + Gy.*Gy);
angle_image = atan2(Gy, Gx);

end