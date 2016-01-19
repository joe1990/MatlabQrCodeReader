function [dataString, dataStringWithoutMask] = readData(croppedImageRGB, qrCodePixelSize, numberOfPixelsPerEdge, maskDec)

    %read data (start bottom right)
    dataEndBottomY = (qrCodePixelSize * 9);
    pixelRowBottom = floor(numberOfPixelsPerEdge);
    dataStartBottomY = (qrCodePixelSize * numberOfPixelsPerEdge) - (qrCodePixelSize/2);
    pixelColumn = floor(numberOfPixelsPerEdge);
    dataString = '';
    pixelRow = 10;
    maskModuloNumber = 0;
    while pixelColumn >= (numberOfPixelsPerEdge / 2)
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
        end
        pixelColumn = pixelColumn - 2;
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

