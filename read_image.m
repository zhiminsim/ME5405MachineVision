clear all;

method = '1';
 
switch lower(method)
    case '1'
        disp('Example 1')
        
        % read the input image
        model = imread('model_web.jpg');

        figure(1);
        imshow(model);

        pause;

        whos model
        
        pause;
        
        modelR = model(:, :, 1);
        modelG = model(:, :, 2);
        modelB = model(:, :, 3);
        
        figure(2);
        subplot(1,3,1), subimage(modelR), axis off, title('red channel');
        subplot(1,3,2), subimage(modelG), axis off, title('green channel');
        subplot(1,3,3), subimage(modelB), axis off, title('blue channel');
            
    case '2'
        disp('Example 2')

        % read the input image
        model = imread('model_web.jpg');
        
        modelGray = rgb2gray(model);
        
        figure(3);
        image(modelGray);
        colormap(gray(256));
        
        pause;
        
        choice = 1;
        if choice == 1
            % draw a horizontal line on the image
            x1 = 10; x2 = 610;
            y1 = 450; y2 = 450;
            line( [x1, x2], [y1, y2], 'Color', 'r', 'LineWidth', 1);
        else
            % draw a vertical line on the image
            x1 = 310; x2 = 310;
            y1 = 10; y2 = 890;
            line( [x1, x2], [y1, y2], 'Color', 'r', 'LineWidth', 1);
        end
        
        figure(4);
        % determine and display the intensity profile along the
        % line segment
        improfile(modelGray, [x1, x2], [y1, y2]);
        ylabel('Pixel intensity value');
        title('Intensity profile along the line segment');        
        
    otherwise
        disp('Unknown example.')
end

