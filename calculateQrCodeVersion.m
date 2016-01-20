% Calculates the version of the qr code. The version depends of the number
% of modules from the qr-code. 21 x 21 modules = version 1, 25 x 25 modules = version 2, 
% 29 x 29 modules = version 3, ...
% The function returns the following:
% - qrCodeVersion = The version number of the qr code
% - formulaString = The formulate to calculate the version number (as
% string)
% - numberOfPixelsPerEdge = number of modules per edge, 21 for version 1,
% 25 for version 2, and so on...
%% AUTHOR    : Joel Holzer 
%% $Revision : 1.00 $ 
%% FILENAME  : calculateQrCodeVersion.m 
function [qrCodeVersion, formulaString, numberOfPixelsPerEdge] = calculateQrCodeVersion(sizeCroppedImage, qrCodePixelSize)
    numberOfPixelsPerEdge = round(sizeCroppedImage / qrCodePixelSize);
    pixelGreaterThan21 = floor(numberOfPixelsPerEdge) - 21;
    
    if pixelGreaterThan21 > 0
        qrCodeVersion = 1 + (pixelGreaterThan21 / 4);
    else
        qrCodeVersion = 1;
    end
    
    formulaString = strcat('1 + ((', num2str(numberOfPixelsPerEdge), ' - 21) / 4)');
end

