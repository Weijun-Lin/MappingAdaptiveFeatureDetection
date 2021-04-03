function I = myimwarp(src, H, backcolor, flag, imgsize)
    [h, w] = size(src);
    if ~flag
        [imgsize, H] = getBoundAfterH(w, h, H);
    end
    I = ones(imgsize);
    I_w = imgsize(2);
    I_h = imgsize(1);
    invH = inv(H);

    for i = 1:I_w
        for j = 1:I_h
            srcP = invH * [i;j;1];
            srcP = srcP ./ srcP(3);
            I(j,i) = backward(src, srcP, backcolor);
        end
    end
end

function [imgsize, H] = getBoundAfterH(w, h, H)
    in = [1 w w 1;
          1 1 h h;
          1 1 1 1];
    out = H * in;
    out = out ./ out(3,:);
    min_x = min(out(1,:));
    min_y = min(out(2,:));
    max_x = max(out(1,:));
    max_y = max(out(2,:));
    T = [1 0 -min_x+1;0 1 -min_y+1;0 0 1];
    H = T*H;
    imgsize = [ceil(max_y - min_y) ceil(max_x - min_x)] + 1;
end

% 后向映射到原图,获取对应的值
function pixel_value = backward(srcimg, srccoord, backcolor)
    x = srccoord(1);
    y = srccoord(2);
    % 不再原图上的点返回黑色
    pixel_value = backcolor;
    [r, c] = size(srcimg);
    % 坐标在图像外的返回
    if x > c || y > r || x < 1 || y < 1
        return;
    end
    % 现在坐标已经在图像内部、或者边界，然后处理边界（图像右和下）避免插值时数组边界访问异常
    if x == c || y == r
        pixel_value = srcimg(floor(x), floor(y));
        return;
    end
    % 此时依据四个点做双线性插值 首先对坐标向零取整
    s = fix(srccoord(1));
    t = fix(srccoord(2));
    k = [s+1-x x-s t+1-y y-t];
    pixel_value = k(1)*k(3)*srcimg(t,s) + k(2)*k(3)*srcimg(t, s+1) +  ...
                  k(1)*k(4)*srcimg(t+1,s) + k(2)*k(4)*srcimg(t+1,s+1);
end