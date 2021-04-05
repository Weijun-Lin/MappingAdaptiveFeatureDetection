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
            I(j,i) = Bilinear(src, srcP, backcolor);
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