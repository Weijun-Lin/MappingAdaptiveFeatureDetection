% 此文件为实验
% 将点图、模拟图使用局部单应变换后生成任意映射的图
% 现在已经有最初始的图I1 MovingDLT变换后的 I2
% I1 -> I2: H
% 当前的目的是将 I2 使用映射适应卷积抗混叠处理为 I1

load pointImg.mat
load matchinges.mat
load testTexture1.mat
src = pointImg;
tarImg = movingDLTTrans(src, matchinges);
tarImgGauss = imgaussfilt(tarImg, 2);
load DLTTransParas.mat
invH_all = calInvHAll(H_all);

[h, w] = size(pointImg);

I = zeros(h, w);
theta = 2;
for i = 1:w
    for j = 1:h
        x0 = [i;j];
        [r,c] = getCubesIndex(w, h, C1, C2, i, j);
        I(j,i) = getValByMAConv(tarImg, invH_all{r,c}, x0, theta);
        % I(j,i) = getValWithoutMAConv(tarImgGauss, H_all{r,c}, x0);
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


% 获取模拟图上某个点对应的坐标
function [r, c] = getCubesIndex(w, h, C1, C2, x, y)
    delta_w = w / C2;
    delta_h = h / C1;
    c = floor((x-1) / delta_w);
    r = floor((y-1) / delta_h);
    if c == 0
        c = 1;
    end
    if r == 0
        r = 1;
    end
end

function val = getValWithoutMAConv(srcImg, invH, x0)
    x0_ = invH * [x0;1];
    x0_ = x0_ ./ x0_(3);
    val = Bilinear(srcImg, x0_, 0);
end