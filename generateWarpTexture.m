% 理论验证阶段，自己设置图像扭曲匹配点

load pointImg.mat
% load 

% 将原图划分为 4*4 个点
[h, w] = size(pointImg);
x = linspace(1, w, 4)';
y = linspace(1, h, 4)';
p = [x;x;x;x];
p(:, 2) = 0;
p(1:4, 2) = y(1);
p(5:8, 2) = y(2);
p(9:12, 2) = y(3);
p(13:16, 2) = y(4);

figure;
imshow(pointImg);
hold on
scatter(p(:,1), p(:,2));
axis([-250 450 -250 450]);
axis on

% 按行获取对应点
p_ = ginput(16);
% p_ = [-58.7780   91.3941;
%     89.2427  -21.3425;
%     140.8778 -119.4492;
%     -53.6145  136.1446;
%     76.3339  116.3511;
%     254.4750    1.8933;
%     -47.5904  206.7126;
%     122.8055  263.5112;
%     309.5525  298.7952;];
scatter(p_(:,1), p_(:,2));

matchinges = [p p_];

save matchinges.mat matchinges