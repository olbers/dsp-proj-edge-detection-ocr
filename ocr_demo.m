function varargout = ocr_demo(varargin)
% OCR_DEMO M-file for ocr_demo.fig
%      OCR_DEMO, by itself, creates a new OCR_DEMO or raises the existing
%      singleton*.
%
%      H = OCR_DEMO returns the handle to a new OCR_DEMO or the handle to
%      the existing singleton*.
%
%      OCR_DEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OCR_DEMO.M with the given input arguments.
%
%      OCR_DEMO('Property','Value',...) creates a new OCR_DEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ocr_demo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ocr_demo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ocr_demo

% Last Modified by GUIDE v2.5 15-Dec-2010 20:15:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ocr_demo_OpeningFcn, ...
    'gui_OutputFcn',  @ocr_demo_OutputFcn, ...
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


% --- Executes just before ocr_demo is made visible.
function ocr_demo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ocr_demo (see VARARGIN)

% Choose default command line output for ocr_demo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ocr_demo wait for user response (see UIRESUME)
% uiwait(handles.figure1);
def_im = ones(110,110);
axes(handles.axes1)
imshow(def_im);
axes(handles.axes2)
imshow(def_im);
axes(handles.axes3)
imshow(def_im);
axes(handles.axes4)
imshow(def_im);
axes(handles.axes5)
imshow(def_im);

% Simulate a whole bunch
%num_iterations = 1000;
%count = 0;
%for ii=1:num_iterations
%    count = count + simulation(handles);
%end
%sprintf('Looked at %d images, match %d of them correctly', num_iterations, count)

function [tim2 letter] = random_image(handles)
fontnames = {'arial','courier','times new roman','helvetica','calibri'};
fontname = fontnames(ceil(rand() * length(fontnames)));
fontsizes = 10:40;
fontsize = fontsizes(ceil(rand() * length(fontsizes)));
letters = 'A':'Z';
letter = letters(ceil(rand() * length(letters)));
tim2 = letterimage(handles.axes1, letter, fontname, fontsize);

function tim2 = letterimage(which_axes, letter, fontname, fontsize)
dim = [90 90];

axes(which_axes);
imshow(ones(dim));
drawnow
text('units','pixels','position',[10 dim(2)-30],'fontsize',fontsize,'fontname',char(fontname),'string',char(letter))
tim = getframe();
tim2 = double(tim.cdata(2:dim(1)+1,2:dim(2)+1,1));
tim2 = floor(tim2 ./ 255.0);
tim2 = tim2 * -1.0 + 1.0;

function cropped_im = crop(im)
[m,n] = size(im);
first_i = m;
last_i = m;
first_j = n;
last_j = n;
for kk=1:m
    if sum(im(kk,:)) > 0.0
        first_i = min(first_i, kk);
        last_i = kk;
    end
end
for jj=1:n
    if sum(im(:,jj)) > 0.0
        first_j = min(first_j, jj);
        last_j = jj;
    end
end

cropped_im = im(first_i-1:last_i+1,first_j-1:last_j+1);



% --- Outputs from this function are returned to the command line.
function varargout = ocr_demo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
simulation(handles)

function match = simulation(handles)
global original_image;
[original_image actual_letter] = random_image(handles);
[resized_image, skeleton] = preprocess_image(original_image);
axes(handles.axes3);
imshow(skeleton);

% Get edges
cropped = crop(original_image);
cropped = padarray(cropped, [3 3]);
edge_image = Canny_detector(cropped, 3, 0.4, 0.8);
axes(handles.axes2);
imshow(edge_image);

% Show hough
draw_hough(handles, skeleton);

% Find features
col_data = compute_features(original_image);
fieldnames = {'Number of Points in Skeleton';
    'Number of Black Holes';
    'Longest Vertical Line';
    'Longest Horizontal Line';
    'Number of Horizontal Lines';
    'Number of Vertical Lines';
    'Template 1 (C/G)';
    'Template 2 (L/I)';
    'Number of Lines (Hough)';
    'Symmetry about Y axis'};
set(handles.text10, 'String', sprintf('%s: %f', char(fieldnames(1)), col_data(1)));
set(handles.text11, 'String', sprintf('%s: %f', char(fieldnames(2)), col_data(2)));
set(handles.text12, 'String', sprintf('%s: %f', char(fieldnames(3)), col_data(3)));
set(handles.text13, 'String', sprintf('%s: %f', char(fieldnames(4)), col_data(4)));
set(handles.text14, 'String', sprintf('%s: %f', char(fieldnames(5)), col_data(5)));
set(handles.text15, 'String', sprintf('%s: %f', char(fieldnames(6)), col_data(6)));
set(handles.text16, 'String', sprintf('%s: %f', char(fieldnames(7)), col_data(7)));
set(handles.text17, 'String', sprintf('%s: %f', char(fieldnames(8)), col_data(8)));
set(handles.text18, 'String', sprintf('%s: %f', char(fieldnames(9)), col_data(9)));
set(handles.text19, 'String', sprintf('%s: %f', char(fieldnames(10)), col_data(10)));

load('ocr_neural_network');
col_output = sim(best_net, col_data);
[~,idx] = max(col_output);
letters = 'A':'Z';
letter = letters(idx);
if char(letter) == char(actual_letter)
    match = 1
else
    match = 0
end

letterimage(handles.axes5, letter, 'times new roman', 50);

% Hough Transform
function draw_hough(handles, skeleton)
[H,theta,rho] = hough(skeleton,'Theta',-90:5:89);
P = houghpeaks(H,5,'NHoodSize', [5 5], 'threshold',ceil(0.6*max(H(:))));
lines = houghlines(skeleton,theta,rho,P,'FillGap',10,'MinLength',8);
axes(handles.axes4);
imshow(skeleton), hold on
for k = 1:length(lines)
    if isfield(lines(k),'point1')
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        
        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end
hold off
