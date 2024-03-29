% ------- 直接线性变换函数接口 ---------
% 接收参数为 匹配 点集
% matchinges: N * 4 大小的矩阵，每行为 x1 y1 x2 y2 格式的匹配对，并且已经归一化处理
% 函数返回单应矩阵
% H: 3*3 的单应矩阵
% 使用 H 单应矩阵变换后的坐标注意还需要齐次化
function H = dlt(matchinges)
    % 将数据切分为两组对应点
    points1 = matchinges(:, [1, 2]);
    points2 = matchinges(:, [3, 4]);
    % 拓展为齐次坐标
    points1(:, 3) = 1;
    points2(:, 3) = 1;
    % 此时的点数据为列向量
    points1 = points1';
    points2 = points2';
    n = size(points1, 2);
    A = zeros(2*n, 9);
    for i = 1:n
        x_vec = points1(:, i)';
        x_ = points2(1, i);
        y_ = points2(2, i);
        A(2*i-1, :) = [zeros(1,3), -x_vec, y_*x_vec];
        A(2*i, :) = [x_vec, zeros(1,3), -x_*x_vec];
    end
    [~, ~, V] = svd(A);
    H = reshape(V(:,end), [3 3])';
end