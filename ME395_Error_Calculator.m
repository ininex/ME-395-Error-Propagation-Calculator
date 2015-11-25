function [errorArray]=ME395_Error_Calculator(ArrayWithError1,...
    ArrayWithError2,ArrayWithError3,ArrayWithError4,ArrayWithError5)
% Created by Guanjiu Zhang
% Refer to core function "PropError" written by Brad Ridder
% Purpose=> Calculating errors propagation for any equation with big data 
%           input.
%        => Save your time with just one click!:)
% This program supports up to 5 variables in the equation.
% Each variable that will be used should accompany with an input data
% array with the following formatting:
%                              Col1       Col2
%                    Row1  meanValue 1   Error 1
%                    Row2  meanValue 2   Error 2
%                     ...      ...          ...
%     *Each row would represents a different condition of lab setup
%                 *If only one setup is used, use just one row

% Example: find volumetric flow rate and error governed by 
% equation Q=(pi/4)*(D^2)*V

% >>[errorArray]=ME395_Error_Calculator(D_dataArray,V_dataArray);

% In the input dialog box:
%                    -> input (pi/4)*(x^2)*y as equation
%                    -> input xy as variables
%                    -> Click OK and wait for your errors!
%      NOTICE:  1. xy must be in the same order as when you input variables
%               into functions, in our case is (D,V). If input is in the order
%               (V,D),use yx instead.
%               2. D is a symbol that will not work in this program. 
%               Use x and y to replace D and V instead.

g=warndlg({['Make sure you have input arrays number equal'],...
    ['to variables number you are going to define!']},'!! Warning !!');
uiwait(g);
prompt = {'Input your equation as a string below (Only RHS of Equation is Needed!)):',...
    'Input your variable names:'};
titletext = 'ME395 Error Calcs V1.0';
result = inputdlg(prompt,titletext,[1, length(titletext)+30]);
if isempty(result)==1
    errorArray = 'Error, empty inputs!';
    return
end
Eqn = char(result{1,1});
VarNames = char(result{2,1});
if isempty(Eqn)==1 || isempty(VarNames)==1
    errorArray = 'Error, empty inputs!';
    return
end
for i=1:length(VarNames)
storeVar.names{i} = sym(VarNames(i));
end
Var = [];
for i=1:length(VarNames)
Var = [Var storeVar.names{1,i}];
end
VarNames = Var;
Eqn = sym(Eqn);
switch nargin 
    case 1
        for i=1:length(ArrayWithError1)
            s=PropError(Eqn,VarNames,ArrayWithError1(i,1),ArrayWithError1(i,2));
            errorArray(i,1)=double(s{1,1});
            errorArray(i,2)=double(s{1,3});
        end
    case 2
        for i=1:length(ArrayWithError1)
            s=PropError(Eqn,VarNames,[ArrayWithError1(i,1) ArrayWithError2(i,1)],...
                [ArrayWithError1(i,2) ArrayWithError2(i,2)]);
            errorArray(i,1)=double(s{1,1});
            errorArray(i,2)=double(s{1,3});
        end
    case 3
        for i=1:length(ArrayWithError1)
            s=PropError(Eqn,VarNames,[ArrayWithError1(i,1) ArrayWithError2(i,1)...
                ArrayWithError3(i,1)],[ArrayWithError1(i,2) ...
                ArrayWithError2(i,2) ArrayWithError3(i,2)]);
            errorArray(i,1)=double(s{1,1});
            errorArray(i,2)=double(s{1,3});
        end
    case 4
        for i=1:length(ArrayWithError1)
            s=PropError(Eqn,VarNames,[ArrayWithError1(i,1) ArrayWithError2(i,1)...
                ArrayWithError3(i,1) ArrayWithError4(i,1)],...
                [ArrayWithError1(i,2) ArrayWithError2(i,2) ...
                ArrayWithError3(i,2) ArrayWithError4(i,2)]);
            errorArray(i,1)=double(s{1,1});
            errorArray(i,2)=double(s{1,3});
        end
    case 5
        for i=1:length(ArrayWithError1)
            s=PropError(Eqn,VarNames,[ArrayWithError1(i,1) ArrayWithError2(i,1)...
                ArrayWithError3(i,1) ArrayWithError4(i,1)...
                ArrayWithError5(i,1)],...
                [ArrayWithError1(i,2) ArrayWithError2(i,2) ...
                ArrayWithError3(i,2) ArrayWithError4(i,2) ArrayWithError5(i,2)]);
            errorArray(i,1)=double(s{1,1});
            errorArray(i,2)=double(s{1,3});
        end
end

function sigma = PropError(f,varlist,vals,errs)
%SIGMA = PROPERROR(F,VARLIST,VALS,ERRS)
%
%Finds the propagated uncertainty in a function f with estimated variables
%"vals" with corresponding uncertainties "errs".
%
%varlist is a row vector of variable names. Enter in the estimated values
%in "vals" and their associated errors in "errs" at positions corresponding 
%to the order you typed in the variables in varlist.
%
%Example using period of a simple harmonic pendulum:
%
%For this example, lets say the pendulum length is 10m with an uncertainty
%of 1mm, and no error in g.
%syms L g
%T = 2*pi*sqrt(L/g)
%type the function T = 2*pi*sqrt(L/g)
%
%PropError(T,[L g],[10 9.81],[0.001 0])
%ans =
%
%    [       6.3437]    '+/-'    [3.1719e-004]
%    'Percent Error'    '+/-'    [     0.0050]
%
%(c) Brad Ridder 2007. Feel free to use this under the BSD guidelines. If
%you wish to add to this program, just leave my name and add yours to it.
n = numel(varlist);
sig = vpa(ones(1,n));
for i = 1:n
    sig(i) = diff(f,varlist(i),1);
end
test = (sum((subs(sig,varlist,vals).^2).*(errs.^2)));
error1 =sqrt(test);
error = double(error1);
sigma = [{subs(f,varlist,vals)} {'+/-'} {error};
         {'Percent Error'} {'+/-'} {abs(100*(error)/subs(f,varlist,vals))}];