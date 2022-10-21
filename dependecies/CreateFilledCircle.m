function h = CreateFilledCircle(center,r,N,color)
% center : center coordinates
% r : radius of the circle
% N : number of points
% color : fill color
THETA=linspace(0,2*pi,N);
RHO=ones(1,N)*r;
[X,Y] = pol2cart(THETA,RHO);
X=X+center(1);
Y=Y+center(2);
h=fill(X,Y,color);
end
