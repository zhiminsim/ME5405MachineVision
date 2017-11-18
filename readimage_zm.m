function readimage_zm

    image1 = readCharacterImage;
    image2 = imread ('charact2.bmp'); %read the image from the root file
    image2 = image2(:,:,3); %save bmp file as an array
    image2 = thresholdimage (image2); %threshold the image and save it into image1bw
    
    for i = 1:200        
        image2 = medianFilter (image2); %apply median filter to the image
    end
    
    image2 = smoothImageEdge (image2);
    image2 = removeSmall (image2);
    
    %image pre-processing and filtering done above this line
    
    boundaryTrace(image1);
    boundaryTrace(image2);

    array1 = connectedComponents(image1);
   %{ 
    for i = 1:numel(array1)
        figure
        imshow(array1{i})
    end
    %}
    array2 = connectedComponents (image2);
    %{ 
    for i = 1:numel(array2)
        figure
        imshow(array2{i})
    end
    %}
    %rotateSegment90cw(array1);
    %rotateSegment90cw(array2);
    %rotateSegment30ccw(array1);
    %rotateSegment30ccw(array2);

end

function bw = thresholdimage (img) %return bw with argument img
    figure
    imshow(img); %show the image
    bw = im2bw(img, 0.5); %#ok<IM2BW> %thresholding
    figure
    imshow(bw);
end

function mF = medianFilter (img)
    mF = medfilt2(img);
end

function sI = smoothImageEdge (img) %smooth out the edges of the characters with a size 1 disk
    sI = imdilate(img,strel('disk',1));
end

function reArray = connectedComponents (img) %create connectivity factor and segment into RGB colours
    initialDisp =  zeros(size(img));

    
    CC = bwconncomp (img, 26);
    reArray = cell(1,(CC.NumObjects) * 2); 
    rotatedImagesArray = cell(1,(CC.NumObjects) * 2); 
    rotatedImagesArray2 = cell(1,(CC.NumObjects) * 2); 
    var = (regionprops (CC, 'BoundingBox', 'Image'));
    q=1;
    
    for k = 1:CC.NumObjects %{ Loop through each object and plot it in white. 
                                %This is where you can create individual figures for each object.

        PixId = CC.PixelIdxList{k}; %// Just simpler to understand
        cropArea = var(k).BoundingBox;
        
        if size(PixId,1) ==1 %// If only one row, don't consider.        
            continue
        else
            BW2 = zeros(size(img)); %// Create dummy image for display purposes.
            BW2(PixId) = 255;
            BW2 = imcrop(BW2, cropArea);
            NArea = bwarea (BW2);
            if NArea > 5000
               n = fix(size(BW2,1)/2);
               A = BW2(:,1:(end/2) - 4);
               B = BW2(:,end/2+1-4:end);
                
               reArray{q}= A;
               reArray{q+1} = B;
               q=q+2;
               
                % ROTATION HERE (-90)
                C = imrotate(A, -90);
                C = insertIntoImage(initialDisp, C, cropArea(2), cropArea(1));
                D = imrotate(B, -90);
                D = insertIntoImage(initialDisp, D, cropArea(2), cropArea(1) + (cropArea(4) / 2));

               rotatedImagesArray{q-2}= C;
               rotatedImagesArray{q-1} = D;
               
                % ROTATION HERE (30)
                E = imrotate(A, 30);
                E = insertIntoImage(initialDisp, E, cropArea(2), cropArea(1));
                F = imrotate(B, 30);
                F = insertIntoImage(initialDisp, F, cropArea(2), cropArea(1) + (cropArea(4) / 2));

               rotatedImagesArray2{q-2}= E;
               rotatedImagesArray2{q-1} = F;
               
                
            else            
                reArray{q} = BW2;
                q=q+1;
                
                % ROTATION HERE (-90)
                A = imrotate(BW2, -90);
                B = insertIntoImage(initialDisp, A, cropArea(2), cropArea(1));
                rotatedImagesArray{q-1}= B;
                
                % ROTATION HERE (30)
                C = imrotate(BW2, 30);
                D = insertIntoImage(initialDisp, C, cropArea(2), cropArea(1));
                rotatedImagesArray2{q-1}= D;
                
            end
        end
    end
    
    % RESIZING CELL ARRAYS
    reArray = reArray(1:(q-1));
    rotatedImagesArray = rotatedImagesArray(1:(q-1));
    rotatedImagesArray2 = rotatedImagesArray2(1:(q-1));
    
    % DISPLAY -90 DEG ROTATION
    initialDisp = findLargestBackground(rotatedImagesArray);
    for k = 1:q-1
       newimg = rotatedImagesArray{k};
       newimgsize = size(newimg);
       initialDisp(1:newimgsize(1), 1:newimgsize(2)) = initialDisp(1:newimgsize(1), 1:newimgsize(2)) + newimg ;
    end
    figure
    imshow(initialDisp)
    
    % DISPLAY 30 DEG ROTATION
    initialDisp = findLargestBackground(rotatedImagesArray2);
    for k = 1:q-1
       newimg = rotatedImagesArray2{k};
       newimgsize = size(newimg);
       initialDisp(1:newimgsize(1), 1:newimgsize(2)) = initialDisp(1:newimgsize(1), 1:newimgsize(2)) + newimg ;
    end
    figure
    imshow(initialDisp)
    
    % Gets OCRed version of image. Need to get the ".Word" component out
    % from 
    for k = 1:q-1
        figure
        A = padarray(reArray{k}, [5 5]) ;
        imshow(A)
        ocrres = ocr(A, 'TextLayout', 'Block', 'CharacterSet', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');
        word = ocrres.Words{1};
    end
    

    %labeled = labelmatrix (CC);
    %RGB_label = label2rgb(labeled);    
    %imshow (RGB_label);
    %RGB_label = bwareaopen(img, 200);
end

function newImg = insertIntoImage(baseImg, imageToInsert, startrow, startcol) 
    newImg =  zeros(size(baseImg));
    newImg(startrow:startrow+size(imageToInsert,1)-1,startcol:startcol+size(imageToInsert,2)-1) = imageToInsert;
end

% Create an image with a large enough background to contain all images in
% the input cell array
function largeEnoughBackground = findLargestBackground(rotatedImagesArray)
    maxDim = 0;
    for k = 1:length(rotatedImagesArray)
        maxDim = max(maxDim, size(rotatedImagesArray{k}));
    end
    largeEnoughBackground = zeros(maxDim);
end

function boundaryTrace(image) %trace the perimeter of the binary image argument
    bT = bwperim(image, 8);
    figure
    imshow(bT)
end

function rotateSegment90cw(array)
    Rarray = {};
    for i = 1:numel(array)
        Rarray{i} = imrotate(array{i},-90);
    end
    for i = 1:numel(Rarray)
        figure
        imshow(Rarray{i})
    end      
end

function rotateSegment30ccw(array)
    Rarray = {};
    for i = 1:numel(array)
        Rarray{i} = imrotate(array{i},30);
    end
    for i = 1:numel(Rarray)
        figure
        imshow(Rarray{i})
    end      
end

function rS = removeSmall (img) %remove any connected components below pixel count of 200
    rS = bwareaopen(img,200);
end

function img = readCharacterImage %for processing txt file to img file
    filetext = fileread('charact1.txt');
    idxs = ((filetext >= '0' & filetext <= '9') | (filetext >= 'A' & filetext <= 'Z'));
    img = filetext(idxs);
    img(img~='0') = '1';
    img = img - '0';
    img = reshape(img, [64 64])';
end