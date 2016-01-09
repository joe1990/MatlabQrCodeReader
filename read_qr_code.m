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
function read_qr_code 

% read QR code image
%[qrCodeImageRGB,map] = imread('Hallo-wie-geht-es-dir-du-schoene-frau.png'); %geht, ausser umlaut
%[qrCodeImageRGB,map] = imread('Dies-ist-ein-qrcode1.jpg'); %geht
%[qrCodeImageRGB,map] = imread('Dies-ist-ein-qrcode3.jpg'); %geht
%[qrCodeImageRGB,map] = imread('Dies-ist-ein-QR-Code.png'); %geht
%[qrCodeImageRGB,map] = imread('Dies-ist-ein-QR-Code-mit.png'); %geht nicht. Problem: alignment pattern wird nicht erkannt
if ~isempty(map)
    qrCodeImageRGB = ind2rgb(qrCodeImageRGB,map);
end
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
findingPatternCounter = 0;
findingPatternAreas = ones(1, 3);
celIndex = 1;
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
        findingPatternCounter = findingPatternCounter + 1;
        findingPatternsCentroids{celIndex} = structLabeledObjects(i).Centroid;
        findingPatternsBBox{celIndex} = structLabeledObjects(i).BoundingBox;
        celIndex = celIndex + 1;
        findingPatternAreas(findingPatternCounter) = structLabeledObjects(i).Area;
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
qrCodeVersion = floor(1 + mod(numberOfPixelsPerEdge,21) / 4);

%read format and error correction infos
formatError1StartX = qrCodePixelSize/2;
formatError1StartY = (qrCodePixelSize * 8) + (qrCodePixelSize / 2);
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
formatError2StartX = (qrCodePixelSize/2) + qrCodePixelSize * 8;
formatError2StartY = qrCodePixelSize * 7 + (qrCodePixelSize/2);
formatError2EndY = (qrCodePixelSize/2);
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
formatErrorString = strcat(formatErrorString(1:6), formatErrorString(8:10), formatErrorString(12:end));

%calculate format mask
formatStringBin = formatErrorString(1:5);
formatStringDec = bin2dec(formatStringBin);
xorOperatorDec = bin2dec('10101');
xorFormatDec = bitxor(formatStringDec, xorOperatorDec);
xorFormatString = dec2bin(xorFormatDec, 5);
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
    for i = 1:numberOfOInCroppedI
        % Loop for every object to the other objects and compare
        number = 0;
        for j = 1:numberOfOInCroppedI
            % the white section of the qr code is the biggest area, then
            % the 3 finding patterns and the the 5th biggest area is the
            % area of one of the alignment patterns
            if structLabeledCropped(i).Area == structLabeledCropped(j).Area
                if structLabeledCropped(i).Area < findingPatternAreas(1) && structLabeledCropped(i).Area < findingPatternAreas(2) && structLabeledCropped(i).Area < findingPatternAreas(3)
                    if findingPatternAreas(1) / 2 == structLabeledCropped(i).Area || (structLabeledCropped(i).Area < findingPatternAreas(1) /2 && structLabeledCropped(i).Area + 50 > findingPatternAreas(1) / 2) || (structLabeledCropped(i).Area > findingPatternAreas(1)  / 2 && structLabeledCropped(i).Area - 50 < findingPatternAreas(1) / 2)
                        number = number + 1;
                    end
                end
            end
        end
        if number == numberOfAlignementPatterns
            %This section is executed for every possible alignement pattern.
            %Checks if the pattern is an alignement pattern and colorized the alignement patterns red
            patternCentroidY = structLabeledCropped(i).Centroid(2);
            patternXStart = structLabeledCropped(i).Centroid(1) - (2 * qrCodePixelSize);
            patternXEnd = structLabeledCropped(i).Centroid(1) + (2 * qrCodePixelSize) + 1;
            
            counter = 1;
            correctColorCounter = 0;
            while patternXStart < patternXEnd
                pixelColors = impixel(croppedImageBinary, patternXStart, patternCentroidY);
                if pixelColors(1) == 0 && (mod(counter, 2) == 1)
                    correctColorCounter = correctColorCounter + 1;
                elseif pixelColors(1) == 1 && (mod(counter, 2) == 0)
                    correctColorCounter = correctColorCounter + 1;
                end
                patternXStart = patternXStart + qrCodePixelSize;
                counter = counter + 1;
            end
            
            %Alignment patterns have the correct color counter = 5
            if correctColorCounter == 5
                
                alignementPatternX = round(structLabeledCropped(i).BoundingBox(1) - qrCodePixelSize);
                alignementPatternXEnd = floor(structLabeledCropped(i).BoundingBox(1) + qrCodePixelSize + structLabeledCropped(i).BoundingBox(3));
                alignementPatternY = round(structLabeledCropped(i).BoundingBox(2) - qrCodePixelSize);
                alignementPatternYEnd = floor(structLabeledCropped(i).BoundingBox(2) + qrCodePixelSize + structLabeledCropped(i).BoundingBox(4));

                croppedImageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,1) = 153;
                croppedImageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,2) = 0;
                croppedImageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,3) = 0;
            end
        end
    end; 
end

%read data (start bottom right)
%coordinates where a column ends when they have a finder pattern.
dataEndBottomY = (qrCodePixelSize * 9);
pixelRowBottom = floor(numberOfPixelsPerEdge);
dataStartBottomY = (qrCodePixelSize * numberOfPixelsPerEdge) - (qrCodePixelSize/2);
pixelColumn = floor(numberOfPixelsPerEdge);
dataString = '';
pixelRow = 8;

maskModuloNumber = checkIfMaskModuloIsOneOrZero(dataStartBottomY, dataStartBottomY, pixelRowBottom, pixelColumn, qrCodePixelSize, maskDec, croppedImageRGB);

while pixelColumn >= 2
    if pixelColumn == floor(numberOfPixelsPerEdge - 8)
        dataEndBottomY = 0;
        pixelRow = 1;
    end
    
    dataStartBottomX = (qrCodePixelSize * pixelColumn) - (qrCodePixelSize/2);
    dataString = strcat(dataString, readColumnBottomUp(dataStartBottomX, dataStartBottomY, dataEndBottomY, pixelRowBottom, pixelColumn, qrCodePixelSize, maskDec, maskModuloNumber, croppedImageRGB));
    dataStartTopY = dataEndBottomY + (qrCodePixelSize/2);
    dataEndTopY = dataStartBottomY;
    dataStartTopX = dataStartBottomX - (2 * qrCodePixelSize);
    
    if pixelColumn > 2
        pixelColumn = pixelColumn - 2;
        dataString = strcat(dataString, readColumnTopDown(dataStartTopX, dataStartTopY, dataEndTopY, pixelRow, pixelColumn, qrCodePixelSize, maskDec, maskModuloNumber, croppedImageRGB));
        %display(strcat(num2str(pixelRow), ',', num2str(pixelRow), ',',readColumnTopDown(dataStartTopX, dataStartTopY, dataEndTopY, pixelRow, pixelColumn, qrCodePixelSize, maskDec, croppedImageRGB)));
    end
    pixelColumn = pixelColumn - 2;
end

% 1 = Numeric (0-9), 2 = Alphanumeric, 3 = ISO 8859-1 
mode = bin2dec(dataString(1:4));
if mode == 4
    modeLength = calculateModeLength(mode, qrCodeVersion);
    qrCodeStringLength = bin2dec(dataString(5:(4 + modeLength)));

    % convert binary with ISO 8859-1 to string
    dataStringEnd = 4 + modeLength + (qrCodeStringLength * 8);
    qrCodeContentBin = dataString(5+modeLength:dataStringEnd);
    startStringLocation = 1;
    qrCodeContentBinLength = length(qrCodeContentBin);
    qrCodeContent = zeros(1, floor(qrCodeContentBinLength / 8));
    whileCounter = 1;
    while startStringLocation <= qrCodeContentBinLength
        endStringLocation = startStringLocation + 7;
        if endStringLocation <= qrCodeContentBinLength
            binToConvert = qrCodeContentBin(startStringLocation:endStringLocation);
        else
            binToConvert = qrCodeContentBin(startStringLocation:end);
        end
        decChar = bin2dec(binToConvert);
        if decChar == 32 
            qrCodeContent(whileCounter) = ' ';
        else
            qrCodeContent(whileCounter) = decChar;
        end
        startStringLocation = endStringLocation + 1;
        whileCounter = whileCounter + 1;
    end
    figure('Name', 'QR-Code-Reader'), imshow(croppedImageRGB);
    title(gca, strcat(qrCodeContent)) 
else
    display('Not an ISO-8859-1 QR-Code! QR-Code Reader cannot read this QR-Code'); 
end

end

function maskModuloNumber = checkIfMaskModuloIsOneOrZero(startX, startY, pixelRow, pixelColumn, pixelSize, maskDec, croppedImageRGB)
    modeStringWithZero = '';
    maskModuloNumber = 0;

    for i = 1:2
        colorRightPixel = impixel(croppedImageRGB, startX, startY);
        colorLeftPixel = impixel(croppedImageRGB, startX - pixelSize, startY);
        
        modeStringWithZero = strcat(modeStringWithZero, calculateDemaskedPixelValue(colorRightPixel, maskDec, maskModuloNumber, pixelRow, pixelColumn));
        modeStringWithZero = strcat(modeStringWithZero, calculateDemaskedPixelValue(colorLeftPixel, maskDec, maskModuloNumber, pixelRow, pixelColumn - 1));
        pixelRow = pixelRow - 1;
        startY = startY - pixelSize;
    end
    mode = bin2dec(modeStringWithZero); 
    if mode ~= 4
        maskModuloNumber = 1;
    end
end

function dataStringBottomUp = readColumnBottomUp(startX, startY, endY, pixelRow, pixelColumn, pixelSize, maskDec, maskModuloNumber, croppedImageRGB)
    dataStringBottomUp = '';
    while startY > endY
        colorRightPixel = impixel(croppedImageRGB, startX, startY);
        colorLeftPixel = impixel(croppedImageRGB, startX - pixelSize, startY);
        
        if pixelRow ~= 7
            dataStringBottomUp = strcat(dataStringBottomUp, calculateDemaskedPixelValue(colorRightPixel, maskDec, maskModuloNumber, pixelRow, pixelColumn));
            dataStringBottomUp = strcat(dataStringBottomUp, calculateDemaskedPixelValue(colorLeftPixel, maskDec, maskModuloNumber, pixelRow, pixelColumn - 1));
        end
        
        pixelRow = pixelRow - 1;
        startY = startY - pixelSize;
    end
end

function dataStringTopDown = readColumnTopDown(startX, startY, endY, pixelRow, pixelColumn, pixelSize, maskDec, maskModuloNumber, croppedImageRGB)
    dataStringTopDown = '';
    while startY <= endY
        colorRightPixel = impixel(croppedImageRGB, startX, startY);
        colorLeftPixel = impixel(croppedImageRGB, startX - pixelSize, startY);

        if pixelRow ~= 7
            dataStringTopDown = strcat(dataStringTopDown, calculateDemaskedPixelValue(colorRightPixel, maskDec, maskModuloNumber, pixelRow, pixelColumn));
            dataStringTopDown = strcat(dataStringTopDown, calculateDemaskedPixelValue(colorLeftPixel, maskDec, maskModuloNumber, pixelRow, pixelColumn - 1));
        end
       
        pixelRow = pixelRow + 1;
        startY = startY + pixelSize;
    end
end

function demaskedPixelValue = calculateDemaskedPixelValue(pixelColors, mask, maskModuloNumber, row, column) 
    if pixelColors(1) == 0
       %white; 
       demaskedPixelValue = '1';
    elseif pixelColors(1) == 1
        %black;
        demaskedPixelValue = '0';
    else
        %red;
        demaskedPixelValue = ' ';
    end
    %display(strcat(demaskedPixelValue, ',', num2str(row), ',', num2str(column)));
    %http://www.its.fd.cvut.cz/ms-en/courses/identification-systems/idfs-qr-code-suplement.pdf
    if demaskedPixelValue == '1' || demaskedPixelValue == '0'
        %apply mask
        if mask == 0
            if mod((row + column),2) == maskModuloNumber
                demaskedPixelValue = invertBit(demaskedPixelValue);
            end
        elseif mask == 1
            if mod(row,2) == maskModuloNumber
                demaskedPixelValue = invertBit(demaskedPixelValue);
            end
        elseif mask == 2
            if mod(column,3) == maskModuloNumber
                demaskedPixelValue = invertBit(demaskedPixelValue);
            end
        elseif mask == 3
            if mod((row + column),3) == maskModuloNumber
                demaskedPixelValue = invertBit(demaskedPixelValue);
            end
        elseif mask == 4
            if mod((floor(row/2) + floor(column/3)),2) == maskModuloNumber
                demaskedPixelValue = invertBit(demaskedPixelValue);
            end
        elseif mask == 5
            if (mod((row * column),2) + mod((row * column),3)) == maskModuloNumber
                demaskedPixelValue = invertBit(demaskedPixelValue);
            end
        elseif mask == 6
            if mod((mod((row * column),2) + (mod((row * column),3))),2) == maskModuloNumber
                demaskedPixelValue = invertBit(demaskedPixelValue);
            end
        elseif mask == 7
            if mod((mod((row * column),2) + (mod((row * column),3))),2) == maskModuloNumber
                demaskedPixelValue = invertBit(demaskedPixelValue);
            end
        end
    end
end 

function invertedBit = invertBit(bitToInvert) 
    if bitToInvert == '0'
        invertedBit = '1';
    else 
        invertedBit = '0';
    end 
end 

function modeLength = calculateModeLength(qrCodeMode, qrCodeVersion)
    modeLength = 100;
    if qrCodeMode == 4
        if qrCodeVersion <= 9
            modeLength = 8;
        elseif qrCodeVersion <= 26
            modeLength = 16;
        else 
            modeLength = 16;
        end
    end
end

