% Convert the given binary string to a string with ISO 8859-1 characters.
% 8 Bits = 1 ISO 8859-1 Character. 
%% AUTHOR    : Joel Holzer 
%% $Revision : 1.00 $ 
%% FILENAME  : convertToIso.m 
function qrCodeResult = convertToIso(dataString)
    %The first 4 chars in the given dataString are the format informations,
    %the second 8 chars are message length informations. The data starts at
    %position the 13 in the string.
    qrCodeStringLength = bin2dec(dataString(5:12));

    % convert binary with ISO 8859-1 to string
    dataStringEnd = 12 + (qrCodeStringLength * 8);
    if dataStringEnd >= length(dataString)
        dataStringEnd = length(dataString) - 1;
    end
    qrCodeContentBin = dataString(12:dataStringEnd);
    startStringLocation = 1;
    qrCodeContentBinLength = length(qrCodeContentBin);
    qrCodeResult = zeros(1, floor(qrCodeContentBinLength / 8));
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
            qrCodeResult(whileCounter) = ' ';
        else
            qrCodeResult(whileCounter) = decChar;
        end
        startStringLocation = endStringLocation + 1;
        whileCounter = whileCounter + 1;
    end
    qrCodeResult = strcat(qrCodeResult);
    qrCodeResult = replaceUmlauts(qrCodeResult);
end

%strcat in the function qrCodeResult transforms decimal chars for ä, ü, and
%ö not correctly to ISO 8859-1. This function replaces this wrong ä,ö,ü 
%values with the correct ä,ö and ü.
function stringWithUmlauts = replaceUmlauts(stringToReplaceUmlauts)
    stringWithUmlauts = strrep(stringToReplaceUmlauts, 'Ã¤', 'ä');
    stringWithUmlauts = strrep(stringWithUmlauts, 'Ã¶', 'ö');
    stringWithUmlauts = strrep(stringWithUmlauts, 'Ã¼', 'ü');
end
