filename = './4.JPG';
img = double(imread(filename));
theta = 0.67*pi;
% 绕原点旋转矩阵
T = [2 0 0;0 2 0;0 0 1];
T1 = [cos(theta) sin(theta) 0;
      -sin(theta) cos(theta) 0;
      0 0 1];
T1 = T1*T;
imgsize = size(img);
w = imgsize(2);
h = imgsize(1);
% matlab 坐标从 1 开始有点烦
bound = [1 1+w 1+w 1;
         1 1 1+h 1+h;
         1 1 1 1];
%  获取变换后图片的大小和左上角顶点在原坐标系的坐标
boundWarp = T1 * bound;
% 正无穷方向取整,避免越界,这里加1稳妥一点
newW = ceil(max(boundWarp(1,:)) - min(boundWarp(1,:))) + 1;
newH = ceil(max(boundWarp(2,:)) - min(boundWarp(2,:))) + 1;
vex = [min(boundWarp(1,:)) min(boundWarp(2,:))];
% 平移到新图坐标系的矩阵为
T2 = [1 0 -vex(1)+1;0 1 -vex(2)+1;0 0 1];
% 最后的变换为
T = T2*T1;
% 变换后的图片矩阵
imgsize2 = imgsize;
imgsize2([1 2]) = [newH newW];
% 上面这样利于单通道/多通道的情况
img2 = zeros(imgsize2);
img3 = img2;

% 前向映射
tic
% tempTrans(i,j) 为矩阵,存储分配到这个像素的原图像素值以及其权值
% 用于记录每一个点所分配的权重
tempTrans = cell(imgsize2([1 2]));
for i = 1:imgsize(1)
    for j = 1:imgsize(2)
        coord = T*[j;i;1];
        x = coord(1); y = coord(2);
        s = fix(coord(1)); t = fix(coord(2));
        k = [s+1-x x-s t+1-y y-t];
        p = img(i,j,:); p = p(:);
        % 双线性插值的方法分配
        tempTrans{t, s}(:, end+1) = [p;k(1)*k(3)];
        tempTrans{t, s+1}(:, end+1) = [p;k(2)*k(3)];
        tempTrans{t+1, s}(:, end+1) = [p;k(1)*k(4)];
        tempTrans{t+1, s+1}(:, end+1) = [p;k(2)*k(4)];
    end
end
% 归一化,否则会造成某些地方很突兀(叠加)
for i = 1:imgsize2(1)
    for j = 1:imgsize2(2)
        temp = tempTrans{i,j};
        len = size(temp,2);
        if len == 0
            continue;
        end
        % 归一化数据,也就是重新分配权值
        sum_w = sum(temp(end,:));
        for k = 1:len
            img2(i,j,:) = img2(i,j,:) + reshape(temp(end, k)/sum_w * temp(1:end-1,k), 1, 1, 3);
        end
    end
end
fprintf("前向映射耗费的总时间:");
toc

figure;
subplot(1,2,1);
imshow(uint8(img2));
title("Forward Mapping");

% 后向映射
tic
for i = 1:imgsize2(1)
    for j = 1:imgsize2(2)
        % 逆映射回去,得到坐标
        coord = T\[j;i;1];
        img3(i, j, :) = backward(img, coord);
    end
end
fprintf("后向映射耗费的总时间:");
toc

subplot(1,2,2);
imshow(uint8(img3));
title("Backward Mapping");

% 后向映射到原图,获取对应的值
function pixel_value = backward(srcimg, srccoord)
    x = srccoord(1);
    y = srccoord(2);
    % 不再原图上的点返回黑色
    pixel_value = 0;
    [r, c, ~] = size(srcimg);
    % 坐标在图像外的返回 0 
    if x > c || y > r || x < 1 || y < 1
        return;
    end
    % 现在坐标已经在图像内部、或者边界，然后处理边界（图像右和下）避免插值时数组边界访问异常
    if x == c || y == r
        pixel_value = srcimg(x, y, :);
        return;
    end
    % 此时依据四个点做双线性插值 首先对坐标向零取整
    s = fix(srccoord(1));
    t = fix(srccoord(2));
    k = [s+1-x x-s t+1-y y-t];
    pixel_value = k(1)*k(3)*srcimg(t,s,:) + k(2)*k(3)*srcimg(t, s+1,:) +  ...
                  k(1)*k(4)*srcimg(t+1,s,:) + k(2)*k(4)*srcimg(t+1,s+1,:);
end