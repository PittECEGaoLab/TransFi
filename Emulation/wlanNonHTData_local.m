function [y,interleavedData,encodedData,scrambData] = wlanNonHTData_local(PSDU,cfgNonHT,varargin)
%wlanNonHTData Non-HT Data field processing of the PSDU
%
%   Y = wlanNonHTData(PSDU,CFGNONHT) generates the non-HT format Data
%   field time-domain waveform for the input PLCP Service Data Unit (PSDU). 
%
%   Y is the time-domain non-HT Data field signal. It is a complex matrix
%   of size Ns-by-Nt, where Ns represents the number of time-domain samples
%   and Nt represents the number of transmit antennas.
%
%   PSDU is the PHY service data unit input to the PHY. It is a double
%   or int8 typed column vector of length CFGNONHT.PSDULength*8, with each
%   element representing a bit.
%
%   CFGNONHT is the format configuration object of type <a href="matlab:help('wlanNonHTConfig')">wlanNonHTConfig</a> which
%   specifies the parameters for the non-HT format. Only OFDM modulation
%   type is supported.
%
%   Y = wlanNonHTData(...,SCRAMINIT) optionally allows specification of the
%   scrambler initialization, SCRAMINIT for the Data field. When not
%   specified, it defaults to a value of 93. When specified, it can be a
%   double or int8-typed positive scalar less than or equal to 127 or a
%   corresponding double or int8-typed binary 7-by-1 column vector.
%
%   Example:
%   %  Generate the signal for a 20 MHz non-HT OFDM data field for 36 Mbps.
%
%     cfgNonHT = wlanNonHTConfig('MCS', 5);               % Configuration
%     inpPSDU = randi([0 1], cfgNonHT.PSDULength*8,1);    % PSDU in bits
%     y = wlanNonHTData(inpPSDU,cfgNonHT);
%   
%   See also wlanNonHTConfig, wlanLSIG, wlanNonHTDataRecover,
%   wlanWaveformGenerator,  wirelessWaveformGenerator.

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen

narginchk(2,3);
if nargin==2
    scramInitBits = uint8([1; 1; 1; 1; 1; 0; 1]); % Default is 93 
else
    scramInit = varargin{1};
    % Validate scrambler init
    validateattributes(scramInit, {'double', 'int8'}, ...
    {'real', 'integer', 'nonempty'}, mfilename, 'Scrambler initialization');
    if isscalar(scramInit)
        % Check for correct range
        coder.internal.errorIf(any((scramInit<1) | (scramInit>127)), ...
            'wlan:wlanNonHTData:InvalidScramInit');

        scramInitBits = uint8(de2bi(scramInit, 7, 'left-msb')).';
    else
        % Check for non-zero binary vector
        coder.internal.errorIf( ...
        any((scramInit~=0) & (scramInit~=1)) || (numel(scramInit)~=7) || ...
        all(scramInit==0) || (size(scramInit,1)~=7), ...
        'wlan:wlanNonHTData:InvalidScramInit');

        scramInitBits = uint8(scramInit);
    end
end

% Validate inputs
% Validate the format configuration object
validateattributes(cfgNonHT, {'wlanNonHTConfig'}, ...
    {'scalar'}, mfilename, 'format configuration object');
% Only applicable for OFDM and DUP-OFDM modulations
coder.internal.errorIf( ~strcmp(cfgNonHT.Modulation, 'OFDM'), ...
                        'wlan:wlanNonHTData:InvalidModulation');
s = validateConfig(cfgNonHT); 
validateattributes(PSDU, {'double', 'int8'},...
    {'real', 'binary', 'size', [cfgNonHT.PSDULength*8 1]}, ...
    mfilename, 'PSDU input');

chanBW = cfgNonHT.ChannelBandwidth;

% Determine number of symbols and pad length
numSym = s.NumDataSymbols;
numPad = s.NumPadBits;
if (strcmp(chanBW, 'CBW10') || strcmp(chanBW, 'CBW5'))
    numTx = 1;  % override and set to 1 only, for 802.11j/p
else
    numTx  = cfgNonHT.NumTransmitAntennas;
end

mcsTable = wlan.internal.getRateTable(cfgNonHT);
rate     = mcsTable.Rate;
numBPSCS = mcsTable.NBPSCS;
numCBPS  = mcsTable.NCBPS;
Ntail = 6;

cfgOFDM = wlan.internal.wlanGetOFDMConfig(chanBW, 'Long', 'Legacy');
FFTLen = cfgOFDM.FFTLength;
CPLen  = cfgOFDM.CyclicPrefixLength;

%% Generate the data field

% SERVICE, Section 18.3.5.2, all zeros
serviceBits = zeros(16,1,'int8');

% Scramble padded data
%   [service; psdu; tail; pad] processing
paddedData = [serviceBits; PSDU; zeros(Ntail,1); zeros(numPad, 1)];
scrambData = wlanScramble(paddedData, scramInitBits);
% Zero-out the tail bits again for encoding
scrambData(16+length(PSDU) + (1:Ntail)) = zeros(Ntail,1);

% BCC Encoding
encodedData = wlanBCCEncode(scrambData, rate);

% BCC Interleaving
interleavedData = wlanBCCInterleave(encodedData, 'Non-HT', numCBPS);

% Constellation mapping
mappedData = wlanConstellationMap(interleavedData, numBPSCS);

% Non-HT pilots, from IEEE Std 802.11-2012, Eqn 18-22
% Reshape to form OFDM symbols
mappedData = reshape(mappedData, numCBPS/numBPSCS, numSym);

% Non-HT pilots, from IEEE Std 802.11-2012, Eqn 18-22
z = 1; % Offset by 1 to account for HT-SIG pilot symbol
pilotValues = wlan.internal.nonHTPilots(numSym,z);
        
% Data packing with pilot insertion
packedData = complex(zeros(FFTLen, numSym));
packedData(cfgOFDM.DataIndices, :) = mappedData;
packedData(cfgOFDM.PilotIndices, :) = pilotValues;

% Tone rotation and replicate over Tx
pDataMat = repmat(bsxfun(@times,packedData, cfgOFDM.CarrierRotations), 1, 1, numTx);

% Cyclic shift applied per Tx
csh = wlan.internal.getCyclicShiftVal('OFDM', numTx, 20);
dataCycShift = wlan.internal.cyclicShift(pDataMat, csh, FFTLen);

% OFDM modulate
wout = wlan.internal.wlanOFDMModulate(dataCycShift, CPLen);

% Scale and output
y = wout * cfgOFDM.NormalizationFactor / sqrt(numTx);

end
