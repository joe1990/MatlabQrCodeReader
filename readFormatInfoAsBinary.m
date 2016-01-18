function formatStringBin = readFormatInfoAsBinary(imageBinary, qrCodePixelSize)

    %read format infos
    formatStartX = qrCodePixelSize/2;
    formatStartY = (qrCodePixelSize * 8) + (qrCodePixelSize / 2);
    formatEndX = qrCodePixelSize * 5;
    formatStringBin = '';
    while formatStartX < formatEndX
        pixelColors = impixel(imageBinary,formatStartX,formatStartY);
        if pixelColors(1) == 0
           formatStringBin = strcat(formatStringBin, '1'); 
        else
           formatStringBin = strcat(formatStringBin, '0');
        end
        formatStartX = formatStartX + qrCodePixelSize;
    end
end

