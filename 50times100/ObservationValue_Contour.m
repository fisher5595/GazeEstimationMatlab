function [ ObservationValue ] = ObservationValue_Contour( EdgeMag, EdgeTheta, Xe, Theta, A, B, C)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Value=0;
ObservationValue=ObservationValue_UpParabola( EdgeMag, EdgeTheta, Xe, Theta, A, B)+ObservationValue_LowParabola( EdgeMag, EdgeTheta, Xe, Theta, C, B);

end

