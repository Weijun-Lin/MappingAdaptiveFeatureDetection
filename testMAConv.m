load transimgs.mat

H = inv(TForm1.T');
T = inv(H);
src = transimg1;
% [h, w, ~] = size(src);
% t = T * [1;1;1];
% t = t ./ t(3);
% t = ceil(t);
% transimg1(t(2), t(1))
I = getMAConvImg(src, H, originSize, 5);
figure;
imshow(I);