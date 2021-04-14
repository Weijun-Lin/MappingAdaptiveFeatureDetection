% 根据模拟图上的一个点以及这个点的单应映射，获取其映射适应卷积
% x0 是模拟图上的点
% H 为原图到模拟图的映射
% I 为原图
function val = getValByMAConv(I, H, x0, theta, invH)
    x0_ = invH * [x0(1);x0(2);1];
    x0_ = x0_ ./ x0_(3);
    [h, w] = size(I);
    val = 0;
    if x0_(1) < 0 || x0_(2) < 0 || x0_(1) > w+1 || x0_(2) > h+1
        return;
    end
    kernelSize = 8*theta;
    RI = getRI(x0, x0_, kernelSize/2, invH);
    if RI(1) > 500 || RI(2) > 500
        val = 0;
        return;
    end
    d_kernel = getDFormKernel(x0, x0_, RI, H, kernelSize, theta);
    % d_kernel
    val = convOperate(I, x0_, d_kernel);
end

function RI = getRI(x0_vec, x0_src, k_size_mid, invH)
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

    % 这里保证是以 x0_ 为中心的
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
    mid_w = floor(RI(1));
    mid_h = floor(RI(2));
    d_kernel = zeros(2*mid_h+1, 2*mid_w+1);
    Det = det(H);
    g_ = H(3,1);
    h_ = H(3,2);
    i_ = H(3,3);
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
            Jh = abs(Det/(g_*x_ + h_*y_ + i_)^3);
            % if i == 0 && j == 0
            %     x
            %     y
            %     x_
            %     y_
            %     x0
            %     Gc
            %     Jh
            % end
            
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
        deltaX = 0;
        deltaY = 0;
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
        % 处理卷积所需的边界填充
        srcpatch = srcI(y_:endY, x_:endX);
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
        try
            tempIval(i) = sum(sum(srcpatch .* kernel));
        catch ErrorInfo 
            disp(ErrorInfo)
            size(srcpatch)
            x0_
            deltaX
            deltaY
            size(kernel);
            tempIval(i) = 0;
        end
    end
    k = [s+1-x x-s t+1-y y-t];
    vals = k(1)*k(3)*tempIval(1) + k(2)*k(3)*tempIval(2) +  ...
                  k(2)*k(4)*tempIval(3) + k(1)*k(4)*tempIval(4);
end