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

% Last Modified by GUIDE v2.5 09-Nov-2010 19:13:26

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
original_image = rgb2gray(imread(filename));
MAX_SIZE = 400;
im_size = size(original_image);
mx = max(im_size);
if mx > MAX_SIZE
   im_size = im_size * MAX_SIZE / mx; 
end
axes(handles.axes1)
imshow(original_image)
new_coords = resizeControl(handles.axes1, [im_size(2) im_size(1)]);
resizeControl(handles.axes2, [im_size(2) im_size(1)]);
moveControl(handles.axes2, [new_coords(1) + im_size(2) + 10, new_coords(2)]);
panel_pos = getpixelposition(handles.uipanel3);
moveControl(handles.uipanel3, [new_coords(1), new_coords(2) - panel_pos(4)]);

axes(handles.axes2)
imshow(ones([round(im_size), 3]))
popupmenu2_Callback(handles.popupmenu2, {}, handles)

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
axes(handles.axes1)
imshow(original_image)
axes(handles.axes2)
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
axes(handles.axes2)
x = 0:10;
y = x.^2;
plot(x,y)
xlabel('X values')
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
axes(handles.axes2);

draw_image = 1;
global original_image;

kernel_types = ['Sobel' 'Prewitt' 'Roberts Cross'];
if ismember(value, kernel_types)
   [edge_image angle_image] = kernel_operator(original_image, value);
else
    draw_image = 0;
end

if draw_image
    edge_image = edge_image / max(edge_image(:));
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
function axes1_CreateFcn(hObject, eventdata, handles)

% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


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
