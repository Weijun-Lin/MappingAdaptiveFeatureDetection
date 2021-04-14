% 后向映射到原图,获取对应的值
function pixel_value = Bilinear(srcimg, srccoord, backcolor)
    x = srccoord(1);
    y = srccoord(2);
    % 不再原图上的点返回黑色
    pixel_value = backcolor;
    [r, c] = size(srcimg);
    % 坐标在图像外的返回
    if x > c || y > r || x < 1 || y < 1
        % x
        % y
        return;
    end
    % 现在坐标已经在图像内部、或者边界，然后处理边界（图像右和下）避免插值时数组边界访问异常
    if x == c || y == r
        pixel_value = srcimg(floor(y), floor(x));
        return;
    end
    % 此时依据四个点做双线性插值 首先对坐标向零取整
    s = fix(srccoord(1));
    t = fix(srccoord(2));
    k = [s+1-x x-s t+1-y y-t];
    pixel_value = k(1)*k(3)*srcimg(t,s) + k(2)*k(3)*srcimg(t, s+1) +  ...
                  k(1)*k(4)*srcimg(t+1,s) + k(2)*k(4)*srcimg(t+1,s+1);
end