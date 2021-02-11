% HW 6 - Image Filtering
% Given a noisy image LennaNoisy.png

clear
clc

%Import file 
image = rgb2gray(imread('LennaNoisy.png'));
rows = size(image, 1);
cols = size(image, 2);
filtered_image = image;

%Define filter parameters
r = 7;


%Run simple averaging filter on image
%for nr = r+1:rows-r-1
%    for nc = r+1:cols-r-1
%        filtered_image(nr, nc) = mean2( image(nr-r:nr+r, nc-r:nc+r) );
%    end
%end

%imshow(image), figure, imshow(filtered_image)



%Bilateral Filter
kI = 7500;
lambda = 0.2;
r = 6;


for nr = r+1:rows-r-1
    for nc = r+1:cols-r-1
        sumV = 1;
        sumPV = image(nr, nc);
        
        for neighbor_r = nr-r:nr+r
            for neighbor_c = nc-r:nc+r
                %distance between pixel locations
                dL = (neighbor_r-nr)^2 + (neighbor_c-nc)^2;
                
                if(dL<1), continue, end;
                
                dI = (image(nr, nc)-image(neighbor_r, neighbor_c))^2;
                
                %weight
                w = lambda/( (1+dL)*exp(-dI/kI));
                
                sumV = sumV + w;
                sumPV = sumPV + w*image(neighbor_r, neighbor_c);
            end
        end
        
        filtered_image(nr, nc) = sumPV/sumV;
    end
end

imshow(image), figure, imshow(filtered_image)


