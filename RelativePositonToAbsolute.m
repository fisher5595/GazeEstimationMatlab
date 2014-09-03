function FunctionValue = RelativePositonToAbsolute( CoordinateAndLengthUnit,RelativePosition )
%Given input Relatvie Position, give the relationship between the absolute coorinates and the
%normorlized length unit and the relative position.
%   CoordinateAndLengthUnit(1)=coordinate on y
%   axis,CoordinateAndLengthUnit(2)=coordinate on x
%   axis,CoordinateAndLengthUnit(3) is the normalized length unit.
%   RelativePosition including the normalized length to
%   upleft,upright,bottomleft,and bottom right corner.
AnchorCoordinate=zeros(2,36);
for y=1:6
    for x=1:6
        AnchorCoordinate(1,(y-1)*6+x)=floor(480/7*y);
        AnchorCoordinate(2,(y-1)*6+x)=floor(640/7*x);
    end
end

for i=1:36
    FunctionValue(i)=((CoordinateAndLengthUnit(1)'-AnchorCoordinate(1,i)).^2+(CoordinateAndLengthUnit(2)'-AnchorCoordinate(2,i)).^2-(CoordinateAndLengthUnit(3)*RelativePosition(i)).^2).^2;
end

end

