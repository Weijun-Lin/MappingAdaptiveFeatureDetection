% ---------- 测试dlt 的 ransac ---------------

% 使用 ASIFT 获取图像对应匹配点
file_img1 = "./CAR5.png";
file_img2 = "./CAR6.png";
% file_img1 = "./out3.png";
% file_img2 = "./LEO2.png";
% file_img1 = "./XMAS5.tif";
% file_img2 = "./XMAS6.tif";
% file_img1 = "./4.jpg";
% file_img2 = "./5.jpg";

% file_img1 = "./P1010517.JPG";
% file_img2 = "./P1010520.JPG";
% file_img1 = "./DSC02933.JPG";
% file_img1 = "./out3.png";
% file_img2 = "./DSC02934.JPG";
imgOutVert = '1_350111imgOutVert.png';
imgOutHori = '1_35011imgOutHori.png';
matchings = 'C0_C2_35011_matchings.txt';
keys1 = 'keys1.txt';
keys2 = 'keys2.txt';
flag_resize = 1;
demo_ASIFT(file_img1, file_img2, imgOutVert, imgOutHori, matchings, keys1, keys2, flag_resize);

I1 = imread(file_img1);
I2 = imread(file_img2);

% 读取 ASIFT 匹配点
filename = matchings;
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
title("ASIFT Matches After RANSAC");