function indices = findNearestIndices(data, commontimestamps)
% findNearestIndices returns the indices of the elements in 'data' 
% that are closest to the values in 'commontimestamps'.
%
% Usage:
%   indices = findNearestIndices(data, commontimestamps)
%
% Inputs:
%   data            - A vector containing data values.
%   commontimestamps- A vector of timestamp values for which the closest 
%                     index in 'data' is required.
%
% Output:
%   indices         - A vector of indices corresponding to the closest 
%                     values in 'data' for each timestamp.
    
    % Preallocate the output vector
    indices = zeros(1, length(commontimestamps));
    
    % Loop through each timestamp
    for i = 1:length(commontimestamps)
        % Find the index of the value in 'data' that minimizes the absolute difference
        [~, indices(i)] = min(abs(data - commontimestamps(i)));
    end
end
