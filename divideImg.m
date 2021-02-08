% 将图片划分为 C1(row) * C2(col) 个块 返回中心点以及每个块四角顶点
% imgsize: 图像大小（行（高）y，列（宽）x）
% centers, cubes 格式均为 meshgrid 的 cell
% centers, cubes: cell{0} = X ; cell{1} = Y
% centers 和 cubes 对应关系为：
% centers(y,x) => 左上角为 cubes(y,x);

function [centers, cubes] = divideImg(imgsize, C1, C2)
    divide_Y = linspace(1, imgsize(1), C1+1);
    divide_X = linspace(1, imgsize(2), C2+1);
    [x, y] = meshgrid(divide_X, divide_Y);
    cubes = {x y};
    % 中心就是再次切分然后每两个点取一个
    center_Y = linspace(1, imgsize(1), C1*2 + 1);
    center_X = linspace(1, imgsize(2), C2*2 + 1);
    center_Y = center_Y(2:2:end);
    center_X = center_X(2:2:end);
    [x, y] = meshgrid(center_X, center_Y);
    centers = {x y};
end