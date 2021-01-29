% ----------- 获取数据的归一化矩阵 ---------
% 这里参考 https://www.cnblogs.com/wangguchangqing/p/4414892.html 的归一化方法
% x,y: x, y 数据向量
% T: 归一化矩阵 3*3，格式如下 s 为尺度 u,v 为均值
% s | 0 | -su
% 0 | s | -sv
% 0 | 0 | 1
% data: 归一化后的数据格式为：
% x1 x2 ...
% y1 y2 ...
% 1  1  ...
function [T, data] = getNormalizeData(x, y)
    % 处理为行向量
    x = reshape(x, 1, []);
    y = reshape(y, 1, []);
    u = mean(x);
    v = mean(y);
    n = length(x);
    s = sqrt(2)*n/sum(((x-u).^2 + (y-v).^2).^0.5);
    T = [s 0 -s*u; 0 s -s*v; 0 0 1];
    data = [x;y;ones(size(x))];
    data = T*data;
end