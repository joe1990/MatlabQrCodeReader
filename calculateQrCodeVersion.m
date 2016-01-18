function [qrCodeVersion, formulaString] = calculateQrCodeVersion(sizeCroppedImage, qrCodePixelSize)
    numberOfPixelsPerEdge = round(sizeCroppedImage / qrCodePixelSize);
    pixelGreaterThan21 = floor(numberOfPixelsPerEdge) - 21;
    
    if pixelGreaterThan21 > 0
        qrCodeVersion = 1 + (pixelGreaterThan21 / 4);
    else
        qrCodeVersion = 1;
    end
    
    formulaString = strcat('1 + ((', num2str(numberOfPixelsPerEdge), ' - 21) / 4)');
end

