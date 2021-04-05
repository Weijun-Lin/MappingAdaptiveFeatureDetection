clear
load pointImg.mat
load testTexture1.mat
% srcImg = testTexture1;
srcImg = pointImg;

[h, w] = size(srcImg);
in_points = [1 w w 1
            1 1 h h];
out_points1 = [60 180 200 0;
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
H = H*T;
out_points = in_mid * H;
out_points = out_points ./ out_points(:,3)
TForm1 = projective2d(H);
transimg1 = myimwarp(srcImg, H', 1, false, []);
% transimg1 = imwarp(srcImg, TForm1, 'FillValues', 1);
figure;
% imshow(transimg2);
invI = invtransWidthConv(transimg1, H', size(srcImg));
imshow(imadjust(invI));
figure
imshow(transimg1);
figure;
I = imadjust(imgaussfilt(srcImg, 2));
imshow(I);


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

function I = invtransWidthConv(src, H, imgsize)
    invH = inv(H);
    % TForm = projective2d(invH);
    I = imgaussfilt(src, 2);
    I = myimwarp(I, invH,0,true,imgsize);
end