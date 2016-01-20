% Reads the format info from the given qr code image (binary image).
% The format string starts in the 8 line from top and contains the value
% of the first 5 modules.
% The function returns the following:
% - formatStringBin = readed format string as binary value
% 25 for version 2, and so on...
%% AUTHOR    : Joel Holzer 
%% $Revision : 1.00 $ 
%% FILENAME  : readFormatInfoAsBinary.m 
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

