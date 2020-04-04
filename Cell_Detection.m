%BME 3053C Final Project
%Cell Detection and Counting
%4/10/2020
%This code is used to identify the number of cells in an image that contain
%magnetic nanoparticles.

clc;clear;
pix=imread('Cell3.png');
[h,w,p]=size(pix);
binary=false(h,w); 
new=pix; I=pix;

%Changes the image to binary
for ii= 1:h
    for jj= 1:w
        if (new(ii,jj,1)>=0 && new(ii,jj,1)<=14)&&(new(ii,jj,2)>=10 && new(ii,jj,2)<=35)&&(new(ii,jj,3)>=95 && new(ii,jj,3)<=200)
            new(ii,jj,:)=255;
        else
            new(ii,jj,:)=0;
        end
    end
end
BWs=rgb2gray(new);

%Dilatates the image by the given structure elements (sec90 and sec0)
se90 = strel('line',2,90);
se0 = strel('line',2,0);
BWsdil = imdilate(BWs,[se90 se0]);

%Fills the wholes from the dilatated image
BWdfill = imfill(BWsdil,'holes');

%Smooth the object by eroding the image
seD = strel('disk',1);
BWfinal = imerode(BWdfill,seD);

%Draw an outline around the target cells
BWoutline = bwperim(BWfinal);
Segout = binary; %The binary image is currently only black pixels. Here we are telling it to change the pixels that correspond to the outline of the cells detected to white.
Segout(BWoutline) = 255; 
BW2 = bwareaopen(Segout, 15); %Based on the circles created by the outline, we are now telling the program to ignore/eliminate any circle made up of less than 15 pixels

CC = bwconncomp(BW2,8); %Here we are counting the pixels with a conectivity of 8 (meaning they are connected up, down, side to side and in the corners)

BWoutline = bwperim(BW2); 
Segout1 = I; %Outline around the cells of the original image using the parameters found in the binary image
Segout1(BWoutline) = 255; 


%Calculate centroids for connected components in the image and thus counts the number of circles in the binary image
measurements = regionprops(CC, 'Centroid', 'Area');
numberOfCircles = length(measurements);
fprintf('There are %.0f cells\n',numberOfCircles);


imshow(Segout1) %Here we want to display the original image that only has the outlines of the circles whose areas fit the threshold (more than 15 pixels). This will be used as reference to see which cells where counted for and which weren't.
title('Cells Detected')