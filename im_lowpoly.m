function [] = im_lowpoly(img, threshold, edg_amount, mid_amount)
%  converts an image to low-poly style by delaunay triangulation
% Input:
%   img        = img to be processed
%   threshold  = threshold of grayscale
%   edg_amount = fraction of points on the edge to use (integers greater
%   than 1, the smaller the number, the finer the triangulation)
%   mid_amount = number of points in the middle of image, the greater the
%   number, the finer the triangulation
% Output: None
% 
% Example: useage
% img = imread('tyrion.jpg');
% im_lowpoly(img, 40, 2, 3000);
%
% Zhonglue Hu, Texas Tech University, zhonglue.hu@ttu.edu

imshow(img);
title('original image');
% sobel detection only handles gray image
% if the image is rgb, covert to gray
if size(img, 3) == 3
    % img is color
    img_gray = rgb2gray(img);
%     img_gray = adaptivethreshold(img_gray, 7, 0.03, 0);
%     imshow(img_gray);
else
    img_gray = img;
%     img_gray = adaptivethreshold(img, 7, 0.03, 0);
%     imshow(img_gray);
end

% edge detection, use sobel detector, prewitt also works

edge_sobel = edge(img_gray, 'sobel');

[height, length] = size(img_gray);

% select the points on the edge, and has gray scale larger than given 
% threshold
edg_prod = uint8(edge_sobel).*img_gray;
[col, row] = find(edg_prod(:, :) > threshold);
edge_pt = cat(2, col, row);
% this edg_rand is subject to change
edg_rand = round(numel(edge_pt(:,1))/edg_amount);

% randomly select edg_rand pts from the edge_sobel
[edge_height, edge_length] = size(edge_pt);
rng('shuffle');
% selected edge points
edge_slt = edge_pt(randperm(edge_height, edg_rand),:);
% add points not in edge

mid_slt = rand(mid_amount, 2);

mid_slt(:,1) = round(mid_slt(:,1)*(height - 1) + 1);
mid_slt(:,2) = round(mid_slt(:,2)*(length - 1) + 1);
pt_set = [edge_slt;mid_slt];
% add four corners
corners = [1, 1;height, 1;1, length; height, length];
pt_set = [pt_set; corners];


figure
imshow(img_gray);
hold on

tri = delaunay(pt_set(:,2), pt_set(:,1));
triplot(tri, pt_set(:,2), pt_set(:,1));

% get color
% if the image is color, then it is n by 3 matrix
color = zeros(numel(tri)/3,numel(img(1, 1, :)));

% get the coordinates of mid points in the triangle
mid_point = zeros(numel(tri)/3, 2);
temp = 1:numel(tri)/3;
mid_point(temp, 1) = round(sum(reshape(pt_set(tri(temp,:), 1), [], 3), 2)/3);
mid_point(temp, 2) = round(sum(reshape(pt_set(tri(temp,:), 2), [], 3), 2)/3);

% get the color of the mid points and use them for filling the triangles
for i = 1:numel(tri)/3
    color(i, :) = img(mid_point(i,1), mid_point(i,2),:);
    patch(pt_set(tri(i,1:3), 2), pt_set(tri(i,1:3), 1), ...
    color(i,:)/256, 'EdgeColor','none');
end
title('low poly image');
end