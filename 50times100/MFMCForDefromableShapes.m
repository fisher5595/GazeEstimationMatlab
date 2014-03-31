% MFMC code for deformable shape tracking. In order to get the shape parameters.
% In this situation, we have tree parts for one eye. Upper parabola, lower
% one and middle circle for iris.
clc;
clear all;
Img=imread('resizedEyes_right_35.jpg');

% Loop body

% Importance sampling: Importance function can use the potential function.
% Do the sampling using the expectation of parameters.

% Re-weight: calculate weight, based on observation, messages and
% importance value.

% Normalize weight

% End of loop body