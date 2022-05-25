%% 4TX-1RX modified Rx-complete Tx with encoding
% Receiver is being updated.
% Ruirong Chen University of Pittsburgh 

clear

close all
load emulatedSig_40M_MCS0_MID.mat   
load BPSK_40m_constellation.mat

% Params:
USE_WARPLAB_TXRX        = 1;           % Enable WARPLab-in-the-loop (otherwise sim-only)
WRITE_PNG_FILES         = 0;           % Enable writing plots to PNG
CHANNEL                 = 6;          % Channel to tune Tx and Rx radios

% Waveform params
MOD_ORDER               = 16;            % Modulation order (2/4/16 = BSPK/QPSK/16-QAM)
N_Data                  = 2250*4;
CodeRate                = 1/2;
scramble_init           = 93;
TX_SCALE                = 1.0;         % Scale for Tx waveform ([0:1])
INTERP_RATE             = 2;           % Interpolation rate (must be 2)
TX_SPATIAL_STREAM_SHIFT = 3;           % Number of samples to shift the transmission from RFB

% OFDM params
SC_IND_PILOTS           = [8 22 44 58];                           % Pilot subcarrier indices
SC_IND_DATA             = [2:4 6:7 9:18 20:21 23:27 39:40 42:43 45:57 59:64];     % Data subcarrier indices
N_SC                    = 64;                                     % Number of subcarriers
CP_LEN                  = 16;                                     % Cyclic prefix length
N_OFDM_SYMS             = N_Data/(CodeRate*length(SC_IND_DATA)*log2(MOD_ORDER));        % Number of OFDM symbols (must be even valued)
N_DATA_SYMS             = N_OFDM_SYMS * length(SC_IND_DATA);      % Number of data symbols (one per data-bearing subcarrier per OFDM symbol)
SC_N_Subcarrier         = [28 29 37 38];
% Rx processing params
FFT_OFFSET                    = 1;           % Number of CP samples to use in FFT (on average)
LTS_CORR_THRESH               = 0.8;         % Normalized threshold for LTS correlation
DO_APPLY_CFO_CORRECTION       = 1;           % Enable CFO estimation/correction
DO_APPLY_PHASE_ERR_CORRECTION = 1;           % Enable Residual CFO estimation/correction
DO_APPLY_SFO_CORRECTION       = 1;           % Enable SFO estimation/correction
DECIMATE_RATE                 = INTERP_RATE;

% WARPLab experiment params
USE_AGC                 = false;        % Use the AGC if running on WARP hardware
MAX_TX_LEN              = 2^19;        % Maximum number of samples to use for this experiment
SAMP_PADDING            = 5000;         % Extra samples to receive to ensure both start and end of waveform visible
failed_frame            = 0;

if(USE_WARPLAB_TXRX)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up the WARPLab experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    NUMNODES = 2;

    % Create a vector of node objects
    nodes   = wl_initNodes(NUMNODES);
    node_tx = nodes(1);
    node_rx = nodes(2);

    % Create a UDP broadcast trigger and tell each node to be ready for it
    eth_trig = wl_trigger_eth_udp_broadcast;
    wl_triggerManagerCmd(nodes, 'add_ethernet_trigger', [eth_trig]);

    % Read Trigger IDs into workspace
    trig_in_ids  = wl_getTriggerInputIDs(nodes(1));
    trig_out_ids = wl_getTriggerOutputIDs(nodes(1));

    % For both nodes, we will allow Ethernet to trigger the buffer baseband and the AGC
    wl_triggerManagerCmd(nodes, 'output_config_input_selection', [trig_out_ids.BASEBAND, trig_out_ids.AGC], [trig_in_ids.ETH_A]);

    % Set the trigger output delays.
    nodes.wl_triggerManagerCmd('output_config_delay', [trig_out_ids.BASEBAND], 0);
    nodes.wl_triggerManagerCmd('output_config_delay', [trig_out_ids.AGC], 3000);     %3000 ns delay before starting the AGC

    % Get IDs for the interfaces on the boards. 
    ifc_ids_TX = wl_getInterfaceIDs(node_tx);
    ifc_ids_RX = wl_getInterfaceIDs(node_rx);

    % Set up the TX / RX nodes and RF interfaces
%     TX_RF     = ifc_ids_TX.RF_ALL;
%     TX_RF_VEC = ifc_ids_TX.RF_ALL_VEC;
%     TX_RF_ALL = ifc_ids_TX.RF_ALL;
    TX_RF     = ifc_ids_TX.RF_ALL;
    TX_RF_VEC = ifc_ids_TX.RF_ALL_VEC;
    TX_RF_ALL = ifc_ids_TX.RF_ALL;
    
    RX_RF     = ifc_ids_RX.RF_A;
    RX_RF_VEC = ifc_ids_RX.RF_A;
    RX_RF_ALL = ifc_ids_RX.RF_ALL;

    % Set up the interface for the experiment
    wl_interfaceCmd(node_tx, TX_RF_ALL, 'channel', 5, CHANNEL);
    wl_interfaceCmd(node_rx, RX_RF, 'channel', 5, CHANNEL);

    wl_interfaceCmd(node_tx, TX_RF_ALL, 'tx_gains', 2, 22);
    
    if(USE_AGC)
        wl_interfaceCmd(node_rx, RX_RF, 'rx_gain_mode', 'automatic');
        wl_basebandCmd(node_rx, 'agc_target', -13); %-13
    else
        wl_interfaceCmd(node_rx, RX_RF, 'rx_gain_mode', 'manual');
        RxGainRF = 3;                  % Rx RF Gain in [1:3]
        RxGainBB = 6;                 % Rx Baseband Gain in [0:31]
        wl_interfaceCmd(node_rx, RX_RF_ALL, 'rx_gains', RxGainRF, RxGainBB);
    end

    % Get parameters from the node
    SAMP_FREQ    = wl_basebandCmd(nodes(1), 'tx_buff_clk_freq');
    Ts           = 1/SAMP_FREQ;

    % We will read the transmitter's maximum I/Q buffer length
    % and assign that value to a temporary variable.
    %
    % NOTE:  We assume that the buffers sizes are the same for all interfaces

    maximum_buffer_len = min(MAX_TX_LEN, wl_basebandCmd(node_tx, TX_RF_VEC, 'tx_buff_max_num_samples'));
    example_mode_string = 'hw';
else
    % Use sane defaults for hardware-dependent params in sim-only version
    maximum_buffer_len  = min(MAX_TX_LEN, 2^20);
    SAMP_FREQ           = 40e6;
    example_mode_string = 'sim';
end

%% Define a half-band 2x interpolation filter response
interp_filt2 = zeros(1,43);
interp_filt2([1 3 5 7 9 11 13 15 17 19 21]) = [12 -32 72 -140 252 -422 682 -1086 1778 -3284 10364];
interp_filt2([23 25 27 29 31 33 35 37 39 41 43]) = interp_filt2(fliplr([1 3 5 7 9 11 13 15 17 19 21]));
interp_filt2(22) = 16384;
interp_filt2 = interp_filt2./max(abs(interp_filt2));

% Define the preamble
% Note: The STS symbols in the preamble meet the requirements needed by the
% AGC core at the receiver. Details on the operation of the AGC are
% available on the wiki: http://warpproject.org/trac/wiki/WARPLab/AGC
sts_f = zeros(1,64);
sts_f(1:27) = [0 0 0 0 -1-1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 1+1i 0 0 0 1+1i 0 0 0 1+1i 0 0];
sts_f(39:64) = [0 0 1+1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 -1-1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0];
sts_t = ifft(sqrt(13/6).*sts_f, 64);
sts_t = sts_t(1:16);

L_ltf_f = fftshift([0;0;0;0;0;0;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;0;1;-1;-1;1;1;-1;1;-1;1;-1;-1;-1;-1;-1;1;1;-1;-1;1;1;-1;-1;1;1;1;1;0;0;0;0;0]);

cfgOFDM = wlan.internal.wlanGetOFDMConfig('CBW20', 'Long', 'Legacy');

CPLen  = cfgOFDM.CyclicPrefixLength;


L_ltf_t = ifft(L_ltf_f,64);
LTF_MOD = wlan.internal.wlanOFDMModulate(L_ltf_f, CPLen);

% Scale and output
LTF_MOD_T = LTF_MOD * cfgOFDM.NormalizationFactor;
%lts_f = [0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1];

lts_f1 = [0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;1.080123 - 0.1543034i;1.080123 + 0.1543034i;1.000000 + 0.000000i;-1.080123 + 0.1543034i;-1.080123 - 0.1543034i;1.080123 - 0.1543034i;-1.080123 - 0.1543034i;1.080123 + 0.1543034i;-1.080123 + 0.1543034i;1.080123 + 0.1543034i;1.080123 + 0.1543034i;1.080123 + 0.1543034i;1.080123 + 0.1543034i;1.080123 - 0.1543034i;1.080123 + 0.1543034i;-1.080123 - 0.1543034i;-1.080123 - 0.1543034i;1.080123 + 0.1543034i;1.080123 + 0.1543034i;-1.080123 - 0.1543034i;1.080123 + 0.1543034i;-1.080123 + 0.1543034i;1.080123 + 0.1543034i;1.080123 + 0.1543034i;1.080123 + 0.1543034i;1.080123 + 0.1543034i;0.1543034 - 0.1543034i;1.080123 + 0.1543034i;-1.080123 - 0.1543034i;-1.080123 + 0.1543034i;1.000000 + 0.000000i;1.080123 + 0.1543034i;-1.080123 - 0.1543034i;0.7715167 + 0.1543034i;-1.080123 + 0.1543034i;1.080123 + 0.1543034i;-1.080123 - 0.1543034i;-1.080123 - 0.1543034i;-1.080123 + 0.1543034i;-1.080123 - 0.1543034i;-1.080123 - 0.1543034i;1.080123 + 0.1543034i;1.080123 - 0.1543034i;-1.080123 - 0.1543034i;1.000000 + 0.000000i;1.080123 - 0.1543034i;1.080123 + 0.1543034i;-1.080123 - 0.1543034i;-1.080123 - 0.1543034i;1.080123 - 0.1543034i;1.080123 + 0.1543034i;1.080123 - 0.1543034i;1.080123 + 0.1543034i;-0.1543034 - 0.1543034i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i];
lts_t1 = ifft(ifftshift(lts_f1),64).';

lts_f2 = [0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.8728716 + 0.2182179i;0.7715167 - 0.1543034i;-0.7071068 + 0.7071068i;-0.7715167 - 0.1543034i;-0.8728716 + 0.2182179i;0.7715167 + 0.1543034i;-0.8728716 + 0.2182179i;0.7715167 - 0.1543034i;-0.8728716 - 0.2182179i;0.7715167 - 0.1543034i;0.8728716 - 0.2182179i;0.7715167 - 0.1543034i;0.8728716 - 0.2182179i;0.7715167 + 0.1543034i;0.8728716 - 0.2182179i;-0.7715167 + 0.1543034i;-0.8728716 + 0.2182179i;0.7715167 - 0.1543034i;0.8728716 - 0.2182179i;-0.7715167 + 0.1543034i;0.8728716 - 0.2182179i;-0.7715167 - 0.1543034i;0.8728716 - 0.2182179i;0.7715167 - 0.1543034i;0.8728716 - 0.2182179i;0.7715167 - 0.1543034i;-0.2182179 + 0.000000i;0.7715167 - 0.1543034i;-0.8728716 + 0.2182179i;-0.7715167 - 0.1543034i;-0.7071068 + 0.7071068i;0.7715167 - 0.1543034i;-0.8728716 + 0.2182179i;1.080123 - 0.1543034i;-0.8728716 - 0.2182179i;0.7715167 - 0.1543034i;-0.8728716 + 0.2182179i;-0.7715167 + 0.1543034i;-0.8728716 - 0.2182179i;-0.7715167 + 0.1543034i;-0.8728716 + 0.2182179i;0.7715167 - 0.1543034i;0.8728716 + 0.2182179i;-0.7715167 + 0.1543034i;0.7071068 + 0.7071068i;0.7715167 + 0.1543034i;0.8728716 - 0.2182179i;-0.7715167 + 0.1543034i;-0.8728716 + 0.2182179i;0.7715167 + 0.1543034i;0.8728716 - 0.2182179i;0.7715167 + 0.1543034i;0.8728716 - 0.2182179i;0.1543034 + 0.1543034i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i;0.000000 + 0.000000i];
lts_t2 = ifft(ifftshift(lts_f2),64).'; %-(0.10 +0.08i)


lts_f = [0 + 0i;0.947595572200122 + 4.82576980817190e-16i;-0.999464920400107 + 0.0327089114708313i;-0.947595572200122 + 4.02147484014325e-16i;0.149891062714697 + 0.361869036484338i;0.947595572200123 + 2.68098322676217e-16i;-0.999464920400107 + 0.0327089114708314i;0.947595572200123 + 1.38070636178252e-15i;-0.999464920400107 - 0.0327089114708320i;0.947595572200122 + 2.68098322676217e-16i;-0.999464920400107 + 0.0327089114708313i;-0.947595572200123 - 2.68098322676217e-16i;-0.999464920400107 - 0.0327089114708320i;-0.947595572200122 - 2.14478658140973e-16i;-0.999464920400107 + 0.0327089114708311i;0.947595572200122 + 1.00536871003581e-16i;0.999464920400107 + 0.0327089114708316i;-0.947595572200122 - 1.60858993605730e-16i;0.873629135683372 + 0.361869036484338i;0.947595572200122 + 3.48527819479082e-16i;0.999464920400107 - 0.0327089114708320i;-0.947595572200122 - 2.94908154943838e-16i;-0.999464920400107 + 0.0327089114708318i;0.947595572200122 + 8.04294968028650e-17i;0.999464920400107 - 0.0327089114708319i;0.947595572200122 + 1.07239329070487e-16i;0.999464920400107 - 0.0327089114708319i;8.04294968028650e-17 + 1.07239329070487e-16i;0.000 + 0.000i;0.000 + 0.000i;0.000 + 0.000i;0.000 + 0.000i;0.000 + 0.000i;0.000 + 0.000i;0.000 + 0.000i;0.000 + 0.000i;0.000 + 0.000i;0.000 + 0.000i;0.999464920400107 + 0.0327089114708316i;0.947595572200123 + 1.31368178111346e-15i;0.149891062714697 + 0.361869036484337i;-0.947595572200122 + 8.57914632563893e-16i;-0.999464920400107 + 0.0327089114708309i;0.947595572200122 - 6.03221226021488e-17i;-0.999464920400108 + 0.0327089114708302i;0.947595572200123 + 5.36196645352433e-16i;-0.999464920400107 - 0.0327089114708313i;0.947595572200123 + 1.12601295524011e-15i;0.999464920400107 - 0.0327089114708318i;0.947595572200123 + 2.03754725233925e-15i;0.999464920400107 - 0.0327089114708310i;0.947595572200122 - 2.81503238810028e-16i;0.999464920400107 - 0.0327089114708304i;-0.947595572200122 - 4.28957316281947e-16i;-0.999464920400107 + 0.0327089114708311i;0.947595572200123 + 1.09920312297249e-15i;0.999464920400107 - 0.0327089114708316i;-0.947595572200123 - 5.36196645352433e-16i;0.999464920400107 - 0.0327089114708312i;-0.947595572200123 + 1.60858993605730e-16i;0.999464920400107 - 0.0327089114708319i;0.947595572200122 + 3.21717987211460e-16i;0.999464920400107 - 0.0327089114708312i;0.947595572200123 + 1.07239329070487e-15i].';

lts_f3 = lts_f+(0.1 +0.1i);
lts_t3 = ifft(lts_f3,64);


% LTS for CFO and channel estimation

lts_t = ifft(lts_f,64);


% lts_f1 = lts_f + (0.1 - 0.1i);
% lts_t1 = ifft(lts_f,64);
% 
% lts_f2 = 1.09*[0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1];
% lts_f2 = lts_f2 +(0.1 + 0.1i);
% lts_t2 = ifft(lts_f2,64);


% lts_t = LTF_MOD_T(17:end).';
% lts_f = L_ltf_f.';

lts_f_N = [1 1 1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0 0 0  1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 -1 -1];
lts_t_N = ifft(lts_f_N, 64);

% We break the construction of our preamble into two pieces. First, the
% legacy portion, is used for CFO recovery and timing synchronization at
% the receiver. The processing of this portion of the preamble is SISO.
% Second, we include explicit MIMO channel training symbols.

% Legacy Preamble

% Use 30 copies of the 16-sample STS for extra AGC settling margin
% To avoid accidentally beamforming the preamble transmissions, we will
% let RFA be dominant and handle the STS and first set of LTS. We will
% append an extra LTS sequence from RFB so that we can build out the
% channel matrix at the receiver
cfg = wlanHTConfig('ChannelBandwidth','CBW20','MCS',2,'NumTransmitAntennas',1,'NumSpaceTimeStreams',1);
ht_ltf = wlanHTLTF(cfg).';
ht_sig = wlanHTSIG(cfg).';
ht_stf = wlanHTSTF(cfg).';
L_ltf = wlanLLTF(cfg).';
L_stf = wlanLSTF(cfg).';

%sts_t = L_stf(1,:)/10;
sts_t_rep = repmat(sts_t, 1, 30);
%lts_t = L_ltf(1,33:96)/5;

preamble_legacy_A = [L_stf/6, lts_t(33:64), lts_t, lts_t, lts_t, lts_t];%, lts_t, lts_t];
preamble_legacy_B = [L_stf/6, lts_t(33:64), lts_t, lts_t, lts_t, lts_t];
preamble_legacy_C = [L_stf/6, lts_t(33:64), lts_t, lts_t, lts_t, lts_t];

%preamble_legacy_B = [sts_t_rep, lts_t(33:64), lts_t, lts_t];
% MIMO Preamble



%preamble_mimo_A = [ht_sig(1,:),ht_stf(1,:),ht_ltf(1,:)];
%preamble_mimo_B = [ht_sig(2,:),ht_stf(2,:),ht_ltf(2,:)];

preamble_mimo_A = [lts_t_N(33:64), lts_t_N, lts_t_N];
preamble_mimo_B = circshift(zeros(1,160),[0,5]);%zeros(1,64), lts_t_N(33:64), lts_t_N];

preamble_A = preamble_legacy_A;
preamble_B = preamble_legacy_B;
preamble_C = preamble_legacy_C;

% Sanity check variables that affect the number of Tx samples
if(SAMP_PADDING + INTERP_RATE*((N_OFDM_SYMS/2 * (N_SC + CP_LEN)) + length(preamble_A) + 100) > maximum_buffer_len)
    fprintf('Too many OFDM symbols for TX_NUM_SAMPS!\n');
    fprintf('Raise TX_NUM_SAMPS to %d, or \n', SAMP_PADDING + INTERP_RATE*((N_OFDM_SYMS/2 * (N_SC + CP_LEN)) + length(preamble_A) + 100));
    fprintf('Reduce N_OFDM_SYMS to %d\n',  2*(floor(( (maximum_buffer_len/INTERP_RATE)-length(preamble_A)-100-SAMP_PADDING )/( N_SC + CP_LEN )) - 1));
    return;
end

%% Generate a payload of random integers

MAC_payload = randi([0,1],N_Data*2*MOD_ORDER,1);

Srambled_payload_standard = wlanScramble(MAC_payload,scramble_init);
numES = 2;
parsedData = reshape(Srambled_payload_standard,numES,[]).';
encodedData = wlanBCCEncode(parsedData,1/2);
%payload_standard = wlanBCCInterleave(encodedData,'HT',48,'CBW20');


tx_data_TX1 = encodedData(:,1);
tx_data_TX2 = encodedData(:,2);

% Functions for data -> complex symbol mapping (like qammod, avoids comm toolbox requirement)
% These anonymous functions implement the modulation mapping from IEEE 802.11-2012 Section 18.3.5.8


modvec_bpsk   =  (1/sqrt(2))  .* [-1 1];
modvec_16qam  =  (1/sqrt(10)) .* [-3 -1 +3 +1];
modvec_64qam  =  (1/sqrt(43)) .* [-7 -5 -1 -3 +7 +5 +1 +3];

mod_fcn_bpsk  = @(x) complex(modvec_bpsk(1+x),0);
mod_fcn_qpsk  = @(x) complex(modvec_bpsk(1+bitshift(x, -1)), modvec_bpsk(1+mod(x, 2)));
mod_fcn_16qam = @(x) complex(modvec_16qam(1+bitshift(x, -2)), modvec_16qam(1+mod(x,4)));
mod_fcn_64qam = @(x) complex(modvec_64qam(1+bitshift(x, -3)), modvec_64qam(1+mod(x,8)));
% Reshape the symbol vector into two different spatial streams

% Break up the matrix into a vector for each antenna
%tx_syms_A = dataSpMapped([38:53 55:63 67:75 77:89 91:91],6:25,1);
%tx_syms_B = dataSpMapped([38:53 55:63 67:75 77:89 91:91],6:25,2);

Emulate_16QAM_Constellation_Tx1 = [-1.0801 - 0.7715i,-0.7715 - 0.1543i,-0.7715 + 1.08i,-1.080 + 0.7715i,...
    -0.4629 - 0.7715i,-0.1543 - 0.46291i,-0.4629 + 0.7715i,-0.4629 + 0.1543i,...
    0.7715 - 1.0801i,1.08 - 0.15431i,1.0801 + 0.7715i,0.7715 + 0.1543i,...
    0.1543 - 0.7715i,0.4621 - 0.1543i,0.4629 + 1.0801i,0.1543 + 0.1543i];

Emulate_16QAM_Constellation_Tx2 = [-0.9993 - 0.87367i,-1.0598 - 0.25943i,-0.87367 + 0.9993i,-0.81317 + 0.38506i,...
    -0.38506 - 0.81317i,-0.44556 - 0.19893i,-0.25943 + 1.0598i,-0.19893 + 0.44556i,...
    0.87367 - 0.9993i,1.1203 - 0.358481i,0.9993 + 0.87367i,1.0598 + 0.25943i,...
    0.25943 - 1.0598i,0.47581 - 0.10819i,0.38506 + 0.81317i,0.4153 + 0.50605i];

Emulate_16QAM_Constellation_Tx3 = [-0.90885 - 0.96741i,-1.0293 - 0.36206i,-0.94868 + 0.94868i,-0.847 + 0.3035i,...
    -0.3035 - 0.847i,-0.42391 - 0.24165i,-0.36206 + 1.0293i,-0.24165 + 0.42391i,...
    0.96741 - 0.90885i,0.847 - 0.3035i,0.90885 + 0.96741i,1.0293 + 0.36206i,...
    0.36206 - 1.0293i,0.24165 - 0.42391i,0.3035 + 0.847i,0.42391 + 0.24165i];

Emulate_16QAM_Constellation_Tx4 = [-0.80965 - 1.0518i,-0.9888 - 0.4612i,-1.0518 + 0.80965i,-0.87267 + 0.21902i,...
    -0.21902 - 0.87267i,-0.3989 - 0.28203i,-0.4612 + 0.9882i,-0.28203 + 0.39819i,...
    1.0518 - 0.80965i,0.87267 - 0.21902i,0.80965 + 1.0518i,0.98882 + 0.4612i,...
    0.4612 - 0.9882i,0.28203 - 0.39819i,0.21902 + 0.87267i,0.39819 + 0.28203i];

Emulate_QPSK_Constellation_Tx1 = [-0.771 - 0.771i,-0.771 + 0.771i,0.771 - 0.771i,0.771 + 0.771i];
Emulate_QPSK_Constellation_Tx2 = [-0.666 - 0.60453i,-0.60453 + 0.666i,0.60453 - 0.666i, 0.666 + 0.60453i];
Emulate_QPSK_Constellation_Tx3 = [-0.82076 - 0.84102i,-0.84102 + 0.82076i,0.84102 - 0.82076i, 0.82076 + 0.84102i];
Emulate_QPSK_Constellation_Tx4 = [-0.60392 - 0.66694i,-0.66694 + 0.60392i,0.66694 - 0.60392i, 0.60392 + 0.66694i];


Emulate_9QAM_Constellation_Tx1 = [0.707 + 0.707i,-0.707 - 0.707i,-0.707 + 0.707i,0.707 - 0.707i,0.707 + 0.707i,-0.707 - 0.707i,-0.707 + 0.707i,-0.707 - 0.707i,-0.707 - 0.707i];
Emulate_9QAM_Constellation_Tx2 = [0.707 + 0.707i,-0.707 - 0.707i,-0.707 + 0.707i,0.707 - 0.707i,0.707 - 0.707i,0.707 - 0.707i,0.707 + 0.707i,-0.707 + 0.707i,+0.707 + 0.707i];

Emulate_BPSK_Constellation_Tx1 = [(-1.08 + 0.1543i),(1.08 -0.1543i)];
Emulate_BPSK_Constellation_Tx2 = [(-1.0895 - 0.05i),(1.08 + 0.05i)];
Emulate_BPSK_Constellation_Tx3 = [(-0.88994 + 0.13243i),(0.88994 - 0.134243i)];
Emulate_BPSK_Constellation_Tx4 = [(-1.0784 - 0.16588i),(1.0784 + 0.16588i)];


deviation_theory_16 = abs((Emulate_16QAM_Constellation_Tx1 + Emulate_16QAM_Constellation_Tx2 +Emulate_16QAM_Constellation_Tx3+Emulate_16QAM_Constellation_Tx4)/4 - wlanConstellationMap(de2bi(0:15)',4));

deviation_theory_4 = abs((Emulate_QPSK_Constellation_Tx1 + Emulate_QPSK_Constellation_Tx2 +Emulate_QPSK_Constellation_Tx3+Emulate_QPSK_Constellation_Tx4)/4 - wlanConstellationMap(de2bi(0:3)',2));

deviation_theory_2 = abs((Emulate_BPSK_Constellation_Tx1 + Emulate_BPSK_Constellation_Tx2 +Emulate_BPSK_Constellation_Tx3+Emulate_BPSK_Constellation_Tx4)/4 - wlanConstellationMap(de2bi(0:1)',1));



demod_fcn_bpsk = @(x) double(real(x)>0);
demod_fcn_qpsk = @(x) double(2*(real(x)>0) + 1*(imag(x)>0));
demod_fcn_16qam = @(x) (8*(real(x)>0)) + (4*(abs(real(x))<0.6325)) + (2*(imag(x)>0)) + (1*(abs(imag(x))<0.6325));
demod_fcn_64qam = @(x) (32*(real(x)>0)) + (16*(abs(real(x))<0.6172)) + (8*((abs(real(x))<(0.9258))&&((abs(real(x))>(0.3086))))) + (4*(imag(x)>0)) + (2*(abs(imag(x))<0.6172)) + (1*((abs(imag(x))<(0.9258))&&((abs(imag(x))>(0.3086)))));
%MOD_ORDER = 9;
if MOD_ORDER == 16
    MAC_bits = randi([0 1],N_Data,1);
    encoded_bits = wlanBCCEncode(MAC_bits,CodeRate);
    de_bits = bi2de(reshape(encoded_bits,4,[])')+1;
    tx_syms_mat = arrayfun(mod_fcn_16qam, de_bits-1);
    
    for j = 1:N_OFDM_SYMS
        for i = 1:length(SC_IND_DATA)
            chosen_constellation = de_bits(length(SC_IND_DATA)*(j-1) + i,1);
            tx_syms_mat_A(i,j) = Emulate_16QAM_Constellation_Tx1(chosen_constellation) ;
            tx_syms_mat_B(i,j) = Emulate_16QAM_Constellation_Tx2(chosen_constellation) ;
            tx_syms_mat_C(i,j) = Emulate_16QAM_Constellation_Tx3(chosen_constellation) ;        
            tx_syms_mat_D(i,j) = Emulate_16QAM_Constellation_Tx4(chosen_constellation) ;         


        end
    end
    tx_bits = arrayfun(demod_fcn_16qam, tx_syms_mat_A(:));
    tx_syms = arrayfun(mod_fcn_16qam, tx_bits);

elseif MOD_ORDER == 4
        MAC_bits = randi([0 1],N_Data,1);
        encoded_bits = wlanBCCEncode(MAC_bits,CodeRate);
        de_bits = bi2de(reshape(encoded_bits,2,[])')+1;        
       
        tx_syms_mat = arrayfun(mod_fcn_qpsk, de_bits-1);
        
        for j = 1:N_OFDM_SYMS
            
            for i = 1:length(SC_IND_DATA)
                chosen_constellation = de_bits(length(SC_IND_DATA)*(j-1) + i,1);
                tx_syms_mat_A(i,j) = Emulate_QPSK_Constellation_Tx1(chosen_constellation);
                tx_syms_mat_B(i,j) = Emulate_QPSK_Constellation_Tx2(chosen_constellation);
                tx_syms_mat_C(i,j) = Emulate_QPSK_Constellation_Tx3(chosen_constellation);
                tx_syms_mat_D(i,j) = Emulate_QPSK_Constellation_Tx4(chosen_constellation);


            end
        end
        tx_bits = arrayfun(demod_fcn_qpsk, tx_syms_mat_A(:));
elseif MOD_ORDER == 9
        for j = 1:N_OFDM_SYMS
            for i = 1:length(SC_IND_DATA)
                chosen_constellation = randi([1 9],1);
                tx_syms_mat_A(i,j) = Emulate_9QAM_Constellation_Tx1(chosen_constellation);
                tx_syms_mat_B(i,j) = Emulate_9QAM_Constellation_Tx2(chosen_constellation);
                tx_syms_mat_C(i,j) = Emulate_9QAM_Constellation_Tx1(chosen_constellation);
                tx_syms_mat_D(i,j) = Emulate_9QAM_Constellation_Tx2(chosen_constellation);

            end
        end
elseif MOD_ORDER == 2
        MAC_bits = randi([0 1],N_Data,1);
        encoded_bits = wlanBCCEncode(MAC_bits,CodeRate);
        tx_syms_mat = arrayfun(mod_fcn_bpsk, encoded_bits)/0.707;

        for j = 1:N_OFDM_SYMS
            for i = 1:length(SC_IND_DATA)
                chosen_constellation = encoded_bits(length(SC_IND_DATA)*(j-1) + i,1) +1;
                tx_syms_mat_A(i,j) = Emulate_BPSK_Constellation_Tx1(chosen_constellation);
                tx_syms_mat_B(i,j) = Emulate_BPSK_Constellation_Tx2(chosen_constellation);
                tx_syms_mat_C(i,j) = Emulate_BPSK_Constellation_Tx3(chosen_constellation);
                tx_syms_mat_D(i,j) = Emulate_BPSK_Constellation_Tx4(chosen_constellation);
            end
        end        

end



% Define the pilot tone values as BPSK symbols
%  We will transmit pilots only on RF A
pilots_A = [1.04 -1.04 1.04 1.04].';
pilots_B = [0.92 -0.92 0.92 0.92].';
pilots_C = [1 -1 1 1].';
pilots_D = [1.04 -1.04 1.04 1.04].';
% Repeat the pilots across all OFDM symbols
pilots_mat_A = repmat(pilots_A, 1, N_OFDM_SYMS);
pilots_mat_B = repmat(pilots_B, 1, N_OFDM_SYMS);
pilots_mat_C = repmat(pilots_C, 1, N_OFDM_SYMS);
pilots_mat_D = repmat(pilots_D, 1, N_OFDM_SYMS);


%% IFFT

% Construct the IFFT input matrix
ifft_in_mat_A = zeros(N_SC, N_OFDM_SYMS);
ifft_in_mat_B = zeros(N_SC, N_OFDM_SYMS);
ifft_in_mat_C = zeros(N_SC, N_OFDM_SYMS);
ifft_in_mat_D = zeros(N_SC, N_OFDM_SYMS);

% Insert the data and pilot values; other subcarriers will remain at 0
ifft_in_mat_A(SC_IND_DATA, :)   = tx_syms_mat_A;
ifft_in_mat_A(SC_IND_PILOTS, :) = pilots_mat_A;

ifft_in_mat_B(SC_IND_DATA, :)   = tx_syms_mat_B;
ifft_in_mat_B(SC_IND_PILOTS, :) = pilots_mat_B;


ifft_in_mat_C(SC_IND_DATA, :)   = tx_syms_mat_C;
ifft_in_mat_C(SC_IND_PILOTS, :) = pilots_mat_C;

ifft_in_mat_D(SC_IND_DATA, :)   = tx_syms_mat_D;
ifft_in_mat_D(SC_IND_PILOTS, :) = pilots_mat_D;

%Perform the IFFT
tx_payload_mat_A = ifft(ifft_in_mat_A, N_SC, 1);
tx_payload_mat_B = ifft(ifft_in_mat_B, N_SC, 1);
tx_payload_mat_C = ifft(ifft_in_mat_C, N_SC, 1);
tx_payload_mat_D = ifft(ifft_in_mat_D, N_SC, 1);

% Insert the cyclic prefix

tx_cp_A = tx_payload_mat_A((end-CP_LEN+1 : end), :);
tx_payload_mat_A = [tx_cp_A; tx_payload_mat_A];

tx_cp_B = tx_payload_mat_B((end-CP_LEN+1 : end), :);
tx_payload_mat_B = [tx_cp_B; tx_payload_mat_B];

tx_cp_C = tx_payload_mat_C((end-CP_LEN+1 : end), :);
tx_payload_mat_C = [tx_cp_C; tx_payload_mat_C];

tx_cp_D = tx_payload_mat_D((end-CP_LEN+1 : end), :);
tx_payload_mat_D = [tx_cp_D; tx_payload_mat_D];

% Reshape to a vector
tx_payload_vec_A = reshape(tx_payload_mat_A, 1, numel(tx_payload_mat_A));
tx_payload_vec_B = reshape(tx_payload_mat_B, 1, numel(tx_payload_mat_B));
tx_payload_vec_C = reshape(tx_payload_mat_C, 1, numel(tx_payload_mat_C));
tx_payload_vec_D = reshape(tx_payload_mat_D, 1, numel(tx_payload_mat_D));



% signal_mat_TX1 = reshape(Emulated_signal(:,1),160,length(Emulated_signal(:,1))/160);
% signal_mat_nocyc_TX1 = signal_mat_TX1(33:end,:);% Remove cylic preflix
% fft_mat_40M_NonInt_TX1 = fftshift(fft(signal_mat_nocyc_TX1,128),1);
% N_OFDM_SYMS1 = length(fft_mat_40M_NonInt_TX1(1,:));
% fft_mat_20M_NonInt_TX1 = [fft_mat_40M_NonInt_TX1(1:32,:);zeros(1,N_OFDM_SYMS1);fft_mat_40M_NonInt_TX1(98:128,:)];%fft_mat_40M_NonInt_TX1(1:64,:);
% 
% fft_mat_20M_NonInt_TX1([12;26;40;54], :) = repmat(pilots_A,1,N_OFDM_SYMS1);
% 
% 
% tx_syms_mat_A = ifft(ifftshift(fft_mat_20M_NonInt_TX1,1),64,1);
% time_tx1 = reshape([tx_syms_mat_A(49:end,:);tx_syms_mat_A],[],1);
% 
% signal_mat_TX2 = reshape(Emulated_signal(:,2),160,length(Emulated_signal(:,2))/160);
% signal_mat_nocyc_TX2 = signal_mat_TX2(33:end,:);% Remove cylic preflix
% fft_mat_40M_NonInt_TX2 = fftshift(fft(signal_mat_nocyc_TX2,128),1);
% 
% fft_mat_20M_NonInt_TX2 = [fft_mat_40M_NonInt_TX2(1:32,:);zeros(1,N_OFDM_SYMS1);fft_mat_40M_NonInt_TX2(98:128,:)];
% 
% fft_mat_20M_NonInt_TX2([12;26;40;54], :) = repmat(pilots_A,1,N_OFDM_SYMS1);
% 
% 
% tx_syms_mat_B = ifft(ifftshift(fft_mat_20M_NonInt_TX2,1),64,1);
% 
% time_tx2 = reshape([tx_syms_mat_B(49:end,:);tx_syms_mat_B],[],1);
% 
% combined_constellation = (fft_mat_20M_NonInt_TX2 + fft_mat_20M_NonInt_TX1)/2;
% combined_constellation_40M = fft_mat_40M_NonInt_TX2 + fft_mat_40M_NonInt_TX1;
% 
% %tx_vec_emu = Emulated_signal;
% 
% tx_vec_emu_20M = [time_tx1 time_tx2];
% 
% 
% %tx_vec = [lstf;lltf;lsig;htstf;htltf;htsig;tx_vec_emu];
% 
% %tx_vec = [lstf;tx_vec_emu];
% 
% %tx_vec = [tx_vec_EQ(1:960,:);tx_vec_emu];
% 
% 
% tx_vec = tx_vec_emu_20M;
% 


% Construct the full time-domain OFDM waveform
%tx_vec_A = [preamble_A tx_vec(:,1).' tx_vec(:,1).'];%lts_t_N(33:64) lts_t_N lts_t_N
%tx_vec_B = [preamble_B tx_vec(:,2).' tx_vec(:,1).'];%lts_t_N(33:64) lts_t_N lts_t_N

tx_vec_A = [preamble_A tx_payload_vec_A];%lts_t_N(33:64) lts_t_N lts_t_N
tx_vec_B = [preamble_B tx_payload_vec_B];%lts_t_N(33:64) lts_t_N lts_t_N
tx_vec_C = [preamble_C tx_payload_vec_C];%lts_t_N(33:64) lts_t_N lts_t_N
tx_vec_D = [preamble_C tx_payload_vec_D];%lts_t_N(33:64) lts_t_N lts_t_N

% Pad with zeros for transmission
tx_vec_padded_A = [zeros(1,500) tx_vec_A zeros(1,25000)];
tx_vec_padded_B = [zeros(1,500) tx_vec_B zeros(1,25000)];
tx_vec_padded_C = [zeros(1,500) tx_vec_C zeros(1,25000)];
tx_vec_padded_D = [zeros(1,500) tx_vec_D zeros(1,25000)];

%% Interpolate

tx_vec_2x_A = zeros(1, 2*numel(tx_vec_padded_A));
tx_vec_2x_A(1:2:end) = tx_vec_padded_A;
tx_vec_air_A = filter(interp_filt2, 1, tx_vec_2x_A);

tx_vec_2x_B = zeros(1, 2*numel(tx_vec_padded_B));
tx_vec_2x_B(1:2:end) = tx_vec_padded_B;
tx_vec_air_B = filter(interp_filt2, 1, tx_vec_2x_B);

tx_vec_2x_C = zeros(1, 2*numel(tx_vec_padded_C));
tx_vec_2x_C(1:2:end) = tx_vec_padded_C;
tx_vec_air_C = filter(interp_filt2, 1, tx_vec_2x_C);

tx_vec_2x_D = zeros(1, 2*numel(tx_vec_padded_D));
tx_vec_2x_D(1:2:end) = tx_vec_padded_D;
tx_vec_air_D = filter(interp_filt2, 1, tx_vec_2x_D);

% Scale the Tx vector to +/- 1
tx_vec_air_A = TX_SCALE .* tx_vec_air_A ./ max(abs(tx_vec_air_A));
tx_vec_air_B = TX_SCALE .* tx_vec_air_B ./ max(abs(tx_vec_air_B));
tx_vec_air_C = TX_SCALE .* tx_vec_air_C ./ max(abs(tx_vec_air_C));
tx_vec_air_D = TX_SCALE .* tx_vec_air_D ./ max(abs(tx_vec_air_D));


TX_NUM_SAMPS = 2^16;

if(USE_WARPLAB_TXRX)
    wl_basebandCmd(nodes, 'tx_delay', 0);
    wl_basebandCmd(nodes, 'tx_length', TX_NUM_SAMPS+100);                   % Number of samples to send
    wl_basebandCmd(nodes, 'rx_length', TX_NUM_SAMPS+SAMP_PADDING);      % Number of samples to receive
end

%%  Tx/Rx
for num_trans = 1: 20
    tx_mat_air = [tx_vec_air_A(:) , tx_vec_air_B(:), tx_vec_air_C(:), tx_vec_air_D(:)];%, tx_vec_air_D(:)];
    %tx_mat_air = [tx_vec_air_B(:) , tx_vec_air_A(:)];

    % Write the Tx waveform to the Tx node
    wl_basebandCmd(node_tx, TX_RF_VEC, 'write_IQ', tx_mat_air);

    % Enable the Tx and Rx radios
    wl_interfaceCmd(node_tx, ifc_ids_TX.RF_ALL, 'tx_en');
    wl_interfaceCmd(node_rx, RX_RF, 'rx_en');

    % Enable the Tx and Rx buffers
    wl_basebandCmd(node_tx, ifc_ids_TX.RF_ALL, 'tx_buff_en');
    wl_basebandCmd(node_rx, RX_RF, 'rx_buff_en');

    % Trigger the Tx/Rx cycle at both nodes
    eth_trig.send();

    % Retrieve the received waveform from the Rx node
    rx_mat_air = wl_basebandCmd(node_rx, RX_RF_VEC, 'read_IQ', 0, TX_NUM_SAMPS+SAMP_PADDING);

    rx_vec_air = rx_mat_air;


    % Disable the Tx/Rx radios and buffers
    wl_basebandCmd(node_tx, TX_RF_ALL, 'tx_rx_buff_dis');

    wl_basebandCmd(node_rx, RX_RF_ALL, 'tx_rx_buff_dis');

    wl_interfaceCmd(node_tx, TX_RF_ALL, 'tx_rx_dis');

    wl_interfaceCmd(node_rx, RX_RF_ALL, 'tx_rx_dis');

    %% Spectrum analysis

    rx_IQ = rx_mat_air;

    %% Decode
    raw_rx_dec = filter(interp_filt2, 1, rx_vec_air);
    raw_rx_dec = raw_rx_dec(1:2:end);

    % Complex cross correlation of Rx waveform with time-domain LTS
    lts_corr = abs(conv(conj(fliplr(lts_t)), sign(raw_rx_dec)));

    % Skip early and late samples - avoids occasional false positives from pre-AGC samples
    lts_corr = lts_corr(32:end-32);

    % Find all correlation peaks
    lts_peaks = find(lts_corr(1:5000) > LTS_CORR_THRESH*max(lts_corr));

    % Select best candidate correlation peak as LTS-payload boundary
    [LTS1, LTS2] = meshgrid(lts_peaks,lts_peaks);
    [lts_second_peak_index,y] = find(LTS2-LTS1 == 64);

    
    if(isempty(lts_second_peak_index) == 1 )
        failed_frame = failed_frame + 1;
        BER(num_trans) = 1;
        pause(1/10);
        continue
    end
    % Stop if no valid correlation peak was found

%     figure(12); clf;
%     lts_to_plot = lts_corr;
%     plot(lts_to_plot, '.-b', 'LineWidth', 1);
%     hold on;
%     grid on;
%     line([1 length(lts_to_plot)], LTS_CORR_THRESH*max(lts_to_plot)*[1 1], 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2);
%     title('LTS Correlation and Threshold')
%     xlabel('Sample Index')
%     myAxis = axis();
%     axis([1, 1000, myAxis(3), myAxis(4)])

    % Set the sample indices of the payload symbols and preamble
    % The "+32" corresponds to the 32-sample cyclic prefix on the preamble LTS
    % The "-160" corresponds to the length of the preamble LTS (2.5 copies of 64-sample LTS)
    HT_preamble_ind = lts_peaks(max(lts_second_peak_index)) + 32;

    payload_ind = HT_preamble_ind ;

    lts_ind = HT_preamble_ind -160 -64;

    extra_preamble = payload_ind -160;

    
    % for drift = 1:50
    %     LTF_peak = lts_ind - 160  +drift +32 - 16; %payload_ind -159;
    % 
    %     payload_ind = LTF_peak  +400;
    %     
    %     [BER(drift,1)] = decode(payload_ind,LTF_peak,raw_rx_dec,NhtCfg);
    % % %     
    % %     [eqSYM_HT, HT_data] = Eq_subtraction(payload_ind,raw_rx_dec,LTF_peak,time_tx1,time_tx2,NhtCfg);
    % %     
    % %     figure(drift+30)
    % %     scatter(real(eqSYM_HT(1:600,1)),imag(eqSYM_HT(1:600,1)));
    % % %     
    %       [VHTbits, VHTDataSym(:,drift)] = Decode_VHT(payload_ind,raw_rx_dec,LTF_peak);
    % %     
    %       figure(drift+100)
    %       scatter(real(VHTDataSym(1:1000,drift)),imag(VHTDataSym(1:1000,drift)));
    % end
   if(lts_ind < 1 )
        pause(1/10);
        continue
    end

    %Extract LTS (not yet CFO corrected)
    rx_lts = raw_rx_dec(lts_ind: lts_ind+159 +64);
    rx_lts1 = rx_lts(-128+-FFT_OFFSET + [97+64:160+64]);
    rx_lts2 = rx_lts(-64-FFT_OFFSET + [97+64:160+64]);
    rx_lts3 = rx_lts(-FFT_OFFSET + [97+64:160+64]);

    %Calculate coarse CFO est
    rx_cfo_est_lts = mean(unwrap(angle(rx_lts1 .* conj(rx_lts1))));
    rx_cfo_est_lts1 = mean(unwrap(angle(rx_lts2 .* conj(rx_lts2))));
    rx_cfo_est_lts2 = mean(unwrap(angle(rx_lts3 .* conj(rx_lts3))));

    %rx_cfo_est_lts_emulated = mean(unwrap(angle(rx_lts3 .* conj(rx_lts4))));

    rx_cfo_est_lts_average = (rx_cfo_est_lts + rx_cfo_est_lts1 +rx_cfo_est_lts2);% + rx_cfo_est_lts_emulated*1/4;
    rx_cfo_est_lts = rx_cfo_est_lts_average/(2*pi*64);


    % Apply CFO correction to raw Rx waveform
    rx_cfo_corr_t = exp(-1i*2*pi*rx_cfo_est_lts*[0:length(raw_rx_dec)-1]);
    rx_dec_cfo_corr = raw_rx_dec.' .* rx_cfo_corr_t;



    % Re-extract LTS for channel estimate
    rx_lts = rx_dec_cfo_corr(lts_ind : lts_ind+159 +64);
    rx_lts1 = rx_lts(-128+-FFT_OFFSET + [97+64:160+64]);
    rx_lts2 = rx_lts(-64-FFT_OFFSET + [97+64:160+64]);
    rx_lts3 = rx_lts(-FFT_OFFSET + [97+64:160+64]);

    rx_lts1_f = fft(rx_lts1);
    rx_lts2_f = fft(rx_lts2);
    rx_lts3_f = fft(rx_lts3);


    % Calculate channel estimate from average of 2 training symbols
    rx_H_est = lts_f .* (rx_lts1_f + rx_lts2_f+ rx_lts3_f)/3;


    rx_est = rx_H_est;%*6/8 + rx_H_est*2/8;

    syms_eq_mat_A = zeros(N_SC, N_OFDM_SYMS);
    syms_eq_mat_B = zeros(N_SC, N_OFDM_SYMS);
    channel_condition_mat = zeros(1,N_SC);



    %% Rx payload processing

    % Extract the payload samples (integral number of OFDM symbols following preamble)
    payload_vec = rx_dec_cfo_corr(payload_ind : payload_ind+(N_OFDM_SYMS)*(N_SC+CP_LEN)-1);
    payload_mat = reshape(payload_vec, (N_SC+CP_LEN), N_OFDM_SYMS);

    % Remove the cyclic prefix, keeping FFT_OFFSET samples of CP (on average)
    payload_mat_noCP = payload_mat(CP_LEN-FFT_OFFSET+[1:N_SC], :);

    % Take the FFTpayload_mat_noCP
    syms_f_mat = fft(payload_mat_noCP, N_SC, 1);

    % Equalize (zero-forcing, just divide by complex chan estimates)
    syms_eq_mat = syms_f_mat./repmat(rx_est.',1, N_OFDM_SYMS);
    %syms_eq_mat = syms_eq_mat_N ./ repmat(rx_H_est.', 1, N_OFDM_SYMS);

    

  
    % SFO manifests as a frequency-dependent phase whose slope increases
    % over time as the Tx and Rx sample streams drift apart from one
    % another. To correct for this effect, we calculate this phase slope at
    % each OFDM symbol using the pilot tones and use this slope to
    % interpolate a phase correction for each data-bearing subcarrier.

    % Extract the pilot tones and "equalize" them by their nominal Tx values
    pilots_f_mat = syms_eq_mat(SC_IND_PILOTS, :);
    pilots_f_mat_comp = pilots_f_mat.*pilots_mat_C;

    N_data_f_mat = syms_eq_mat(SC_N_Subcarrier,:);


    % Calculate the phases of every Rx pilot tone
    pilot_phases = unwrap(angle(fftshift(pilots_f_mat_comp,1)), [], 1);


    % Calculate slope of pilot tone phases vs frequency in each OFDM symbol
    pilot_spacing_mat = repmat(mod(diff(fftshift(SC_IND_PILOTS)),64).', 1, N_OFDM_SYMS);                        
    pilot_slope_mat = mean(diff(pilot_phases) ./ pilot_spacing_mat);

    %Custom N data equalization
    N_spacing_mat = repmat(mod(diff(fftshift(SC_N_Subcarrier)),64).', 1, N_OFDM_SYMS);                        


    % Calculate the SFO correction phases for each OFDM symbol
    pilot_phase_sfo_corr = fftshift((-32:31).' * pilot_slope_mat, 1);
    pilot_phase_corr = exp(-1i*(pilot_phase_sfo_corr));


    % Apply the pilot phase correction per symbol
    %syms_eq_mat = syms_eq_mat .* pilot_phase_corr;
    syms_eq_mat = syms_eq_mat .* (pilot_phase_corr);
    %syms_eq_mat = syms_eq_mat .* N_phase_corr;




    % Extract the pilots and calculate per-symbol phase error
    pilots_f_mat = syms_eq_mat(SC_IND_PILOTS, :);
    pilots_f_mat_comp = pilots_f_mat.*pilots_mat_C;
    pilot_phase_err = angle(mean(pilots_f_mat_comp));

    pilot_phase_err_corr = repmat(pilot_phase_err, N_SC, 1);
    pilot_phase_corr = exp(-1i*(pilot_phase_err_corr));



    % Apply the pilot phase correction per symbol
    %syms_eq_pc_mat = syms_eq_mat .* pilot_phase_corr;

    %syms_eq_pc_mat = syms_eq_mat .* N_phase_corr;

    syms_eq_pc_mat = syms_eq_mat .* (pilot_phase_corr);

    payload_syms_mat = syms_eq_pc_mat(SC_IND_DATA, :);

    %% Demodulate
    rx_syms = reshape(payload_syms_mat, 1, N_DATA_SYMS);
    %MOD_ORDER = 4;
    rx_syms_snr = reshape(payload_syms_mat, 1, N_DATA_SYMS)*1.5/max(abs(rx_syms));


    switch(MOD_ORDER)
        case 2         % BPSK
            rx_data = arrayfun(demod_fcn_bpsk, rx_syms);
            rx_data_bits = reshape(de2bi(rx_data)',[],1);

        case 4         % QPSK
            rx_data = arrayfun(demod_fcn_qpsk, rx_syms);
            rx_data_bits = reshape(de2bi(rx_data)',[],1);
        case 16        % 16-QAM
            rx_data = arrayfun(demod_fcn_16qam, rx_syms_snr);
            rx_data_bits = reshape(de2bi(rx_data)',[],1);
        case 64        % 64-QAM
            rx_data = arrayfun(demod_fcn_64qam, rx_syms);
    end
    
    evm_mat = abs(rx_syms_snr.' - tx_syms_mat).^2;
    aevms = mean(evm_mat(:));
    snr(num_trans) = 10*log10(1./aevms);

    decoded_bits = wlanBCCDecode(rx_data_bits,CodeRate,'hard');
    average_divation(num_trans) = mean(abs(rx_syms_snr(1:end-100).' - tx_syms_mat(1:end-100)));

    %% Plot Results
    cf = 10;

    % Tx signal
    cf = cf + 1;
%    figure(cf); clf;

%     subplot(2,1,1);
%     plot(real(tx_mat_air), 'b');
%     axis([0 length(tx_mat_air) -TX_SCALE TX_SCALE])
%     grid on;
%     title('Tx Waveform (I)');
% 
%     subplot(2,1,2);
%     plot(imag(tx_mat_air), 'r');
%     axis([0 length(tx_mat_air) -TX_SCALE TX_SCALE])
%     grid on;
%     title('Tx Waveform (Q)');


    % Rx signal
    cf = cf + 1;
    figure(cf); clf;
    subplot(2,1,1);
    plot(real(rx_vec_air), 'b');
    axis([0 length(rx_vec_air) -TX_SCALE TX_SCALE])
    grid on;
    title('Rx Waveform (I)');

    subplot(2,1,2);
    plot(imag(rx_vec_air), 'r');
    axis([0 length(rx_vec_air) -TX_SCALE TX_SCALE])
    grid on;
    title('Rx Waveform (Q)');

  
    % Rx LTS correlation



    % Channel Estimates
%     cf = cf + 1;
% 
%     rx_H_est_plot = repmat(complex(NaN,NaN),1,length(rx_H_est));
%     rx_H_est_plot(SC_IND_DATA) = rx_H_est(SC_IND_DATA);
%     rx_H_est_plot(SC_IND_PILOTS) = rx_H_est(SC_IND_PILOTS);
% 
%     x = (20/N_SC) * (-(N_SC/2):(N_SC/2 - 1));

%     figure(cf); clf;
%     subplot(2,1,1);
%     stairs(x - (20/(2*N_SC)), fftshift(real(rx_H_est_plot)), 'b', 'LineWidth', 2);
%     hold on
%     stairs(x - (20/(2*N_SC)), fftshift(imag(rx_H_est_plot)), 'r', 'LineWidth', 2);
%     hold off
%     axis([min(x) max(x) -1.1*max(abs(rx_H_est_plot)) 1.1*max(abs(rx_H_est_plot))])
%     grid on;
%     title('Channel Estimates (I and Q)')
% 
%     subplot(2,1,2);
%     bh = bar(x, fftshift(abs(rx_H_est_plot)),1,'LineWidth', 1);
%     shading flat
%     set(bh,'FaceColor',[0 0 1])
%     axis([min(x) max(x) 0 1.1*max(abs(rx_H_est_plot))])
%     grid on;
%     title('Channel Estimates (Magnitude)')
%     xlabel('Baseband Frequency (MHz)')


    %% Pilot phase error estimate
%     cf = cf + 1;
%     figure(cf); clf;
%     subplot(2,1,1)
%     plot(pilot_phase_err, 'b', 'LineWidth', 2);
%     title('Phase Error Estimates')
%     xlabel('OFDM Symbol Index')
%     ylabel('Radians')
%     axis([1 N_OFDM_SYMS -3.2 3.2])
%     grid on
% 
%     h = colorbar;
%     set(h,'Visible','off');
% 
%     subplot(2,1,2)
%     imagesc(1:N_OFDM_SYMS, (SC_IND_DATA - N_SC/2), fftshift(pilot_phase_sfo_corr,1))
%     xlabel('OFDM Symbol Index')
%     ylabel('Subcarrier Index')
%     title('Phase Correction for SFO')
%     colorbar
%     myAxis = caxis();
%     if(myAxis(2)-myAxis(1) < (pi))
%        caxis([-pi/2 pi/2])
%     end
% 
% 
%     if(WRITE_PNG_FILES)
%         print(gcf,sprintf('wl_ofdm_plots_%s_phaseError', example_mode_string), '-dpng', '-r96', '-painters')
%     end

    %% Symbol constellation     
    cf = cf + 1;
    figure(cf); clf;
    payload_syms_mat_plot = rx_syms_snr(:);
    plot(payload_syms_mat_plot,'ro','MarkerSize',1);
    axis square; axis(3*[-1 1 -1 1]);
     grid on;
    hold on;

% 
%     cf = cf + 1;
%     figure(cf); clf;
%     scale = max(max(abs(payload_syms_mat_plot)));
%     plot(payload_syms_mat_plot./scale,'ro','MarkerSize',1);
%     axis square; axis([-1 1 -1 1]);
%     grid on;
%     hold on;


    noise_floor = 0.0260;% mean(abs(rx_vec_air(45000:60000,1)));
    receive_signal_strength = max(abs(rx_vec_air(4000:end,1)));
    SNR(num_trans) = 10*log10(receive_signal_strength/noise_floor);

    BER_encoded = length(find(abs(double(rx_data_bits - encoded_bits))~=0))/9600;
    
    BER(num_trans) = length(find(abs(double(decoded_bits(1:end-22)) - MAC_bits(1:end-22))~=0))/length(MAC_bits);
    pause(1/10);
end
BER_mean = mean(BER)
% BSNR_mean = mean(snr)
% advalue = mean(average_divation(find(average_divation<0.4)))
% BBBBB = [snr;BER];