% 此文件为实验
% 将点图、模拟图使用局部单应变换后生成任意映射的图
% 现在已经有最初始的图I1 MovingDLT变换后的 I2
% I1 -> I2: H
% 当前的目的是将 I2 使用映射适应卷积抗混叠处理为 I1

load matchings.mat
src = imread("./CAR5.png");
% src = imread("./CAR5.png");
src = rgb2gray(src);
src = im2double(src);

tarImg = movingDLTTrans(src, matchings);

theta = 2;
[h, w] = size(tarImg);
scales = 1;
S = [scales 0 0;0 scales 0;0 0 1];
S_ = [1/scales 0 0;0 1/scales 0;0 0 1];
ImgBig = imresize(src, scales);
ImgGauss = imgaussfilt(ImgBig, theta);
invH_all = calInvHAll(H_all);
load DLTTransParas.mat

I = zeros(h, w);
size(I)
for i = 15:314
    if mod(i, 50) == 0
        i
    end
    for j = 630:1003
        pos = mapping{i,j};
        if isempty(pos)
            continue;
        end
        x0 = [j;i];
        % 映射适应卷积
        I(i,j) = getValByMAConv(ImgBig, H_all{pos(1),pos(2)}*S_, x0, theta, S*invH_all{pos(1),pos(2)});
        % 直接高斯
        % I(i,j) = getValWithoutMAConv(tarImgGauss, S*invH_all{pos(1),pos(2)}, x0);
    end
end

figure;
imshow(I);


function invH_all = calInvHAll(H_all)
    [r, c] = size(H_all);
    invH_all = cell(r,c);
    for i = 1:r
        for j = 1:c
            invH_all{i,j} = inv(H_all{i,j});
        end
    end
end

function val = getValWithoutMAConv(srcImg, invH, x0)
    x0_ = invH * [x0;1];
    x0_ = x0_ ./ x0_(3);
    val = Bilinear(srcImg, x0_, 0);
end