clc;
close all;
clear all;

%% INPUT
[inp, path] = uigetfile('*.jpg', 'select an input image');
str = strcat(path, inp);
s = imread(str);
% figure;
% imshow(s);
% title('Input image');

%% FILTERING
disp('Preprocessing image please wait . . .');
% Define structuring element
NHOOD2 = [0 1 0; 1 1 1; 0 1 0];
fprintf('Removing noise\n');
filteredImage = imclose(imopen(s, NHOOD2), NHOOD2);
fprintf('Filtering Completed.\n');
% figure;
% imshow(filteredImage);
% title('Filtered image');

%% THRESHOLDING
inp=filteredImage;
t0=150;
th=t0+mean(mean(inp));
[m, n]=size(inp);
for i=1:1:m
    for j=1:1:n
        if inp(i,j)>th
            inp(i,j)=255;
        else
            inp(i,j)=1;
        end
    end
end
% figure
% imshow(inp);
% title('Threshold image');

%% MORPHOLOGICAL OPERATION
sq = strel('disk',5); % Structural element for morphological operations
tumor = imopen(inp, sq); % Opening operation to remove small objects
tumor = imclose(tumor, sq); % Closing operation to fill gaps
I_gray = im2gray(tumor);
tumor = imbinarize(I_gray); % Ensure the image is in binary format
tumor = bwareafilt(tumor, 1); % Keep only the largest white region

%% OUTLINE
I_bin = imbinarize(I_gray);
rd = imdilate(I_bin, sq); % Dilate the image
r_ext = rd & ~I_bin; % Detect the external boundary
% Create a red channel to overlay on the original image
R = I_gray; G = I_gray; B = I_gray;
R(r_ext) = 255; G(r_ext) = 0; B(r_ext) = 0; % Set the boundary pixels to red
outputImage = cat(3, R, G, B); % Combine the channels to form the output image
% figure;
% imshow(outputImage); 
% title('Tumor Boundary');
merged_image = s;
merged_image(r_ext) = 0;

%% Display Together
figure
subplot(221);imshow(s);title('Input Image');
subplot(222);imshow(filteredImage);title('Filtered Image');
subplot(223);imshow(outputImage);title('Tumor Alone');
subplot(224);imshow(merged_image);title('Detected Tumor');

%% OUTPUT
if all(tumor(:))
    h = msgbox('NO TUMOR!', 'Status');
else
%     figure;
%     imshow(merged_image);
    h = msgbox('TUMOR DETECTED!!', 'Status');
end

