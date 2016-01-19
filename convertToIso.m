function qrCodeResult = convertToIso(dataString, mode, qrCodeVersion)
    modeLength = calculateModeLength(mode, qrCodeVersion);
    qrCodeStringLength = bin2dec(dataString(5:(4 + modeLength)));

    % convert binary with ISO 8859-1 to string
    dataStringEnd = 4 + modeLength + (qrCodeStringLength * 8);
    if dataStringEnd >= length(dataString)
        dataStringEnd = length(dataString) - 1;
    end
    qrCodeContentBin = dataString(5+modeLength:dataStringEnd);
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

