% QR-Code Reader: 
% This application finds a QR code in a given image and extraxts the string
% message which is included in the QR code. 
%
% The given image should be a png image and the qr code location in
% the image can be different for every image. Only important is, than the
% qr code in the image is completely (no errors) and both colors are
% contrasty. The text in the QR code can contains characters in ISO-8859-1.
% Other formats are not supported.
% This QR code reader supports only QR code versions from 1 (21 x 21 modules)
% to 5 (37 x 37 modules).
%
% This is the main class from the application.
%   
%% AUTHOR    : Joel Holzer
%% $DATE     : 20.01.2016 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : R2015a 
%% FILENAME  : gui.m 
function varargout = matlabQrCodeGui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @matlabQrCodeGui_OpeningFcn, ...
                   'gui_OutputFcn',  @matlabQrCodeGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);

if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before matlabQrCodeGui is made visible.
function matlabQrCodeGui_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for matlabQrCodeGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = matlabQrCodeGui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function txtPath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when the text in path-textfield changed. Saves the given
% path in a local variable
function txtPath_Callback(hObject, eventdata, handles)
% hObject    handle to txtPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPath as text
%        str2double(get(hObject,'String')) returns contents of txtPath as a double
% Save the new path value
handles.path = get(hObject, 'String');
guidata(hObject,handles);

% --- Executes on button press in btnSelectFile. Displays a dialog to open
% a file on the computer.
function btnSelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,pathName] = uigetfile('*.png');
handles.path = strcat(pathName, fileName);
set(handles.txtPath, 'string', handles.path);
guidata(hObject,handles);

% --- Executes on button press in btnReadImage. Read the qr-code-image on
% the given path and display all reading steps in the gui
function btnReadImage_Callback(hObject, eventdata, handles)
%set gui to initial status (reset axes and set text) and refresh gui
cla(handles.axesQrCodeImage1);
cla(handles.axesQrCodeImage2);
cla(handles.axesQrCodeImage3);
cla(handles.axesQrCodeImage5);
cla(handles.axesQrCodeImage7);
cla(handles.axesQrCodeImage8);
cla(handles.axesQrCodeImage9);
set(handles.txtStep3Value,'string', '');
set(handles.txtVersion,'string', '');
set(handles.txtStep4Value,'string', '');
set(handles.txtStep5Value,'string', '');
set(handles.txtStep5Value2, 'string', '');
set(handles.txtValueStep7Data, 'string', '');
set(handles.txtQrCodeResult, 'string', '');
drawnow();

if isempty(handles.txtPath.String)
    msgbox('Sie haben keine Datei ausgewählt.','keine Datei ausgewählt');
else
    fileEnding = handles.txtPath.String(length(handles.txtPath.String) - 3: end);
    if ~strcmp(fileEnding, '.png')
         msgbox('Die ausgewählte Datei ist kein .PNG File','kein PNG-File ausgewählt');
    else
        %Inital step: display loaded image in axesQrCodeImage1
        [qrCodeImageRGB,map] = imread(handles.path);
        if ~isempty(map)
            qrCodeImageRGB = ind2rgb(qrCodeImageRGB,map);
        end
        set(handles.axesQrCodeImage1,'visible','on');
        axes(handles.axesQrCodeImage1);
        imshow(qrCodeImageRGB);
        drawnow();

        %Step 1: display binary image in axesQrCodeImage2
        binaryImage = convertImageToBinary(qrCodeImageRGB);
        set(handles.axesQrCodeImage2,'visible','on');
        axes(handles.axesQrCodeImage2);
        imshow(binaryImage);
        drawnow();

        %Step 2: find finder patterns, crop image and display in axesQrCodeImage3
        [croppedBinaryImage, finderPatternAreas, qrCodePixelSize, sizeCroppedImage] = findFinderPatternsAndCropImage(binaryImage);
        set(handles.axesQrCodeImage3,'visible','on');
        axes(handles.axesQrCodeImage3);
        imshow(croppedBinaryImage);
        drawnow();

        %colorize the tree finder patterns with a green rectangle
        finderPatternWidthHeight = round(qrCodePixelSize * 7);
        finderPatternsEnd = round(sizeCroppedImage) + 1;
        drawnow();

        %left finder pattern
        rectangle('Position', [1 1 finderPatternWidthHeight finderPatternWidthHeight], 'EdgeColor','g', 'LineWidth',3);
        %right finder pattern
        rectangle('Position', [(finderPatternsEnd-finderPatternWidthHeight) 1 finderPatternWidthHeight finderPatternWidthHeight], 'EdgeColor','g', 'LineWidth',3);
        %bottom left finder pattern
        rectangle('Position', [1 (finderPatternsEnd-finderPatternWidthHeight) finderPatternWidthHeight finderPatternWidthHeight], 'EdgeColor','g', 'LineWidth',3);

        %Step 3: calculate qr code version
        [qrCodeVersion, formulaString, numberOfPixelsPerEdge] = calculateQrCodeVersion(sizeCroppedImage, qrCodePixelSize);
        set(handles.txtStep3Value,'string', formulaString);
        set(handles.txtVersion,'string', strcat('Version: ', num2str(qrCodeVersion)));
        drawnow();

        %Step 4: read format info
        formatInfoBin = readFormatInfoAsBinary(croppedBinaryImage, qrCodePixelSize);
        set(handles.axesQrCodeImage5,'visible','on');
        axes(handles.axesQrCodeImage5);
        imshow(croppedBinaryImage);
        rectangle('Position', [1 (1 + 8 * qrCodePixelSize) (5 * qrCodePixelSize) qrCodePixelSize], 'EdgeColor','g', 'LineWidth',3);
        set(handles.txtStep4Value,'string', strcat('Format-Info Binär: ', formatInfoBin));
        drawnow();

        %Step 5: calculate mask
        [maskDec, maskBin, xorFormatString] = calculateMask(formatInfoBin);
        set(handles.txtStep5Value,'string', strcat(formatInfoBin, ' XOR 10101 = ', xorFormatString));
        set(handles.txtStep5Value2, 'string', strcat('3 letzte Zeichen = ', maskBin, ' = ', num2str(maskDec), ' d.h. Maske ', num2str(maskDec), ' kam zur Anwendung.'));
        drawnow();

        %Step 6: find and colorize alignment patterns
        imageRGBWithAlignmentPattern = findAndColorizeAlignmentPatterns(croppedBinaryImage, qrCodeVersion, qrCodePixelSize, finderPatternAreas);
        set(handles.axesQrCodeImage7,'visible','on');
        axes(handles.axesQrCodeImage7);
        imshow(imageRGBWithAlignmentPattern);
        drawnow();

        %Step 7: Read data
        dataString = readData(imageRGBWithAlignmentPattern, qrCodePixelSize, numberOfPixelsPerEdge, maskDec);
        set(handles.axesQrCodeImage8,'visible','on');
        axes(handles.axesQrCodeImage8);
        imshow(imageRGBWithAlignmentPattern);
        %draw column numbers
        for i=0:(numberOfPixelsPerEdge - 1)
            if i < 10
                xPos1 = qrCodePixelSize * i + (qrCodePixelSize / 2);
            else
                xPos1 = qrCodePixelSize * i;
            end
            yPos2 = qrCodePixelSize * i + (qrCodePixelSize / 2);

            yPos1 = (numberOfPixelsPerEdge + 1) * qrCodePixelSize;
            xPos2 = (numberOfPixelsPerEdge + 1) * qrCodePixelSize;

            text(xPos1, yPos1, sprintf('%d', i), 'Units', 'data', 'FontSize',8, 'Color','r');
            text(xPos2, yPos2, sprintf('%d', i), 'Units', 'data', 'FontSize',8, 'Color','r');

            %rectangle for the read
            if mod(i, 2) == 0
                rectangle('Position', [((numberOfPixelsPerEdge - 2 - i) * qrCodePixelSize + 1) 0 (2 * qrCodePixelSize) ((numberOfPixelsPerEdge + 1) * qrCodePixelSize)], 'EdgeColor', 'g', 'LineWidth',3);
            end
        end
        %mark not readable content of the qr code
        %mark 3 areas with finder pattern, empty line and format info
        rectangle('Position', [1 1 (9 * qrCodePixelSize) (9 * qrCodePixelSize)], 'FaceColor','r', 'EdgeColor', 'r');
        rectangle('Position', [(finderPatternsEnd - 8 * qrCodePixelSize - 1) 1 (8 * qrCodePixelSize + 1) (9 * qrCodePixelSize)], 'FaceColor','r', 'EdgeColor', 'r');
        rectangle('Position', [1 (finderPatternsEnd - 8 * qrCodePixelSize - 1) (9 * qrCodePixelSize + 1) (9 * qrCodePixelSize)], 'FaceColor','r', 'EdgeColor', 'r');
        %mark fixed patterns
        rectangle('Position', [(9 * qrCodePixelSize)  (6 * qrCodePixelSize + 1) ((numberOfPixelsPerEdge - 16) * qrCodePixelSize) qrCodePixelSize], 'FaceColor','r', 'EdgeColor', 'r');
        rectangle('Position', [(6 * qrCodePixelSize + 1) (9 * qrCodePixelSize) qrCodePixelSize ((numberOfPixelsPerEdge - 16) * qrCodePixelSize)], 'FaceColor','r', 'EdgeColor', 'r');
        drawnow();

        %Step 7 - Continuation
        set(handles.txtStep7MaskCalculation,'string', displayMaskFormula(maskDec));
        dataStringTodisplay = dataString;
        if length(dataString) > 110
            dataStringTodisplay = strcat(dataStringTodisplay(1:110), '...');
        end
        set(handles.txtValueStep7Data, 'string', dataStringTodisplay);
        drawnow();

        %Step 8 and 9: Convert dataString to ISO
        mode = bin2dec(dataString(1:4));
        set(handles.axesQrCodeImage9,'visible','on');
        axes(handles.axesQrCodeImage9);
        imshow(imageRGBWithAlignmentPattern);
        rectangle('Position', [((numberOfPixelsPerEdge - 2) * qrCodePixelSize + 1) ((numberOfPixelsPerEdge - 2) * qrCodePixelSize + 1) (2 * qrCodePixelSize) (2 * qrCodePixelSize)], 'EdgeColor', 'g', 'LineWidth',3);
        if (mode == 4)
           modeText = '0100 =  ISO 8859-1';
           qrCodeResult = convertToIso(dataString);
           set(handles.txtQrCodeResult, 'string', qrCodeResult);
        else
           modeText = 'Kein ISO 8859-1. Nicht unterstützt.';
        end
        text(1, ((numberOfPixelsPerEdge + 1) * qrCodePixelSize), modeText, 'Units', 'data', 'FontSize',12, 'Color','g');
        drawnow();
    end
end
