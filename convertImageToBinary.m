function imageBinary = convertImageToBinary(qrCodeImageRGB)
    % convert to grayscale image
    imageGrayScale = rgb2gray(qrCodeImageRGB);
    % convert grayscale image to binary image
    imageBinary = im2bw(imageGrayScale, graythresh(imageGrayScale));
end

