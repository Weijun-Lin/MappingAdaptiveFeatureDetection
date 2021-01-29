% 将匹配点数据归一化并包装成行向量为匹配点数据的新数据
function [data, T1, T2] = warpNormalizeMatchData(match_data)
    % 将数据切分为两组对应点
    points1 = match_data(:, [1, 2]);
    points2 = match_data(:, [3, 4]);
    [T1, points1] = getNormalizeData(points1(:, 1), points1(:, 2));
    [T2, points2] = getNormalizeData(points2(:, 1), points2(:, 2));
    data = [points1([1 2], :)' points2([1 2], :)'];
end