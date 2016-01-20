% Finds the three finder patterns of the qr code and crop the image that 
% only the qr code is part of the image. use bwlabel and regionprops to 
% make this step. The function returns the following:
% - croppedBinaryImage = The cropped image as binary image
% - finderPatternAreas = contains the area size of the 3 finder patterns. Is
% returned because in some qr-codes the area has not the same size, but
% nearly the same. And is used later to compare when searching the
% alignment patterns.
% - qrCodePixelSize = The size in px of one module (black or white square)
% in the qr-code-image.
% - sizeCroppedImage = The with or height of the cropped image in px.
%% AUTHOR    : Joel Holzer 
%% $Revision : 1.00 $ 
%% FILENAME  : findFinderPatternsAndCropImage.m 
function [croppedBinaryImage, finderPatternAreas, qrCodePixelSize, sizeCroppedImage]  = findFinderPatternsAndCropImage(binaryImage)
    % find 3 finders pattern with connected components labeling
    % http://homepages.inf.ed.ac.uk/rbf/HIPR2/label.htm
    % http://pille.iwr.uni-heidelberg.de/~ocr02/MATLAB-%20Befehle3.html
    % create matrix labeled, where every connected pixel in the binary image
    % gets the same number in labeled. The number of objects is saved in
    % numberOfObjects.
    [labeled, numberOfObjects] = bwlabel(binaryImage, 8);
    % Creates a structure for every object in labeled (3 finder
    % pattern, 1 border pattern and alignement patterns)
    structLabeledObjects = regionprops(labeled, 'all');  
    
    % Loop through every object and get area centroid and bounding box
    % informations about the 3 finder patterns.
    finderPatternCounter = 1;
    possibleFinderPatterns = cell(10, 2);
    % initialize first column of every row in cell with 0 -> needed later for
    % sorting.
    for i = 1:10
        possibleFinderPatterns{i, 1} = 0;
    end

    for i = 1:numberOfObjects
        % Loop for every object to the other objects and compare, if area is
        % the same in 2 other objects, it is a finder pattern.
        number = 0;
        for j = 1:numberOfObjects
            % sometimes, the finder patterns have not the same area size,
            % checks also near area sizes (+- 50)
            if (structLabeledObjects(i).Area == structLabeledObjects(j).Area) || ((structLabeledObjects(i).Area > structLabeledObjects(j).Area - 50) && (structLabeledObjects(i).Area < structLabeledObjects(j).Area)) || ((structLabeledObjects(i).Area < structLabeledObjects(j).Area + 50) && (structLabeledObjects(i).Area > structLabeledObjects(j).Area)) 
                number = number + 1;
            end
        end
        if number == 3
            possibleFinderPatterns{finderPatternCounter, 1} = structLabeledObjects(i).Area;
            possibleFinderPatterns{finderPatternCounter, 2} = structLabeledObjects(i).BoundingBox;
            finderPatternCounter = finderPatternCounter + 1;
        end
    end
    possibleFinderPatterns = sortrows(possibleFinderPatterns, 1);
    
    %create cell with the area size of the 3 finder patterns (for further
    %usage)
    finderPatternAreas = cell(3, 1);
    finderPatternAreas{1} = possibleFinderPatterns{8, 1};
    finderPatternAreas{2} = possibleFinderPatterns{9, 1};
    finderPatternAreas{3} = possibleFinderPatterns{10, 1};
    
    %calculate size of one pixel (finder pattern has 5x5 pixels)
    qrCodePixelSize = possibleFinderPatterns{8, 2}(3) / 5;
    
    %crop image that only the qr code is part of the image
    topLeftXCroppedImage = possibleFinderPatterns{8, 2}(1) - qrCodePixelSize;
    topLeftYCroppedImage = possibleFinderPatterns{8, 2}(2) - qrCodePixelSize;
    
    sizeCroppedImage = (possibleFinderPatterns{10, 2}(1) + possibleFinderPatterns{10, 2}(3)) - topLeftXCroppedImage + qrCodePixelSize;
    croppedBinaryImage = imcrop(binaryImage, [topLeftXCroppedImage, topLeftYCroppedImage, sizeCroppedImage, sizeCroppedImage]);  
end


