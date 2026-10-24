function varargout = untitledcontroller(varargin)
% UNTITLEDCONTROLLER MATLAB code for untitledcontroller.fig
%      UNTITLEDCONTROLLER, by itself, creates a new UNTITLEDCONTROLLER or raises the existing
%      singleton*.
%
%      H = UNTITLEDCONTROLLER returns the handle to a new UNTITLEDCONTROLLER or the handle to
%      the existing singleton*.
%
%      UNTITLEDCONTROLLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLEDCONTROLLER.M with the given input arguments.
%
%      UNTITLEDCONTROLLER('Property','Value',...) creates a new UNTITLEDCONTROLLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitledcontroller_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitledcontroller_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitledcontroller

% Last Modified by GUIDE v2.5 08-Jul-2024 13:24:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitledcontroller_OpeningFcn, ...
                   'gui_OutputFcn',  @untitledcontroller_OutputFcn, ...
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


% --- Executes just before untitledcontroller is made visible.
function untitledcontroller_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitledcontroller (see VARARGIN)

% Choose default command line output for untitledcontroller
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitledcontroller wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitledcontroller_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;







%slider0
function slider0_Callback(hObject, eventdata, handles)
 a1 = 486;
a2 = 500;
a3 = 420.17;
a4 = 160;
ModelName = 'Assem1';

theta1=get(handles.slider0,'value');
set(handles.edit5,'string',num2str(theta1));
theta2=get(handles.slider1,'value');
set(handles.edit6,'string',num2str(theta2));
theta3=get(handles.slider2,'value');
set(handles.edit7,'string',num2str(theta3));
theta4=get(handles.slider3,'value');
set(handles.edit8,'string',num2str(theta4));

set_param([ModelName '/Slider Gain0'],'Gain',num2str(theta1));
set_param([ModelName '/Slider Gain1'],'Gain',num2str(theta2));
set_param([ModelName '/Slider Gain2'],'Gain',num2str(theta3));
set_param([ModelName '/Slider Gain3'],'Gain',num2str(theta4));


%zaviye ha
% theta1=get(handles.slider0,'value');
% set_param([ModelName '/Slider Gain0'],'Gain',num2str(theta1));
set(handles.slider0,'value',theta1);


T1 = [ cosd(theta1) 0   -sind(theta1)    0;
       sind(theta1) 0   -cosd(theta1)    0;
       0            -1       0           486;
       0            0       0            1];

T2 = [ cosd(theta2) -sind(theta2)   0   a2*cosd(theta2);
       sind(theta2) cosd(theta2)    0   a2*sind(theta2);
       0            0               1       0;
       0            0               0        1];
   
T3 = [ cosd(theta3) -sind(theta3)   0   a3*cosd(theta3);
       sind(theta3) cosd(theta3)    0   a3*sind(theta3);
       0            0               1     0;
       0            0               0       1];
   
T4 = [ cosd(theta4) -sind(theta4)   0   a4*cosd(theta4);
       sind(theta4) cosd(theta4)    0   a4*sind(theta4);
       0            0               1   0;
       0            0               0     1];
T = T1*T2*T3*T4;
px=T(1,4);
py=T(2,4);
pz=T(3,4);

set(handles.edit9,'string',num2str(px));
set(handles.edit10,'string',num2str(py));
set(handles.edit11,'string',num2str(pz));
% hObject    handle to slider0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider










% --- Executes during object creation, after setting all properties.
function slider0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end











% start push button
function pushbutton1_Callback(hObject, eventdata, handles)

ModelName = 'Assem1';

% Opens the Simulink model 
open_system(ModelName);


set_param(ModelName,'BlockReduction','off');
set_param(ModelName,'StopTime','inf');
set_param(ModelName,'simulationMode','normal');

set_param(ModelName,'StartFcn','1');

set_param(ModelName, 'SimulationCommand', 'start');
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)














% default push button
function pushbutton3_Callback(hObject, eventdata, handles)
ModelName = 'Assem1';

theta1 = 0;
theta2 = 0;
theta3 = 0;
theta4 = 0;

set_param([ModelName '/Slider Gain0'],'Gain',num2str(theta1));
set_param([ModelName '/Slider Gain1'],'Gain',num2str(theta2));
set_param([ModelName '/Slider Gain2'],'Gain',num2str(theta3));
set_param([ModelName '/Slider Gain3'],'Gain',num2str(theta4));

set(handles.slider0,'value',theta1);
set(handles.slider0,'value',theta2);
set(handles.slider1,'value',theta3);
set(handles.slider2,'value',theta4);
set(handles.edit5,'string',num2str(theta1));
set(handles.edit6,'string',num2str(theta2));
set(handles.edit7,'string',num2str(theta3));
set(handles.edit8,'string',num2str(theta4));

% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)










% slider1
function slider1_Callback(hObject, eventdata, handles)
ModelName = 'Assem1';
 a1 = 486;
a2 = 500;
a3 = 420.17;
a4 = 160;
theta1=get(handles.slider0,'value');
set(handles.edit5,'string',num2str(theta1));
theta2=get(handles.slider1,'value');
set(handles.edit6,'string',num2str(theta2));
theta3=get(handles.slider2,'value');
set(handles.edit7,'string',num2str(theta3));
theta4=get(handles.slider3,'value');
set(handles.edit8,'string',num2str(theta4));


set_param([ModelName '/Slider Gain0'],'Gain',num2str(theta1));
set_param([ModelName '/Slider Gain1'],'Gain',num2str(theta2));
set_param([ModelName '/Slider Gain2'],'Gain',num2str(theta3));
set_param([ModelName '/Slider Gain3'],'Gain',num2str(theta4));

% theta2=get(handles.slider1,'value');
% set_param([ModelName '/Slider Gain1'],'Gain',num2str(theta2));

% slider 1 dar in meghdar bemoneh
set(handles.slider1,'value',theta2);

T1 = [ cosd(theta1) 0   -sind(theta1)    0;
       sind(theta1) 0   -cosd(theta1)    0;
       0            -1       0           486;
       0            0       0            1];

T2 = [ cosd(theta2) -sind(theta2)   0   a2*cosd(theta2);
       sind(theta2) cosd(theta2)    0   a2*sind(theta2);
       0            0               1       0;
       0            0               0        1];
   
T3 = [ cosd(theta3) -sind(theta3)   0   a3*cosd(theta3);
       sind(theta3) cosd(theta3)    0   a3*sind(theta3);
       0            0               1     0;
       0            0               0       1];
   
T4 = [ cosd(theta4) -sind(theta4)   0   a4*cosd(theta4);
       sind(theta4) cosd(theta4)    0   a4*sind(theta4);
       0            0               1   0;
       0            0               0     1];


T = T1*T2*T3*T4;
px=T(1,4);
py=T(2,4);
pz=T(3,4);

set(handles.edit9,'string',num2str(px));
set(handles.edit10,'string',num2str(py));
set(handles.edit11,'string',num2str(pz));





% slider0
function slider1_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end












% slider2
function slider2_Callback(hObject, eventdata, handles)
ModelName = 'Assem1';
 a1 = 486;
a2 = 500;
a3 = 420.17;
a4 = 160;
theta1=get(handles.slider0,'value');
set(handles.edit5,'string',num2str(theta1));
theta2=get(handles.slider1,'value');
set(handles.edit6,'string',num2str(theta2));
theta3=get(handles.slider2,'value');
set(handles.edit7,'string',num2str(theta3));
theta4=get(handles.slider3,'value');
set(handles.edit8,'string',num2str(theta4));

set_param([ModelName '/Slider Gain0'],'Gain',num2str(theta1));
set_param([ModelName '/Slider Gain1'],'Gain',num2str(theta2));
set_param([ModelName '/Slider Gain2'],'Gain',num2str(theta3));
set_param([ModelName '/Slider Gain3'],'Gain',num2str(theta4));


% theta3=get(handles.slider2,'value');
% set_param([ModelName '/Slider Gain2'],'Gain',num2str(theta3));
set(handles.slider2,'value',theta3);

T1 = [ cosd(theta1) 0   -sind(theta1)    0;
       sind(theta1) 0   -cosd(theta1)    0;
       0            -1       0           486;
       0            0       0            1];

T2 = [ cosd(theta2) -sind(theta2)   0   a2*cosd(theta2);
       sind(theta2) cosd(theta2)    0   a2*sind(theta2);
       0            0               1       0;
       0            0               0        1];
   
T3 = [ cosd(theta3) -sind(theta3)   0   a3*cosd(theta3);
       sind(theta3) cosd(theta3)    0   a3*sind(theta3);
       0            0               1     0;
       0            0               0       1];
   
T4 = [ cosd(theta4) -sind(theta4)   0   a4*cosd(theta4);
       sind(theta4) cosd(theta4)    0   a4*sind(theta4);
       0            0               1   0;
       0            0               0     1];
T = T1*T2*T3*T4;
px=T(1,4);
py=T(2,4);
pz=T(3,4);

set(handles.edit9,'string',num2str(px));
set(handles.edit10,'string',num2str(py));
set(handles.edit11,'string',num2str(pz));







% slider2
function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





















% slider3
function slider3_Callback(hObject, eventdata, handles)
ModelName = 'Assem1';
a1 = 486;
a2 = 500;
a3 = 420.17;
a4 = 160;
theta1=get(handles.slider0,'value');
set(handles.edit5,'string',num2str(theta1));
theta2=get(handles.slider1,'value');
set(handles.edit6,'string',num2str(theta2));
theta3=get(handles.slider2,'value');
set(handles.edit7,'string',num2str(theta3));
theta4=get(handles.slider3,'value');
set(handles.edit8,'string',num2str(theta4));

set_param([ModelName '/Slider Gain0'],'Gain',num2str(theta1));
set_param([ModelName '/Slider Gain1'],'Gain',num2str(theta2));
set_param([ModelName '/Slider Gain2'],'Gain',num2str(theta3));
set_param([ModelName '/Slider Gain3'],'Gain',num2str(theta4));


% theta4=get(handles.slider3,'value');
% set_param([ModelName '/Slider Gain3'],'Gain',num2str(theta4));
set(handles.slider3,'value',theta4);


T1 = [ cosd(theta1) 0   -sind(theta1)    0;
       sind(theta1) 0   -cosd(theta1)    0;
       0            -1       0           486;
       0            0       0            1];

T2 = [ cosd(theta2) -sind(theta2)   0   a2*cosd(theta2);
       sind(theta2) cosd(theta2)    0   a2*sind(theta2);
       0            0               1       0;
       0            0               0        1];
   
T3 = [ cosd(theta3) -sind(theta3)   0   a3*cosd(theta3);
       sind(theta3) cosd(theta3)    0   a3*sind(theta3);
       0            0               1     0;
       0            0               0       1];
   
T4 = [ cosd(theta4) -sind(theta4)   0   a4*cosd(theta4);
       sind(theta4) cosd(theta4)    0   a4*sind(theta4);
       0            0               1   0;
       0            0               0     1];
T = T1*T2*T3*T4;
px=T(1,4);
py=T(2,4);
pz=T(3,4);

set(handles.edit9,'string',num2str(px));
set(handles.edit10,'string',num2str(py));
set(handles.edit11,'string',num2str(pz));
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function edit0_Callback(hObject, eventdata, handles)
% hObject    handle to edit0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0 as text
%        str2double(get(hObject,'String')) returns contents of edit0 as a double


function edit0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)

px=get(handles.slider7,'value');
set(handles.edit13,'string',num2str(px));
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)

py=get(handles.slider8,'value');
set(handles.edit14,'string',num2str(py));
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
pz=get(handles.slider9,'value');
set(handles.edit15,'string',num2str(pz));
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

















% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)

% Å«—«„ —Â«? ·?‰òùÂ«
a1 = 486;
a2 = 500;
a3 = 420.17;
a4 = 160;

% „Œ ’«  Âœ›
px = get(handles.slider7, 'value');
py = get(handles.slider8, 'value');
pz = get(handles.slider9, 'value');

% „Õ«”»Â theta1
theta1 = atan2d(py, px);

% „Õ«”»Â ›«’·Â «“ „»œ«  « Âœ› œ— ’›ÕÂ «›ﬁ?
d = sqrt(px^2 + py^2) - a4;

% «— ›«⁄ «“ ”ÿÕ „»œ«  « Âœ›
z4 = pz - a1;

% „Õ«”»Â theta3
cos_theta3 = (d^2 + z4^2 - a2^2 - a3^2) / (2 * a2 * a3);
theta3 = acosd(cos_theta3);

% „Õ«”»Â theta2
theta2 = atan2d(z4, d) - atan2d(a3 * sind(theta3), a2 + a3 * cosd(theta3));

% „Õ«”»Â theta4
theta234 = 0; % ›—÷?Â »—«? „À«·° »«?œ „ﬁœ«— œ—”  —«  ⁄??‰ ò‰?œ
theta4 = theta234 - theta2 - theta3;

% »—Ê“ —”«‰? Å«—«„ —Â« œ— GUI
set(handles.edit13, 'string', num2str(px));
set(handles.edit14, 'string', num2str(py));
set(handles.edit15, 'string', num2str(pz));

set(handles.edit9, 'string', num2str(px));
set(handles.edit10, 'string', num2str(py));
set(handles.edit11, 'string', num2str(pz));

% »Â —Ê“ —”«‰? “Ê«?« œ— GUI
set(handles.edit5, 'string', num2str(theta1));
set(handles.edit6, 'string', num2str(theta2));
set(handles.edit7, 'string', num2str(theta3));
set(handles.edit8, 'string', num2str(theta4));

% »Â —Ê“ —”«‰? Å«—«„ —Â« œ— Simulink
ModelName = 'assem1';
set_param([ModelName '/Slider Gain0'], 'Gain', num2str(theta1));
set_param([ModelName '/Slider Gain1'], 'Gain', num2str(theta2));
set_param([ModelName '/Slider Gain2'], 'Gain', num2str(theta3));
set_param([ModelName '/Slider Gain3'], 'Gain', num2str(theta4));

guidata(hObject, handles);








function slider5_Callback(hObject, eventdata, handles)
px=get(handles.slider5,'value');
set(handles.edit9,'string',num2str(px));
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
