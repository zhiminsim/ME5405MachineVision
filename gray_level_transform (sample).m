% 
% File Name: gray_level_transform
% Type: m file (main program)
% Description: 
% The program demonstrates the application of a gray level transform 
% on an input image. For teaching of ME5405.
% Note: 
% You calculate the execution time using "tic" and "toc". 
% Type "help tic" on Command Window to find out more.
% Date: August 2017
%

clear all;

% option 1 - you can choose the matrix operation or the for loop.
to_use_for_loop = 0; 
%to_use_for_loop = 1;

% read the input image
model = imread('model_web.jpg');
% convert the color image to gray scale image 
% with gray level ranges from 0 to L - 1 and L = 256.
im = rgb2gray(model); colormap(gray);

% display the original image
figure(1);
imshow(im);

% s = T(r) = L-1-r is an example of a gray level transform function.
% This function will produce a negative image of the original image.
% Hence, it is called the Negative transformation.
% You may want to try applying other transformation function on the image.  

% Step 1: Create a new image im_out with the same dimension as im, and
% initialize each pixel value to 0.
a = size(im);
im_out = zeros(a(1), a(2));

% Step 2: For each pixel of the new image, assign the pixel value 
% according to the transformation function.
L = 256;
if to_use_for_loop == 0 
    im_out = L - 1 - im;
else 
    for i = 1:a(1)
        for j = 1:a(2)
            im_out(i,j) = L - 1 - im(i,j);
        end
    end
end
    
% display the transformed/output image
figure(2);
imshow(im_out, [0 L-1]);
