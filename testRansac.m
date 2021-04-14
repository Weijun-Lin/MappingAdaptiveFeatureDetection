% ---------- 测试dlt 的 ransac ---------------

I1 = imread(file_img1);
I2 = imread(file_img2);

% 读取 ASIFT 匹配点
filename = 'matchings.txt';
fileid = fopen(filename);
data = textscan(fileid, '%f %f %f %f', 'HeaderLines', 1);
fclose(fileid);
data = cell2mat(data);
% 切分为两组匹配点
match1 = data(:, [1 2]);
match2 = data(:, [3 4]);
% 绘制 ransac 之前的
figure;
subplot(2, 1, 1);
% ax = axes;
showMatchedFeatures(I1, I2, match1, match2, 'montage');
title("ASIFT Matches Before RANSAC");
% 绘制 ransac 之后的
% 制行 ransacc 
[H, inlierIdx] = ransacForDLT(data, 15, 0.3);
% 切分为两组对应点
data = data(inlierIdx, :);
match1 = data(:, [1 2]);
match2 = data(:, [3 4]);
subplot(2, 1, 2);
% ax = axes;
showMatchedFeatures(I1, I2, match1, match2, 'montage');
matchings = data;
save matchings.mat matchings
title("ASIFT Matches After RANSAC");