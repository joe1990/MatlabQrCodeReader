% READ_QR_CODE: 
% This application finds a QR code in a given image and extraxts the string
% message which is included in the QR code. 
%
% The given image should be a png or jpg image and the qr code location in
% the image can be different for every image. Only important is, than the
% qr code in the image is completely (no errors) and both colors are
% contrasty. The text in the QR code can contains charagters, digits and
% special chars in the format ISO-8859-1. 
% This QR code reader support all the different QR code versions, from
% version 1 (21 x 21 modules) to version 40 (177 x 177 modules).
%   
%% AUTHOR    : Joel Holzer
%% $DATE     : 09.12.2015 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : R2015a 
%% FILENAME  : read_qr_code.m 

% read QR code image
qrCodeImageRGB = imread('qrcode-red.jpg');
% convert to grayscale image
imageGrayScale = rgb2gray(qrCodeImageRGB);
% convert grayscale image to binary image
imageBinary = im2bw(imageGrayScale, graythresh(imageGrayScale));
% find 3 finders pattern with connected components labeling
% http://homepages.inf.ed.ac.uk/rbf/HIPR2/label.htm
% http://pille.iwr.uni-heidelberg.de/~ocr02/MATLAB-%20Befehle3.html
% create matrix labeled, where every connected pixel in the binary image
% gets the same number in labeled. The number of objects is saved in
% numberOfObjects.
[labeled, numberOfObjects]= bwlabel(imageBinary, 8);
% Creates a structure for every object in labeled (3 finder
% pattern, 1 border pattern and alignement patterns)
structLabeledObjects = regionprops(labeled, 'all');  

% Loop through every object and get area centroid and bounding box
% informations about the 3 finder patterns.
findingPatternsCentroids = cell(3, 1);
findingPatternsBBox= cell(3, 1);
celIndex = 1;
for i = 1:numberOfObjects
    % Loop for every object to the other objects and compare, if area is
    % the same in 2 other objects, it is a finder pattern.
    number = 0;
    for j = 1:numberOfObjects
        if structLabeledObjects(i).Area == structLabeledObjects(j).Area
            number = number + 1;
        end
    end
    if number == 3
        findingPatternsCentroids{celIndex} = structLabeledObjects(i).Centroid;
        findingPatternsBBox{celIndex} = structLabeledObjects(i).BoundingBox;
        celIndex = celIndex + 1;
    end
end
%crop image
qrCodePixelSize = findingPatternsBBox{1}(3) / 5;
topLeftXCroppedImage = findingPatternsBBox{1}(1) - qrCodePixelSize;
topLeftYCroppedImage = findingPatternsBBox{1}(2) - qrCodePixelSize;
sizeCroppedImage = (findingPatternsBBox{3}(1) + findingPatternsBBox{3}(3)) - topLeftXCroppedImage + qrCodePixelSize;
croppedImageBinary = imcrop(imageBinary, [topLeftXCroppedImage, topLeftYCroppedImage, sizeCroppedImage, sizeCroppedImage]);
%display(findingPatternsCentroids);
%display(findingPatternsBBox);
figure,imshow(croppedImageBinary)
