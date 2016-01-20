% Convert the given image to a grayscale and then to a binary image. The
% binary image is returned from the function.
%% AUTHOR    : Joel Holzer 
%% $Revision : 1.00 $ 
%% FILENAME  : convertImageToBinary.m 
function imageBinary = convertImageToBinary(qrCodeImageRGB)
    % convert to grayscale image
    imageGrayScale = rgb2gray(qrCodeImageRGB);
    % convert grayscale image to binary image
    imageBinary = im2bw(imageGrayScale, graythresh(imageGrayScale));
end

