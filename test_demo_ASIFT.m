% *************************************************************************
% NOTE: The ASIFT SOFTWARE ./demo_ASIFT IS STANDALONE AND CAN BE EXECUTED
%       WITHOUT MATLAB. 
% *************************************************************************
%
% demo_ASIFT.m is a MATLAB interface for the ASIFT software. This
% script provides an example of using demo_ASIFT.m. The input/output of
% demo_ASIFT.m follow those of the ASIFT software and a description can
% found in README.txt. (Note that the ASIFT software support only the PNG format, 
% the Matlab interface reads most standard image formats.)
%
% The ASIFT C/C++ source code must be compiled before running the ASIFT software
% for the first time. See README.txt for more details. 
% 
% Copyright, Jean-Michel Morel, Guoshen Yu, 2008. 
%
% Please report bugs and/or send comments to Guoshen Yu yu@cmap.polytechnique.fr
%
% Reference: J.M. Morel and G.Yu, ASIFT: A New Framework for Fully Affine Invariant Image 
%           Comparison, SIAM Journal on Imaging Sciences, vol. 2, issue 2, pp. 438-469, 2009. 
% Reference: ASIFT online demo (You can try ASIFT with your own images online.) 
% http://www.ipol.im/pub/algo/my_affine_sift/
%
% 2010.08.17
tic;
% file_img1 = "./out3.png";
% file_img1 = "./test1.jpg";
% file_img2 = "./test2.jpg";
% file_img2 = "./test1.jpg";
% file_img1 = "./P1010517.JPG";
% file_img2 = "./P1010520.JPG";
% file_img1 = "./DSC02933.JPG";
% file_img1 = "./XMAS5.png";
% file_img1 = "./XMAS_out1.png";
% file_img1 = "./LEO_out2.png";
% file_img1 = "./LEO_out1.png";
file_img1 = "./CAR_out4.png";
file_img2 = "./CAR8.png";

imgOutVert = 'imgOutVertRANSAC.png';
imgOutHori = 'imgOutHoriRANSAC.png';
matchings = 'matchings.txt';
keys1 = 'keys1.txt';
keys2 = 'keys2.txt';
flag_resize = 0;
demo_ASIFT(file_img1, file_img2, imgOutVert, imgOutHori, matchings, keys1, keys2, flag_resize);

toc;