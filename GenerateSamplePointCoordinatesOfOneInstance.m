function [ SamplePointCoordinateVector ] = GenerateSamplePointCoordinatesOfOneInstance( Xe, Xc, Theta, A, A2, C, B, B2, R )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
SamplePointCoordinateVector=[];
Delta=2*pi/10;
for x0=-B:B/5:B
    y0=A-A/(B^2)*(x0^2);
    SamplePointCoordinateVector=[SamplePointCoordinateVector;x0;y0];
end
for x0=-B:B/5:B
    y0=-C+C/(B^2)*(x0^2);
    SamplePointCoordinateVector=[SamplePointCoordinateVector;x0;y0];
end
for x0=-B2:B2/5:B2
    y0=A2-A2/(B2^2)*(x0^2);
    SamplePointCoordinateVector=[SamplePointCoordinateVector;x0;y0];
end
for CircleTheta=0:Delta:(2*pi)
    x0=R*cos(CircleTheta)+Xc(2);
    y0=R*sin(CircleTheta)+Xc(1);
    SamplePointCoordinateVector=[SamplePointCoordinateVector;x0;y0];
end

end


