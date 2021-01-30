% ---------- 测试dlt 的 ransac ---------------
% 读取图像
I1 = imread("./CAR5.tif");
I2 = imread("./CAR6.tif");
% 读取 ASIFT 匹配点
filename = "./C0_C2_35011_matchings.txt";
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
[H, inlierIdx] = ransacForDLT(data);
% 切分为两组对应点
data = data(inlierIdx, :);
match1 = data(:, [1 2]);
match2 = data(:, [3 4]);
subplot(2, 1, 2);
% ax = axes;
showMatchedFeatures(I1, I2, match1, match2, 'montage');
title("ASIFT Matches After RANSAC");