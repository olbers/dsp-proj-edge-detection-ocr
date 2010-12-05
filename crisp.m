% "Crispens" the image by adding the edges to the original image
% Note that the crispened image will be a grayscale image
% Input: 
%   -the source image: an m by n [by d] matrix. If it is RBG (ie d=3) it will
%   be converted to grayscale (m by n)
%   -the matrix of edges, either binary or grayscale
%   -the "crispening" factor - the degree by which the image will appear to
%   be sharpened
% Output:
%   -m by n matrix of enhanced edges computed for each pixel


function [crisp_image] = crisp(source_image, edge_image, a)

if length(size(edge_image)) == 3
    source_image = rgb2gray(source_image);
end

crisp_image = source_image + a * 1 * edge_image;

%[h,w] = size (edge_image);
%crisp_image = zeros(h,w);

%for i= 1:h
%    for j = 1:w
%        crisp_image(i,j) =(t_image(i,j)+a*0.1*new_image(i,j));
%    end
%end
