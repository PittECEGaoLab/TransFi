clear all
close all
load Interleave_matrix_40Mhz.mat
load Shift_table40M.mat
load Encode_table_24.mat
load C_map_rotated.mat
load ref_pilot_vht.mat
load ref_pilot.mat
load Tx12_sig.mat
load driver_bits.mat
load carrier_rotations.mat
load interleaver_mat.mat
load Shift_table3Tx.mat
%% initialization 
distance_difference = zeros(26,2,3);
mean_d = zeros(10,2,3);
new_distance = zeros(26,2);
old_distance = zeros(26,2); 
encoder_input = zeros(1080,1);
output_seq = zeros(520,1);
bit_error_num = zeros(1024,1);
legal_segment = zeros(1024,1);

serviceBits = zeros(16,1,'int8');
scrambler_com = 97;
scrambled_sevicesbits = wlanScramble(serviceBits,scrambler_com); % Compute scrambled service bits
scrambled_driverbits = wlanScramble(randi([0 1],288,1),scrambler_com); % Compute scrambled driver inserted bits 36*8
scramblerInitBits = de2bi(scrambler_com,7,'left-msb').'; 
%% Target Signal Generation
N_SYSMS =1;
scrambler = 93;
NhtCfg = wlanNonHTConfig;             % Create packet configuration
NhtCfg.ChannelBandwidth = 'CBW20'; % 160 MHz channel bandwidth
%htCfg.NumTransmitAntennas = 1;     % 1 transmit antenna
%htCfg.NumSpaceTimeStreams = 1;     % 1 space-time stream
NhtCfg.MCS = 2;% Modulation: QPSK Rate: 1/2
numPackets = 1;   % Generate 4 packets

idleTime = 20e-6; % 20 microseconds idle period after packet
%macCfg.MSDUAggregation = true;  % Form A-MSDUs internally
               % Number of bits in 1 byte
beaconCfg = wlanMACManagementConfig;
beaconCfg.BeaconInterval = 100;
beaconCfg.Timestamp = 123456;
beaconCfg.SSID = 'MowwwSSSSSSSSSSSSSSSSSSSSSSS';
macCfg = wlanMACFrameConfig('FrameType','Beacon');
macCfg.ManagementConfig = beaconCfg;%MAC config
% macCfg.FrameFormat = 'HT';     % Frame format
% macCfg.AckPolicy = 'Normal ACK';
% macCfg.Address1 = 'FCF8B0102001';
% macCfg.Address2 = 'FCF8B0102002';
% macCfg.Address2 = 'FCF8B0102002';
data = [];
%%  ACK
%macCfg = wlanMACFrameConfig('FrameType', 'ACK');
%macCfg.FrameFormat = 'Non-HT';     % Frame format
%macCfg.Address1 = 'b252166d039c';
%macCfg.MSDUAggregation = true;  % Form A-MSDUs internally
%bitsPerByte = 6;                % Number of bits in 1 byte
%data_trans = [];

%%
% Create MSDUs with beacon
[psdu, mpduLength] = wlanMACFrame(macCfg);
NhtCfg.PSDULength = mpduLength;
% Convert the PSDU in hexadecimal format to bits
%decimalBytes = hex2dec(psdu);

% decimalBytes=[
%     218,96,86,206,91,168,190,20,59,254,112,79,147,64,100,116,109,48,43,231,45,84,95,138,29,124,139,198,120,102,82,144,53,9,188,177,159,56,59,185,78,25,213,249,102,50,57,215,7,220,122,123,32,71,151,195,135,95,204,232,179,144,19,54,155,114,161,188,135,197,121,151,229,13,125,40,177,84,78,215,53,147,171,220,38,127,36,88,220,88,242,8,177,222,121,11,172,113,223,109,160,232,66,218,232,201,60,124,67,80,209,241,202,174,4,186,78,253,191,209,84,243,218,160,171,12,203,234,248,82,92,234,169,189,39,90,207,54,47,185,67,245,93,47,185,185,243,81,148,121,131,55,61,154,135,195,60,34,10,52,179,7,243,183,234,111,231,15,158,196,76,188,134,13,25,27,206,229,75,45,211,149,232,219,167,254,97,18,187,172,119,15,2,111,61,5,199,148,56,113,186,11,238,105,107,110,49,4,178,96,206,116,229,175,217,192,198,186,154,64,41,161,243,142,71,185,249,6,82,64,168,126,233,249,110,50,9,213,39,112,173,159,132,49,76,111,22,214,226,15,15,195,65,122,206,28,150,232,82,130,252,54,27,116,108,95,35,66,79,230,109,145,107,167,15,213,254,146,130,231,46,179,13,32,48,149,4,190,147,241,156,182,151,213,134,63,239,243,253,18,125,215,154,76,231,166,130,71,34,158,29,127,193,65,244,138,141,188,29,80,245,182,132,219,10,112,227,75,252,54,145,73,88,87,144,20,218,204,6,115,143,28,210,183,227,158,150,147,162,104,176,56,8,41,193,208,81,125,209,129,180,223,22,237,17,147,200,134,222,149,112,247,53,102,76,227,181,180,129,105,168,154,66,215,111,67,55,38,130,47,186,112,77,188,114,66,114,111,186,55,95,61,92,95,185,61,166,186,195,195,161,178,151,233,17,7,70,234,112,79,234,166,217,222,210,54,0,47,77,17,205,251,56,202,213,211,105,197,135,227,119,146,30,43,6,31,34,99,150,65,201,123,41,231,157,70,53,34,84,70,38,70,135,81,221,243,253,230,73,115,135,167,146,70,6,145,201,131,248,161,127,171,234,90,236,249,227,23,75,50,186,80,188,197,176,4,181,247,71,59,114,247,193,26,5,1,200,204,238,208,84,204,106,201,15,22,95,126,177,231,187,88,228,114,202,108,43,229,140,118,89,173,26,245,132,135,249,33,16,186,22,216,145,55,21,232,150,217,6,191,222,115,166,8,93,255,51,204,202,104,25,197,47,211,199,61,92,105,26,204,24,175,79,119,213,122,20,248,235,255,33,105,247,20,143,102,114,93,46,53,98,212,75,196,228,65,241,151,251,153,12,50,254,226,1,236,27,101,227,240,104,106,255,65,165,73,152,33,209,158,209,140,197,241,16,220,107,127,216,54,15,180,146,96,48,186,195,100,8,127,171,172,40,163,78,114,111,163,1,52,112,93,146,43,95,21,90,199,12,174,59,122,193,66,32,22,158,5,18,165,125,166,162,7,213,174,102,154,147,133,82,16,121,204,93,88,106,163,13,247,193,245,217,202,106,0,180,20,30,15,70,213,253,213,238,123,19,227,183,207,58,145,194,245,147,196,213,121,222,102,209,150,82,193,9,203,146,37,144,163,99,199,205,56,45,176,202,148,125,234,99,115,143,100,145,241,51,227,152,22,159,214,109,35,127,205,160,7,38,145,72,235,210,112,11,71,217,29,156,30,121,244,74,201,148,194,252,112,247,128,43,228,30,53,110,204,125,85,187,54,96,98,187,40,34,228,85,213,31,128,109,231,174,181,192,195,148,18,50,207,27,109,138,57,41,84,54,122,88,135,120,125,86,136,142,129,63,64,227,190,15,246,243,161,235,15,196,20,208,70,34,93,135,51,95,1,203,103,16,36,43,231,84,178,226,32,162,121,147,111,41,101,160,203,19,45,248,135,54,79,154,156,207,53,87,11,52,165,20,251,3,178,223,209,6,34,19,121,233,240,114,23,55,25,188,53,23,51,222,234,207,129,83,70,190,11,145,19,101,42,214,199,162,135,206,184,141,89,32,163,250,246,152,85,243,38,246,190,71,41,81,214,209,135,40,63,91,157,84,214,217,187,213,188,240,199,126,170,137,48,203,188,155,12,254,99,29,115,34,109,187,211,109,243,150,145,96,68,198,15,179,195,254,152,247,53,81,242,158,127,156,132,180,182,201,137,27,56,79,197,254,208,116,200,103,140,77,1,162,241,108,195,200,22,54,208,80,246,255,110,84,98,252,225,231,192,60,98,87,220,75,158,174,30,58,207,49,142,147,4,111,118,245,61,53,103,187,243,247,152,89,249,146,99,106,16,170,190,164,41,148,240,37,203,30,131,238,21,223,66,13,82,144,207,15,176,10,95,2,255,213,64,231,149,242,121,162,138,167,60,13,199,165,252,167,107,234,169,124,151,97,32,77,68,68,248,52,149,116,220,200,233,29,200,249,135,72,219,141,34,199,65,2,112,44,63,48,108,243,58,42,163,26,111,230,181,82,181,233,132,45,181,83,254,41,36,250,133,180,167,1,245,43,83,114,80,146,131,200,22,54,123,217,119,93,183,80,116,124,77,160,11,141,107,20,246,200,173,103,39,63,79,149,40,184,52,48,189,85,17,136,165,217,130,47,212,218,37,81,163,29,219,236,201,249,50,1,30,96,212,29,62,9,184,186,136,173,172,102,213,30,53,232,72,130,162,134,247,80,35,197,111,194,86,34,228,127,148,39,197,255,211,99,95,25,4,10,139,218,129,90,186,111,243,252,54,198,121,67,0,142,139,131,215,233,25,204,52,149,16,90,46,100,216,241,142,46,161,88,200,176,38,22,103,25,24,166,139,163,248,197,85,145,66,204,92,203,55,9,109,49,88,79,130,20,126,249,29,9,224,18,185,182,161,65,122,20,185,45,21,238,149,238,215,39,177,25,109,185,124,200,122,56,180,166,36,167,53,237,248,59,202,5,60,25,26,37,154,140,192,9,147,195,133,235,36,185,70,109,69,6,18,50,158,96,116,4,192,110,31,237,142,64,34,161,68,177,127,63,109,43,230,234,252,240,195,14,109,219,147,181,63,64,44,177,104,217,239,156,138,38,129,177,14,103,202,233,200,112,96,222,81,169,143,85,250,254,52,68,145,216,105,106,237,166,140,79,63,16,217,160,217,92,136,63,77,178,131,187,53,171,244,194,80,202,5,198,31,22,158,90,182,4,101,157,61,197,224,59,41,245,29,126,215,175,236,66,128,136,45,238,77,68,100,29,157,117,211,39,247,75,247,54,38,118,96,209,4,57,110,102,82,253,165,235,209,94,121,254,142,163,35,70,92,208,171,218,93,32,50,195,208,37,63,76,16,129,231,165,203,173,173,246,145,125,109,125,254,121,147,56,1,94,79,114,114,18,72,113,108,157,36,163,250,226,254,146,66,245,84,189,48,79,102,172,84,79,7,157,121,10,23,155,64,180,154,20,188,2,243,62,158,158,197,164,47,189,65,102,240,177,31,27,232,151,240,13,212,7,162,225,146,222,169,16,137,6,138,27,215,231,191,132,202,161,179,7,175,55,141,21,198,198,193,179,111,114,220,64,223,99,223,247,13,75,176,21,42,139,105,163,65,121,47,9,248,234,208,225,91,59,76,230,65,177,190,241,138,189,183,200,69,153,103,245,224,15,6,81,200,140,91,225,86,222,214,40,184,166,139,44,16,201,179,98,64,227,109,24,31,86,45,126,79,235,143,61,88,15,11,32,22,231,191,158,148,99,214,140,162,245,78,61,221,89,0,6,168,95,24,205,234,147,9,49,55,162,126,3,108,233,4,61,80,174,15,100,207,122,130,236,193,129,201,30,255,28,11,100,94,151,70,27,112,102,126,236,61,222,240,99,171,250,15,18,133,74,131,193,1,223,176,243,82,223,153,242,123,45,40,146,64,156,131,37,14,163,44,189,15,127,214,163,188,6,11,212,248,106,98,125,92,91,9,254,84,25,127,209,87,12,216,242,96,41,48,41,200,31,114,89,136,151,99,0,183,65,32,1,154,239,154,241,121,151,42,2,26,7,173,105,47,254,112,54,117,253,206,203,107,27,227,135,104,198,46,175,168,18,204,135,172,149,107,251,60,19,77,227,163,167,137,221,240,42,116,222,211,148,2,115,221,113,148,148,158,145,173,120,11,45,96,42,249,151,37,249,73,168,208,16,206,216,73,33,93,178,147,250,39,193,13,220,247,114,252,136,110,99,121,8,50,197,200,234,245,82,112,200,89,34,162,172,43,246,112,124,179,153,102,16,231,177,171,202,242,221,205,63,225,165,216,136,97,198,48,187,36,136,163,227,28,171,30,132,79,63,152,216,38,136,20,67,155,90,109,209,25,145,17,72,3,60,222,241,22,26,61,175,14,229,164,69,133,174,201,178,242,11,179,189,31,86,144,23,96,158,80,218,98,241,183,232,217,150,115,178,150,34,2,43,67,113,58,110,129,104,202,254,74,107,253,43,163,163,23,145,98,52,128,55,225,127,35,71,220,248,216,102,11,73,104,199,96,206,72,253,178,166,16,48,222,112,111,147,202,88,206,125,58,34,244,108,87,27,234,28,191,49,190,132,177,52,8,210,74,181,251,54,232,10,210,22,55,248,195,47,16,154,28,226,204,142,251,8,196,147,38,78,9,252,191,210,238,161,140,9,70,225,174,181,194,90,185,203,157,247,149,73,132,110,212,7,147,224,70,80,71,13,24,151,38,73,92,32,129,59,119,3,232,59,101,144,218,75,170,184,73,188,205,31,145,73,51,103,182,132,179,91,93,41,86,252,107,162,156,145,194,225,201,33,85,138,59,169,126,157,34,51,225,73,33,164,182,84,101,16,105,194,58,204,87,174,13,116,184,36,8,217,50,254,180,155,132,247,82,35,57,215,88,255,186,254,6,20,57,89,9,252,226,104,3,253,5,98,102,95,46,65,17,137,172,60,149,116,87,20,69,140,234,131,37,43,84,172,21,196,247,213,12,130,82,199,4,181,47,89,113,154,123,2,130,132,185,115,135,82,25,111,129,250,216,208,66,211,55,68,17,208,210,241,161,173,92,62,73,176,184,112,78,5,76,6,137,232,170,255,119,206,198,127,184,181,20,184,191,137,79,215,194,103,101,105,116,162,241,63,130,159,236,48,93,188,135,77,50,2,146,39,144,189,97,22,11,111,5,166,60,221,243,182,136,11,239,179,12,172,216,57,19,179,193,95,3,110,216,16,130,189,142,20,32,165,54,4,106,86,177,123,137,81,46,17,64,77,247,6,147,114,84,126,79,181,210,248,148,58,153,64,66,162,171,10,64,244,254,167,72,182,62,216,203,29,15,39,134,73,189,229,188,151,158,66,60,208,52,232,106,157,46,161,82,104,200,115,116,4,61,9,134,150,60,124,232,103,9,241,100,94,125,48,186,167,237,84,159,138,45,35,41,37,238,78,56,184,149,160,179,245,144,50,51,101,62,63,247,65,36,113,93,189,57,143,250,76,10,77,17,195,49,215,200,99,34,234,136,12,149,66,231,173,140,234,250,145,57,13,103,189,10,93,66,209,134,37,103,124,72,183,164,248,149,131,249,2,52,134,18,107,128,106,88,94,231,154,120,239,105,234,127,196,144,133,173,117,231,165,182,245,114,93,163,106,236,81,156,13,19,200,73,154,32,116,79,250,176,33,140,173,234,52,79,145,111,86,82,107,50,161,251,149,68,87,138,46,95,97,165,45,170,179,58,27,71,28,97,163,86,245,165,161,23,58,209,37,2,9,107,11,198,203,72,74,20,151,38,204,29,118,100,12,8,26,9,165,116,161,58,175,46,104,129,123,11,101,133,8,71,117,182,55,245,18,244,65,100,140,154,120,21,111,230,196,4,170,65,193,123,25,229,189,234,226,238,211,81,61,236,66,209,243,52,96,180,3,47,198,105,109,118,254,206,172,0,135,202,98,198,216,70,198,91,155,158,205,57,154,250,206,19,109,187,253,255,133,215,61,77,123,119,108,31,126,170,183,127,48,56,187,7,217,84,243,82,161,45,93,131,33,92,69,131,184,11,25,157,230,14,90,59,77,147,240,118,30,237,90,115,185,202,206,39,101,116,149,199,99,217,165,159,207,209,61,35,6,100,247,140,175,98,110,64,222,55,216,80,199,59,184,133,131,187,244,27,207,45,43,161,248,125,222,222,197,63,199,30,41,193,189,193,159,188,110,82,25,163,247,124,204,65,175,19,125,20,0,0,121,230,189,170,191,6,43,200,96,69,146,113,37,181,109,116,32,229,181,89,65,10,139,216,16,181,13,166,24,126,21,168,13,247,132,27,46,230,172,126,149,213,148,145,26,109,26,157,67,255,190,239,141,102,233,61,234,106,51,154,164,162,28,108,237,143,133,91,11,37,202,142,246,4,5,196,192,215,66,121,20,89,120,213,163,94,105,155,251,43,6,8,177,75,42,25,173,110,227,234,114,236,96,69,155,229,194,247,94,143,39,143,156,61,64,193,152,118,246,112,190,70,197,124,98,217,97,70,3,210,58,10,14,233,222,122,127,55,68,214,116,101,4,154,231,47,101,62,59,31,27,56,102,225,8,42,58,48,63,201,243,20,11,13,195,169,56,86,239,4,160,24,127,27,236,138,125,207,214,213,219,219,151,110,107,178,10,148,234,175,78,229,188,148,248,91,9,82,15,220,36,9,181,6,227,37,176,195,214,1,100,39,216,45,143,57,190,54,128,163,202,27,73,51,127,169,250,83,204,210,197,13,102,131,152,213,169,89,174,59,141,66,121,34,86,120,194,30,38,165,252,88,216,99,87,238,177,170,90,180,251,71,108,205,19,86,209,168,109,50,41,205,235,83,89,0,45,85,169,175,97,34,18,162,118,216,61,241,174,150,54,93,136,62,56,3,68,27,41,123,58,204,82,65,187,196,158,99,86,63,62,105,118,9,13,174,29,235,101,186,55,90,153,209,101,47,213,16,158,68,110,227,183,179,88,206,35,103,231,56,89,197,123,190,89,171,165,106,19,153,31,226,145,58,80,237,114,231,43,252,0,146,226,212,240,234,252,157,83,236,0,52,117,115,138,90,65,238,225,240,34,116,238,209,180,174,164,57,213,226,79,50,0,36,86,236,145,51,120,181,194,75,206,29,125,151,149,111,38,48,48,42,32,133,251,22,153,15,28,140,91,86,82,164,61,198,212,137,121,54,163,107,250,191,132,197,30,252,121,36,152,134,175,60,39,36,188,193,225,73,41,238,17,119,162,174,236,84,147,128,153,182,253,114,109,161,74,64,134,120,169,101,208,161,175,11,216,8,106,245,115,192,248,72,193,63,68,34,145,241,177,211,144,140,167,88,92,185,118,150,231,250,165,194,248,249,79,248,212,105,243,106,152,145,1,58,114,202,147,112,228,197,111,51,24,199,55,18,159,162,30,95,185,110,192,178,135,138,46,220,186,209,178,170,10,79,190,9,108,211,47,35,88,87,93,172,96,185,2,209,131,226,69,11,170,185,114,164,174,136,42,209,247,148,47,250,64,184,210,110,6,118,233,204,199,230,23,60,234,200,240,101,103,190,118,167,31,158,134,186,191,211,147,81,16,253,161,91,18,172,114,66,28,120,75,24,215,20,67,172,158,50,96,91,47,240,100,253,30,55,137,192,89,218,113,18,14,113,235,175,20,58,102,102,92,101,88,32,91,69,82,47,69,181,104,105,58,29,124,9,198,72,36,246,178,116,49,153,245,150,172,157,139,94,31,126,241,166,23,43,93,51,92,123,120,40,71,151,96,129,139,71,43,131,177,80,63,11,213,103,124,163,100,107,243,227,58,125,28,59,85,76,223,183,210,32,152,246,212,36,240,208,13,227,156,183,42,171,105,173,107,249,106,131,112,86,80,232,201,29,223,2,192,213,209,203,238,149,147,143,236,175,214,94,57,254,47,177,46,234,219,114,106,254,75,160,159,132,90,167,118,127,145,66,220,76,115,168,41,242,133,150,121,15,23,93,186,18,73,60,132,11,62,177,7,243,119,172,159,207,78,143,208,21,173,130,12,85,219,170,239,65,73,214,54,98,251,135,95,105,24,185,140,12,13,246,100,61,36,242,156,56,225,14,103,36,13,228,126,81,36,163,248,246,228,229,175,248,211,198,242,152,180,169,98,74,130,216,161,109,178,202,72,168,242,227,125,106,165,9,217,41,209,166,156,6,112,4,111,98,212,96,31,11,140,72,122,201,194,158,232,248,154,220,54,31,236,76,65,130,72,100,117,12,129,41,3,13,87,230,134,1,255,46,181,53,34,48,27,30,184,178,208,156,154,53,212,133,23,222,243,12,80,249,247,25,196,222,235,139,215,55,202,31,127,230,73,52,136,25,174,17,222,244,182,164,88,107,65,227,159,117,181,152,89,222,87,0,181,46,214,64,245,159,28,213,0,123,170,52,147,161,97,176,121,208,45,181,209,211,101,245,21,180,91,22,161,195,241,238,142,92,150,84,247,33,102,236,233,159,53,224,51,232,158,233,215,127,67,37,38,134,143,238,112,77,48,104,70,114,239,48,27,247,61,92,118,24,29,30,252,103,105,161,19,171,107,17,147,242,120,106,9,234,188,25,252,247,174,0,45,77,19,204,73,121,25,209,243,72,196,191,214,117,138,138,44,158,215,6,96,156,165,236,109,59,211,37,230,62,1,231,39,116,64,83,216,94,250,201,188,88,227,134,63,72,100,14,139,171,160,105,161,107,45,74,83];
% psduBits = reshape(de2bi(decimalBytes,8)', [], 1);
% NhtCfg.PSDULength = length(decimalBytes);
% % Concatenate packet PSDUs for waveform generation
% data_psdu = psduBits;

% for i=1:numPackets
%     % Get MSDU lengths to create a random payload for forming an A-MPDU of
%     % 4048 octets (pre-EOF padding)
%     %msduLengths = wlanMSDULengths(10, macCfg, vhtCfg);
%     msdu =repmat(121,10,1);
%    
% 
%     % Generate a PSDU containing A-MPDU with EOF delimiters and padding
%     [psdu, apepLength] = wlanMACFrame(msdu, macCfg);
% %     k= 10;
% %     Seed = char('A0');
% %     psdu(1,:) = Seed;
%     %psdu =char(psdu(1:k,:),Seed,psdu(k+1:end,:));
%     % Convert the PSDU in hexadecimal format to bits
%     decimalBytes = hex2dec(psdu);
%     psduBits = reshape(de2bi(decimalBytes, bitsPerByte)', [], 1);  
%     NhtCfg.PSDULength = apepLength;
%     % Set the APEP length in the VHT configuration
%     %vhtCfg.APEPLength = apepLength;
% 
%     % Concatenate packet PSDUs for waveform generation
%     data_trans = [data_trans; psduBits]; %#ok<AGROW>
% end
% 
% % Create MSDUs with the obtained lengths
% %QoS_data = repmat('10',1,50);
% % Generate a PSDU containing A-MPDU with EOF delimiters and padding
% [psdu, mpduLength] = wlanMACFrame('000012002e4800001018a4154001cc070000080030000016ea1234560016ea123456ffffffffffff00007979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797958b41852',macCfg);
% %htCfg.PSDULength = mpduLength;

%  Convert the PSDU in hexadecimal format to bits
PSDUBytes = hex2dec(psdu);
%psduBits = reshape(de2bi(PSDUBytes,8)', [], 1);
psduBits = randi([0 1], 600, 1);

% htCfg.PSDULength = length(decimalBytes);

% % Concatenate packet PSDUs for waveform generation
% data_psdu = psduBits;
[tx_sig,Target_interleavedData,Target_encodedData,Target_scrambData] = wlanNonHTData_local(psduBits,NhtCfg);
%[tx_sig_emulate,psdu_modulated_bits_emu,encodedTxData,scrambTxData] = wlanNonHTData_local(psduBits,NhtCfg);

txWaveform = wlanWaveformGenerator(psduBits,NhtCfg, ...
    'NumPackets',numPackets,'IdleTime',idleTime, ...
    'ScramblerInitialization',scrambler,'WindowTransitionTime',1.0e-07);% Generate Time domain waveform

L_stf = wlanLSTF(NhtCfg);
L_ltf = wlanLLTF(NhtCfg);
[L_sig,sigbits] = wlanLSIG(NhtCfg);

L_stf_f = [zeros(6,1); wlan.internal.lstfSequence; zeros(5,1)]; 
%swap bit 53,54 to emulate the pilot at subcarrier 54, for following
%decoding use this sequence for equalization.
L_ltf_f = [0;0;0;0;0;0;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;0;1;-1;-1;1;1;-1;1;-1;1;-1;-1;-1;-1;-1;1;1;-1;-1;1;1;-1;-1;1;1;1;1;0;0;0;0;0];

cfgOFDM = wlan.internal.wlanGetOFDMConfig('CBW20', 'Long', 'Legacy');

CPLen  = cfgOFDM.CyclicPrefixLength;



LTF_MOD = wlan.internal.wlanOFDMModulate(L_ltf_f, CPLen);

% Scale and output
LTF_MOD_T = LTF_MOD * cfgOFDM.NormalizationFactor;


%% HT Target signal stucture
cfgHT = wlanHTConfig('ChannelBandwidth','CBW40','NumTransmitAntennas',2,'NumSpaceTimeStreams', 2,'MCS',15);

lstf_HT = wlanLSTF(cfgHT);
lltf_HT = wlanLLTF(cfgHT);
lsig_HT = wlanLSIG(cfgHT);
HTstf_HT = wlanHTSTF(cfgHT);
HTltf_HT = wlanHTLTF(cfgHT);
HTsig_HT = wlanHTSIG(cfgHT);


Frame_ind = wlanFieldIndices(cfgHT);

sim_bits = randi([0 1],1000*6,1);
sim_constellation = unique(wlanConstellationMap(sim_bits,6));
% 
% for i =1:1000
%     x_ind = randi([1,4],1);
%     y_ind = randi([1,4],1);
%     value = [0.7715 0.1543 -0.4629 -1.0801 -0.7715 -0.1543 0.4629 1.0801];
%     constellation(i) = complex(value(x_ind) ,value(y_ind));
% 
% end
%     
% 
sim_bits_4 = randi([0 1],1000*4,1);
sim_constellation_4 = wlanConstellationMap(sim_bits_4,4);
% figure(31)
% scatter(real(sim_constellation_4),imag(sim_constellation_4));
% hold on
% scatter(real(sim_constellation),imag(sim_constellation));


%% Zigbee 
% EcNo = -25:2.5:17.5;                % Ec/No range of BER curves
% spc = 4;                            % samples per chip
% msgLen = 8*10;                     % length in bits
% message = randi([0 1], msgLen, 1);  % transmitted message
% Zigbee_waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '2450 MHz');
% figure(4)
% plot(abs(Zigbee_waveform));

%% Payload Generation
% The non-shifted data index is the index from -20M to +20M 
SC_IND_DATA_40M = [7;8;9;10;11;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34;35;36;37;38;39;41;42;43;44;45;46;47;48;49;50;51;52;53;55;56;57;58;59;60;61;62;63;67;68;69;70;71;72;73;74;75;77;78;79;80;81;82;83;84;85;86;87;88;89;91;92;93;94;95;96;97;98;99;100;101;102;103;104;105;106;107;108;109;110;111;112;113;114;115;116;117;119;120;121;122;123];
SC_IND_PILOTS_N_40M = [12;40;54;76;90;118];

SC_IND_DATA_N = [5;6;7;8;9;10;11;13;14;15;16;17;18;19;20;21;22;23;24;25;27;28;29;30;31;32;34;35;36;37;38;39;41;42;43;44;45;46;47;48;49;50;51;52;53;55;56;57;58;59;60;61]; %802.11n data subcarrier index
SC_IND_PILOTS_N = [12;26;40;54]; %802.11g pilot subcarrier index

SC_IND_DATA_G =  [7;8;9;10;11;13;14;15;16;17;18;19;20;21;22;23;24;25;27;28;29;30;31;32;34;35;36;37;38;39;41;42;43;44;45;46;47;48;49;50;51;52;53;55;56;57;58;59]; %802.11g data subcarrier index
SC_IND_PILOTS =  [12;26;40;54]; %802.11g pilot subcarrier index

SC_IND_DATA_G_shift = [2:7 9:21 23:27 39:43 45:57 59:64]; %802.11g data subcarrier index
SC_IND_PILOTS_shift = [8 22 44 58];

SC_IND_DATA_40M_shift = [3;4;5;6;7;8;9;10;11;13;14;15;16;17;18;19;20;21;22;23;24;25;27;28;29;30;31;32;33;34;35;36;37;38;39;40;41;42;43;44;45;46;47;48;49;50;51;52;53;55;56;57;58;59;71;72;73;74;75;77;78;79;80;81;82;83;84;85;86;87;88;89;90;91;92;93;94;95;96;97;98;99;100;101;102;103;105;106;107;108;109;110;111;112;113;114;115;116;117;119;120;121;122;123;124;125;126;127];
SC_IND_PILOTS_40M_shift = [12;26;54;76;104;118];

G_to_plot_shift = zeros(128,1);
N_to_plot_shift = zeros(128,1);
% N_shift  = zeros(128,1);
% N_shift(SC_IND_DATA_N_40M) = 10;
% N_shift(SC_IND_PILOTS_N_40M) = 3;
G_to_plot_shift(SC_IND_DATA_G+3) = 10;
N_to_plot_shift(SC_IND_DATA_40M) = 5;




% G_to_plot_noshift = zeros(128,1);
% N_to_plot_noshift = zeros(128,1);
% 
% G_to_plot_noshift(SC_IND_DATA_G) = 10;
% N_to_plot_noshift(SC_IND_DATA_40M) = 5;

% figure(2)
% bar(1:128,G_to_plot_noshift);
% hold on 
% bar(1:128,N_to_plot_noshift);
% xlabel('F(Mhz)');
% title('Baseband signal (center at 0Mhz)');



ht_stf = zeros(1,64);
ht_stf(1:27) = [0 0 0 0 -1-1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 1+1i 0 0 0 1+1i 0 0 0 1+1i 0 0];
ht_stf(39:64) = [0 0 1+1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 -1-1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0];
sts_t = ifft(sqrt(13/6).*ht_stf, 64);
sts_t = sts_t(1:16);

l_ltf = [0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1];
l_ltf_t = ifft(l_ltf, 64);

ht_ltf = [0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 -1 -1 0 0 0 0 0 0 0 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1];
ht_lts_t = ifft(ht_ltf, 64);

ht_lts_shift = [ht_lts_t(20:35) ht_lts_t(1:48)];
tx_cp = ht_lts_t(:,(end-16+1 : end));

node_number =randi([1,4],1,64);%[(1+0j),(-1+0j)];
custom_constellation = [0.707+0.707i,0.707-0.707i,-0.707+0.707i,-0.707-0.707i];%,0.65+0i,0+0.65i,0-0.65i,-0.65-0i];
custom_preamble = zeros(64,1);
for temp_custom  = 2:27
    custom_preamble(temp_custom,1) = custom_constellation(node_number(temp_custom));
end

for temp_custom_2  = 39:64
    custom_preamble(temp_custom_2,1) = custom_constellation(node_number(temp_custom_2));
end
custom_preamble_time = fft(custom_preamble,64);
custom_preamble_time_cp = [custom_preamble_time(49:end,1);custom_preamble_time];
% x = [1;0;0;0;1;1;0;1];%randi([0 1],numSym*gfskMod.SamplesPerSymbol,1);
% y = gfskMod(x);


% points_notused = find(abs(target_signal)>12);
% target_signal(points_notused)= [];
goldseq = comm.GoldSequence('FirstPolynomial','x^5+x^2+1',...
    'SecondPolynomial','x^5+x^4+x^3+x^2+1',...
    'FirstInitialConditions',[0 0 0 0 1],...
    'SecondInitialConditions',[0 0 0 0 1],...
    'Index',4,'SamplesPerFrame',64);
Gold_Sequence = goldseq();
Gold_one = find(Gold_Sequence == 1);
Gold_zero = find(Gold_Sequence == 0);
Gold_Sequence(Gold_one)=-1;
Gold_Sequence(Gold_zero)=1;
Gold_t = ifft(ifftshift(Gold_Sequence),64);
Gold_t_cyc = [Gold_t(49:end);Gold_t];

L_LTF_seg = L_ltf(33:96);
L_LTF_target_1 = circshift(L_LTF_seg,16);
L_LTF_emulated = [L_LTF_target_1(49:64);L_LTF_target_1;L_LTF_seg(49:64);L_LTF_seg];% [LLTF(49:64);LLTF(1:48)]
L_LTF_doubled = [L_LTF_target_1(49:64);L_LTF_seg;L_LTF_target_1(49:64);L_LTF_seg];
%target_signal = [L_stf;L_LTF_emulated;L_sig;Gold_t_cyc;Gold_t_cyc;Gold_t_cyc;Gold_t_cyc;tx_sig]; %Gold_Sequence(SC_IND_DATA);
signal_various_symbolduration = [zeros(16,1);tx_sig(1:40,1);zeros(24,1)];
tic
target_signal = [signal_various_symbolduration;signal_various_symbolduration;signal_various_symbolduration;signal_various_symbolduration;L_LTF_doubled;L_sig;custom_preamble_time_cp;custom_preamble_time_cp;tx_sig]; %Gold_Sequence(SC_IND_DATA);
%target_signal = upsample(target_signal,2);
%[L_LTF_emulated,L_ltf];
% target_signal_interp = interp(target_signal,2);%zeros(2*length(target_signal),1);
% %target_signal_interp(1:2:end) = target_signal;
% 
% signal_mat = reshape(target_signal_interp,160,length(target_signal_interp)/160);
% signal_mat_nocyc = signal_mat(32:end,:);% Remove cylic preflix
% fft_mat = fftshift(fft(signal_mat_nocyc,128),1);
% fft_mat_20M = fft_mat(33:96,:);
% target_signal_freq = reshape(fft_mat_20M(SC_IND_DATA_G,:),[],1);%sig_freq; y_spect/max(y_spect);Get the target signal in frequency domain 
% target_signal_subcar = target_signal_freq/max(abs(target_signal_freq)); % Get target constellation points



%fs = 40000000;
%t = 0:1/fs:0.000044-1/fs;
%target_signal_centershift = target_signal.*exp(2*pi*10000000*i*t)';
%This is the subcarrier index for shifting the subcarrier to the left one
%This corresponding to the target signal subcarrier index before fftshift, the pilot index in 40Mhz is 37,51,74
SC_IND_DATA_subshift = [33,34,35,36,38,39,40,41,42,43,44,45,46,47,48,49,50,52,53,54,55,56,57,58,59,60,71,72,73,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96];


Target_SC_IND = SC_IND_DATA_subshift-32;   %sort([SC_IND_DATA_G;26;33;60;61;62;63;64]);
%SC_IND_emulated = [3:11 13:25 27:29 101:103 105:117 119:127];% This mapping corresponding to data payload in the middle
%SC_IND_emulated = [34:53 55:59 71:75 77:96];% This mapping corresponding
%to data payload at the both end

SC_IND_emulated = [74:75 77:103 105:117 119:127]; % This is the 40Mhz subcarrier index for mapping mappings the first 20Mhz the shifted subcarrier number. Here we uses 2nd half of 40Mhz, the index is 71+N

Target_t_mat_20M = reshape(target_signal,80,length(target_signal)/80);
Target_t_nocyc_20M = Target_t_mat_20M(17:end,:);% Remove cylic preflix
Target_f_mat_20M = fft(Target_t_nocyc_20M,64);
Pulse_f = [0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.782294604415977 - 0.324037034920393i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.800000000000000 + 0.800000000000000i;0.800000000000000 + 0.800000000000000i;0.800000000000000 + 0.800000000000000i;0.800000000000000 + 0.800000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.782294604415977 - 0.324037034920393i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.782294604415977 + 0.324037034920393i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i;0.00000000000000 + 0.00000000000000i];
%zeros(64,1);
%Pulse_f(24:27) = (0.8+0.8i);

Target_f_mat_20M = [Pulse_f,Pulse_f,Pulse_f,Target_f_mat_20M];
Target_f_mat_40M = zeros(128,length(Target_f_mat_20M(1,:)));

Target_f_mat_40M(SC_IND_emulated,:) = Target_f_mat_20M(Target_SC_IND,:); 

Target_f_mat_40M_shift = fftshift(Target_f_mat_40M,1); % find the baseband signal for emulation
SC_IND_emulated_shifted = find(Target_f_mat_40M_shift(:,length(Target_f_mat_40M_shift(1,:))) ~= 0);


%target_signal_40M = upsample(target_signal,2);
% target_signal_40M = zeros(1, 2*numel(target_signal));
% target_signal_40M(1:2:end) = target_signal;
% 
% Target_t_mat_40M = reshape(target_signal_40M,160,length(target_signal_40M)/160);
% Target_t_nocyc_40M = Target_t_mat_40M(33:end,:);% Remove cylic preflix
% Target_f_mat_40M = circshift(fft(Target_t_nocyc_40M,128),32,1);

target_signal_freq = fftshift(Target_f_mat_40M_shift(SC_IND_emulated_shifted,:),1);%sig_freq; y_spect/max(y_spect);Get the target signal in frequency domain 
Target_f_mat_20M_normalize = target_signal_freq./max(abs(target_signal_freq));
%Target_f_mat_20M_normalize(:,6:7) = Target_f_mat_20M_normalize(:,6:7);
target_signal_subcar = reshape(Target_f_mat_20M_normalize,[],1); % Get target constellation points
computation_time1 = toc;
% fft_mat_40Mhz = zeros(128,length(Target_f_mat_20M(1,:))); +/- 20Mhz emulation
% fft_mat_40Mhz(1:64,:) = Target_f_mat_40M(1:64,:);
% Time_40Mhz = ifft(ifftshift(fft_mat_40Mhz,1),128);


%[fft_mat_20M_downsample(:,length(Target_f_mat_40M_shift(1,:))) Target_f_mat_20M(:,length(Target_f_mat_40M_shift(1,:)))];
% 
% figure(1)
% bar(1:128,G_to_plot_shift);
% hold on 
% bar(1:128,N_to_plot_shift);
% xlabel('Subcarrier index');
% title('Target signal subcarrier mapping');



% figure(2)
% plot(real(Target_t_nocyc_20M(:,length(Target_f_mat_40M_shift(1,:)))))
% hold on
% plot(real(Time_downsample_noncyc(:,length(Target_f_mat_40M_shift(1,:)))),'r')
% 
% figure(3)
% plot(imag(Target_t_nocyc_20M(:,length(Target_f_mat_40M_shift(1,:)))))
% hold on
% plot(imag(Time_downsample_noncyc(:,length(Target_f_mat_40M_shift(1,:)))),'r')


n = 2;
Numbits = 6;

ltf_tx1 = zeros(100,128);
ltf_tx2 = zeros(100,128);
ltf_tx2_shift = zeros(100,128);
% 
% for subcarrier_index = 1:128 %WiFi has shifts 45 degress with 2Tx 22.5 degress with 3Txs, total 128 subcarriers at 40Mhz
%     temp_sig = 1;
%     for Tx_dec1 = 1:64
%         for Tx_dec2 = 1:64    
%             tx_bit1 = de2bi(Tx_dec1-1,Numbits);
%             tx_bit2 = de2bi(Tx_dec2-1,Numbits);
%             tx_bit3 = de2bi(Tx_dec2-1,Numbits);
% 
%             txSig_1 = wlanConstellationMap(tx_bit1',Numbits).*carrier_rotations(subcarrier_index,1);
%             txSig_2 = wlanConstellationMap(tx_bit2',Numbits).*carrier_rotations(subcarrier_index,1);               
%             txSig_3 = wlanConstellationMap(tx_bit2',Numbits).*carrier_rotations(subcarrier_index,1);               
% 
%            
%             constellation_shift2 = txSig_2 .* phaseShift3(subcarrier_index,:,2); 
%             constellation_shift3 = txSig_3 .* phaseShift3(subcarrier_index,:,3); 
%             
%             TxSig2_shift(Tx_dec2,subcarrier_index) = constellation_shift2;
%             TxSig3_shift(Tx_dec2,subcarrier_index) = constellation_shift3;
% 
%             difference_txsig = abs(txSig_1 - constellation_shift2);      % Compute the minimal difference between two constellations
%             BPSK_txsig1_C1 = abs(txSig_1 - (1+0i));                     % Minimal distance at BPSK(1+0i) constellation at Tx1
%             BPSK_txsig2_C1 = abs(constellation_shift2 -(1+0i));          % Minimal distance at BPSK(1+0i) constellation at Tx2
% %             switch MOD_ORDER
% %                 case 1
% %                     if (BPSK_txsig1_C2 < 0.1 && BPSK_txsig1_C1<0.2)
% %                         ltf_tx1(temp_sig,time_slots)  = txSig_1;
% %                         ltf_tx2(temp_sig,time_slots)  = txSig_2;
% %                         ltf_tx2_shift(temp_sig,time_slots)  = constellation_shift;
% %                         temp_sig = temp_sig + 1;
% %                     end   
% %                     
% %             end
%             rxSig = (txSig_1 + constellation_shift2)/2; % Convert the combined constellation to the same plane as the target for mapping
%             
%           
%             C_map(64*(Tx_dec1-1)+Tx_dec2,subcarrier_index) = rxSig;
%         end        
%         TxSig1_shift(Tx_dec1,subcarrier_index) = txSig_1;
%     end
% end
% 


% figure(4)
% scatter(real(TxSig2_shift(:,2)),imag(TxSig2_shift(:,2)));
% hold on
% scatter(real(sim_constellation_4),imag(sim_constellation_4));
% hold on
% scatter(real(sim_constellation),imag(sim_constellation));
% figure(5)
% scatter(real(TxSig3_shift(:,2)),imag(TxSig3_shift(:,2)));

%%
if n == 2
    
    
    tx_1_temp = zeros(300,length(target_signal_subcar)); 
    tx_2_temp = zeros(300,length(target_signal_subcar)); 

 
    num_sym = length(target_signal_subcar)/length(SC_IND_emulated_shifted);
%     C_map_64 = repmat(C_map,1,4);
    C_map_data = C_map(:,SC_IND_emulated_shifted);
    Tx1_const = TxSig1_shift(:,SC_IND_emulated_shifted);
    Tx2_const = TxSig2_shift(:,SC_IND_emulated_shifted);
    C_map_target = repmat(C_map_data,1,num_sym);
    Tx1_const_target = repmat(Tx1_const,1,num_sym);
    Tx2_const_target = repmat(Tx2_const,1,num_sym);


    trellis = poly2trellis(7, [133 171]);
    nextStates = trellis.nextStates;
    [numStates,numIn] = size(nextStates); 
    trellis_map = NaN*ones(3*numIn,numStates);
    trellis_map(1:3:end,:) = ones(numIn,1)*[0:numStates-1];
    trellis_map(2:3:end,:) = nextStates';
    trellis_map(3:3:end,:) = oct2dec(trellis.outputs');
    
    tx_1 = zeros(5,length(target_signal_subcar)); 
    tx_2 = zeros(5,length(target_signal_subcar)); 
    idx = zeros(4096, length(target_signal_subcar));

    for PHY_payload = 1:64    
        PHY_payload_bit = de2bi(PHY_payload-1,Numbits); 
        PHY_symbol(PHY_payload) = wlanConstellationMap(PHY_payload_bit',Numbits);
    end
    tic
    Tx_num = 3;
    for temp_tx1 = 1:length(target_signal_subcar)
        chosen_idx = find(abs(PHY_symbol - target_signal_subcar(temp_tx1))<0.625); 
        available_constellation = PHY_symbol(chosen_idx);
        if Tx_num == 2
            [M,constellation_index] = min(PHY_symbol(chosen_idx) - target_signal_subcar(temp_tx1));
            first_choice = available_constellation(constellation_index);
            first_optimal = 2*target_signal_subcar(temp_tx1) -first_choice;
            [M2,constellation_index2] = min(PHY_symbol(chosen_idx) - first_optimal);    
            second_choice = available_constellation(constellation_index2);
            second_mix = second_choice + first_choice;
        end
        if Tx_num == 3
            [M,constellation_index] = min(PHY_symbol(chosen_idx) - target_signal_subcar(temp_tx1));
            first_choice = available_constellation(constellation_index);
            first_optimal = target_signal_subcar(temp_tx1) -(first_choice- target_signal_subcar(temp_tx1));
            [M2,constellation_index2] = min(PHY_symbol(chosen_idx) - first_optimal);    
            second_choice = available_constellation(constellation_index2);
            second_mix = second_choice + first_choice;
            second_optimal = 2*target_signal_subcar(temp_tx1) - second_mix;
            [M3,constellation_index3] = min(PHY_symbol(chosen_idx) - second_optimal);    
            third_choice = available_constellation(constellation_index3);
            third_mix = second_choice + first_choice + third_choice;
        end
    end
    new_method_time = toc;
    
    for temp_tx1 = 1:length(target_signal_subcar)
           
        [difference_table, idx(:,temp_tx1)] = sort(abs(C_map_target(:,temp_tx1) - target_signal_subcar(temp_tx1))); 
    end
    tic 
    for temp_tx1 = 1:length(target_signal_subcar)      
        % 0.15 is picked because the mininmal distance without BER is 0.3, we divided into half =0.15
        tx_2_temp(1:100,temp_tx1) = mod(idx(1:100,temp_tx1)-1,64);  
        tx_1_temp(1:100,temp_tx1) = floor((idx(1:100,temp_tx1)-1)/64);    
        tx_1_constellation = Tx1_const_target(tx_1_temp(1:100,temp_tx1)+1,temp_tx1);
        tx_2_constellation = Tx2_const_target(tx_2_temp(1:100,temp_tx1)+1,temp_tx1);        
        chosen_idx = find(abs(tx_1_constellation - tx_2_constellation)<0.65);        
        tx_1(1,temp_tx1) = tx_1_temp(chosen_idx(1),temp_tx1);
        tx_2(1,temp_tx1) = tx_2_temp(chosen_idx(1),temp_tx1);        
       
    end
    computational_matching = toc;
%     tx_1_binary = reshape(de2bi(tx_1(2,1:52),Numbits)',[],1);
%     tx_2_binary = reshape(de2bi(tx_2(2,1:52),Numbits)',[],1);
% 
%     Constellation_tx1 = wlanConstellationMap(tx_1_binary,Numbits);
%     Constellation_tx2 = wlanConstellationMap(tx_2_binary,Numbits).*phaseShift(SC_IND_DATA,:,2);     
% 
%     combined_constellation = (Constellation_tx1+Constellation_tx2)/2; 
%     distance_table_tx_seg = distance_table_tx(1,1:648)'; % Extract first symbol = 52*6 = 312 bits

%     

%     
    
    y_complete =[];
    tx_1_bits_complete = [];
    tx_2_bits_complete = [];
    tx_AT1_complete = [];
    tx_AT2_complete = [];
    %Controlled_bits = sort([1:6:6*48 2:6:6*48 5:6:6*48 6:6:6*48]);
    tx_1_mat = zeros(128,num_sym) + 99;
    tx_2_mat = zeros(128,num_sym) + 99;
    
    
    %encoder_output = zeros(5,648*5/6*2*num_sym*2);
    %tx_deinterleave = zeros(5,648*2*num_sym);
    %bit_deparser = zeros(5,648*2*num_sym);
    tic
    search_row = 1;
    %for         
    tx_1_bits_mat = de2bi(tx_1(search_row,:),Numbits);
    tx_2_bits_mat = de2bi(tx_2(search_row,:),Numbits);         
    tx_1_bits = reshape(tx_1_bits_mat',length(SC_IND_emulated_shifted)*6,[]);
    tx_2_bits = reshape(tx_2_bits_mat',length(SC_IND_emulated_shifted)*6,[]);        
    %tx_1_bits_verify(:,search_row) = reshape(tx_1_bits_mat',[],1);
    %tx_2_bits_verify(:,search_row) = reshape(tx_2_bits_mat',[],1);
    tx_1_bits_dummy = zeros(6*57,num_sym)+5;        
     %tx_2_bits_dummy = zeros(6*58,num_sym)+5;

     %This is used to emulate subcarrier 1:32 97:128 
     %tx_1_array = reshape([tx_1_bits(1:150,:);tx_1_bits_dummy;tx_1_bits(151:300,:)],[],1);
     %tx_2_array = reshape([tx_2_bits(1:150,:);tx_1_bits_dummy;tx_2_bits(151:300,:)],[],1);

    %This is used to emulate subcarrier 33:96
    %tx_1_array = reshape([tx_1_bits_dummy(1:3*58,:);tx_1_bits;tx_1_bits_dummy(3*58+1:end,:)],[],1);
    %tx_2_array = reshape([tx_1_bits_dummy(1:3*58,:);tx_2_bits;tx_1_bits_dummy(3*58+1:end,:)],[],1);

    %This is used to emulate subcarrier 33:96 corresponding to the
    %71:127 subcarrier index shifted bits are 1??N*6
    tx_1_array = reshape([tx_1_bits_dummy(1:18,:);tx_1_bits;tx_1_bits_dummy(19:end,:);],[],1);
    tx_2_array = reshape([tx_1_bits_dummy(1:18,:);tx_2_bits;tx_1_bits_dummy(19:end,:);],[],1);
    %tx_1_array = reshape([tx_1_bits_dummy(1:18,:);tx_1_bits(1:150,:);tx_1_bits_dummy(19:24,:);tx_1_bits(151:300,:);tx_1_bits_dummy(25:end,:);],[],1);
    %tx_2_array = reshape([tx_1_bits_dummy(1:18,:);tx_2_bits(1:150,:);tx_1_bits_dummy(19:24,:);tx_2_bits(151:300,:);tx_1_bits_dummy(25:end,:);],[],1);

    tx_bits_AT1 = [tx_1_array tx_2_array];
    tic    
    
    
    outputs_mat1_cell = cell(64,1);
    encoder_input_mat_cell = cell(64,1);
    for start_node = 0:63
        [outputs_mat1,encoder_input_mat] = weight_bit(start_node,trellis_map);
        outputs_mat1_cell{start_node+1,1} = outputs_mat1;        
        encoder_input_mat_cell{start_node+1,1} = encoder_input_mat;     
    end
    %tx_deinterleave = wlanBCCDeinterleave(tx_bits_AT1,'VHT',108*6,'CBW40'); 
    outputs_mat1 = outputs_mat1_cell{1,1};
    encoder_input_mat = encoder_input_mat_cell{1,1};    
    unnecessary_time = toc; 
    
    i = 2;
    
    tic
    data = reshape(tx_bits_AT1,648,num_sym,2,1);        
    yIn4D = coder.nullcopy(zeros(size(data)));
    for nssIdx = 1:size(data,3)
        yIn4D(thirdPIdx(secondPIdx(pRMat(:,nssIdx))),:,nssIdx,:) = data(:,:,nssIdx,:);
    end
    tx_deinterleave = reshape(yIn4D,648*num_sym,2,1);

    tempX = reshape(tx_deinterleave,3,1,[],2); % [blkSize, numES, numBlock*numSym, numSS]
    tempX = permute(tempX,[1 4 3 2]); % [blkSize, numSS, numBlock*numSym, numES]
    bit_deparser = reshape(tempX,[],1); % [(numCBPS*numSym/numES), numES]
    encoder_output = depuncture(bit_deparser); 
      
    %segment the sequence into 20bits small sequence
    encoder_inputSeg = encoder_output(:,1:10);
    bits_fordecode = find(encoder_inputSeg(1,:) ~= 5);            
    aa = bi2de(outputs_mat1(:,bits_fordecode));           
    bb = bi2de(encoder_inputSeg(:,bits_fordecode));   
    for lowest_length = 1:24
        matched_location = find(aa == bb(lowest_length,1));
        if isempty(matched_location) == 0
            illegal_start = 2;
            search_row = lowest_length;
            break
        end        
    end
    encoder_input(1:5,1) = encoder_input_mat(matched_location(1,1),:);
    output_seq(1:10,1) = outputs_mat1(matched_location(1,1),1:10);
    start_node = outputs_mat1(matched_location(1,1),11);   
    previous_outputs_mat1 = outputs_mat1;
    previous_matched_location = matched_location(:,1);
    previous_encoder_input_mat = encoder_input_mat;  
     
    while (1< i && i <= length(encoder_output)/10) % find the corresponding MAC payload         
       outputs_mat1 = outputs_mat1_cell{start_node+1,1};         
       encoder_inputSeg = encoder_output(search_row,(i-1)*10+1:(i-1)*10+10); 
       bits_fordecode = find(encoder_inputSeg(1,:) ~= 5);          
       matched_location = find(sum(xor(outputs_mat1(:,bits_fordecode),encoder_inputSeg(:,bits_fordecode)),2)== 0);%find(aa == bb);
       if isempty(matched_location)
           i = i-1;
           start_node = previous_outputs_mat1(previous_matched_location(illegal_start,1),11);
           encoder_input((i-1)*5+1:i*5,1) = previous_encoder_input_mat(previous_matched_location(illegal_start,1),:);
           output_seq((i-1)*10+1:i*10,1) = previous_outputs_mat1(previous_matched_location(illegal_start,1),1:10);
           illegal_start = illegal_start+1;              
       else               
           start_node = outputs_mat1(matched_location(1,1),11);           
           previous_outputs_mat1 = outputs_mat1;
           previous_matched_location = matched_location(:,1);
           previous_encoder_input_mat = encoder_input_mat;
           encoder_input((i-1)*5+1:i*5,1) = encoder_input_mat(matched_location(1,1),:);
           output_seq((i-1)*10+1:i*10,1) = outputs_mat1(matched_location(1,1),1:10);               
           illegal_start = 2;               
       end   
       i=i+1;        
    end   
end 
for scrambler_com = 1:127
    scrambled_sevicesbits = wlanScramble(serviceBits,scrambler_com); % Compute scrambled service bits
    scrambled_driverbits = wlanScramble(zeros(288,1),scrambler_com); % Compute scrambled driver inserted bits 36*8   
    scrambled_sequence_with_Encoder = [scrambled_sevicesbits;scrambled_driverbits;zeros(776,1);encoder_input]; % Combined scrambled bits together
    MAC_combined = wlanScramble(scrambled_sequence_with_Encoder,scrambler_com); % From scrambled bits -> MAC PAYLOAD 
    MACData_input = MAC_combined(17+288:end,1);
end
computation_time = toc;
%% SCRAMBLER appended

descrambled = wlanScramble(encoder_input,scrambler); %% Scrambled Emulated signal 
appended_bits = zeros(1064,1); %% Append bits at the end
serviceBits = zeros(16,1,'int8');





for scrambler_com = 1:9
    scrambled_sevicesbits = wlanScramble(serviceBits,scrambler_com); % Compute scrambled service bits
    scrambled_driverbits = wlanScramble(randi([0 1],288,1),scrambler_com); % Compute scrambled driver inserted bits 36*8
    scrambled_sequence_with_Encoder = [scrambled_sevicesbits;scrambled_driverbits;randi([0 1],776,1);encoder_input]; % Combined scrambled bits together
    MAC_combined = wlanScramble(scrambled_sequence_with_Encoder,scrambler_com); % From scrambled bits -> MAC PAYLOAD 
    MACData_input = MAC_combined(17+288:end,1);
    %MACData_for_verifications=[randi([0 1],288,1);MACData_input];
    %[Emulated_signal,scrambData,encodedData,interleavedData,streamParsedData,mappedData,packedData,rotatedData,dataCycShift,dataSpMapped]= wlanHTData_local(MACData_for_verifications,cfgHT,scrambler_com);
    %DataSpMapped_sum_veri = sum(dataSpMapped,3)/2;    
    MAC_payload_mat = reshape(MACData_input,8,[]);
    MAC_payload_hex = char(binaryVectorToHex(double(MAC_payload_mat')));
    MAC_payload_bit = num2str(fliplr(MAC_payload_mat'),'%-1d'); 
    fid = fopen(['MAC_Payload','00',int2str(scrambler_com),'.txt'],'wt');%('MAC_Payload.txt','wt')
    %fid_hex = fopen(['MAC_Payload_hex','00',int2str(scrambler_com),'.txt'],'wt');%('MAC_Payload.txt','wt')
    for payload_ind = 1:length(MAC_payload_bit)
        fprintf(fid,'%s\n',MAC_payload_bit(payload_ind,:));      % # \n Change row
       % fprintf(fid_hex,'%s\n',MAC_payload_hex(payload_ind,:));      % # \n Change row
    end
    fclose(fid);
end

for scrambler_com = 10:99
    scrambled_sevicesbits = wlanScramble(serviceBits,scrambler_com); % Compute scrambled service bits
    scrambled_driverbits = wlanScramble(randi([0 1],288,1),scrambler_com); % Compute scrambled driver inserted bits 36*8
    scrambled_sequence_with_Encoder = [scrambled_sevicesbits;scrambled_driverbits;randi([0 1],776,1);encoder_input]; % Combined scrambled bits together
    MAC_combined = wlanScramble(scrambled_sequence_with_Encoder,scrambler_com); % From scrambled bits -> MAC PAYLOAD 
    MACData_input = MAC_combined(17 + 288:end,1);
%     MACData_for_verifications=[randi([0 1],288,1);MACData_input];
%     [Emulated_signal,scrambData,encodedData,interleavedData,streamParsedData,mappedData,packedData,rotatedData,dataCycShift,dataSpMapped]= wlanHTData_local(MACData_for_verifications,cfgHT,scrambler_com);
%     DataSpMapped_sum_veri = sum(dataSpMapped,3)/2;
% %     
    
    MAC_payload_mat = reshape(MACData_input,8,[]);

    MAC_payload_hex = char(binaryVectorToHex(double(MAC_payload_mat')));
    
    MAC_payload_bit = num2str(fliplr(MAC_payload_mat'),'%-1d');

    fid = fopen(['MAC_Payload','0',int2str(scrambler_com),'.txt'],'wt');%('MAC_Payload.txt','wt')
    %fid_hex = fopen(['MAC_Payload_hex','0',int2str(scrambler_com),'.txt'],'wt');%('MAC_Payload.txt','wt')

    for payload_ind = 1:length(MAC_payload_bit)
        fprintf(fid,'%s\n',MAC_payload_bit(payload_ind,:));      % # \n Change row
      %  fprintf(fid_hex,'%s\n',MAC_payload_hex(payload_ind,:));      % # \n Change row
    end
    fclose(fid);
end

for scrambler_com = 100:127
    scrambled_sevicesbits = wlanScramble(serviceBits,scrambler_com); % Compute scrambled service bits
    scrambled_driverbits = wlanScramble(randi([0 1],288,1),scrambler_com); % Compute scrambled driver inserted bits 36*8
    scrambled_sequence_with_Encoder = [scrambled_sevicesbits;scrambled_driverbits;randi([0 1],776,1);encoder_input]; % Combined scrambled bits together
    MAC_combined = wlanScramble(scrambled_sequence_with_Encoder,scrambler_com); % From scrambled bits -> MAC PAYLOAD 
    MACData_input = MAC_combined(17 + 288:end,1);
%     MACData_for_verifications=[driver_bits;MACData_input];
%     [Emulated_signal,scrambData,encodedData,interleavedData,streamParsedData,mappedData,packedData,rotatedData,dataCycShift,dataSpMapped]= wlanHTData_local(MACData_for_verifications,cfgHT,scrambler_com);
%     DataSpMapped_sum_veri = sum(dataSpMapped,3)/2;
% %     
    
    MAC_payload_mat = reshape(MACData_input,8,[]);

    MAC_payload_hex = char(binaryVectorToHex(double(MAC_payload_mat')));
    
    MAC_payload_bit = num2str(fliplr(MAC_payload_mat'),'%-1d');

    fid = fopen(['MAC_Payload',int2str(scrambler_com),'.txt'],'wt');%('MAC_Payload.txt','wt')
    %fid_hex = fopen(['MAC_Payload_hex',int2str(scrambler_com),'.txt'],'wt');%('MAC_Payload.txt','wt')

    for payload_ind = 1:length(MAC_payload_bit)
        fprintf(fid,'%s\n',MAC_payload_bit(payload_ind,:));      % # \n Change row
   %     fprintf(fid_hex,'%s\n',MAC_payload_hex(payload_ind,:));      % # \n Change row
    end
    fclose(fid);
end
