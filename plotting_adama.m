%% Load Station Connections and Initialize
clear; clc; close all; 
instafile = 'ADAMA_staconns.csv';
tablelstfull = readtable(instafile);
tablelstfull = tablelstfull(find(tablelstfull.distance_km<=1500),:);
[ndata, ~] = size(tablelstfull);
plot_count = 0; 
fprintf('Searching for valid station pairs and plotting...\n');

%% Loop Through All Station Pairs to Find and Plot Valid Data
for i = 1:10 
    
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

    plot_count = plot_count + 1;
    figure; 
    
    subplot(2, 1, 1);
    ncf_signal = rncf + 1i * incf;
    sampling_rate = 40;
    time_axis = (0:length(ncf_signal)-1) / sampling_rate;
    plot(time_axis, real(ncf_signal), 'g');
    title('NCF Waveform');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    subplot(2, 1, 2);
    periods = 1./freq_adama;
    valid_indices = pvel > 0;
    
    filtered_periods = periods(valid_indices);
    filtered_pvel = pvel(valid_indices);
    sorted_data = sortrows([filtered_periods(:), filtered_pvel(:)], 1);
    
    plot(sorted_data(:, 1), sorted_data(:, 2), 'r');
    
    title('Phase Velocity (Akiestimate)');
    xlabel('Period (s)');
    ylabel('Velocity (km/s)');
    grid on;
    
    sgtitle(['Station Pair: ' NET1STA1 ' - ' NET2STA2 ' (#' num2str(i) ')']);

end

fprintf('\nSearch complete. Generated %d plots.\n', plot_count);
