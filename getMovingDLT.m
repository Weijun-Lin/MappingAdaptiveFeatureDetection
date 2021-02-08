% ------ moving dlt interface ---------------
% 对给定的匹配点数据集，以及 x_* 返回其对应的 DLT
% matchinges: 匹配点已经数据归一化
% x: x_* 的横坐标
% y: x_* 的纵坐标
% sigma_para: 权值函数的尺度因子
% lambda_para: 对极远点的补偿阈值
function [H] = getMovingDLT(matchinges, W)
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
    [~, ~, V] = svd(diag(W)*A);
    H = reshape(V(:,end), [3 3])';
end