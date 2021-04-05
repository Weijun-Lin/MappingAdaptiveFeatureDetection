% 映射适应卷积测试脚本

% 输入参数
%     src: 原图
%     H: 原图到模拟图的映射
% 输出
%     I: 模拟图
function I = getMAConvImg(src, H, originSize, theta)
    [h, w, ~] = size(src);
    % [imgsize, T] = getBoundAfterH(w, h, H);
    % H = T*H;
    invH = inv(H);
    imgsize = originSize;
    I = zeros(imgsize);
    % imgsize
    kernelSize = 8*theta;
    % d_kernels = cell(imgsize);
    d_h = imgsize(1);
    d_w = imgsize(2);
    for i = 1:d_h
        if mod(i, 50) == 0
            i
        end
        for j = 1:d_w
            x0_ = invH * [j;i;1];
            x0_ = x0_ ./ x0_(3);
            if x0_(1) < 0 || x0_(2) < 0 || x0_(1) > w+1 || x0_(2) > h+1
                continue;
            end
            RI = isInValidRegion([j i], x0_, kernelSize/2, invH);
            d_kernel = getDFormKernel([j i]', x0_, RI, H, kernelSize, theta);
            % d_kernel_norm = normalize(d_kernel, 'range');
            % d_kernel_norm = reshape(d_kernel_norm, size(d_kernel));
            % d_kernels{i,j} = d_kernel;
            % x0_
            % val = convOperate(src, x0_, d_kernel_norm);
            val = convOperate(src, x0_, d_kernel);
            I(i,j) = val;
            % return
        end 
    end
    % figure;
    % imshow(src);
    % hold on
    % scatter([99 100 100 99], [134 134 135 135]);
end

% imgsize 为图像大小 T 为 H 变换后平移到标准坐标系下的平移变换
function [imgsize, T] = getBoundAfterH(w, h, H)
    in = [1 w w 1;
          1 1 h h;
          1 1 1 1];
    out = H*in;
    out = out ./ out(3,:);
    min_x = min(out(1,:));
    min_y = min(out(2,:));
    max_x = max(out(1,:));
    max_y = max(out(2,:));
    T = [1 0 -min_x+1;0 1 -min_y+1;0 0 1];
    imgsize = [ceil(max_y - min_y + 1) ceil(max_x - min_x + 1)];
end

% 从模拟图逆映射到原图查看是否为有效区域
function RI = isInValidRegion(x0_vec, x0_src, k_size_mid, invH)
    % xv = [1 w w 1];
    % yv = [1 1 h h];
    x0 = x0_vec(1);
    y0 = x0_vec(2);
    testPoints = [x0-k_size_mid x0+k_size_mid x0+k_size_mid x0-k_size_mid;
                  y0-k_size_mid y0-k_size_mid y0+k_size_mid y0+k_size_mid;
                  1 1 1 1];
    srcPoints = invH * testPoints;
    srcPoints = srcPoints ./ srcPoints(3,:);
    % figure;
    % plot(srcPoints(1,:), srcPoints(2,:));
    % x0_vec
    % srcPoints
    % 返回 RI：[w h]
    min_x = min(srcPoints(1,:));
    min_y = min(srcPoints(2,:));
    max_x = max(srcPoints(1,:));
    max_y = max(srcPoints(2,:));
    w = x0_src(1) - min_x;
    h = x0_src(2) - min_y;

    if max_x - x0_src(1) > w
        w = max_x - x0_src(1);
    end

    if max_y - x0_src(2) > h
        h = max_y - x0_src(2);
    end

    RI = [w, h];
end

% 获取模拟图上某个具体位置 x0 对应的变形卷积核                  
function d_kernel = getDFormKernel(x0, x0_, RI, H, k_size, c)
    mid_h = floor(RI(2));
    mid_w = floor(RI(1));
    d_kernel = zeros(2*mid_h+1, 2*mid_w+1);
    for i = -mid_w:mid_w
        for j = -mid_h:mid_h
            % 映射回模拟图像坐标
            x_ = x0_(1) + i;
            y_ = x0_(2) + j;
            hx = H * [x_;y_;1];
            hx = hx ./ hx(3);
            x_vec = x0 - hx([1 2],:);
            % 这里的 xy 是相对与 x0 的坐标
            x = x_vec(1);
            y = x_vec(2);
            mid_size = k_size / 2;
            % 映射回标准卷积的时候在区域外则直接赋值为 0
            if x < -mid_size || x > mid_size || y < -mid_size || y > mid_size
                continue;
            end
            % x_vec
            % x_
            % y_
            % 否则得到其在标准高斯核上的值
            Gc = 1/(2*pi*c*c) * exp(-(x^2 + y^2)/(2*c*c));
            % 并获取雅可比行列式的值
            g_ = H(3,1);
            h_ = H(3,2);
            i_ = H(3,3);
            Jh = abs(det(H)/(g_*x_ + h_*y_ + i_)^3);
            
            % Jh = abs(det(H)/(g_*hx(1) + h_*hx(2) + i_)^3);
            d_kernel(mid_h+1+j,i+1+mid_w) = Gc*Jh;
        end
    end
end

% 计算Wn*Wn内插值的值
function vals = convOperate(srcI, x0_, kernel)
    % kernel
    [H, W] = size(srcI);
    x = x0_(1);
    y = x0_(2);
    % x0_ 是 2*1 的向量，是 x0 的逆映射
    s = fix(x);
    t = fix(y);
    % ----------- 这里采用双线性插值，所以需要四个点 ---------------------
    tarP = [s t; s+1 t; s+1 t+1; s t+1];
    % 对这些点做卷积操作
    [kh, kw] = size(kernel);
    % 现在暂时就考虑灰度图像
    tempIval = ones(1, 4);
    for i = 1:4
        p = tarP(i, :);
        x_ = p(1)-floor(kw/2);
        y_ = p(2)-floor(kh/2);
        % 这里需要获取有意义的边界，然后做合适的拓展，重复拓展
        flagY = 0;
        flagX = 0;
        endY = y_+kh-1;
        endX = x_+kw-1;
        if endY > H
            deltaY = endY - H;
            endY = H;
            flagY = 1;
        end
        if y_ < 1
            deltaY = 1 - y_;
            flagY = 2;
            y_ = 1;
        end
        if endX > W
            deltaX = endX - W;
            endX = W;
            flagX = 1;
        end
        if x_ < 1
            deltaX = 1 - x_;
            flagX = 2;
            x_ = 1;
        end
        srcpatch = srcI(y_:endY, x_:endX);
        % X 向右填充
        if flagY == 1
            srcpatch = padarray(srcpatch, [deltaY 0], 'replicate', 'post');
        end
        if flagY == 2
            srcpatch = padarray(srcpatch, [deltaY 0], 'replicate', 'pre');
        end
        if flagX == 1
            srcpatch = padarray(srcpatch, [0 deltaX], 'replicate', 'post');
        end
        if flagX == 2
            srcpatch = padarray(srcpatch, [0 deltaX], 'replicate', 'pre');
        end
        % size(srcpatch)
        % size(kernel)
        tempIval(i) = sum(sum(srcpatch .* kernel));
        % tempIval(i) = srcI(p(2), p(1));
    end
    k = [s+1-x x-s t+1-y y-t];
    vals = k(1)*k(3)*tempIval(1) + k(2)*k(3)*tempIval(2) +  ...
                  k(2)*k(4)*tempIval(3) + k(1)*k(4)*tempIval(4);

    % % ----------- 这里采用双三次插值，所以需要四个点 ---------------------
    % s = s - 1;
    % t = t - 1;
    % % 对这些点做卷积操作
    % [kh, kw] = size(kernel);
    % % 现在暂时就考虑灰度图像
    % tempIval = ones(4, 4);
    % for i = 1:4 % x
    %     for j = 1:4 % y
    %         p = [s+i-1 t+j-1];
    %         x_ = p(1)-floor(kw/2);
    %         y_ = p(2)-floor(kh/2);
    %         % 这里需要获取有意义的边界，然后做合适的拓展，重复拓展
    %         flagY = 0;
    %         flagX = 0;
    %         endY = y_+kh-1;
    %         endX = x_+kw-1;
    %         if endY > H
    %             deltaY = endY - H;
    %             endY = H;
    %             flagY = 1;
    %         end
    %         if y_ < 1
    %             deltaY = 1 - y_;
    %             flagY = 2;
    %             y_ = 1;
    %         end
    %         if endX > W
    %             deltaX = endX - W;
    %             endX = W;
    %             flagX = 1;
    %         end
    %         if x_ < 1
    %             deltaX = 1 - x_;
    %             flagX = 2;
    %             x_ = 1;
    %         end
    %         srcpatch = srcI(y_:endY, x_:endX);
    %         % X 向右填充
    %         if flagY == 1
    %             srcpatch = padarray(srcpatch, [deltaY 0], 'replicate', 'post');
    %         end
    %         if flagY == 2
    %             srcpatch = padarray(srcpatch, [deltaY 0], 'replicate', 'pre');
    %         end
    %         if flagX == 1
    %             srcpatch = padarray(srcpatch, [0 deltaX], 'replicate', 'post');
    %         end
    %         if flagX == 2
    %             srcpatch = padarray(srcpatch, [0 deltaX], 'replicate', 'pre');
    %         end
    %         tempIval(j, i) = sum(sum(srcpatch .* kernel));
    %     end
    % end

    % % 四个点左上角的那个点
    % u = x - s;
    % v = y - t;
    % [kh, kw] = size(kernel);
    % s = s - 1;
    % t = t - 1;
    % B = zeros(4, 4);
    % for i = 0:3
    %     for j = 0:3
    %         p = [s+i;t+j];
    %         x_ = p(1)-floor(kw/2);
    %         y_ = p(2)-floor(kh/2);
    %         if y_+kh-1 > H || x_+kw-1 > W || x_ < 1 || y_ < 1
    %             continue;
    %         end
    %         srcpatch = srcI(y_:y_+kh-1, x_:x_+kw-1);
    %         B(j+1, i+1) = sum(sum(srcpatch .* kernel));
    %     end
    % end
    % A = [bicubicFunc(1+v) bicubicFunc(v) bicubicFunc(1-v) bicubicFunc(2-v)];
    % C = [bicubicFunc(1+u) bicubicFunc(u) bicubicFunc(1-u) bicubicFunc(2-u)]';
    % vals = A * B * C;
end

% % 插值核函数
% function w = bicubicFunc(wx)
%     wx = abs(wx);
%     if wx <= 1
%         w = 1 - 2*(wx^2) + wx^3;
%     elseif wx < 2
%         w = 4 - 8*wx + 5*(wx^2) - wx^3;
%     else
%         w = 0;
%     end
% end