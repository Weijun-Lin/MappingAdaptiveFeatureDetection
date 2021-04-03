% 生成测试图像

% 1. 生成点图
s = 200;
p_num = 3;
p_size = 15;
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