function [ ObservationValue ] = ObservationValue_Contour_Plus_Outter_Up_Parabola( EdgeMag, EdgeTheta, Xe, Theta, A, A2, B, B2, C)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Value=0;
ObservationValue=ObservationValue_UpParabola( EdgeMag, EdgeTheta, Xe, Theta, A, B)+ObservationValue_LowParabola( EdgeMag, EdgeTheta, Xe, Theta, C, B)+ObservationValue_OutterUpParabola( EdgeMag, EdgeTheta, Xe, Theta, A2, B2);

end

