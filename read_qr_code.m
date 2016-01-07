% READ_QR_CODE: 
% This application finds a QR code in a given image and extraxts the string
% message which is included in the QR code. 
%
% The given image should be a png or jpg image and the qr code location in
% the image can be different for every image. Only important is, than the
% qr code in the image is completely (no errors) and both colors are
% contrasty. The text in the QR code can contains characters, digits and
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
qrCodeImageRGB = imread('Dies-ist-ein-qrcode.jpg');
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
findingPatternArea = 0;
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
        findingPatternArea = structLabeledObjects(i).Area;
    end
end
%crop image that only the qr code is part of the image
qrCodePixelSize = findingPatternsBBox{1}(3) / 5;
topLeftXCroppedImage = findingPatternsBBox{1}(1) - qrCodePixelSize;
topLeftYCroppedImage = findingPatternsBBox{1}(2) - qrCodePixelSize;
sizeCroppedImage = (findingPatternsBBox{3}(1) + findingPatternsBBox{3}(3)) - topLeftXCroppedImage + qrCodePixelSize;
croppedImageBinary = imcrop(imageBinary, [topLeftXCroppedImage, topLeftYCroppedImage, sizeCroppedImage, sizeCroppedImage]);

%calculate qr code version
numberOfPixelsPerEdge = sizeCroppedImage / qrCodePixelSize;
qrCodeVersion = 1 + mod(numberOfPixelsPerEdge,21) / 4;
display(qrCodeVersion);

%read format and error correction infos
formatError1StartX = 1;
formatError1StartY = (qrCodePixelSize * 8) + 1;
formatError1EndX = qrCodePixelSize * 9;
formatErrorString = '';
while formatError1StartX < formatError1EndX
    pixelColors = impixel(croppedImageBinary,formatError1StartX,formatError1StartY);
    if pixelColors(1) == 0
       formatErrorString = strcat(formatErrorString, '1'); 
    else
       formatErrorString = strcat(formatErrorString, '0');
    end
    formatError1StartX = formatError1StartX + qrCodePixelSize;
end
formatError2StartX = 1 + qrCodePixelSize * 8;
formatError2StartY = qrCodePixelSize * 8 - 1;
formatError2EndY = 1;
while formatError2StartY > formatError2EndY
    pixelColors = impixel(croppedImageBinary,formatError2StartX,formatError2StartY);
    if pixelColors(1) == 0
       formatErrorString = strcat(formatErrorString, '1'); 
    else
       formatErrorString = strcat(formatErrorString, '0');
    end
    formatError2StartY = formatError2StartY - qrCodePixelSize;
end
% Remove timing pattern pixel from format string
formatErrorString = strcat(formatErrorString(1:6), formatErrorString(8:9), formatErrorString(11:end));
display(formatErrorString);

%calculate format mask
formatStringBin = formatErrorString(1:5);
formatStringDec = bin2dec(formatStringBin);
xorOperatorDec = bin2dec('10101');
xorFormatDec = bitxor(formatStringDec, xorOperatorDec);
xorFormatString = dec2bin(xorFormatDec, 5);
errorCorrectionLevelBin = xorFormatString(1:2);
maskBin = xorFormatString(3:5);
maskDec = bin2dec(maskBin);

if qrCodeVersion >= 7
   %QR-Code hat noch die Versionsnummer integriert. Mehr siehe http://www.thonky.com/qr-code-tutorial/format-version-information     
end

% convert binary image to rgb image for further use
croppedImageRGB = double(cat(3, croppedImageBinary, croppedImageBinary, croppedImageBinary));

% search alignement patterns and colorize the alignement patterns (red), if
% qrCodeVersion > 1.
if qrCodeVersion > 1
    if qrCodeVersion <= 6
        numberOfAlignementPatterns = 1;
    elseif qrCodeVersion <= 13
        numberOfAlignementPatterns = 6;
    elseif qrCodeVersion <= 20
        numberOfAlignementPatterns = 13;
    elseif qrCodeVersion <= 27
        numberOfAlignementPatterns = 22;
    elseif qrCodeVersion <= 34
        numberOfAlignementPatterns = 33;
    elseif qrCodeVersion <= 40
        numberOfAlignementPatterns = 46;
    end
    
    [labeledCroppedImage, numberOfOInCroppedI]= bwlabel(croppedImageBinary, 8);
    % Creates a structure for every object in labeled (3 finder
    % pattern, 1 border pattern and alignement patterns)
    structLabeledCropped = regionprops(labeledCroppedImage, 'all');  
    % Loop through every object.
    for i = 1:numberOfObjects
        % Loop for every object to the other objects and compare, if area is
        % the same in 2 other objects, it is a finder pattern.
        number = 0;
        for j = 1:numberOfObjects
            if (structLabeledCropped(i).Area == structLabeledCropped(j).Area) && (structLabeledCropped(i).Area < findingPatternArea)
                number = number + 1;
            end
        end
        if number == numberOfAlignementPatterns
            %This section is executed for every alignement pattern.
            %Colorized the alignement patterns red
            display(structLabeledCropped(i).BoundingBox);
            alignementPatternX = round(structLabeledCropped(i).BoundingBox(1) - qrCodePixelSize);
            alignementPatternXEnd = floor(structLabeledCropped(i).BoundingBox(1) + qrCodePixelSize + structLabeledCropped(i).BoundingBox(3));
            alignementPatternY = round(structLabeledCropped(i).BoundingBox(2) - qrCodePixelSize);
            alignementPatternYEnd = floor(structLabeledCropped(i).BoundingBox(2) + qrCodePixelSize + structLabeledCropped(i).BoundingBox(4));
            
            croppedImageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,1) = 153;
            croppedImageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,2) = 0;
            croppedImageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,3) = 0;
        end
    end; 
end

%read data (start bottom right)
dataStartX = (qrCodePixelSize * numberOfPixelsPerEdge) - 1;
dataStartY = dataStartX;
%coordinates where a column ends when they have a finding pattern.
dataColumnEndFindingPatternY = (qrCodePixelSize * 8);


%display(findingPatternsCentroids);
%display(findingPatternsBBox);
figure,imshow(croppedImageRGB)