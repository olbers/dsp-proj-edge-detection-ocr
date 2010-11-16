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

% Last Modified by GUIDE v2.5 16-Nov-2010 13:48:02

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

function loadImageFromFile(filename, handles)
global original_image;
global smoothed_image;
global smoothed_axes;
smoothed_axes = handles.smoothed_axes;
original_image = double(rgb2gray(imread(filename))) / 255.0;
smoothed_image = original_image;
MAX_SIZE = 400;
im_size = size(original_image);
mx = max(im_size);
if mx > MAX_SIZE
   im_size = im_size * MAX_SIZE / mx; 
end
axes(handles.original_axes)
imshow(original_image)
%new_coords = resizeControl(handles.original_axes, [im_size(2) im_size(1)]);
%resizeControl(handles.axes2, [im_size(2) im_size(1)]);
%moveControl(handles.axes2, [new_coords(1) + im_size(2) + 10, new_coords(2)]);
%panel_pos = getpixelposition(handles.uipanel3);
%moveControl(handles.uipanel3, [new_coords(1), new_coords(2) - panel_pos(4)]);

axes(handles.smoothed_axes)
imshow(smoothed_image)

axes(handles.edges_axes)
imshow(ones([round(im_size), 3]))

axes(handles.application_axes)
imshow(ones([round(im_size), 3]))
popupmenu2_Callback(handles.popupmenu2, {}, handles)

function applySmoothing(type, stdev)
global original_image;
global smoothed_image;
global smoothed_axes;
if strcmp(type, 'None') || stdev == 0.0
    smoothed_image = original_image;
elseif strcmp(type, 'Gaussian Smoothing')
    smoothed_image = conv2(double(original_image), fspecial('gaussian', 9, stdev), 'same');
end
axes(smoothed_axes);
imshow(smoothed_image);


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
[m,n] = size(mat);
img = zeros(m,n,3);
img(1:end,1:end,1) = mat;
img(1:end,1:end,2) = mat;
img(1:end,1:end,3) = mat;

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
value = contents{get(hObject,'Value')};
axes(handles.edges_axes);

draw_image = 1;
global original_image;
global smoothed_image;

kernel_types = ['Sobel' 'Prewitt' 'Roberts Cross'];
canny_params = [handles.low_thresh_label handles.low_thresh_edit handles.low_thresh_slider handles.high_thresh_edit handles.high_thresh_label handles.high_thresh_slider];
if strcmp(value, 'Canny')
    setting = 'on';
else
    setting = 'off';
end

for i=1:size(canny_params)
    set(canny_params(i), 'Visible', setting);
end

if ismember(value, kernel_types)
   [edge_image angle_image] = kernel_operator(smoothed_image, value);
elseif strcmp(value, 'Differential')
    [edge_image] = differential_detector(smoothed_image);
elseif strcmp(value, 'Canny')
    % TODO 
else
    draw_image = 0;
end

if draw_image
    edge_image = edge_image ./ max(edge_image(:));
    imshow(matrixToImage(edge_image))
end
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
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


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
contents = cellstr(get(hObject,'String'));
value = contents{get(hObject,'Value')};
gauss_smooth_objs = [handles.gauss_smooth_stdev_edit handles.gauss_smooth_stdev_slider handles.gauss_smooth_stdev_label];
if strcmp(value, 'Gaussian Smoothing')
    bool = 'on';
else
    bool = 'off';
end
for i=1:length(gauss_smooth_objs)
    set(gauss_smooth_objs(i), 'Visible', bool); 
end
stdev = get(handles.gauss_smooth_stdev_slider, 'Value');
applySmoothing(value, stdev);

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function gauss_smooth_stdev_slider_Callback(hObject, eventdata, handles)
% hObject    handle to gauss_smooth_stdev_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global gauss_smooth_edit_box;
val = num2str(get(hObject, 'Value'));
set(handles.gauss_smooth_stdev_edit, 'String', val);
applySmoothing('Gaussian Smoothing', str2num(val));

% --- Executes during object creation, after setting all properties.
function gauss_smooth_stdev_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gauss_smooth_stdev_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%hListener = handle.listener(hObject, 'ActionEvent', @gauss_smooth_stdev_slider_Callback);
%lh1 = addlistener(hObject,'Action',@gauss_smooth_stdev_slider_Callback);
%global gauss_smooth_edit_box;
%gauss_smooth_edit_box = handles.gauss_smooth_stdev_edit;


function gauss_smooth_stdev_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gauss_smooth_stdev_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gauss_smooth_stdev_edit as text
%        str2double(get(hObject,'String')) returns contents of gauss_smooth_stdev_edit as a double
val = str2num(get(hObject,'String'));
set(handles.gauss_smooth_stdev_slider, 'Value', val);
applySmoothing('Gaussian Smoothing', val);

% --- Executes during object creation, after setting all properties.
function gauss_smooth_stdev_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gauss_smooth_stdev_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over gauss_smooth_stdev_slider.
function gauss_smooth_stdev_slider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to gauss_smooth_stdev_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function low_thresh_edit_Callback(hObject, eventdata, handles)
% hObject    handle to low_thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of low_thresh_edit as text
%        str2double(get(hObject,'String')) returns contents of low_thresh_edit as a double


% --- Executes during object creation, after setting all properties.
function low_thresh_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function high_thresh_edit_Callback(hObject, eventdata, handles)
% hObject    handle to high_thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of high_thresh_edit as text
%        str2double(get(hObject,'String')) returns contents of high_thresh_edit as a double


% --- Executes during object creation, after setting all properties.
function high_thresh_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function low_thresh_slider_Callback(hObject, eventdata, handles)
% hObject    handle to low_thresh_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function low_thresh_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_thresh_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function high_thresh_slider_Callback(hObject, eventdata, handles)
% hObject    handle to high_thresh_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function high_thresh_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_thresh_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
