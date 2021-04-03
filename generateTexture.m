% 图像大小 h, w
% 只取得三个周期结果
imgsize = [200 200];
f1 = 0.02;
f2 = 0.45;
[X, Y] = meshgrid(1:imgsize(2), 1:imgsize(1));
Z = cos(2*pi*f1*X) .* cos(2*pi*f1*Y) + 2*cos(2*pi*f2*X).*cos(2*pi*f2*Y);
normalZ = normalize(Z(:), 'range');
Z = reshape(normalZ, imgsize);
testTexture1 = Z;
figure;
imshow(Z);
save testTexture1.mat testTexture1