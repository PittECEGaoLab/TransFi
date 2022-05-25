%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ruirong Chen CUSTOM STARLEGO RECEIVER DESIGN 
% Run injection_40M
% sudo ./injection_40M -i wls4
% @PITT
% Part of STARLEGO project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
load target_signal_time.mat
load target_data.mat
load LTF_f_emulated.mat
CHANNEL         = 2;         % Choose the channel we will receive on
MODE            = 40;                   % Setting receiver mode 20= 20M 40 = 40M
detected_10M    = 0;
detected_5M     = 0;
detected_10M_FSA= 0;
N_DATA_SYMS = 5;
NUM_SAMPLES     = 2^23;      % Number of samples to request

SC_IND_PILOTS           = [9 36];                           % Pilot subcarrier indices
SC_IND_DATA             = [2:7 9:21 23:27 39:43 45:57 59:64];     % Data subcarrier indices

FFT_OFFSET                    = 0;
N_OFDM_SYMS                   = 401;
N_SC                          = 64;                                     % Number of subcarriers
CP_LEN                        = 16;                                     % Cyclic prefix length
Total_samples                 = NUM_SAMPLES;


%% WARP Configure

% Create a node object
node = wl_initNodes(1);

% Read Trigger IDs into workspace
trig_in_ids  = wl_getTriggerInputIDs(node);
trig_out_ids = wl_getTriggerOutputIDs(node);

% For both nodes, we will allow Ethernet to trigger the buffer baseband and the AGC
wl_triggerManagerCmd(node, 'output_config_input_selection', [trig_out_ids.BASEBAND, trig_out_ids.AGC], [trig_in_ids.ETH_A]);

% Set the trigger output delays. 
%
% NOTE:  We are waiting 3000 ns before starting the AGC so that there is time for the inputs 
%   to settle before sampling the waveform to calculate the RX gains.
%
node.wl_triggerManagerCmd('output_config_delay', [trig_out_ids.BASEBAND], 0);
node.wl_triggerManagerCmd('output_config_delay', [trig_out_ids.AGC], 3000);     % 3000 ns delay before starting the AGC

% Get IDs for the interfaces on the board.
ifc_ids = wl_getInterfaceIDs(node);

% Use RFA as the receiver
RF_RX     = ifc_ids.RF_ON_BOARD;
RF_RX_VEC = ifc_ids.RF_ON_BOARD_VEC;

wl_interfaceCmd(node, RF_RX, 'rx_lpf_corn_freq',3);
wl_interfaceCmd(node, RF_RX, 'rx_lpf_corn_freq_fine',5);

% Check the number of samples
max_rx_samples = wl_basebandCmd(node, RF_RX_VEC, 'rx_buff_max_num_samples');

% Get the sample rate of the node
Ts = 1/(wl_basebandCmd(node, 'tx_buff_clk_freq'));

% Print information to the console
fprintf('Generating spectrogram using %.4f seconds of data (%d samples).\n', (NUM_SAMPLES * Ts), NUM_SAMPLES );

% Create a UDP broadcast trigger and tell each node to be ready for it
eth_trig = wl_trigger_eth_udp_broadcast;
wl_triggerManagerCmd(node, 'add_ethernet_trigger', [eth_trig]);

% Set up the interface for the experiment
wl_interfaceCmd(node, ifc_ids.RF_ALL, 'channel', 5, CHANNEL);

% Set the gains manually
wl_interfaceCmd(node, ifc_ids.RF_ALL, 'rx_gain_mode', 'manual');
RxGainRF = 2;                % Rx RF Gain in [1:3]
RxGainBB = 6;               % Rx Baseband Gain in [0:31]
wl_interfaceCmd(node, ifc_ids.RF_ALL, 'rx_gains', RxGainRF, RxGainBB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Receive signal using WARPLab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the receive length to the number of samples
wl_basebandCmd(node, 'rx_length', NUM_SAMPLES);

% Open up the transceiver's low-pass filter to its maximum bandwidth (36MHz)

% Enable to node to receive data 
wl_interfaceCmd(node, RF_RX, 'rx_en');
wl_basebandCmd(node, RF_RX, 'rx_buff_en');

% Trigger the node to receive samples
eth_trig.send();

% Read the samples from the node
rx_IQ = wl_basebandCmd(node, RF_RX_VEC, 'read_IQ', 0, NUM_SAMPLES);



% Disable the RX buffers
wl_basebandCmd(node, ifc_ids.RF_ALL, 'tx_rx_buff_dis');
wl_interfaceCmd(node, ifc_ids.RF_ALL, 'tx_rx_dis');

%% section for spectrum analysis
close all
rx_vec_air_A = rx_IQ(:,1);
rx_vec_air_B = rx_IQ(:,2);
%Figure 1: Time Series
t_vec = (0:(NUM_SAMPLES-1))/(40e6);


rx_IQ_decimate = rx_IQ(1:floor(NUM_SAMPLES/1000):end,1);
t_vec_decimate = t_vec(1,1:floor(NUM_SAMPLES/1000):end);

cf = 0;
cf = cf + 1;
figure(cf); clf;
subplot(2,1,1);
plot(real(rx_IQ), 'b');
axis([0 length(rx_IQ) -1 1])
grid on;
title('Rx Waveform (I)');

subplot(2,1,2);
plot(imag(rx_IQ), 'r');
axis([0 length(rx_IQ) -1 1])
grid on;
title('Rx Waveform (Q)');

zoom_span_time    = 100/1000;                         % 100 ms 
ZOOM_SAMPLE_LIMIT = 4 * (zoom_span_time * 40e6);



M = floor(sqrt(NUM_SAMPLES));
N = M;



rx_IQ_slice    = rx_IQ(1:(M*N),1);
rx_IQ_mat      = reshape(rx_IQ_slice, M, N).';
rx_spectrogram = fft(rx_IQ_mat, N, 2);

% Zero out any DC offset
rx_spectrogram(:,1) = zeros(M,1);

% Perform an fftshift so that the DC frequency bin is in the middle
rx_spectrogram = fftshift(rx_spectrogram,2);

% Plot the Spectrogram on a dB scale
h = figure('units','pixels','Position',[100 100 2000 1000]);clf;
set(h,'PaperPosition',[.25 .25 20 10]);

% Plot the entire view
if ( NUM_SAMPLES >= ZOOM_SAMPLE_LIMIT )
    subplot(1,2,1)
end

x_axis = linspace(-20,20,N);
y_axis = (0:(M-1)) / (40e6 / N);
imagesc(x_axis,y_axis,20*log10(abs(rx_spectrogram)./max(abs(rx_spectrogram(:)))));
caxis([-50 0])
colorbar
axis square

xlabel('Frequency (MHz)')
ylabel('Time (s)')
title(sprintf('Spectrogram on dB Scale (%1.4f second view)', max(t_vec)))

if ( NUM_SAMPLES >= ZOOM_SAMPLE_LIMIT )
    % Zoom into a small piece in the middle of the spectrogram
    subplot(1,2,2)

    % Let's zoom in on a chunk out of the entire reception
    zoom_span_index = ceil(zoom_span_time * (40e6 / N));
    index_range     = floor((M/2)-(zoom_span_index/2)):floor((M/2)+(zoom_span_index/2));

    y_axis_slice         = y_axis( index_range );
    rx_spectrogram_slice = rx_spectrogram( index_range, : );

    imagesc(x_axis, y_axis_slice, 20 * log10(abs(rx_spectrogram_slice)./max(abs(rx_spectrogram(:)))));
    caxis([-50 0])
    colorbar
    axis square

    xlabel('Frequency (MHz)')
    ylabel('Time (s)')
    title(sprintf('Spectrogram on dB Scale (%1.4f second view)', zoom_span_time))
end

%% Payload processing
   
cfg = wlanHTConfig('ChannelBandwidth','CBW20','MCS',0,'NumTransmitAntennas',1,'NumSpaceTimeStreams',1,'PSDULength',500);
cfg_40M = wlanHTConfig('ChannelBandwidth','CBW40','MCS',0,'NumTransmitAntennas',1,'NumSpaceTimeStreams',1,'PSDULength',500);

LLTF_40M = wlanLLTF(cfg_40M);
LSTF_40M = wlanLSTF(cfg_40M);



[ltfLeft, ltfRight] = wlan.internal.lltfSequence(); % Sequences based on lltf

cfgOFDM = wlan.internal.wlanGetOFDMConfig('CBW20', 'Long', 'Legacy');

CPLen  = cfgOFDM.CyclicPrefixLength;

% LTS for CFO and channel estimation
L_ltf_f = [0;0;0;0;0;0;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;0;1;-1;-1;1;1;-1;1;-1;1;-1;-1;-1;-1;-1;1;1;-1;-1;1;1;-1;-1;1;1;1;1;0;0;0;0;0];
% from emulation algorithm
L_ltf_emulated = [0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;-0.308606699924184 + 0.462910049886276i;-0.532307590882836 - 0.0771516749810494i;0.925820099772552 + 6.66133814775094e-16i;0.976497505339307 + 0.0319572701369498i;-0.925820099772552 - 1.31838984174237e-15i;0.146446609406726 + 0.353553390593274i;-0.925820099772552 + 7.63278329429795e-16i;0.976497505339307 - 0.0319572701369492i;-0.925820099772552 + 9.71445146547012e-17i;0.976497505339307 - 0.0319572701369484i;-0.925820099772552 - 5.68989300120393e-16i;0.976497505339307 + 0.0319572701369498i;0.925820099772552 + 1.23512311489549e-15i;0.976497505339307 - 0.0319572701369500i;0.925820099772552 + 1.88737914186277e-15i;0.976497505339307 - 0.0319572701369493i;0.925820099772552 - 1.94289029309402e-16i;-0.976497505339307 + 0.0319572701369486i;-0.925820099772552 - 4.71844785465692e-16i;0.976497505339307 - 0.0319572701369493i;0.925820099772552 + 1.13797860024079e-15i;-0.976497505339307 + 0.0319572701369501i;0.925820099772552 + 4.30211422042248e-16i;-0.976497505339307 + 0.0319572701369494i;0.925820099772552 - 2.77555756156289e-16i;0.976497505339307 - 0.0319572701369502i;0.925820099772552 + 3.74700270810990e-16i;0.976497505339307 - 0.0319572701369495i;0.925820099772552 + 1.04083408558608e-15i;-0.976497505339307 - 0.0319572701369503i;-0.925820099772552 - 3.33066907387547e-16i;0.976497505339307 - 0.0319572701369495i;0.925820099772552 - 3.74700270810990e-16i;0.146446609406726 + 0.353553390593274i;-0.925820099772552 - 2.77555756156289e-16i;0.976497505339307 - 0.0319572701369496i;-0.925820099772552 - 1.31838984174237e-15i;0.976497505339307 + 0.0319572701369501i;-0.925820099772552 - 2.35922392732846e-16i;-0.976497505339307 + 0.0319572701369496i;-0.925820099772552 - 2.08166817117217e-16i;-0.976497505339307 - 0.0319572701369501i;-0.925820099772552 - 1.94289029309402e-16i;0.976497505339307 - 0.0319572701369497i;0.925820099772552 + 1.66533453693773e-16i;-0.976497505339307 - 0.0319572701369500i;-0.925820099772552 - 1.38777878078145e-16i;0.853553390593273 + 0.353553390593274i;0.925820099772552 + 1.24900090270330e-16i;0.976497505339307 - 0.0319572701369501i;-0.925820099772552 - 9.71445146547012e-17i;0.976497505339307 - 0.0319572701369501i;0.925820099772552 + 6.93889390390723e-17i;0.976497505339307 + 0.0319572701369503i;0.925820099772552 + 4.16333634234434e-17i;0.603976265141222 + 1.08560645045730i;-0.154303349962092 - 0.154303349962092i;0.00000000000000 + 0.00000000000000i];
L_stf_emulated = [0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;-1.08012344973464 + 0.154303349962092i;-0.995217640769111 - 0.540061724867325i;-1.38777878078145e-16 + 1.38777878078145e-16i;-0.0771516749810459 + 0.0319572701369502i;0.771516749810458 + 0.771516749810461i;-0.146446609406726 - 0.353553390593274i;1.52655665885959e-16 - 1.52655665885959e-16i;0.0319572701369502 - 0.0771516749810457i;-0.771516749810460 - 0.771516749810460i;0.0319572701369502 - 0.0771516749810455i;-1.11022302462516e-16 + 1.11022302462516e-16i;-0.0771516749810458 + 0.0319572701369502i;0.771516749810458 + 0.771516749810461i;0.0319572701369502 - 0.0771516749810459i;-3.74700270810990e-16 + 3.74700270810990e-16i;0.0319572701369503 - 0.0771516749810457i;-0.771516749810460 - 0.771516749810459i;0.0319572701369502 - 0.0771516749810455i;-9.71445146547012e-17 + 9.71445146547012e-17i;0.0319572701369502 - 0.0771516749810457i;-0.771516749810459 - 0.771516749810461i;0.0319572701369502 - 0.0771516749810459i;-8.32667268468867e-17 + 8.32667268468867e-17i;0.0319572701369502 - 0.0771516749810458i;0.771516749810460 + 0.771516749810459i;0.0319572701369502 - 0.0771516749810459i;-6.93889390390723e-17 + 6.93889390390723e-17i;0.0319572701369502 - 0.0771516749810458i;-2.08166817117217e-16 + 2.08166817117217e-16i;0.0319572701369502 - 0.0771516749810460i;-6.93889390390723e-17 + 6.93889390390723e-17i;-0.713085210259218 - 0.667890805415123i;6.93889390390723e-17 - 6.93889390390723e-17i;0.146446609406726 + 0.353553390593274i;-5.55111512312578e-17 + 5.55111512312578e-17i;0.0319572701369503 - 0.0771516749810458i;-0.771516749810459 - 0.771516749810461i;-0.0771516749810459 + 0.0319572701369502i;-4.16333634234434e-17 + 4.16333634234434e-17i;0.0319572701369502 - 0.0771516749810458i;0.771516749810459 + 0.771516749810460i;-0.0771516749810459 + 0.0319572701369502i;-4.16333634234434e-17 + 4.16333634234434e-17i;0.0319572701369502 - 0.0771516749810458i;0.771516749810459 + 0.771516749810460i;-0.0771516749810459 + 0.0319572701369502i;-2.77555756156289e-17 + 2.77555756156289e-17i;0.146446609406727 - 0.353553390593274i;-2.77555756156289e-17 + 2.77555756156289e-17i;0.0319572701369502 - 0.0771516749810459i;-1.38777878078145e-17 + 1.38777878078145e-17i;0.0319572701369502 - 0.0771516749810459i;0.771516749810460 + 0.771516749810460i;0.0319572701369503 - 0.0771516749810459i;-1.38777878078145e-17 + 1.38777878078145e-17i;0.186260620099042 + 0.423198645764839i;-0.462910049886276 - 0.771516749810460i;0.00000000000000 + 0.00000000000000i];

LTF_MOD = wlan.internal.wlanOFDMModulate(L_ltf_f, CPLen);
LTF_MOD_T = LTF_MOD * cfgOFDM.NormalizationFactor;


lts_f = [0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1];%[zeros(6,1);0;0;ltfLeft; 0; ltfRight;0;0; zeros(1,1)].';
%lts_f = ifftshift(L_ltf_emulated);
lts_20M = ifft(lts_f, 64);
%lts_t = ifft(L_ltf_emulated, 64);
sts_20M = wlanLSTF(cfg);
idx = wlanFieldIndices(cfg);

lts_t = LLTF_40M(193:end,1); 
sts_t = LSTF_40M;  

interp_filt2 = zeros(1,43);
interp_filt2([1 3 5 7 9 11 13 15 17 19 21]) = [12 -32 72 -140 252 -422 682 -1086 1778 -3284 10364];
interp_filt2([23 25 27 29 31 33 35 37 39 41 43]) = interp_filt2(fliplr([1 3 5 7 9 11 13 15 17 19 21]));
interp_filt2(22) = 16384;
interp_filt2 = interp_filt2./max(abs(interp_filt2));

%raw_rx_dec_A = filter(interp_filt2, 1, rx_vec_air_A(1:Total_samples,1));
raw_rx_dec_A = rx_vec_air_A;   %downsample(raw_rx_dec_A,2);%raw_rx_dec_A(1:2:end);

%raw_rx_dec_B = filter(interp_filt2, 1, rx_vec_air_B(1:Total_samples,1));
raw_rx_dec_B = rx_vec_air_B;   %downsample(raw_rx_dec_B,2);%raw_rx_dec_B(1:2:end);


% raw_rx_mat = reshape(raw_rx_dec_A,64,[]);
% fft_mat = fft(raw_rx_mat,64);
%raw_rx_dec_A = rx_vec_air_A;
%raw_rx_dec_B = rx_vec_air_B;
% number_sym = 40;
% frame_start = 23600 + 98000*4;
% frame_1 = frame_start*2+1:frame_start*2+40*160;
% 
% signal_mat_RX = reshape(rx_vec_air_A(frame_1),160,length(rx_vec_air_A(frame_1))/160);
% signal_mat_nocyc_RX = signal_mat_RX(33:end,:);% Remove cylic preflix
% fft_mat_40M_NonInt_RX = fftshift(fft(signal_mat_nocyc_RX,128),1);
% 
% fft_mat_20M_NonInt_RX = [zeros(6,number_sym);fft_mat_40M_NonInt_RX(37:62,:);zeros(1,number_sym);fft_mat_40M_NonInt_RX(68:93,:);zeros(5,number_sym)];%fft_mat_40M_NonInt_TX1(1:64,:);
% 
% fft_mat_20M_normalized = (fft_mat_20M_NonInt_RX)./max(abs(fft_mat_20M_NonInt_RX));
% 
% RX_A = ifft(ifftshift(fft_mat_20M_NonInt_RX,1),64,1);
% time_Rx = reshape([RX_A(49:end,:);RX_A],[],1);

noise_floor = 0.0270;
receive_signal_strength = max(abs(rx_IQ(:,1)));
SNR = 10*log10(receive_signal_strength/noise_floor);
%for packet_num = 1:5
%packet_num = 1;    
    %[scraminit_Emu(:,packet_num),HT_HEX_emu(:,:,packet_num)] = Decode_20M_MISO(raw_rx_dec_A,raw_rx_dec_B,cfg,packet_num,lts_t,sts_t,N_OFDM_SYMS);
    %[VHTbits, eqDataSym] = Decode_VHT_receiver(raw_rx_dec_B,lts_t,sts_t);
%end
%[VHTbits, eqDataSym] = Decode_VHT_receiver(raw_rx_dec_B,lts_t,sts_t);
%packet_number = HT_HEX(47:48,:,:);

LTS_CORR_THRESH = 0.75;


lts_corr = abs(conv(conj(fliplr(lts_t)), sign(raw_rx_dec_A)));
sts_corr = abs(conv(conj(fliplr(sts_t)), sign(raw_rx_dec_A)));

lts_peaks = find(lts_corr > LTS_CORR_THRESH*max(lts_corr)); % Find all correlation peaks
sts_peaks = find(sts_corr > LTS_CORR_THRESH*max(sts_corr));


[LTS1_A, LTS2_A] = meshgrid(lts_peaks,lts_peaks);
[lts_last_peak_index,y1] = find(LTS2_A-LTS1_A == length(lts_t));

[LTS1_B, LTS2_B] = meshgrid(sts_peaks,sts_peaks);
[sts_last_peak_index,y2] = find(LTS2_B-LTS1_B == length(sts_t));
% 
figure(7); clf;
sts_to_plot = sts_corr;
plot(sts_to_plot, '.-b', 'LineWidth', 1);
hold on;
grid on;
line([1 length(sts_to_plot)], LTS_CORR_THRESH*max(sts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
title('STS Correlation and Threshold_B')
xlabel('Sample Index')
myAxis = axis();
    
figure(8); clf;
lts_to_plot = lts_corr;
plot(lts_to_plot, '.-b', 'LineWidth', 1);
hold on;
grid on;
line([1 length(lts_to_plot)], LTS_CORR_THRESH*max(lts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
title('LTS Correlation and Threshold_B')
xlabel('Sample Index')
myAxis = axis();
% 
% LTF_Peak = lts_peaks(lts_last_peak_index(1));
% frame_sample = raw_rx_dec_A(LTF_Peak + 1  -1600:LTF_Peak+160*30,1);
% coarsePktOffset = wlanPacketDetect(frame_sample,'CBW40',0);

if MODE == 40
%% Using 40Mhz mode 
    number_sym = 30;
    for frame_index = 1:length(lts_last_peak_index)
        LTF_Peak = lts_peaks(lts_last_peak_index(frame_index));
        frame_sample = raw_rx_dec_A(LTF_Peak + 1 :LTF_Peak+160*30,1);
        %coarsePktOffset = wlanPacketDetect(frame_sample,'CBW40',0);
        coarsePktOffset =32;
        signal_mat_RX = reshape(raw_rx_dec_A(LTF_Peak+coarsePktOffset+1-160*10:LTF_Peak+160*20 +coarsePktOffset,1),160,number_sym);
        signal_mat_nocyc_RX = signal_mat_RX(33:end,:);% Remove cylic preflix
        fft_mat_40M_NonInt_RX = fftshift(fft(signal_mat_nocyc_RX,128),1);

        fft_mat_20M_NonInt_RX_shift = [zeros(6,number_sym);fft_mat_40M_NonInt_RX(10:63,:);zeros(4,number_sym)];%fft_mat_40M_NonInt_TX1(1:64,:);

        fft_mat_20M_normalized = (fft_mat_20M_NonInt_RX_shift)./max(abs(fft_mat_20M_NonInt_RX_shift));

        RX_A = ifft(ifftshift(fft_mat_20M_NonInt_RX_shift,1),64);
        
        time_Rx = reshape(RX_A,[],1);

        lts_corr_shift = abs(conv(conj(fliplr(lts_20M)), sign(time_Rx)));
        sts_corr_shift = abs(conv(conj(fliplr(sts_20M)), sign(time_Rx)));

        lts_peaks_shift = find(lts_corr_shift > LTS_CORR_THRESH*max(lts_corr_shift)); % Find all correlation peaks
        sts_peaks_shift = find(sts_corr_shift > LTS_CORR_THRESH*max(sts_corr_shift));


        [LTS1_A_shift, LTS2_A_shift] = meshgrid(lts_peaks_shift,lts_peaks_shift);
        [lts_last_peak_index_shift,y1_shift] = find(LTS2_A_shift-LTS1_A_shift == length(lts_20M));

        [STS1_B_shift, STS2_B_shift] = meshgrid(sts_peaks_shift,sts_peaks_shift);
        [sts_last_peak_index_shift,y2_shift] = find(STS1_B_shift-STS2_B_shift == 16);%2<=(LTS1_B_shift-LTS2_B_shift) & (LTS1_B_shift-LTS2_B_shift)  <= 5);
        
        sts_to_plot = abs(fft_mat_20M_NonInt_RX_shift(:,19));
        sts_frequency = find(sts_to_plot>=0.5*max(sts_to_plot));
        [STS1_A_F, STS2_A_F] = meshgrid(sts_frequency,sts_frequency);
        [sts_last_peak_f,y1_shift] = find(3<=(STS2_A_F-STS1_A_F) & (STS2_A_F-STS1_A_F) <=4);

        
        % Target 2 testing
        if length(sts_last_peak_index_shift)>=14
            detected_10M = detected_10M +1;
        end

        if length(unique(sts_last_peak_f))>=4
            detected_10M_FSA = detected_10M_FSA +1;
        end
        for k = 1:30
            figure(1000 + k); 
            lts_to_plot = abs(fft_mat_20M_NonInt_RX_shift(:,k));
            plot(lts_to_plot, '.-b', 'LineWidth', 1);
            hold on;
            grid on;
            line([1 length(lts_to_plot)],0.6*max(lts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
            title('Custom Correlation and Threshold')
            xlabel('Sample Index')
            myAxis = axis();
        end
        
        
%         ltf_time = time_Rx(1276 +1:1276 + 64);
%         ltf_f_r = fftshift(fft(ltf_time,64),1);
% 
%         
%         figure(200+frame_index)
%         scatter(real(ltf_f_r(:)),imag(ltf_f_r(:)));

        figure(40+frame_index);
        sts_to_plot = sts_corr_shift;
        plot(sts_to_plot, '.-b', 'LineWidth', 1);
        hold on;
        grid on;
        line([1 length(sts_to_plot)], LTS_CORR_THRESH*max(sts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
        title('STSshift Correlation and Threshold_B')
        xlabel('Sample Index')
        myAxis = axis();
% % % %     % 
%         figure(100+frame_index); clf;
%         lts_to_plot = lts_corr_shift;
%         plot(lts_to_plot, '.-b', 'LineWidth', 1);
%         hold on;
%         grid on;
%         line([1 length(lts_to_plot)], LTS_CORR_THRESH*max(lts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
%         title('LTSshift Correlation and Threshold_B')
%         xlabel('Sample Index')
%         myAxis = axis();
% % %         
%     %     
%         Custom_corr = abs(conv(conj(fliplr(custom_preamble_time)), sign(time_Rx)));    
%         
%         
%         figure(1000+frame_index); 
%         lts_to_plot = Custom_corr;
%         plot(lts_to_plot, '.-b', 'LineWidth', 1);
%         hold on;
%         grid on;
%         line([1 length(lts_to_plot)],0.8*max(lts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
%         title('Custom Correlation and Threshold')
%         xlabel('Sample Index')
%         myAxis = axis();

        %HT_preamble_ind = lts_peaks_shift(max(lts_last_peak_index_shift)) ;

        %payload_syms_mat = tradition_decode(HT_preamble_ind,time_Rx,LTF_f_emulated);



        
    end
%% using 20Mhz mode
else
    raw_rx_dec_A = rx_vec_air_A(1:Total_samples,1);%filter(interp_filt2, 1, rx_vec_air_A(1:Total_samples,1));
    raw_rx_dec_A_20M = downsample(raw_rx_dec_A,2);%raw_rx_dec_A(1:2:end);

    raw_rx_dec_B = rx_vec_air_B(1:Total_samples,1);%filter(interp_filt2, 1, rx_vec_air_B(1:Total_samples,1));
    raw_rx_dec_B_20M = downsample(raw_rx_dec_B,2);%raw_rx_dec_B(1:2:end);

    lts_t = lts_20M; 
    sts_t = sts_20M;  

    lts_corr = abs(conv(conj(fliplr(lts_t)), sign(raw_rx_dec_A_20M)));
    sts_corr = abs(conv(conj(fliplr(sts_t)), sign(raw_rx_dec_A_20M)));

    lts_peaks = find(lts_corr > LTS_CORR_THRESH*max(lts_corr)); % Find all correlation peaks
    sts_peaks = find(sts_corr > LTS_CORR_THRESH*max(sts_corr));


    [LTS1_A, LTS2_A] = meshgrid(lts_peaks,lts_peaks);
    [lts_last_peak_index,y1] = find(LTS2_A-LTS1_A == length(lts_t));

    [LTS1_B, LTS2_B] = meshgrid(sts_peaks,sts_peaks);
    [sts_last_peak_index,y2] = find(LTS2_B-LTS1_B == length(sts_t));

    figure(7); clf;
    sts_to_plot = sts_corr;
    plot(sts_to_plot, '.-b', 'LineWidth', 1);
    hold on;
    grid on;
    line([1 length(sts_to_plot)], LTS_CORR_THRESH*max(sts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
    title('STS Correlation and Threshold_B')
    xlabel('Sample Index')
    myAxis = axis();

    figure(8); clf;
    lts_to_plot = lts_corr;
    plot(lts_to_plot, '.-b', 'LineWidth', 1);
    hold on;
    grid on;
    line([1 length(lts_to_plot)], LTS_CORR_THRESH*max(lts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
    title('LTS Correlation and Threshold_B')
    xlabel('Sample Index')
    myAxis = axis();

    LTF_Peak = lts_peaks(lts_last_peak_index(1));
    frame_sample = raw_rx_dec_A_20M(LTF_Peak + 1  -2000:LTF_Peak+160*30,1);
    coarsePktOffset = wlanPacketDetect(frame_sample,'CBW20',0);

    number_sym =23;
    for frame_index = 1:length(lts_last_peak_index)
        LTF_Peak = lts_peaks(lts_last_peak_index(frame_index));

        signal_mat_RX = reshape(raw_rx_dec_B_20M(LTF_Peak+1-64*3 +32:LTF_Peak+64*20 +32,1),64,number_sym);
        signal_mat_nocyc_RX = signal_mat_RX;% Remove cylic preflix
        fft_mat_20M_NonInt_RX = fftshift(fft(signal_mat_nocyc_RX,64),1);

        fft_mat_20M_NonInt_RX_shift = [zeros(6,number_sym);fft_mat_20M_NonInt_RX(10:63,:);zeros(4,number_sym)];%fft_mat_40M_NonInt_TX1(1:64,:);

        fft_mat_20M_normalized = (fft_mat_20M_NonInt_RX_shift)./max(abs(fft_mat_20M_NonInt_RX_shift));

        RX_A = ifft(ifftshift(fft_mat_20M_NonInt_RX_shift,1),64);
        time_Rx = reshape(RX_A,[],1);

        lts_corr_shift = abs(conv(conj(fliplr(lts_20M)), sign(time_Rx)));
        sts_corr_shift = abs(conv(conj(fliplr(sts_20M)), sign(time_Rx)));

        lts_peaks_shift = find(lts_corr_shift > LTS_CORR_THRESH*max(lts_corr_shift)); % Find all correlation peaks
        sts_peaks_shift = find(sts_corr_shift > LTS_CORR_THRESH*max(sts_corr_shift));


        [LTS1_A_shift, LTS2_A_shift] = meshgrid(lts_peaks_shift,lts_peaks_shift);
        [lts_last_peak_index_shift,y1_shift] = find(LTS2_A_shift-LTS1_A_shift == length(lts_20M));

        [LTS1_B_shift, LTS2_B_shift] = meshgrid(sts_peaks_shift,sts_peaks_shift);
        [sts_last_peak_index_shift,y2_shift] = find(LTS2_B_shift-LTS1_B_shift == length(sts_20M));

        figure(40+frame_index);
        sts_to_plot = sts_corr_shift;
        plot(sts_to_plot, '.-b', 'LineWidth', 1);
        hold on;
        grid on;
        line([1 length(sts_to_plot)], LTS_CORR_THRESH*max(sts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
        title('STSshift Correlation and Threshold_B')
        xlabel('Sample Index')
        myAxis = axis();
    % 
        figure(100+frame_index); clf;
        lts_to_plot = lts_corr_shift;
        plot(lts_to_plot, '.-b', 'LineWidth', 1);
        hold on;
        grid on;
        line([1 length(lts_to_plot)], LTS_CORR_THRESH*max(lts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
        title('LTSshift Correlation and Threshold_B')
        xlabel('Sample Index')
        myAxis = axis();
        Custom_corr = abs(conv(conj(fliplr(custom_preamble_time)), sign(time_Rx)));    
%     %     
        %Received_preambles = length(find(Custom_corr >  LTS_CORR_THRESH*max(lts_to_plot)*[1 1]));   
        figure(1000+frame_index); 
        lts_to_plot = Custom_corr;
        plot(lts_to_plot, '.-b', 'LineWidth', 1);
        hold on;
        grid on;
        line([1 length(lts_to_plot)],0.8*max(lts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
        title('Custom Correlation and Threshold')
        xlabel('Sample Index')
        myAxis = axis();
    
   
        HT_preamble_ind = lts_peaks_shift(max(lts_last_peak_index_shift));

        payload_ind = HT_preamble_ind ;

        lts_ind = HT_preamble_ind -128;

        extra_preamble = payload_ind -160;

        %Extract LTS (not yet CFO corrected)
        rx_lts = time_Rx(lts_ind: lts_ind+128);
        rx_lts1 = rx_lts(1:64);
        rx_lts2 = rx_lts(65:128);

        %Calculate coarse CFO est
        rx_cfo_est_lts = mean(unwrap(angle(rx_lts2 .* conj(rx_lts1))));
        %rx_cfo_est_lts_emulated = mean(unwrap(angle(rx_lts3 .* conj(rx_lts4))));

        rx_cfo_est_lts_average = rx_cfo_est_lts;% + rx_cfo_est_lts_emulated*1/4;
        rx_cfo_est_lts = rx_cfo_est_lts_average/(2*pi*64);

        % Apply CFO correction to raw Rx waveform
        rx_cfo_corr_t = exp(-1i*2*pi*rx_cfo_est_lts*[0:length(time_Rx)-1]);
        rx_dec_cfo_corr = time_Rx.' .* rx_cfo_corr_t;
        
        rx_lts = rx_dec_cfo_corr(lts_ind : lts_ind+128);
        rx_lts1 = rx_lts(1:64);
        rx_lts2 = rx_lts(65:128);
        rx_lts1_f = fft(rx_lts1);
        rx_lts2_f = fft(rx_lts2);



        % Calculate channel estimate from average of 2 training symbols
        rx_H_est =  LTF_f_emulated.'.* (rx_lts1_f + rx_lts2_f)/2;


        rx_est = rx_H_est;
        %% Rx payload processing

        % Extract the payload samples (integral number of OFDM symbols following preamble)
        payload_vec = rx_dec_cfo_corr(payload_ind : payload_ind+64*5-1);
        payload_mat = reshape(payload_vec, 64, 5);

        
        % Take the FFTpayload_mat_noCP
        syms_f_mat = fft(payload_mat, 64, 1);

        % Equalize (zero-forcing, just divide by complex chan estimates)
        syms_eq_mat = syms_f_mat./repmat(rx_est.',1, 5);
        %syms_eq_mat = syms_eq_mat_N ./ repmat(rx_H_est.', 1, N_OFDM_SYMS);
        syms_eq_mat_to_plot = syms_eq_mat([7:8 10:35 37:59],:);
        
        
        pilots_f_mat = syms_eq_mat(SC_IND_PILOTS, :);
        pilots_f_mat_comp = pilots_f_mat.*pilots_mat_C*exp(-1i*pi/4);
        % Calculate the phases of every Rx pilot tone
        pilot_phases = unwrap(angle(fftshift(pilots_f_mat_comp,1)), [], 1);


        % Calculate slope of pilot tone phases vs frequency in each OFDM symbol
        pilot_spacing_mat = repmat(mod(diff(fftshift(SC_IND_PILOTS)),64).', 1, N_OFDM_SYMS);                        
        pilot_slope_mat = mean(diff(pilot_phases) ./ pilot_spacing_mat);
    % 
  

        % Calculate the SFO correction phases for each OFDM symbol
        pilot_phase_sfo_corr = fftshift((-32:31).' * pilot_slope_mat, 1);
        pilot_phase_corr = exp(-1i*(pilot_phase_sfo_corr));


     
        % Apply the pilot phase correction per symbol
        %syms_eq_mat = syms_eq_mat .* pilot_phase_corr;
        syms_eq_mat = syms_eq_mat .* (pilot_phase_corr);


        pilots_f_mat = syms_eq_mat(SC_IND_PILOTS, :);
        pilots_f_mat_comp = pilots_f_mat.*pilots_mat_C;
        pilot_phase_err = angle(mean(pilots_f_mat_comp));

        pilot_phase_err_corr = repmat(pilot_phase_err, N_SC, 1);
        pilot_phase_corr = exp(-1i*(pilot_phase_err_corr));
        syms_eq_pc_mat = syms_eq_mat .* (pilot_phase_corr);
        payload_syms_mat = syms_eq_pc_mat(SC_IND_DATA, :);

        pilots_corrected = syms_eq_pc_mat(SC_IND_PILOTS,:);
        pilot_error = pilots_corrected*exp(-1i*pi/8) - pilots_f_mat*exp(1i*pi/8);
        noise_est(frame_ind) = mean(real(pilot_error(1:20).*conj(pilot_error(1:20))));
        SNR(frame_ind) = 10*log10(1/noise_est(frame_ind));    
        
        rx_syms = reshape(payload_syms_mat, 1, N_DATA_SYMS);
        rx_syms_snr = reshape(payload_syms_mat, 1, N_DATA_SYMS)*exp(-1i*0.3927*2)*1.4./max(abs(rx_syms)) ;


        rx_syms_MMSE = reshape(payload_syms_mat_MMSE, 1, N_DATA_SYMS)*exp(-1i*0.3927*2);
        rx_syms_snr_MMSE = reshape(payload_syms_mat_MMSE, 1, N_DATA_SYMS)*exp(-1i*0.3927*2)*1.4./max(abs(rx_syms_MMSE)) ;

    
    
        switch(MOD_ORDER)
            case 2         % BPSK
                rx_data = arrayfun(demod_fcn_bpsk, rx_syms_snr);
                rx_data_bits = reshape(de2bi(rx_data)',[],1);

            case 4         % QPSK
                rx_data = arrayfun(demod_fcn_qpsk, rx_syms_snr);
                rx_data_bits = reshape(de2bi(rx_data)',[],1);
            case 16        % 16-QAM
                rx_data = arrayfun(demod_fcn_16qam, rx_syms_snr);
                rx_data_bits = reshape(de2bi(rx_data)',[],1);
            case 64        % 64-QAM
                rx_data = arrayfun(demod_fcn_64qam, rx_syms);
        end
    % evm_mat = abs(rx_syms_snr.' - tx_syms_mat).^2;
    % aevms = mean(evm_mat(:));
    % snr = 10*log10(1./aevms)

        decoded_bits = wlanBCCDecode(rx_data_bits,CodeRate,'hard');
        
        
        
        figure(300+frame_index)
        scatter(real(syms_eq_mat_to_plot(:)),imag(syms_eq_mat_to_plot(:)));
       
    
    
    end
end





