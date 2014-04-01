function [ OutCor ] = ImgCor2NewCor( InputCor, Xe, Theta )
%UNTITLED Summary of this function goes here
%   InputCor(1) is input image height, InputCor(2) is input image width.
%   OutCor(1) is y, OutCor(2) is x. All column vectors

InputCoordinate=double(InputCor);
InputXe=double(Xe);
InputTheta=double(Theta);

CorShiftXe=[InputXe(1)-InputCoordinate(1);InputCoordinate(2)-InputXe(2)];

OutCor=[cos(InputTheta),-sin(InputTheta);sin(InputTheta),cos(InputTheta)]*CorShiftXe;
end

