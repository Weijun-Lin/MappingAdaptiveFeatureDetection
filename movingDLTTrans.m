% 对 RANSAC 后的匹配点进行 moving DLT 变换
function I_trans = movingDLTTrans(I, matchinges)
    imgsize = size(I);
    % C1 为高 C2 为宽 这里适合宽更大的图像
    C1 = 20;
    C2 = 20;
    % 切分图像
    [centers, cubes] = divideImg(imgsize, C1, C2);
    % 计算每一个变形
    % 超参数设置
    sigma_para = 15;
    lambda_para = 0.01;
    % 获取每一个中心点的单应矩阵
    H_all = getCenterDLT(centers, matchinges, sigma_para, lambda_para);
    % 获取每一个子块边界点的坐标 cubes_trans 每一个元素都是 2*4 大小的矩阵，代表 4 个点
    cubes_trans = getDLTCubes(H_all, cubes);
    % 根据 cubes_trans 获取变换后图像的大小（包含所有原图点）以及新图坐标系到原图坐标系的转换矩阵
    [imgsize, T] = getTransImgSize(cubes_trans);
    imgsize
    % imgsize
    % 图像转换
    % I_trans = uint8(transImgByH(I, imgsize, H_all, T, cubes_trans));

end

% 为每一个中心点计算 DLT
% 返回和 centers 大小相同的局部单应矩阵 为元胞数组形式
% centers: 为 meshgrid 返回值组成的元胞数组
% H 大小和 centers{1} 相同的元胞矩阵，每个元素都是 3*3 的单应矩阵
% 输入参数的数据不需要归一化，函数内部归一化处理，返回的 H 为去归一化的
function H = getCenterDLT(centers, matchinges, sigma_para, lambda_para)
    % 首先将数据归一化
    [data, T1, T2] = warpNormalizeMatchData(matchinges);
    [r, c,~] = size(centers{1});
    H = cell(r, c);
    for i = 1:r
        for j = 1:c
            x_star = centers{1}(i, j);
            y_star = centers{2}(i, j);
            Gk = exp(-pdist2([x_star y_star], matchinges(:, [1 2])) ./ sigma_para^2);
            W = max(Gk, lambda_para);
            W = [W; W];
            H{i, j} = getMovingDLT(data, W(:));
            % H{i,j} = dlt(data);
            H{i, j} = T2\H{i,j}*T1;
        end
    end
end

% 获取边界变换后的坐标
% H_all: 所有中心点的 H 矩阵，为元胞矩阵
% cubes: 图像每个方块的 meshgrid 即 {X, Y}
% cubes_trans: 和 H_all 相同大小的元胞矩阵，每个元素都是 2*4 的矩阵，每列为一个点
function cubes_trans = getDLTCubes(H_all, cubes)
    [r, c] = size(H_all);
    x_mat = cubes{1};
    y_mat = cubes{2};
    figure;
    % 获取边界点
    cubes_trans = cell(r, c);
    for i = 1:r
        for j = 1:c
            % 获取该中心点对应的四个边界点
            tar_points = [x_mat(i,j) x_mat(i,j+1) x_mat(i+1,j+1) x_mat(i+1,j);
                          y_mat(i,j) y_mat(i,j+1) y_mat(i+1,j+1) y_mat(i+1,j);
                          1 1 1 1];
            trans_points = H_all{i,j} * tar_points;
            trans_points = trans_points ./ trans_points(3, :);
            cubes_trans{i, j} = trans_points([1 2], :);
            plot([trans_points(1,:) trans_points(1,1)], [trans_points(2,:) trans_points(2,1)]);
            hold on
        end
    end
    axis equal
    hold off
end

% 获取变换后图像的大小
% cubes_trans: 元胞矩阵元素为每一个块四个边界点变换后的坐标
% imgsize: 图像大小 [row col]
% T: 变换矩阵，从新图坐标系到旧图坐标系的矩阵
% 所以图像变换后的点 [x,y] 到原始图像的后向映射为：H^-1*T*[x;y;1]
function [imgsize, T] = getTransImgSize(cubes_trans)
    [r, c] = size(cubes_trans);
    points = zeros(r*c*4, 2);
    idx = 1;
    for i = 1:r
        for j = 1:c
            points(idx:idx+3, :) = cubes_trans{i,j}';
            idx = idx + 4;
        end
    end
    % 获取包含这些的最小值
    x_vec = points(:, 1);
    y_vec = points(:, 2);
    max_x = max(x_vec);
    min_x = min(x_vec);
    max_y = max(y_vec);
    min_y = min(y_vec);
    % 这里的 T 为新坐标系到原坐标系的变换矩阵
    T = [1 0 min_x-1;0 1 min_y-1;0 0 1];
    imgsize = [round(max_y - min_y + 1) round(max_x - min_x + 1)];
end

% 根据单应矩阵和使用逆向映射构造新的图
% 对给定新图大小的矩阵中遍历
% 对每一个坐标先通过 T 变换到原图坐标系
% 然后判断所属的子图块，最后通过 H 逆映射回去
% 使用双线性插值获得变换后的值
function I_delta = transImgByH(I, imgsize, H_all, T, cubes_trans)
    % 创建黑色底的新图像，并确定通道数
    I_size = size(I);
    I_delta = zeros(imgsize);
    if numel(I_size) == 3
        I_delta = zeros([imgsize I_size(3)]);
    end
    % 遍历新图的每一个元素
    r = imgsize(1);
    c = imgsize(2);
    for i = 1:r
        for j = 1:c
            % 计算在原图坐标系的坐标
            coord = T * [j;i;1];
            % 获取所属的单应子块
            [rH, cH] = size(H_all);
            for s = 1:rH
                mark = false;
                for t = 1:cH
                    cur_cubes = cubes_trans{s,t};
                    % 判断是否属于当前块
                    in = inpolygon(coord(1), coord(2), cur_cubes(1,:), cur_cubes(2,:));
                    if in
                        mark = true;
                        % (s,t) 为所属块，对其执行 H 的逆变换
                        src_coord = H_all{s,t}\coord;
                        src_coord = src_coord ./ src_coord(3,:);
                        % src_coord
                        % 双线性插值
                        I_delta(i,j,:) = bilinearInterp(I, src_coord);
                        break;
                    end
                end
                if mark
                    break;
                end
            end
        end
    end
end

% 双线性插值函数
% I: 原图像
% srccoord: 在原图像坐标系上的坐标，可能非整数
% pixel_value: 返回插值的值，不再原图上返回 0
function pixel_value = bilinearInterp(I, srccoord)
    x = srccoord(1);
    y = srccoord(2);
    % 不再原图上的点返回黑色
    pixel_value = 0;
    [r, c, ~] = size(I);
    % 坐标在图像外的返回 0 
    if x > c || y > r || x < 1 || y < 1
        return;
    end
    % 现在坐标已经在图像内部、或者边界，然后处理边界（图像右和下）避免插值时数组边界访问异常
    if x == c || y == r
        pixel_value = I(x, y, :);
        return;
    end
    % 此时依据四个点做双线性插值
    % 首先对坐标向零取整
    s = fix(srccoord(1));
    t = fix(srccoord(2));
    A = I(t,s,:) + (x-s)*(I(t,s+1,:) - I(t,s,:));
    B = I(t+1,s,:) + (x-s)*(I(t+1,s+1,:)-I(t+1,s,:));
    pixel_value = A + (y-t)*(B-A);
    % pixel_value
end