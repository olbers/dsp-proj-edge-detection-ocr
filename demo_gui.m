function varargout = demo_gui(varargin)
% DEMO_GUI M-file for demo_gui.fig
%      DEMO_GUI, by itself, creates a new DEMO_GUI or raises the existing
%      singleton*.
%
%      H = DEMO_GUI returns the handle to a new DEMO_GUI or the handle to
%      the existing singleton*.
%
%      DEMO_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMO_GUI.M with the given input arguments.
%
%      DEMO_GUI('Property','Value',...) creates a new DEMO_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before demo_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to demo_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help demo_gui

% Last Modified by GUIDE v2.5 14-Dec-2010 15:46:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @demo_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @demo_gui_OutputFcn, ...
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

function [imagepath] = imagedir(f)
filename = 'demo_gui.m';
fullpath = which(filename);
parentpath = strrep(fullpath,filename,'');
imagepath = sprintf('%simages\\%s', parentpath, f);

function loadImageFromFile(filename, handles)
global original_image;
global original_image_noise;
global smoothed_axes;
global edge_image;
global edges_axes;
smoothed_axes = handles.smoothed_axes;
edges_axes = handles.edges_axes;
original_image = double(rgb2gray(imread(imagedir(filename)))) / 255.0;
%smoothed_image = original_image;
%smoothed_image_full = smoothed_image;
original_image_noise = original_image;
edge_image = original_image;
MAX_SIZE = 400;
im_size = size(original_image);
mx = max(im_size);
if mx > MAX_SIZE
   im_size = im_size * MAX_SIZE / mx; 
end
axes(handles.original_axes)
applyNoise(handles);
%imshow(original_image_noi)
%new_coords = resizeControl(handles.original_axes, [im_size(2) im_size(1)]);
%resizeControl(handles.axes2, [im_size(2) im_size(1)]);
%moveControl(handles.axes2, [new_coords(1) + im_size(2) + 10, new_coords(2)]);
%panel_pos = getpixelposition(handles.uipanel3);
%moveControl(handles.uipanel3, [new_coords(1), new_coords(2) - panel_pos(4)]);

%axes(handles.smoothed_axes)
%imshow(smoothed_image)

%axes(handles.edges_axes)
%imshow(ones(300,300,3))

%axes(handles.application_axes)
%imshow(ones(300,300,3))

function applyNoise(handles)
enable_gauss = get(handles.enable_gaussian_noise, 'Value');
enable_sp = get(handles.enable_sp_noise, 'Value');
enable_speckle = get(handles.enable_speckle_noise, 'Value');
global original_image;
global original_image_noise;
original_image_noise = original_image;
if enable_speckle
    v = str2num(get(handles.noise_speckle_v_edit,'String'));
    original_image_noise = imnoise(original_image_noise, 'speckle', v);
end
if enable_gauss
    m = str2num(get(handles.noise_gauss_m_edit,'String'));
    v = str2num(get(handles.noise_gauss_v_edit,'String'));
    original_image_noise = imnoise(original_image_noise, 'gaussian', m, v);
end
if enable_sp
    d = str2num(get(handles.noise_sp_density_edit,'String'));
    original_image_noise = imnoise(original_image_noise, 'salt & pepper', d);
end
axes(handles.original_axes)
imshow(original_image_noise);
imwrite(original_image_noise, imagedir('original_noise.png'));
applySmoothing(handles);

function applySmoothing(handles)
global original_image;
global smoothed_image;
global smoothed_image_full;
global smoothed_axes;
global smooth_stdev_slider;
global smooth_size_popup;
global smoothing_type;
global original_image_noise;

size_contents = cellstr(get(smooth_size_popup,'String'));
size = size_contents{get(smooth_size_popup,'Value')};

stdev = get(smooth_stdev_slider, 'Value');
dim = str2num(size(1:strfind(size,'x')-1));
if strcmp(smoothing_type, 'None') || stdev == 0.0
    smoothed_image = original_image_noise;
    smoothed_image_full = smoothed_image;
elseif strcmp(smoothing_type, 'Gaussian Smoothing')
    smoothed_image = conv2(double(original_image_noise), fspecial('gaussian', dim, stdev), 'same');
    smoothed_image_full = conv2(double(original_image_noise), fspecial('gaussian', dim, stdev), 'full');
elseif strcmp(smoothing_type, 'Mean Filtering')
    smoothed_image = conv2(double(original_image_noise), fspecial('average', dim), 'same');
    smoothed_image_full = conv2(double(original_image_noise), fspecial('average', dim), 'full');
elseif strcmp(smoothing_type, 'Median Filtering')
    smoothed_image = medfilt2(original_image_noise, [dim dim]);
    smoothed_image_full = smoothed_image;
else
    smoothed_image = original_image_noise;
    smoothed_image_full = smoothed_image;
end
axes(smoothed_axes);
imwrite(smoothed_image, imagedir('smoothed_image.png'));
imshow(smoothed_image);

%Compute signal to noise ratio
snr = sum(smoothed_image(:).^2) / sum((smoothed_image(:)-original_image(:)).^2);
set(handles.snr_text, 'String', sprintf('%f dB', 10*log10(snr)));

detectEdges(handles);

function new_image = applyLowThreshold(the_image, handles)
thresh = get(handles.edge_low_thresh_slider, 'Value');
if thresh > 0
    new_image = sign(the_image - thresh)/2 + 0.5;
else
    new_image = the_image;
end

function detectEdges(handles)
axes(handles.edges_axes);

draw_image = 1;
global smoothed_image;
global smoothed_image_full;
global edge_detect_type;
global smooth_size_popup;
global edge_image;

keepgradient = get(handles.cb_keepgradient, 'Value');

kernel_types = ['Sobel' 'Prewitt' 'Roberts Cross' 'Scharr'];
if ismember(edge_detect_type, kernel_types)
   [edge_image angle_image] = kernel_operator(smoothed_image, edge_detect_type);
    edges = applyLowThreshold(edge_image, handles);
    if keepgradient
        edge_image = edges .* edge_image;
    else
        edge_image = edges;
    end
elseif strcmp(edge_detect_type, 'Laplacian of Gaussian')
    [edges] = double(edge(smoothed_image, 'log',0.01*get(handles.edge_low_thresh_slider,'Value'),get(handles.log_std_slider,'Value')));
    edge_im = kernel_operator(smoothed_image, 'Sobel');
    if keepgradient
        edge_image = edges .* edge_im;
    else
        edge_image = edges;
    end
elseif strcmp(edge_detect_type, 'Canny')
    size_contents = cellstr(get(smooth_size_popup,'String'));
    ksize = size_contents{get(smooth_size_popup,'Value')};
    kernel_size = str2double(ksize(1:strfind(ksize,'x')-1));
    [edges] = Canny_detector(smoothed_image_full, kernel_size, get(handles.edge_low_thresh_slider,'Value'), get(handles.edge_high_thresh_slider,'Value'));
    edge_im = kernel_operator(smoothed_image, 'Sobel');
    if keepgradient
        edge_image = edges .* edge_im;
    else
        edge_image = edges;
    end
else
    draw_image = 0;
end

if draw_image
    edge_image = edge_image ./ max(edge_image(:));
    im = matrixToImage(edge_image);
    imshow(im);
    imwrite(im,imagedir('edge_image.png'));
    
    applyCrispening(handles)
end

function applyCrispening(handles)
global smoothed_image;
global edge_image;
crispening_factor = get(handles.crisp_factor_slider,'Value');
crisp_image = crisp(smoothed_image, edge_image, crispening_factor);
axes(handles.application_axes);
imwrite(crisp_image, imagedir('crisp_image.png'));
imshow(crisp_image)


function [cur_pos] = resizeControl(handle, new_size)
cur_pos = getpixelposition(handle);
cur_pos(2) = cur_pos(2) + cur_pos(4) - new_size(2);
cur_pos(3:4) = new_size;
setpixelposition(handle, cur_pos);

function [cur_pos] = moveControl(handle, new_left_bottom)
cur_pos = getpixelposition(handle);
cur_pos(1) = new_left_bottom(1);
cur_pos(2) = new_left_bottom(2);
setpixelposition(handle, cur_pos);

% --- Executes just before demo_gui is made visible.
function demo_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to demo_gui (see VARARGIN)

% Choose default command line output for demo_gui
handles.output = hObject;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up groups of GUI objects for changing visibility
global smoothing_all;
global edges_all;
global smoothing_gauss;
global edges_canny;
global edges_kernelops;
global edges_differential;
global smoothing_mean;
global smoothing_median;
global smoothing_type;
global edge_detect_type;
edge_detect_type = '';
smoothing_type = '';
smoothing_all = [handles.smooth_stdev_label;
    handles.smooth_stdev_edit;
    handles.smooth_stdev_slider;
    handles.smooth_size_label;
    handles.smooth_size_popup];
smoothing_gauss = smoothing_all(1:5);
smoothing_mean = smoothing_all(4:5);
smoothing_median = smoothing_all(4:5);
edges_all = [handles.thresholding_label;
    handles.edge_low_thresh_label;
    handles.edge_low_thresh_edit;
    handles.edge_low_thresh_slider;
    handles.edge_high_thresh_label;
    handles.edge_high_thresh_edit;
    handles.edge_high_thresh_slider;
    handles.cb_keepgradient;
    handles.log_std_label;
    handles.log_std_text;
    handles.log_std_slider];
edges_canny = edges_all(2:8);

edges_kernelops = edges_all([1:4,8]);
edges_differential = [edges_all([1:4,8:11])];
    
global smooth_stdev_slider;
global smooth_size_popup;
smooth_stdev_slider = handles.smooth_stdev_slider;
smooth_size_popup = handles.smooth_size_popup;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global original_image;
original_image = ones(50,50,3);
axes(handles.original_axes)
imshow(original_image)

axes(handles.smoothed_axes)
imshow(original_image)

axes(handles.edges_axes)
imshow(original_image)

axes(handles.application_axes)
imshow(original_image)


global lookup_table;
lookup_table = java.util.Hashtable;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes demo_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function showFields(setting, onoff)
for i=1:length(setting)
    set(setting(i), 'Visible', onoff);
end

function changeVisibility(type)
global smoothing_all;
global smoothing_gauss;
global smoothing_mean;
global smoothing_median;
global edges_all;
global edges_kernelops;
global edges_differential;
global edges_canny;
kernel_types = ['Sobel' 'Prewitt' 'Roberts Cross' 'Scharr'];
if strcmp(type, 'Gaussian Smoothing')
   showFields(smoothing_all, 'off');
   showFields(smoothing_gauss, 'on');
elseif ismember(type, kernel_types)
    showFields(edges_all, 'off');
    showFields(edges_kernelops, 'on');
elseif strcmp(type, 'Laplacian of Gaussian')
    showFields(edges_all, 'off');
    showFields(edges_differential, 'on');
elseif strcmp(type, 'Canny')
    showFields(edges_all, 'off');
    showFields(edges_canny, 'on');
elseif strcmp(type, 'None')
    showFields(smoothing_all, 'off');
elseif strcmp(type, 'Mean Filtering')
    showFields(smoothing_all, 'off');
    showFields(smoothing_mean, 'on');
elseif strcmp(type, 'Median Filtering')
    showFields(smoothing_all, 'off');
    showFields(smoothing_median, 'on');
end

% --- Outputs from this function are returned to the command line.
function varargout = demo_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
obj = get(hObject);
items = obj.String;
temp = items(1);
obj.String(1) = items(2);
obj.String(2) = temp;
obj.Enable = 0;
obj.Enable = 1;
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function img = matrixToImage(mat)
maxsize = 300;
[m,n] = size(mat);
scale = max(m/maxsize, n/maxsize);
img = zeros(m,n,3);
img(1:end,1:end,1) = mat;
img(1:end,1:end,2) = mat;
img(1:end,1:end,3) = mat;
img = imresize(img,1/scale);

% --- Executes on selection change in edge_type_popup.
function edge_type_popup_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
value = contents{get(hObject,'Value')};
changeVisibility(value);
global edge_detect_type;
edge_detect_type = value;
detectEdges(handles);

% hObject    handle to edge_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns edge_type_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from edge_type_popup


% --- Executes during object creation, after setting all properties.
function edge_type_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edge_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function original_axes_CreateFcn(hObject, eventdata, handles)

% hObject    handle to original_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate original_axes



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
get(handles.pushbutton2)
pos = get(handles.pushbutton2, 'Position');
pos(1) = pos(1) + 40;
set(handles.pushbutton2, 'Position', pos);
%set(handles.pushbutton2, 'Visible', 'off');
%contents
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function fullpath = lookupFile(filename, path)
global lookup_table;
global lookup_initialized;
if isempty(lookup_initialized)
      
    lookup_initialized = 1;
end
fullpath = char(lookup_table.get( filename ));
if isempty(fullpath)
    fullpath = strcat(path, filename);
    lookup_table.put(filename, cellstr(fullpath));
end
    
% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
contents = cellstr(get(hObject,'String')); 
value = contents{get(hObject,'Value')};
if strcmp(value, 'Basic Shapes')
    loadImageFromFile('basic_shapes.bmp', handles);
elseif strcmp(value, 'RPI Logo')
    loadImageFromFile('rpi_logo.jpg', handles);
elseif strcmp(value, 'CII Building')
    loadImageFromFile('rpi_cii.jpg', handles);
elseif strcmp(value, 'Lena')
    loadImageFromFile('lena.bmp', handles);
elseif strcmp(value, 'Cameraman')
    loadImageFromFile('cameraman.png', handles);
elseif strcmp(value, 'Load From File')
    [filename path] = uigetfile('*.*', 'Image Files');
    if filename ~= 0
       loadImageFromFile(lookupFile(filename, path), handles);
       list = get(hObject, 'String');
       list(end+1) = list(end);
       list(end-1) = cellstr(filename);
       set(hObject, 'String', list);
       set(hObject, 'Value', length(list)-1);
    end
elseif strcmp(value, 'Select an Image')
else
    loadImageFromFile(lookupFile(value), handles);
end


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in smoothing_type_popup.
function smoothing_type_popup_Callback(hObject, eventdata, handles)
% hObject    handle to smoothing_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns smoothing_type_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from smoothing_type_popup
contents = cellstr(get(hObject,'String'));
value = contents{get(hObject,'Value')};
%gauss_smooth_objs = [handles.smooth_stdev_edit
%handles.smooth_stdev_slider handles.smooth_stdev_label];
changeVisibility(value);
global smoothing_type;
smoothing_type = value;
applySmoothing(handles);

% --- Executes during object creation, after setting all properties.
function smoothing_type_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothing_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function smooth_stdev_slider_Callback(hObject, eventdata, handles)
% hObject    handle to smooth_stdev_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global gauss_smooth_edit_box;
val = num2str(get(hObject, 'Value'));
set(handles.smooth_stdev_edit, 'String', val);
applySmoothing(handles);

% --- Executes during object creation, after setting all properties.
function smooth_stdev_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smooth_stdev_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%hListener = handle.listener(hObject, 'ActionEvent', @gauss_smooth_stdev_slider_Callback);
%lh1 = addlistener(hObject,'Action',@gauss_smooth_stdev_slider_Callback);
%global gauss_smooth_edit_box;
%gauss_smooth_edit_box = handles.smooth_stdev_edit;


function smooth_stdev_edit_Callback(hObject, eventdata, handles)
% hObject    handle to smooth_stdev_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smooth_stdev_edit as text
%        str2double(get(hObject,'String')) returns contents of smooth_stdev_edit as a double
val = str2num(get(hObject,'String'));
set(handles.smooth_stdev_slider, 'Value', val);
applySmoothing(handles);

% --- Executes during object creation, after setting all properties.
function smooth_stdev_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smooth_stdev_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over smooth_stdev_slider.
function smooth_stdev_slider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to smooth_stdev_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edge_low_thresh_edit_Callback(hObject, eventdata, handles)
% hObject    handle to edge_low_thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edge_low_thresh_edit as text
%        str2double(get(hObject,'String')) returns contents of edge_low_thresh_edit as a double
val = str2num(get(hObject,'String'));
set(handles.edge_low_thresh_slider, 'Value', val);
detectEdges(handles);

% --- Executes during object creation, after setting all properties.
function edge_low_thresh_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edge_low_thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edge_high_thresh_edit_Callback(hObject, eventdata, handles)
% hObject    handle to edge_high_thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edge_high_thresh_edit as text
%        str2double(get(hObject,'String')) returns contents of edge_high_thresh_edit as a double
val = str2num(get(hObject, 'String'));
set(handles.edge_high_thresh_slider, 'Value', val);
detectEdges(handles);

% --- Executes during object creation, after setting all properties.
function edge_high_thresh_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edge_high_thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function edge_low_thresh_slider_Callback(hObject, eventdata, handles)
% hObject    handle to edge_low_thresh_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = num2str(get(hObject,'Value'));
set(handles.edge_low_thresh_edit, 'String', val);
detectEdges(handles);

% --- Executes during object creation, after setting all properties.
function edge_low_thresh_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edge_low_thresh_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function edge_high_thresh_slider_Callback(hObject, eventdata, handles)
% hObject    handle to edge_high_thresh_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = num2str(get(hObject, 'Value'));
set(handles.edge_high_thresh_edit, 'String', val);
detectEdges(handles);

% --- Executes during object creation, after setting all properties.
function edge_high_thresh_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edge_high_thresh_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in smooth_size_popup.
function smooth_size_popup_Callback(hObject, eventdata, handles)
% hObject    handle to smooth_size_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns smooth_size_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from smooth_size_popup
applySmoothing(handles);

% --- Executes during object creation, after setting all properties.
function smooth_size_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smooth_size_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enable_gaussian_noise.
function enable_gaussian_noise_Callback(hObject, eventdata, handles)
% hObject    handle to enable_gaussian_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_gaussian_noise
applyNoise(handles);

% --- Executes on button press in enable_sp_noise.
function enable_sp_noise_Callback(hObject, eventdata, handles)
% hObject    handle to enable_sp_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_sp_noise
applyNoise(handles);

% --- Executes on button press in enable_speckle_noise.
function enable_speckle_noise_Callback(hObject, eventdata, handles)
% hObject    handle to enable_speckle_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_speckle_noise
applyNoise(handles);


function noise_gauss_m_edit_Callback(hObject, eventdata, handles)
% hObject    handle to noise_gauss_m_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_gauss_m_edit as text
%        str2double(get(hObject,'String')) returns contents of noise_gauss_m_edit as a double
applyNoise(handles);

% --- Executes during object creation, after setting all properties.
function noise_gauss_m_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_gauss_m_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_gauss_v_edit_Callback(hObject, eventdata, handles)
% hObject    handle to noise_gauss_v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_gauss_v_edit as text
%        str2double(get(hObject,'String')) returns contents of noise_gauss_v_edit as a double
applyNoise(handles);

% --- Executes during object creation, after setting all properties.
function noise_gauss_v_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_gauss_v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_sp_density_edit_Callback(hObject, eventdata, handles)
% hObject    handle to noise_sp_density_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_sp_density_edit as text
%        str2double(get(hObject,'String')) returns contents of noise_sp_density_edit as a double
applyNoise(handles);

% --- Executes during object creation, after setting all properties.
function noise_sp_density_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_sp_density_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_speckle_v_edit_Callback(hObject, eventdata, handles)
% hObject    handle to noise_speckle_v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_speckle_v_edit as text
%        str2double(get(hObject,'String')) returns contents of noise_speckle_v_edit as a double
applyNoise(handles);

% --- Executes during object creation, after setting all properties.
function noise_speckle_v_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_speckle_v_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in application_type.
function application_type_Callback(hObject, eventdata, handles)
% hObject    handle to application_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns application_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from application_type


% --- Executes during object creation, after setting all properties.
function application_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to application_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function crisp_factor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to crisp_factor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of crisp_factor_edit as text
%        str2double(get(hObject,'String')) returns contents of crisp_factor_edit as a double
val = str2double(get(hObject,'String'));
set(handles.crisp_factor_slider,'Value',val);
applyCrispening(handles);

% --- Executes during object creation, after setting all properties.
function crisp_factor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crisp_factor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function crisp_factor_slider_Callback(hObject, eventdata, handles)
% hObject    handle to crisp_factor_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.crisp_factor_edit,'String',num2str(val));
applyCrispening(handles);

% --- Executes during object creation, after setting all properties.
function crisp_factor_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crisp_factor_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in cb_keepgradient.
function cb_keepgradient_Callback(hObject, eventdata, handles)
% hObject    handle to cb_keepgradient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_keepgradient
detectEdges(handles)


% --- Executes on slider movement.
function log_std_slider_Callback(hObject, eventdata, handles)
% hObject    handle to log_std_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.log_std_text, 'String', num2str(get(hObject, 'Value')));
detectEdges(handles);

% --- Executes during object creation, after setting all properties.
function log_std_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to log_std_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function log_std_text_Callback(hObject, eventdata, handles)
% hObject    handle to log_std_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of log_std_text as text
%        str2double(get(hObject,'String')) returns contents of log_std_text as a double
set(handles.log_std_slider, 'Value', str2double(get(hObject,'String')));
detectEdges(handles);


% --- Executes during object creation, after setting all properties.
function log_std_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to log_std_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
