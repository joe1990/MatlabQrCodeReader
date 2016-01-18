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
function qrCodeImage = read_qr_code(croppedImageBinary, finderPatternAreas, qrCodePixelSize, sizeCroppedImage) 


%read data (start bottom right)
dataEndBottomY = (qrCodePixelSize * 9);
pixelRowBottom = floor(numberOfPixelsPerEdge);
dataStartBottomY = (qrCodePixelSize * numberOfPixelsPerEdge) - (qrCodePixelSize/2);
pixelColumn = floor(numberOfPixelsPerEdge);
dataString = '';
pixelRow = 10;

maskModuloNumber = checkIfMaskModuloIsOneOrZero(dataStartBottomY, dataStartBottomY, pixelRowBottom, pixelColumn, qrCodePixelSize, maskDec, croppedImageRGB);

while pixelColumn >= 2
    if pixelColumn == floor(numberOfPixelsPerEdge - 8)
        dataEndBottomY = 0;
        pixelRow = 1;
    end
    
    dataStartBottomX = (qrCodePixelSize * pixelColumn) - (qrCodePixelSize/2);
    dataString = strcat(dataString, readColumnBottomUp(dataStartBottomX, dataStartBottomY, dataEndBottomY, pixelRowBottom, pixelColumn, qrCodePixelSize, maskDec, maskModuloNumber, croppedImageRGB));
    dataStartTopY = dataEndBottomY + (qrCodePixelSize/2);
    %add pixelSize/3 for inaccurate pixel
    dataEndTopY = dataStartBottomY + (qrCodePixelSize/3);
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
        display(strcat(num2str(whileCounter), ':', binToConvert));
        decChar = bin2dec(binToConvert);
        if decChar == 32 
            qrCodeContent(whileCounter) = ' ';
        else
            qrCodeContent(whileCounter) = decChar;
        end
        startStringLocation = endStringLocation + 1;
        whileCounter = whileCounter + 1;
    end
    
    display('qr code was successfully read');
    display(strcat(qrCodeContent));
    imageTitle = strcat('Version:', num2str(qrCodeVersion), ' Text:', qrCodeContent);
    figure('Name', 'QR-Code-Reader'), imshow(croppedImageRGB);
    title(gca, imageTitle) 
else
    display('Not an ISO-8859-1 QR-Code! QR-Code Reader cannot read this QR-Code'); 
end

    qrCodeImage = croppedImageRGB;
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
        %black;
       demaskedPixelValue = '1';
    elseif pixelColors(1) == 1
        %white;
        demaskedPixelValue = '0';
    else
        %red;
        demaskedPixelValue = ' ';
    end
    
    row = row - 1;
    column = column - 1;
    
    display(strcat(demaskedPixelValue, ',', num2str(row), ',', num2str(column)));
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
            if mod(mod((row * column), 3) + row + column, 2) == maskModuloNumber
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

