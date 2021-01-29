clear;clc;
% 自带的数据 
load pointsForLineFitting.mat
data = points;
figure;
plot(data(:,1), data(:,2), 'o');
axis equal
hold on

sampleSize = 2;
maxDistance = 1;
[model, inlierIdx] = ransac(data, @fitFcn, @distFcn, sampleSize, maxDistance);
% 绘制内点
inlier = data(inlierIdx, :);
plot(inlier(:,1), inlier(:,2), 'o');
x = [min(data(:,1)), max(data(:, 1))];
y = model(1)*x + model(2);
plot(x,y,'g--');
hold off

% 这里的模型就是算直线的 k 和 b ，y = kx+b
function model = fitFcn(data)
    x = data(:,1);
    y = data(:,2);
    k = (y(1) - y(2))/(x(1) - x(2));
    b = -k*x(2) + y(2);
    model = [k, b];
end

% 就是算 (y - y')^2
function distances  = distFcn(model, data)
    k = model(1);
    b = model(2);
    distances  = (data(:,2) - (k*data(:,1) + b)).^2;
end