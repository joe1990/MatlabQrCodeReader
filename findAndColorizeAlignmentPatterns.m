% Finds the alignment patterns (qr code v2 or greater have at least 1).
% Colorize the alignment patterns red in the image and return this image.
%% AUTHOR    : Joel Holzer 
%% $Revision : 1.00 $ 
%% FILENAME  : findAndColorizeAlignmentPatterns.m 
function imageRGB = findAndColorizeAlignmentPatterns(binaryImage, qrCodeVersion, qrCodePixelSize, finderPatternAreas)
    % convert binary image to rgb image for further use
    imageRGB = double(cat(3, binaryImage, binaryImage, binaryImage));

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

        [labeledCroppedImage, numberOfOInCroppedI]= bwlabel(binaryImage, 8);
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
                    if structLabeledCropped(i).Area < finderPatternAreas{1} && structLabeledCropped(i).Area < finderPatternAreas{2} && structLabeledCropped(i).Area < finderPatternAreas{3}
                        if finderPatternAreas{1} / 2 == structLabeledCropped(i).Area || (structLabeledCropped(i).Area < finderPatternAreas{1} /2 && structLabeledCropped(i).Area + 50 > finderPatternAreas{1} / 2) || (structLabeledCropped(i).Area > finderPatternAreas{1}  / 2 && structLabeledCropped(i).Area - 50 < finderPatternAreas{1} / 2)
                            number = number + 1;
                        end
                    end
                end
            end
            % >= test, because sometimes is another connected section in the qr
            % code which have the same size than the alignement patterns. 
            if number >= numberOfAlignementPatterns
                %This section is executed for every possible alignement pattern.
                %Checks if the pattern is an alignement pattern and colorized the alignement patterns red
                patternCentroidY = structLabeledCropped(i).Centroid(2);
                patternXStart = structLabeledCropped(i).Centroid(1) - (2 * qrCodePixelSize);
                patternXEnd = structLabeledCropped(i).Centroid(1) + (2 * qrCodePixelSize) + 1;

                counter = 1;
                correctColorCounter = 0;
                while patternXStart < patternXEnd
                    pixelColors = impixel(binaryImage, patternXStart, patternCentroidY);
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

                    imageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,1) = 153;
                    imageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,2) = 0;
                    imageRGB(alignementPatternX:alignementPatternXEnd,alignementPatternY:alignementPatternYEnd,3) = 0;
                end
            end
        end; 
    end
end

