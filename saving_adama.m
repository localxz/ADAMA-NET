%% Load Station Connections and Initialize
clear; clc; close all; 
instafile = 'ADAMA_staconns.csv';
tablelstfull = readtable(instafile);
tablelstfull = tablelstfull(find(tablelstfull.distance_km<=1500),:);
[ndata, ~] = size(tablelstfull);

%% Loop Through All Station Pairs to Find and Plot Valid Data

output_dir = "SAC_files"

if ~exist(output_dir, 'dir') 
  mkdir(output_dir)
end


for i = 1:10 
    station_dist = tablelstfull(i,:).distance_km;
    net1 = tablelstfull(i,:).net1{:};
    sta1 = tablelstfull(i,:).sta1{:};
    NET1STA1 = [net1 '.' sta1];
    net2 = tablelstfull(i,:).net2{:};
    sta2 = tablelstfull(i,:).sta2{:};
    NET2STA2 = [net2 '.' sta2];
    
    try
        [freq_adama, pvel, ~] = read_ADAMA_raw(NET1STA1, NET2STA2, 'R', 'cf');
        if ~any(pvel)
            error('Phase velocity data is all zeros.');
        end
        
        [~, rncf, incf, ~] = read_ADAMA_ncfs(NET1STA1, NET2STA2, 'ZZ');
        if isempty(rncf) || isempty(incf)
            error('NCF data is empty.');
        end
    catch
        continue; 
    end

   ncf_signal = rncf;

   sampling_rate = 40;

    header.DELTA = 1 / sampling_rate;
    header.DIST = station_dist;
    header.KNETWK = net1;
    header.KSTNM = sta1;
    header.KCMPNM = 'ZZ'; 
    header.KUSER0 = net2; 
    header.KUSER1 = sta2; 
   
    t0 = datenum(1970, 1, 1, 0, 0, 0);

    header.B = - (length(ncf_signal) - 1) / (2 * sampling_rate);
    header.E = (length(ncf_signal) - 1) / (2 * sampling_rate);
    
    sac_filename = fullfile(output_dir, sprintf('%s-%s.sac', NET1STA1, NET2STA2));
    
    mksac(sac_filename, ncf_signal,t0, header);

end


