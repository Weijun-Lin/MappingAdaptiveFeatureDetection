clear
load pointImg.mat
load testTexture1.mat
% srcImg = testTexture1;
srcImg = pointImg;

[h, w] = size(srcImg);
in_points = [1 w w 1
            1 1 h h];
out_points1 = [80 180 200 0;
              1 -100 200 150];
% out_points1 = [36.1359  286.4508  212.9639   70.1237;
% 15.8337   14.0885  288.6566  283.4212];


TForm1 = fitgeotrans(in_points',out_points1','projective');
H = TForm1.T;
in_mid = in_points';
in_mid(:,3) = 1;
out_points = in_mid * H;
out_points = out_points ./ out_points(:, 3);
min_x = min(out_points(:,1));
min_y = min(out_points(:,2));
T = [1 0 -min_x+1;0 1 -min_y+1;0 0 1]';
S = [4 0 0;0 4 0; 0 0 1]';
H = H*T*S;
out_points = in_mid * H;
out_points = out_points ./ out_points(:,3);
TForm1 = projective2d(H);
transimg1 = myimwarp(srcImg, H', 0, false, []);
% size()
% transimg1 = imwarp(srcImg, TForm1, 'FillValues', 1);
invI = invtransWidthConv(transimg1, H', size(srcImg), true);
figure;
I = imgaussfilt(srcImg, 1);
imshow(I);
title("原图高斯模糊");
figure
imshow(transimg1);
title("扭曲图");
figure;
imshow(invI);
title("高斯后映射");
figure
imshow(invtransWidthConv(transimg1, H', size(srcImg), false))
title("直接映射");



% TForm2 = fitgeotrans(in_points',out_points2','projective');
% H = TForm2.T;
% out_points = in_mid * H;
% out_points = out_points ./ out_points(:, 3);
% min_x = min(out_points(:,1));
% min_y = min(out_points(:,2));
% T = [1 0 -min_x;0 1 -min_y;0 0 1]';
% H = H*T;
% transimg2 = imwarp(pointImg, projective2d(H), 'FillValues', 1);
% figure
% imshow(transimg2);
% figure;
% imshow(invtransWidthConv(transimg2, H));
originSize = size(srcImg);

save transimgs.mat transimg1 TForm1 originSize

function I = invtransWidthConv(src, H, imgsize, flag)
    invH = inv(H);
    % TForm = projective2d(invH);
    % figure;
    % imshow(I)
    % I = src;
    if flag
        I = imgaussfilt(src, 1);
        I = myimwarp(I, invH,0,true,imgsize);
    else
        I = myimwarp(src, invH,0,true,imgsize);
    end
end