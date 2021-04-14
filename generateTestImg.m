% 生成测试图像

% 生成标准点图测试图像
s = 200; % 图像大小
p_num = 6;  % 平均生成 p_num*p_num 规模的点
p_size = 9; % 点的大小
pointImg = zeros(s);
tar_coord = linspace(1, s, p_num+2);
tar_coord = tar_coord(2:p_num+1);
[X,Y] = meshgrid(tar_coord, tar_coord);
for i = 1:p_num
    for j = 1:p_num
        coord = [X(i, j) Y(i, j)];
        coord = floor(coord - p_size/2);
        pointImg(coord(1):coord(1)+p_size-1, coord(2):coord(2)+p_size-1) = 1;
    end
end
save pointImg.mat pointImg
imshow(pointImg);