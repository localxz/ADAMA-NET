function [freq, rncf, incf, msg] = read_ADAMA_ncfs(NET_STA1, NET_STA2, CHAN)
%% Author: Baowei Liu, baowei.liu@rochester.edu
%% Goal: read out the noise correlation function (NCF) between two stations pairs
%%       from hdf5 created by python
%% Input: NET_STA1,2: the network.stations
%%        CHAN: channel Name (R, T, Z)
%% Output: frequency: array with frequency values
%%         rncf:      real part of NCF
%%         incf:      imaginary part of NCF
%%         msg:       message about the running 
%% Example of Usage: [freq, rncf, incf, msg] = read_ADAMA_ncfs('ZV.SUMA', 'G.ATD', 'Z');
%% Updated: 12.9.2021 
%% Modified by Siyu: Dec. 29, 2021
%%   -- Deleted the LettersPattern section of the code
%%   -- Updated the channel search based on user input
%%   -- Added the station switch (now sta2_sta1 will also return true results)

clc;

%% File paths
ifn = ['.\data\ADAMA_ncfs_' CHAN '_fi.h5'];
rfn = ['.\data\ADAMA_ncfs_' CHAN '_fr.h5'];
% Check if files exist
if exist(rfn, 'file') ~= 2
    error('HDF5 file for real part does not exist: %s', rfn);
end
if exist(ifn, 'file') ~= 2
    error('HDF5 file for imaginary part does not exist: %s', ifn);
end

freq = zeros(7200, 1);
rncf = zeros(7200, 1);
incf = zeros(7200, 1);

%% Find the channel names from the filename
chn = strcat(CHAN, CHAN);
chnP = strcat('.ZZ-.ZZ');

%% Construct group and dataset names
grpNm = strcat('/waveforms/', NET_STA1, '-', NET_STA2, '/', chnP, '/');
datasetNm = strcat(grpNm, '1970-01-01T00:00:00_1970-01-01T01:59:59');

% Debugging statements
disp(['Real part file: ', rfn]);
disp(['Imaginary part file: ', ifn]);
disp(['Group name: ', grpNm]);
disp(['Dataset name: ', datasetNm]);

msg = 'Finished searching...';

try
    rncf = h5read(rfn, datasetNm);
    disp('Read real part successfully');
catch ME
    disp('Failed to read real part with original station order.');
    disp(getReport(ME));
    try
        grpNm = strcat('/waveforms/', NET_STA2, '-', NET_STA1, '/', chnP, '/');
        datasetNm = strcat(grpNm, '1970-01-01T00:00:00_1970-01-01T01:59:59');
        disp(['Trying switched station order, dataset name: ', datasetNm]);
        rncf = h5read(rfn, datasetNm);
        disp('Read real part successfully with switched station order');
    catch ME2
        msg = strcat('cannot find real NCF data for: ', NET_STA1, '-', NET_STA2);
        disp(getReport(ME2));
    end
end

try
    incf = h5read(ifn, datasetNm);
    disp('Read imaginary part successfully');
catch ME
    disp('Failed to read imaginary part with original station order.');
    disp(getReport(ME));
    try
        grpNm = strcat('/waveforms/', NET_STA2, '-', NET_STA1, '/', chnP, '/');
        datasetNm = strcat(grpNm, '1970-01-01T00:00:00_1970-01-01T01:59:59');
        disp(['Trying switched station order, dataset name: ', datasetNm]);
        incf = h5read(ifn, datasetNm);
        disp('Read imaginary part successfully with switched station order');
    catch ME2
        msg = strcat(msg, '; cannot find imag NCF data for: ', NET_STA1, '-', NET_STA2);
        disp(getReport(ME2));
    end
end

T = 4 * 60 * 60 * 1; %% 4 hours at 1Hz sRate
dt = 1; %%1 second
freq = [1/T:1/T:0.5*dt];

disp('Function read_ADAMA_ncfs executed successfully.');
end
