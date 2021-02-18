load quadTree
region = quadTree.root_node.region;
p = [100.5315;100.2879];
% tic
quadTree.getQuadTreeIdx(p, quadTree.root_node)
% toc

tic
% quadTree.getQuadTreeIdx(p, quadTree.root_node)
for i=1:1000
    % tic
    quadTree.getQuadTreeIdx(p, quadTree.root_node);
    % toc
end
toc