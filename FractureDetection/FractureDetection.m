% HW 10 - Fracture Detection
% Detects presence of fractures from a Matlab data file
% Uses FindLine function defined by FindLine.m file

clear 
clc

%Import data
EdgeImg = importdata('FracturesNoisy.mat');


%Find image size
[nrows, ncols] = size(EdgeImg);


%Convert the image to 1D buffer, to compute quantiles
EdgeImg1D = reshape(EdgeImg, [nrows*ncols,1]);
t = max(100, quantile(EdgeImg1D, 0.99)); %select edge intensity threshold

 
%Resize og image after detecting edges
EdgeImg = EdgeImg(1:2:nrows, 1:2:ncols);


%Get lines of resized image
E = FindLine(EdgeImg);



E = sortrows(E, -1);
Res = E(1:ceil(length(E)*0.1),:);

for l = 1:length(Res)
    x_start = Res(l, 2);
    x_end = Res(l, 3);
    y_start = Res(l, 4);
    y_end = Res(l, 5);
    plot(x_start, y_start, '*')
    hold on
    plot(y_end, y_end, '*')
    hold on
end
        

