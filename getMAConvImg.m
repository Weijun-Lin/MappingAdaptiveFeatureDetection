% 映射适应卷积测试脚本

% 输入参数
%     src: 原图
%     H: 原图到模拟图的映射
% 输出
%     I: 模拟图
function I = getMAConvImg(src, H, originSize, theta)
    % [h, w, ~] = size(src);
    % [imgsize, T] = getBoundAfterH(w, h, H);
    % H = T*H;
    imgsize = originSize;
    I = zeros(imgsize);
    d_h = imgsize(1);
    d_w = imgsize(2);
    invH = inv(H);
    for i = 1:d_h
        if mod(i, 50) == 0
            i
        end
        for j = 1:d_w
            I(i,j) = getValByMAConv(src, H, [j;i], theta, invH);
            % I(i,j)
        end 
    end
    % figure;
    % imshow(src);
    % hold on
    % scatter([99 100 100 99], [134 134 135 135]);
end