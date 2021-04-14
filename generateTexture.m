imgsize = [200 200];    % 图像大小
f1 = 0.02; % 低频频率
f2 = 0.4;  % 高频频率
T = 1/f2;  % 高频的周期
% 分辨率，采样率 T 越大采样率越低
[X, Y] = meshgrid(linspace(0,50*T,200), linspace(0,50*T,200));  
% 通过余弦函数生成固定频率的信号，在XY两个方向上叠加
Z = cos(2*pi*f1*X) .* cos(2*pi*f1*Y) + 2*cos(2*pi*f2*X).*cos(2*pi*f2*Y);
% 将图案数值归一化，以显示图像
normalZ = normalize(Z(:), 'range');
Z = reshape(normalZ, imgsize);
testTexture1 = Z;
figure;
imshow(Z);
title("纹理原图");
save testTexture1.mat testTexture1