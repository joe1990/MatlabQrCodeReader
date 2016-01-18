function [maskDec, maskBin, xorFormatString] = calculateMask(formatStringBin)
    %calculate format mask
    formatStringDec = bin2dec(formatStringBin);
    xorOperatorDec = bin2dec('10101');
    xorFormatDec = bitxor(formatStringDec, xorOperatorDec);
    xorFormatString = dec2bin(xorFormatDec, 5);
    maskBin = xorFormatString(3:5);
    maskDec = bin2dec(maskBin);
end

