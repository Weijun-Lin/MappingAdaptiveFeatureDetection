% clear;clc;
% % 自带的数据 
% load pointsForLineFitting.mat
% data = points;
% figure;
% plot(data(:,1), data(:,2), 'o');
% axis equal
% hold on

% sampleSize = 2;
% maxDistance = 1;
% [model, inlierIdx] = ransac(data, @fitFcn, @distFcn, sampleSize, maxDistance);
% % 绘制内点
% inlier = data(inlierIdx, :);
% plot(inlier(:,1), inlier(:,2), 'o');
% x = [min(data(:,1)), max(data(:, 1))];
% y = model(1)*x + model(2);
% plot(x,y,'g--');
% hold off

% % 这里的模型就是算直线的 k 和 b ，y = kx+b
% function model = fitFcn(data)
%     x = data(:,1);
%     y = data(:,2);
%     k = (y(1) - y(2))/(x(1) - x(2));
%     b = -k*x(2) + y(2);
%     model = [k, b];
% end

% % 就是算 (y - y')^2
% function distances  = distFcn(model, data)
%     k = model(1);
%     b = model(2);
%     distances  = (data(:,2) - (k*data(:,1) + b)).^2;
% end

load pointsForLineFitting.mat
sampleSize = 2; % number of points to sample per trial
maxDistance = 2; % max allowable distance for inliers

fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % fit function using polyfit

[modelRANSAC, inlierIdx] = ransac(points,fitLineFcn,@evalLineFcn, ...
  sampleSize,maxDistance);

function dist = evalLineFcn(model, points)
    points(:, 2)
    
    dist = sum((points(:, 2) - polyval(model, points(:,1))).^2,2)
end