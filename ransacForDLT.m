% 对匹配的数据进行 RANSAC ransac 使用 DLT 模型
function [H, inlierIdx] = ransacForDLT(match_data)
    % 首先将数据归一化
    [data, T1, T2] = warpNormalizeMatchData(match_data);
    fitFcn = @dlt;
    % 构成模型需要的点 至少需要四个点对
    samplesize = 6;
    % 看作内点的最大偏移量 这里应该为距离的平方，和 distFcn 对应
    maxdistance = 0.1;
    [H, inlierIdx] = ransac(data, fitFcn, @distFcn, samplesize, maxdistance);
    points1 = data(:, [1, 2])
    points2 = data(:, [3, 4])
    t = H * ([points1';ones(1,8)]);
    t = (t./(t(3,:)))'

end


function distances = distFcn(model, data)
    % 将数据切分为两组对应点
    points1 = data(:, [1, 2]);
    points2 = data(:, [3, 4]);
    % 拓展为齐次坐标
    points1(:, 3) = 1;
    % 单应变换后的点，还需要齐次化
    deal_point = model*points1';
    deal_point = deal_point ./ deal_point(3, :);
    % 获得处理后点的 XY 向量，为列向量
    deal_x = deal_point(1, :)';
    deal_y = deal_point(2, :)';
    % 目标的 XY 列向量
    x = points2(:, 1);
    y = points2(:, 2);
    % 然后计算距离 目标值和结果值的误差距离
    deal_x-x
    distances  = (deal_x - x).^2 + (deal_y - y).^2;
    % distances
    sum(distances)
    % size(distances)
end
