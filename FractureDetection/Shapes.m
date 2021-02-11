function Shapes()
% Filtering images with averaging filter
clc; home;
close all hidden

% Load some image, convert to grayscale 
Img = double(rgb2gray(imread('Shapes.png'))); 
%Img = rgb2gray(imread('Fractures.png')); 
%Img = double(rgb2gray(imread('FracturesNoisy.png'))); 
%load('FracturesNoisy.mat', 'Img');  
%Img = dicomread('hand1'); 
imshow(Img);

% Create a noisy version, save into a file
% Img(Img<127) = 10;
% Img = double(Img) + 10*(rand(size(Img))-0.5); 
% Img = max(0, min(255, round(Img)));
% save('FracturesNoisy.mat', 'Img');
% imshow(Img);


% Compute edges
[nrows, ncols] = size(Img);
Edges = zeros(size(Img));
for x=2:nrows-1
    for y=2:ncols-1
        Edges(x,y) = sqrt((Img(x+1,y)-Img(x-1,y))^2 + ... 
                          (Img(x,y+1)-Img(x,y-1))^2);
    end;
end
Img = Edges;
imshow(Img);

% For faster processing, resize
[nrows, ncols] = size(Img);
Img = Img(1:2:nrows, 1:2:ncols);


% Display what we have loaded
imshow(Img);

% Find lines
E = FindLine(Img);

% Done!
return;




% Function to find lines in the edge image EdgeImg
function E = FindLine(EdgeImg)

% Find image sizes
[nrows, ncols] = size(EdgeImg);

% Convert the image to 1D buffer, to compute quantiles
EdgeImg1D = reshape (EdgeImg, [nrows*ncols,1]);
t = max(100,quantile(EdgeImg1D,0.99)); % select edge intensity threshold

% Set minimal and maximal line size
r0=50; r1=2*r0;
nLine = 0; 

% Search
tic
for x0 = 1:nrows
    progress = 100*x0/nrows % display current progress
    for y0 = 1:ncols
        if(EdgeImg(x0,y0)<t), continue; end; % non-edge, skip
        
        for x1 = x0+1:min(x0+r1,nrows)
            for y1 = max(1,y0-r1):min(ncols,y0+r1)
                 if(EdgeImg(x1,y1)<t), continue; end; % non-edge, skip
                 if(EdgeImg(round((x0+x1)/2),round((y0+y1)/2))<t), continue; end; 
                 d = sqrt( (x1-x0)^2+(y1-y0)^2 );
                 if d<r0 || d>r1
                     continue; % too large or too small
                 end;
                 a = (y1-y0)/(x1-x0);
                 b = y0-a*x0;
                 % Compute line cost function
                 C=0; dx=(x1-x0)/5; 
                 for x=x0:dx:x1
                     C = C+EdgeImg(round(x), round(a*x+b));
                 end;
                 % Add new detected line
                 nLine = nLine+1;
                 Lines(nLine,1) = C;   % save the cost of this line
                 Lines(nLine,2) = x0;    Lines(nLine,3) = y0; % save start point
                 Lines(nLine,4) = x1;    Lines(nLine,5) = y1; % save end point
                
            end;
        end;
    end;
end;
toc

% Sort detected lines by strength
Lines = sortrows(Lines,-1);
nLine = max(1,round(nLine/10));

% Draw the best lines
E = zeros(size(EdgeImg));
for nL=1:nLine
    x1=Lines(nL,4);     y1=Lines(nL,5); 
    x0=Lines(nL,2);     y0=Lines(nL,3);
    a = (y1-y0)/(x1-x0);
    b = y0-a*x0;
    dx=(x1-x0)/r1;
    for x=x0:dx:x1
         E(round(x),round(a*x+b))=255;
    end;
end;
imshow([EdgeImg E]);

return;

        



% Function to find ellipses in image Img
function E = FindEllipse(Img)

% Find image sizes
[nrows, ncols] = size(Img);

% Convert the image to 1D buffer
Img1 = reshape (Img, [nrows*ncols,1]);

% Find intensity threshold for edges
t = quantile(Img1,0.95);

% Set minimal ellipse size
r = nrows/3;
r2 = r^2;
Cbest=0; abest=0; bbest=0; pbest=0; qbest=0;

% Search
for x0 = r+1:nrows-r
    donex = 100*x0/nrows
    for y0 = r+1:ncols-r
        if(Img(x0,y0)<t), continue; end; %non-edge, skip
        %doney = 100*y0/ncols
        
        for x1 = x0+r:min(x0+3*r,nrows)
            for y1 = y0+r:min(y0+3*r,ncols)
                 if(Img(x1,y1)<t), continue; end; %non-edge, skip
%                  dp = sqrt( (x0-x1)^2+(y0-y1)^2 );
%                  if dp<r/2 || dp>2*r
%                      continue; % too small or too large
%                  end

                for a = x0-r:min(x1+r,nrows)
                    for b = y0+r:min(y1+r,ncols)
                        u0 = (x0-a)^2; u1 = (x1-a)^2;
                        v0 = (y0-b)^2; v1 = (y1-b)^2;
                        q2 = (v0*u1-u0*v1)/(v0-u0);
                        if q2<(r/4)^2, continue, end;
                        p2 = v0*q2/(q2-v1);
                        if p2<(r/4)^2, continue, end;
                        p = sqrt(p2); q = sqrt(q2);
                        
                        % Compute ellipse cost function
                        C=0; n=0;
                        for x=max(2, round(a-p)):min(nrows-1, round(a+p))
                            de = q2*(1-((x-a)^2)/p2);
                            if(de<1), continue, end;
                            yb = sqrt(de);
                            yb1 = round(b+yb);
                            if yb1>1 && yb1<ncols
                                C = C+Img(x, yb1); n = n+1;
                            end;
                            yb2 = round(b-yb);
                            if yb2>2 && yb2<ncols
                                C = C+Img(x, yb2); n = n+1;
                            end;
                        end;
                        C = C/n;
                        if C>Cbest
                            Cbest=C;
                            abest=a; bbest=b; 
                            pbest=p; qbest=q;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

% Draw the best ellipse
E = zeros(size(Img));
a=abest, b=bbest; p=pbest; q=qbest;
for x=max(2, round(a-p)):min(nrows-1, round(a+p))
    yb = sqrt(q2*(1-((x-a)^2)/p2));
    yb1 = round(b+yb);
    if yb1>1 && yb1<ncols
        E(x, yb1) = 200;
    end;
    yb2 = round(b-yb);
    if yb1>2 && yb2<ncols
        E(x, yb2) = 200;
    end;
end;
imshow(E);
                            
        

return;