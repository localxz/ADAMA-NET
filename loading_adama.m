%% Load the Station Connections File for All Listed Stations
clear; clc;
instafile = 'adama/ADAMA_staconns.csv';
tablelstfull = readtable(instafile);
tablelstfull = tablelstfull(find(tablelstfull.distance_km<=1500),:);
[ndata, ~] = size(tablelstfull);

%% For Now Load Only One Station (For full scan we loop from 1:ndata)

% cf_adama_mat = zeros(ndata,7200);
cf_adama_mat = zeros(1,7200);
idx = find(strcmp(tablelstfull.sta1, 'RUNG') & strcmp(tablelstfull.sta2, 'MTAN'));
for i = idx % 1:ndata
    dist = tablelstfull(i,:).distance_km;
    net1 = tablelstfull(i,:).net1{:};
    sta1 = tablelstfull(i,:).sta1{:};
    NET1STA1 = [net1 '.' sta1];

    net2 = tablelstfull(i,:).net2{:};
    sta2 = tablelstfull(i,:).sta2{:};
    NET2STA2 = [net2 '.' sta2];


    % The below code loads Phase Velocity
    % [freq_adama, cf_adama_mat(1,:), ~] = read_ADAMA_raw(NET1STA1, NET2STA2, 'R', 'cf'); %replace 1 with i while scaning


    % The below code loads the NCFs
    [freq, rncf, incf, msg] = read_ADAMA_ncfs(NET1STA1,  NET2STA2, 'ZZ');

end

%% Plot Phase Velocity
figure(1);
plot(freq_adama, cf_adama_mat);
xlabel('freuquency');
ylabel('phase vel');

%% Plot CCF
figure(2);
plot(freq, rncf);
xlabel('freuquency');
ylabel('ccf');
