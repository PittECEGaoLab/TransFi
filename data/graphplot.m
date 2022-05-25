%plots for paper
%Ruirong Chen
%For use to publish papers graphs.
%MobiCOM 2021
%
close all
clear all
bits = de2bi(0:63);
Constellation_64QAM = wlanConstellationMap(bits',6);
Combined_constellation = (Constellation_64QAM +  Constellation_64QAM.')/2;
unique_constellation = unique(Combined_constellation(:));
Combined_constellation3 = (Constellation_64QAM +  unique_constellation)/2;
unique_constellation3 = unique(Combined_constellation3(:));

Combined_constellation4 = (Constellation_64QAM +  unique_constellation3)/2;
unique_constellation4 = unique(Combined_constellation4(:));


BPSK_Constellation = wlanConstellationMap([0 1],1);
QPSK_Constellation = wlanConstellationMap(de2bi(0:3),2);
QAM16_Constellation = wlanConstellationMap(de2bi(0:15)',4);
real_random = -1 + (1-(-1)).*rand(11,1);
imag_random = -1 + (1-(-1)).*rand(11,1);
random_constellation = wlanConstellationMap(de2bi([0:255],8)',8)';%complex(real_random,imag_random);


for i = 1:2
    distance_BPSK(i,:) = abs(BPSK_Constellation(i) - unique_constellation);
    distance_BPSK3(i,:) = abs(BPSK_Constellation(i) - unique_constellation3);
    distance_BPSK4(i,:) = abs(BPSK_Constellation(i) - unique_constellation4);
    distance_BPSK_64(i,:) = abs(BPSK_Constellation(i) - Constellation_64QAM);
    
end

for i = 1:4
    distance_QPSK(i,:) = abs(QPSK_Constellation(i) - unique_constellation);
    distance_QPSK3(i,:) = abs(QPSK_Constellation(i) - unique_constellation3);
    distance_QPSK4(i,:) = abs(QPSK_Constellation(i) - unique_constellation4);
    distance_QPSK_64(i,:) = abs(QPSK_Constellation(i) - Constellation_64QAM);
    
end

for i = 1:16
    distance_16QAM(i,:) = abs(QAM16_Constellation(i) - unique_constellation);
    distance_16QAM3(i,:) = abs(QAM16_Constellation(i) - unique_constellation3);
    distance_16QAM4(i,:) = abs(QAM16_Constellation(i) - unique_constellation4);
    distance_16QAM_64(i,:) = abs(QAM16_Constellation(i) - Constellation_64QAM);
end

for i = 1:256
    distance_custom(i,:) = abs(random_constellation(i) - unique_constellation);
    distance_custom3(i,:) = abs(random_constellation(i) - unique_constellation3);
    distance_custom4(i,:) = abs(random_constellation(i) - unique_constellation4);
    distance_custom_64(i,:) = abs(random_constellation(i) - Constellation_64QAM);
end


min_d_BPSK = mean(min(distance_BPSK'));
min_d_QPSK = mean(min(distance_QPSK'));
min_d_16QAM = mean(min(distance_16QAM'));
min_d_custom = mean(min(distance_custom'));

min_d_BPSK_64 = mean(min(distance_BPSK_64'));
min_d_QPSK_64 = mean(min(distance_QPSK_64'));
min_d_16QAM_64 = mean(min(distance_16QAM_64'));
min_d_custom_64 = mean(min(distance_custom_64'));

min_d_BPSK3 = mean(min(distance_BPSK3'));
min_d_QPSK3 = mean(min(distance_QPSK3'));
min_d_16QAM3 = mean(min(distance_16QAM3'));
min_d_custom3 = mean(min(distance_custom3'));

min_d_BPSK4 = mean(min(distance_BPSK4'));
min_d_QPSK4 = mean(min(distance_QPSK4'));
min_d_16QAM4 = mean(min(distance_16QAM4'));
min_d_custom4 = mean(min(distance_custom4'));

standard_distance = [min_d_BPSK_64 min_d_QPSK_64 min_d_16QAM_64 0];
emulated_distance = [min_d_BPSK min_d_QPSK min_d_16QAM min_d_custom];
emulated_distance3 = [min_d_BPSK3 min_d_QPSK3 min_d_16QAM3 min_d_custom3];
emulated_distance4 = [min_d_BPSK4 min_d_QPSK4 min_d_16QAM4 min_d_custom4];

plot_matrix = [standard_distance;emulated_distance;emulated_distance3;emulated_distance4].';
figure(1)
x_1 = 1:4;%categorical({'BPSK','QPSK','16QAM','Random'});

bar(x_1 ,plot_matrix,0.7);
xticks([1 2 3 4])
yticks([0 0.1  0.2])
xticklabels(categorical({'BPSK','QPSK','16QAM','256QAM'}));
legend({'64QAM','2x64QAM Mix','3x64QAM Mix','4x64QAM Mix'},'FontSize',36,'Orientation','horizontal');
xlim([0.5 4.55])
ylim([0 0.25])
xlabel('Target constellation diagram','FontSize',36);
ylabel('Distance','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

%plot_matrix = [standard_distance;emulated_distance;emulated_distance3;emulated_distance4].';
% figure(1)
% x_1 = 1:4;%categorical({'BPSK','QPSK','16QAM','Random'});
% 
% bar(x_1 ,plot_matrix,0.7);
% xticks([1 2 3 4])
% yticks([0 0.1  0.2])
% xticklabels(categorical({'BPSK','QPSK','16QAM','256QAM'}));
% legend({'64QAM','2x64QAM Mix','3x64QAM Mix','4x64QAM Mix'},'FontSize',36,'Orientation','horizontal');
% xlim([0.5 4.55])
% ylim([0 0.25])
% xlabel('Target constellation diagram','FontSize',36);
% ylabel('Distance','FontSize',36);
% %title('Minimal distance between constellation points','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 

distance_bpsk = plot_matrix(1,2:4);
distance = [0.02,0.04,0.08];
plot_matrix_20 = [distance_bpsk;distance];
emulation_accuracy_improvement = [0.005,0.18,0.183]*100;
x_20 = 1:3;
figure(20)
yyaxis left
bar(x_20 ,plot_matrix_20',0.7);
yyaxis right
plot(x_20,emulation_accuracy_improvement,'b>-','LineWidth',3,'MarkerSize',24,'MarkerFaceColor','b');
legend({'Granularity','Distortion','Improvement'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 ])
xticklabels(categorical({'2TX','3TX','4TX'}));

yyaxis left
xlabel('Number of Txs','FontSize',24)
ylabel('Distance','FontSize',24)
yticks([ 0 0.04 0.08 0.12])
xlim([0.6 3.4])
ylim([000 0.125])
yyaxis right
ylabel('Improvement(%)','FontSize',24)
yticks([0 5 10 15 20])
xlim([0.6 3.4])
ylim([0 20])
set(gca,'looseInset',[0 0 0 0],'FontSize',36);



figure(3)

scatter(real(Constellation_64QAM),imag(Constellation_64QAM),150,'d','filled');
hold on
scatter(real(random_constellation),imag(random_constellation),150,'filled');
xlim([-1.1 1.1])
ylim([-1.2 1.3])
[hLg, icons]=legend({'64QAM','256QAM'},'FontSize',20,'NumColumns',2,'Orientation','horizontal');
icons = findobj(icons,'Type','patch');
icons = findobj(icons,'Marker','none','-xor');
xline(0, 'k--', 'LineWidth', 5);
yline(0, 'k--', 'LineWidth', 5);

set(icons(1:2),'MarkerSize',20);
xlabel('I','FontSize',24);
ylabel('Q','FontSize',24);
%title('Constellation Diagram','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',24,'XTick',[],'YTick',[],'XTickLabel',[]);
% temp = 1;
% for i = 50:10:500
%     bits_encoded = randi([0 1],108*6*2*i,1);
% 
%     tic 
%     bits_decoded = wlanBCCDecode(bits_encoded,'5/6','hard');
%     time(temp) = toc;
%     total_time(temp) = time(temp);
%     temp = temp + 1;
% end
% total_time = total_time*2^20;
% total_time_SigBrick = [0.98844 1.54068 1.62371 2.68874 5.46394 10.76662];
% 

%x_41 = [50 70 90 133 258 500]*1296;
x_41 = 1:200;
search_space = 2.^(x_41);
total_time = (0.00000005025:0.00000000025:0.0000001).*2.^(x_41);
figure(4)
plot(x_41,total_time,'LineWidth',20);
%[hLg, icons]=legend({'SigBrick','Search'},'FontSize',24,'NumColumns',2,'Orientation','horizontal');
ylim([0 10^56])
xlim([1 200])
yticks([10^0 10^49])

xlabel('Number of uncontrolled bits X','FontSize',24);
ylabel('Max search time(s)','FontSize',24);
%title('Computational Time','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',24,'YScale', 'log');
figure(15)
plot(x_41,search_space,'LineWidth',20);


%[hLg, icons]=legend({'SigBrick','Search'},'FontSize',24,'NumColumns',2,'Orientation','horizontal');
%ylim([-0.5 10^6])
xlim([1 200 ])

xlabel('Number of uncontrolled bits X','FontSize',24);
ylabel('Search space','FontSize',24);
%title('Computational Time','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',24,'YScale', 'log');

T1_collision=zeros(7,6);
T1_detection=zeros(7,2);
T1_collision(:,1) = xlsread('Target_one.xlsx','G3:G9');
T1_collision(:,2) = xlsread('Target_one.xlsx','I3:I9');
T1_collision(:,3) = xlsread('Target_one.xlsx','K3:K9');
T1_collision(:,4) = xlsread('Target_one.xlsx','N3:N9');
T1_collision(:,5) = xlsread('Target_one.xlsx','O3:O9');
T1_collision(:,6) = xlsread('Target_one.xlsx','P3:P9');
T1_detection(:,1) = xlsread('Target_one.xlsx','D3:D9');
T1_detection(:,2) = xlsread('Target_one.xlsx','E3:E9');

T1_collision_x = [2 4 6 8 10 12 14];
figure(5);
hBarGrp = bar(abs(randn(7,2)),'grouped','stacked');
off = hBarGrp(2).XOffset +0.15;
hbar1 = bar(T1_collision_x - off,T1_collision(:,1:3),0.25,'stacked');
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
hold on 
hbar2 = bar(T1_collision_x + off,T1_collision(:,4:6),0.25,'stacked');
hold on
plot(T1_collision_x,T1_detection(:,1),'-rs','LineWidth',5,'MarkerSize',15);
hold on
plot(T1_collision_x,T1_detection(:,2),'--go','LineWidth',5,'MarkerSize',15);



legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)','Correctly decoded(CSMA/CN)',...
    'Preamble decoded but packet lost(CSMA/CN)','Preamble lost(CSMA/CN)','Detection Accuarcy(Emulated)','Detection Accuarcy(CSMA/CN)'},'FontSize',24,'NumColumns',3);

xlim([1 15])
ylim([0 1.2])
xlabel('SIR(dB)','FontSize',24);
ylabel('Fraction of packets','FontSize',24);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',24);


T1_collision1=zeros(4,6);
T1_detection1=zeros(4,2);
T1_collision1(:,1) = xlsread('Target_one.xlsx','N11:N14');
T1_collision1(:,2) = xlsread('Target_one.xlsx','O11:O14');
T1_collision1(:,3) = xlsread('Target_one.xlsx','P11:P14');
T1_collision1(:,4) = xlsread('Target_one.xlsx','N15:N18');
T1_collision1(:,5) = xlsread('Target_one.xlsx','O15:O18');
T1_collision1(:,6) = xlsread('Target_one.xlsx','P15:P18');
T1_detection1(:,1) = xlsread('Target_one.xlsx','S11:S14');
T1_detection1(:,2) = xlsread('Target_one.xlsx','T11:T14');

T1_collision_x1 = [0.5 1 1.5 2];
figure(6);
hBarGrp = bar(abs(randn(4,2)),'grouped','stacked');
off = hBarGrp(2).XOffset -0.05;
hbar1 = bar(T1_collision_x1 - off,T1_collision1(:,1:3),0.25,'stacked');
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
hold on 
hbar2 = bar(T1_collision_x1 + off,T1_collision1(:,4:6),0.25,'stacked');
hold on
plot(T1_collision_x1,T1_detection1(:,1),'-rs','LineWidth',5,'MarkerSize',15);
hold on
plot(T1_collision_x1,T1_detection1(:,2),'--go','LineWidth',5,'MarkerSize',15);



legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)','Correctly decoded(CSMA/CN)',...
    'Preamble decoded but packet lost(CSMA/CN)','Preamble lost(CSMA/CN)','Detection Accuarcy(Emulated)','Detection Accuarcy(CSMA/CN)'},'FontSize',24,'NumColumns',3);
xticks([0.5 1 1.5 2])
yticks([0.2 0.4 0.6 0.8 1])
xticklabels(categorical({'BPSK 1/2','BPSK 3/4','QPSK 1/2','QPSK 3/4'}));
xlim([0.2 2.2])
ylim([0 1.2])
xlabel('Data Rate','FontSize',36);
ylabel('Fraction of packets','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

%% Target 2

T2_Detection_SNR=zeros(4,3);
T2_Detection_BAND=zeros(3,3);

T2_Detection_SNR(:,1) = xlsread('Target_TWO.xlsx','N36:N39');
T2_Detection_SNR(:,2) = xlsread('Target_TWO.xlsx','O36:O39');
%T2_Detection_SNR(:,3) = xlsread('Target_TWO.xlsx','P36:P39');

T2_Detection_BAND(:,1) = xlsread('Target_TWO.xlsx','N42:P42');
T2_Detection_BAND(:,2) = xlsread('Target_TWO.xlsx','N43:P43');
%T2_Detection_BAND(:,3) = xlsread('Target_TWO.xlsx','N44:P44');


T2_Detection_SNR_x1 = [1 2 3 4];
figure(7);
hbar1 = bar(T2_Detection_SNR_x1 ,T2_Detection_SNR,0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'Emulation','FSA'},'FontSize',24,'NumColumns',3);
xticks([0.9 1.9 2.9 3.9])
yticks([0.5  1 ])
xticklabels(categorical({'0-5','5-10','10-15','15-20'}));
xlim([0.3 4.5])
ylim([0 1.18])
xlabel('SNR(dB)','FontSize',36);
ylabel('Detection rate','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);



T2_Detection_SNR_x2 = [1 2 3];
figure(8);

T2_hbar = bar(T2_Detection_SNR_x2 ,T2_Detection_BAND,0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'Emulation','FSA'},'FontSize',24,'NumColumns',3);
xticks([0.9 1.9 2.9])
yticks([0.5 1 ])
xticklabels(categorical({'5Mhz','10Mhz','15Mhz'}));
xlim([0.4 3.3])
ylim([0 1.18])
xlabel('Spectrum Width','FontSize',36);
ylabel('Detection rate','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


%% Target 3

T3_Detection_ACC=zeros(5,4);

T3_Detection_ACC(:,1) = xlsread('Target_TWO_part2.xlsx','H80:H84');
T3_Detection_ACC(:,2) = xlsread('Target_TWO_part2.xlsx','I80:I84');
T3_Detection_ACC(:,3) = xlsread('Target_TWO_part2.xlsx','J80:J84');
T3_Detection_ACC(:,4) = xlsread('Target_TWO_part2.xlsx','K80:K84');

T3_Detection_HE=zeros(5,4);

T3_Detection_HE(:,1) = xlsread('Target_TWO_part2.xlsx','G129:G133');
T3_Detection_HE(:,2) = xlsread('Target_TWO_part2.xlsx','H129:H133');
T3_Detection_HE(:,3) = xlsread('Target_TWO_part2.xlsx','I129:I133');
T3_Detection_HE(:,4) = xlsread('Target_TWO_part2.xlsx','J129:J133');

T3_BER=zeros(5,4);

T3_BER(:,1) = xlsread('Target_TWO_part2.xlsx','H66:H70');
T3_BER(:,2) = xlsread('Target_TWO_part2.xlsx','I66:I70');
T3_BER(:,3) = xlsread('Target_TWO_part2.xlsx','J66:J70');
T3_BER(:,4) = xlsread('Target_TWO_part2.xlsx','K66:K70');
T3_BER(:,5) = xlsread('Target_TWO_part2.xlsx','L66:L70');



figure(9);
T3_x1 = 1:5;
plot(T3_x1,T3_Detection_ACC,'LineWidth',5);

legend({'4 USERS','3 USERS','2 USERS','1 USERS'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5])
yticks([0.9 0.95 1 ])
xticklabels(categorical({'4','8','12','16','20'}));
xlim([1 5])
ylim([0.9 1.03])
xlabel('SNR','FontSize',36);
ylabel('Packet detection rate(dB)','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


figure(10);
T3_x1 = 1:5;

plot(T3_x1,T3_Detection_HE,'LineWidth',5);

%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'4 USERS','3 USERS','2 USERS','1 USERS'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5])
yticks([0.8 0.9 1 ])
xticklabels(categorical({'4','7','12','15','20'}));
xlim([1 5])
ylim([0.85,1.03])
xlabel('SNR(dB)','FontSize',36);
ylabel('HE-SIG-B reception rate','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

figure(11)

plot(T3_x1,T3_BER,'LineWidth',5);

legend({'BPSK(1/2)','BPSK(3/4)','QPSK(1/2)','QPSK(3/4)'},'FontSize',24,'NumColumns',3);

xticks([1 2 3 4 5])
yticks([0 3 6])
xticklabels(categorical({'4','7','12','15','20'}));
xlim([1 5])
ylim([0 7])
xlabel('SNR(dB)','FontSize',36);
ylabel('Bit Error rate','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


T3_BERC1=zeros(5,4);

T3_BERC1(:,1) = xlsread('Target_TWO_part2.xlsx','K289:K293');
T3_BERC1(:,2) = xlsread('Target_TWO_part2.xlsx','L289:L293');
T3_BERC1(:,3) = xlsread('Target_TWO_part2.xlsx','M289:M293');
T3_BERC1(:,4) = xlsread('Target_TWO_part2.xlsx','N289:N293');

T3_BERC2=zeros(5,3);

T3_BERC2(:,1) = xlsread('Target_TWO_part2.xlsx','R289:R293');
T3_BERC2(:,2) = xlsread('Target_TWO_part2.xlsx','S289:S293');
T3_BERC2(:,3) = xlsread('Target_TWO_part2.xlsx','T289:T293');


T3_BERC3=zeros(5,4);

T3_BERC3(:,1) = xlsread('Target_TWO_part2.xlsx','X289:X293');
T3_BERC3(:,2) = xlsread('Target_TWO_part2.xlsx','Y289:Y293');
T3_BERC3(:,3) = xlsread('Target_TWO_part2.xlsx','Z289:Z293');
T3_BERC3(:,4) = xlsread('Target_TWO_part2.xlsx','AA289:AA293');


figure(12);
T3_x1 = 1:5;
plot(T3_x1,T3_BERC1(:,1),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(T3_x1,T3_BERC1(:,2),'k>-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(T3_x1,T3_BERC1(:,3),'ro-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(T3_x1,T3_BERC1(:,4),'b*-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',

legend({'USER1(5)','USER1(17)','USER1(4)','USER1(19)'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5])
yticks([0 3 6])
xticklabels(categorical({'4','8','12','16','20'}));
xlim([1 5])
ylim([0 7])
xlabel('SNR(dB)','FontSize',36);
ylabel('Bit Error rate','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


figure(13);
T3_x1 = 1:5;
plot(T3_x1,T3_BERC2(:,1),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(T3_x1,T3_BERC2(:,2),'k>-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(T3_x1,T3_BERC2(:,3),'ro-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',

%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'USER1(5)','USER1(15)','USER1(6)'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5])
yticks([0 3 6])
xticklabels(categorical({'4','8','12','16','20'}));
xlim([1 5])
ylim([0 7])
xlabel('SNR(dB)','FontSize',36);
ylabel('Bit Error rate','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

figure(14)

plot(T3_x1,T3_BERC3(:,1),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(T3_x1,T3_BERC3(:,2),'k>-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(T3_x1,T3_BERC3(:,3),'ro-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(T3_x1,T3_BERC3(:,4),'b*-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',

legend({'USER1(11)','USER2(11)','USER3(11)','USER4(12)'},'FontSize',24,'NumColumns',3);

xticks([1 2 3 4 5])
yticks([0 3 6])
xticklabels(categorical({'4','8','12','16','20'}));
xlim([1 5])
ylim([0 7])
xlabel('SNR(dB)','FontSize',36);
ylabel('Bit Error rate','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);



Time_algorithm=zeros(1,6);
Time_std = zeros(1,6);

Time_algorithm = xlsread('time.xlsx','I73:I80');
Time_std = xlsread('time.xlsx','D37:D44');


Find_MAC_time =  xlsread('time.xlsx','E52:E57');
Optimal_constellation =  xlsread('time.xlsx','F52:F57');
OtherPHY =  xlsread('time.xlsx','G52:G57');

Time_10 =  xlsread('time.xlsx','E73:E78');
Time_20 =  xlsread('time.xlsx','E52:E57');
Time_30 =  xlsread('time.xlsx','E63:E68');

time = [Time_10 Time_20 Time_30];
%Extra_time = xlsread('time.xlsx','C52:C57');




figure(15);
T3_x1 = 1:8;
plot(T3_x1,Time_algorithm,'rv-','LineWidth',3,'MarkerSize',24,'MarkerFaceColor','r');
hold on
plot(T3_x1,Time_std,'b>-','LineWidth',3,'MarkerSize',24,'MarkerFaceColor','b');

legend({'SigBrick Runtime','Commodity Frame Gap'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5 6 7 8])
yticks([ 250 500 750])
xticklabels(categorical({'5','10','15','20','25','30','35','40'}));
xlim([1 8])
ylim([200 950])
xlabel('Number of symbols','FontSize',36);
ylabel('Time(us)','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

figure(16);
T3_x1 = 1:6;
bar(T3_x1,time,0.6);


legend({'10 bits','20 bits','30bits'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5 6])
yticks([1000 2000 3000])
xticklabels(categorical({'5','10','15','20','25','30'}));
xlim([0.3 6.7])
ylim([0 3000])
xlabel('Number of symbols','FontSize',36);
ylabel('Time(us)','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


% figure(17);
% deviation_s2 = mean(sqrt((constellation_short(:,1)-0.9287).^2 + constellation_short(:,2).^2));
% deviation_s1 = mean(sqrt((constellation_long(:,1)-0.9287).^2 + constellation_long(:,2).^2));
% 
% 
% 
% 
% 
% scatter(constellation_short(1100:1150,1),constellation_short(1100:1150,2),400,'x','r','LineWidth',5);
% hold on 
% scatter(constellation_long(130:180,1),constellation_long(130:180,2),400,'c','filled');
% hold on
% scatter(0.9281,0,2000,'g','filled');
% hold on 
% scatter(1,0,2000,'k','filled');
% [hLg, icons]=legend({'Selection 1','Selection 2','Mixed signal ','Target signal'},'FontSize',24,'Orientation','horizontal');
% 
% icons = findobj(icons,'Type','patch');
% icons = findobj(icons,'Marker','none','-xor');
% %xline(0, 'k--', 'LineWidth', 5);
% %yline(0, 'k--', 'LineWidth', 5);
% 
% set(icons(1:4),'MarkerSize',30);
% set(icons(1),'LineWidth',5);
% 
% xlabel('I','FontSize',36);
% ylabel('Q','FontSize',36);
% %title('Collision detection accuracy at different SIRs','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);



Time_tradeoff = xlsread('time.xlsx','C87:C94');
Storage = xlsread('time.xlsx','B87:B94');


figure(19);
T3_x1 = 1:8;
plot(T3_x1,Time_tradeoff,'rv-','LineWidth',3,'MarkerSize',24,'MarkerFaceColor','r');
yyaxis right

plot(T3_x1,Storage,'b>-','LineWidth',3,'MarkerSize',24,'MarkerFaceColor','b');
legend({'Time overhead','Storage overhead'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5 6 7 8])
xticklabels(categorical({'2','6','10','14','18','22','26','30'}));

yyaxis left
xlabel('Segment length','FontSize',24)
ylabel('Time(us)','FontSize',24)
yticks([ 0 500 1000 1500])
xlim([0.9 8.2])
ylim([000 1500])
yyaxis right
ylabel('Storage(KB)','FontSize',24)
xticks([1 2 3 4 5 6 7 8])
xticklabels(categorical({'2','6','10','14','18','22','26','30'}));

yticks([ 0 400 800 1200])
xlim([0.9 8.2])
ylim([-20 1320])



%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

figure(16);
T3_x1 = 1:6;
bar(T3_x1,time,0.6);


legend({'10 bits','20 bits','30bits'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5 6])
yticks([1000 2000 3000])
xticklabels(categorical({'5','10','15','20','25','30'}));
xlim([0.3 6.7])
ylim([0 3000])
xlabel('Number of symbols','FontSize',36);
ylabel('Time(us)','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);




