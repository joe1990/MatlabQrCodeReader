function varargout = untitled(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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


% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Choose default command line output for untitled
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function txtPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtPath_Callback(hObject, eventdata, handles)
% hObject    handle to txtPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPath as text
%        str2double(get(hObject,'String')) returns contents of txtPath as a double
% Save the new path value
handles.path = get(hObject, 'String');
guidata(hObject,handles);

% --- Executes on button press in btnSelectFile.
function btnSelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.path = uigetfile('*.png');
set(handles.txtPath, 'string', handles.path);
guidata(hObject,handles);

% --- Executes on button press in btnReadImage.
function btnReadImage_Callback(hObject, eventdata, handles)
%Inital step: display loaded image in axesQrCodeImage1
[qrCodeImageRGB,map] = imread(handles.path);
if ~isempty(map)
    qrCodeImageRGB = ind2rgb(qrCodeImageRGB,map);
end
set(handles.axesQrCodeImage1,'visible','on');
axes(handles.axesQrCodeImage1);
imshow(qrCodeImageRGB);

%Step 1: display binary image in axesQrCodeImage2
binaryImage = convertImageToBinary(qrCodeImageRGB);
set(handles.axesQrCodeImage2,'visible','on');
axes(handles.axesQrCodeImage2);
imshow(binaryImage);

%Step 2: find finder patterns, crop image and display in axesQrCodeImage3
[croppedBinaryImage, finderPatternAreas, qrCodePixelSize, sizeCroppedImage] = findFinderPatternsAndCropImage(binaryImage);
set(handles.axesQrCodeImage3,'visible','on');
axes(handles.axesQrCodeImage3);
imshow(croppedBinaryImage);

%colorize the tree finder patterns with a green rectangle
finderPatternWidthHeight = round(qrCodePixelSize * 7);
finderPatternsEnd = round(sizeCroppedImage) + 1;

%left finder pattern
rectangle('Position', [1 1 finderPatternWidthHeight finderPatternWidthHeight], 'EdgeColor','g', 'LineWidth',3);
%right finder pattern
rectangle('Position', [(finderPatternsEnd-finderPatternWidthHeight) 1 finderPatternWidthHeight finderPatternWidthHeight], 'EdgeColor','g', 'LineWidth',3);
%bottom left finder pattern
rectangle('Position', [1 (finderPatternsEnd-finderPatternWidthHeight) finderPatternWidthHeight finderPatternWidthHeight], 'EdgeColor','g', 'LineWidth',3);

%Step 3: calculate qr code version
[qrCodeVersion, formulaString] = calculateQrCodeVersion(sizeCroppedImage, qrCodePixelSize);
set(handles.txtStep3Value,'string', formulaString);
set(handles.txtVersion,'string', strcat('Version: ', num2str(qrCodeVersion)));

%Step 4: read format info
formatInfoBin = readFormatInfoAsBinary(croppedBinaryImage, qrCodePixelSize);
set(handles.axesQrCodeImage5,'visible','on');
axes(handles.axesQrCodeImage5);
imshow(croppedBinaryImage);
rectangle('Position', [1 (1 + 8 * qrCodePixelSize) (5 * qrCodePixelSize) qrCodePixelSize], 'EdgeColor','g', 'LineWidth',3);
set(handles.txtStep4Value,'string', strcat('Format-Info Binär: ', formatInfoBin));

%Step 5: calculate mask
[maskDec, maskBin, xorFormatString] = calculateMask(formatInfoBin);
set(handles.txtStep5Value,'string', strcat(formatInfoBin, ' XOR 10101 = ', xorFormatString));
set(handles.txtStep5Value2, 'string', strcat('3 letzte Zeichen = ', maskBin, ' = ', num2str(maskDec), ' d.h. Maske ', num2str(maskDec), ' kam zur Anwendung.'));

%Step 6: find and colorize alignment patterns
imageRGBWithAlignmentPattern = findAndColorizeAlignmentPatterns(croppedBinaryImage, qrCodeVersion, qrCodePixelSize, finderPatternAreas);
set(handles.axesQrCodeImage7,'visible','on');
axes(handles.axesQrCodeImage7);
imshow(imageRGBWithAlignmentPattern);

%qrCodeImage = read_qr_code(croppedRGBImage, finderPatternAreas, qrCodePixelSize, sizeCroppedImage);
%set(handles.axesQrCodeImage4,'visible','on');
%axes(handles.axesQrCodeImage4);
%imshow(qrCodeImage);

%qrCodeImage = read_qr_code(handles.path);
%qrCodeImage = convertImageToBinary(handles.path);

%guidata(hObject,handles)
%imshow(qrCodeImage);
