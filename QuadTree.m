% 四叉树类 包含根节点数据
% 每一个节点 node(以node结尾) 都是一个结构体包含以下字段：
% 1. region 包含的区域，元胞数组 {[2*1], w, h} 
% 2. idx 包含的 data 数据索引，这里是变换后的网格数据，只有叶节点有意义
% 3. children_nodes 四个子节点
classdef QuadTree
    properties
        % 根节点
        root_node
        % 数据，为一个一维（元胞）数组，每一个都是四叉树的一个目标元素
        data
        % 每个块中的最大阈值 
        maxOfOne
        % 函数句柄，用于确认是否可以归纳到某个区域，接收参数为data元素和一个区域，返回逻辑值
        isInFunc = @isIntersect;
        % 设置最深的深度
        maxdepth = 4;
    end

    methods
        % 构造函数
        function obj = QuadTree(data, src_region, delta)
            obj.data = data;
            figure;
            for i = 1:length(data)
                poly = polyshape(data{i}(1,:), data{i}(2,:));
                plot(poly);
                hold on
            end
            obj.maxOfOne = delta;
            obj.root_node = obj.createQualTree(src_region, 1:length(data), 1);
        end

        % 获取目标点在四叉树数据的索引，不再则返回 0
        function idx = getQuadTreeIdx(obj, tar_point, root_node)
            % figure(2);
            idx = 0;
            % 首先判断是否在当前这个大区域中
            p = regionToStd(root_node.region);
            % plot(p(1,:),p(2,:));
            in = inpolygon(tar_point(1), tar_point(2), p(1,:), p(2,:));
            if ~in
                return;
            end
            % 然后查看是否是叶节点
            % disp("tag1");
            if isempty(root_node.children_nodes)
                % 叶节点遍历其索引
                % root_node.idx
                for i = 1:length(root_node.idx)
                    polygon = obj.data{root_node.idx(i)};
                    in = inpolygon(tar_point(1), tar_point(2), polygon(1,:), polygon(2,:));
                    % 如果在当前的块中则返回索引
                    if in
                        idx = root_node.idx(i);
                        return;
                    end
                end
                return;
            end
            % 非叶节点就查看在哪一个大块中，到对应的大块中找，都不在则返回
            % disp('tag2');
            for i=1:4
                % 因为此递归函数在入口就判断是不是在，所以直接递归下去就可以了
                temp = obj.getQuadTreeIdx(tar_point, root_node.children_nodes{i});
                % 说明在当前子区域
                if temp ~= 0
                    idx = temp;
                    return;
                end
            end
        end
    end

    methods (Access = private)
        % src_region: 原始区域
        % idx: 该区域待分配的块索引，对应 obj.data
        function root_node = createQualTree(obj, src_region, idx, curLev)
            root_node.region = src_region;
            p1 = src_region{1};
            w = src_region{2};
            h = src_region{3};
            p2 = p1 + [w;0];
            p3 = p1 + [w;h];
            p4 = p1 + [0;h];
            p = [p1 p2 p3 p4 p1];
            plot(p(1,:),p(2,:),'linewidth',1);
            hold on;
            % 如果小于阈值则作为叶节点返回
            root_node.idx = [];
            root_node.children_nodes = {};
            if length(idx) <= obj.maxOfOne || curLev > obj.maxdepth
                root_node.idx = idx;
                % idx
                return
            end
            p1 = src_region{1};
            w = src_region{2};
            h = src_region{3};
            p2 = p1 + [w/2;0];
            p3 = p1 + [w/2;h/2];
            p4 = p1 + [0;h/2];
            % 切分为四个子区域
            sub_regs = {{p1, w/2, h/2}
                        {p2, w/2, h/2}
                        {p3, w/2, h/2}
                        {p4, w/2, h/2}};
            % 切分索引到四个区域
            sub_idx = {[] [] [] []};
            for i = 1:length(obj.data)
                for j = 1:4
                    if obj.isInFunc(obj.data{i}, sub_regs{j})
                        sub_idx{j}(end+1) = i;
                        % break;
                    end
                end
            end
            for i = 1:4
                root_node.children_nodes{i} = obj.createQualTree(sub_regs{i}, sub_idx{i}, curLev + 1);
            end
        end
    end
end

function isIn = isIntersect(data, tar_region)
    p = regionToStd(tar_region);
    poly1 = polyshape(p(1,:), p(2,:));
    poly2 = polyshape(data(1,:), data(2,:));
    polyout = intersect(poly1,poly2);
    isIn = polyout.NumRegions ~= 0;
end

% 将四叉树中的区域表示变为四个点(2*4) 表示
function p_vec = regionToStd(region)
    p1 = region{1};
    w = region{2};
    h = region{3};
    p2 = p1 + [w;0];
    p3 = p1 + [w;h];
    p4 = p1 + [0;h]; 
    p_vec = [p1 p2 p3 p4];
end