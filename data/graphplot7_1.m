%plots for paper
%Ruirong Chen
%For use to publish papers graphs.
%MobiCOM 2021
%
close all
clear all

T1_distance=zeros(4,4);
T1_distanceNLOS=zeros(4,4);
T1_distance_STD=zeros(4,4);
T1_distanceNLOS_STD=zeros(4,4);

T1_distance(:,1) = xlsread('7.1.1_constellation_distance.xlsx','B14:E14');
T1_distance(:,2) = xlsread('7.1.1_constellation_distance.xlsx','B15:E15');
T1_distance(:,3) = xlsread('7.1.1_constellation_distance.xlsx','B16:E16');
T1_distance(:,4) = xlsread('7.1.1_constellation_distance.xlsx','B17:E17');

T1_distance_STD(:,1) = xlsread('7.1.1_constellation_distance.xlsx','K14:N14');
T1_distance_STD(:,2) = xlsread('7.1.1_constellation_distance.xlsx','K15:N15');
T1_distance_STD(:,3) = xlsread('7.1.1_constellation_distance.xlsx','K16:N16');
T1_distance_STD(:,4) = xlsread('7.1.1_constellation_distance.xlsx','K17:N17');


T1_distanceNLOS(:,1) = xlsread('7.1.1_constellation_distance.xlsx','B19:E19');
T1_distanceNLOS(:,2) = xlsread('7.1.1_constellation_distance.xlsx','B20:E20');
T1_distanceNLOS(:,3) = xlsread('7.1.1_constellation_distance.xlsx','B21:E21');
T1_distanceNLOS(:,4) = xlsread('7.1.1_constellation_distance.xlsx','B22:E22');

T1_distanceNLOS_STD(:,1) = xlsread('7.1.1_constellation_distance.xlsx','K19:N19');
T1_distanceNLOS_STD(:,2) = xlsread('7.1.1_constellation_distance.xlsx','K20:N20');
T1_distanceNLOS_STD(:,3) = xlsread('7.1.1_constellation_distance.xlsx','K21:N21');
T1_distanceNLOS_STD(:,4) = xlsread('7.1.1_constellation_distance.xlsx','K22:N22');



figure(1)
x_1 = 1:4;%categorical({'BPSK','QPSK','16QAM','Random'});
plot(x_1,T1_distance(1,:),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,T1_distance(2,:),'r>-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distance(3,:),'ks-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distance(4,:),'bh-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distance_STD(1,:),'gv--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distance_STD(2,:),'r>--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distance_STD(3,:),'ks--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distance_STD(4,:),'bh--','LineWidth',3,'MarkerSize',24);
xticks([1 2 3 4])
yticks([0 0.2  0.4])
xticklabels(categorical({'2','3','5','7'}));
legend({'BPSK(Emulated)','QPSK(Emulated)','8QAM(Emulated)','Custom(Emulated)','BPSK(64QAM)','QPSK(64QAM)','8QAM(64QAM)','Custom(64QAM)'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
xlim([1 4])
ylim([0 0.5])
xlabel('Distance(m)','FontSize',36);
ylabel('Deviation','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

figure(2)


x_1 = 1:4;%categorical({'BPSK','QPSK','16QAM','Random'});
plot(x_1,T1_distanceNLOS(1,:),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,T1_distanceNLOS(2,:),'r>-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceNLOS(3,:),'ks-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceNLOS(4,:),'bh-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceNLOS_STD(1,:),'gv--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceNLOS_STD(2,:),'r>--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceNLOS_STD(3,:),'ks--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceNLOS_STD(4,:),'bh--','LineWidth',3,'MarkerSize',24);
xticks([1 2 3 4])
yticks([0 0.2 0.4])
xticklabels(categorical({'2','3','5','7'}));
legend({'BPSK(Emulated)','QPSK(Emulated)','8QAM(Emulated)','Custom(Emulated)','BPSK(64QAM)','QPSK(64QAM)','8QAM(64QAM)','Custom(64QAM)'},'FontSize',24,'Orientation','horizontal','NumColumns',4);
xlim([1 4])
ylim([0 0.6])
xlabel('Distance(m)','FontSize',36);
ylabel('Deviation','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);



TX3_distance=zeros(4,4);
TX4_distance=zeros(4,4);


TX3_distance(:,1) = xlsread('7.1.1_constellation_distance_3TX.xlsx','B14:E14');
TX3_distance(:,2) = xlsread('7.1.1_constellation_distance_3TX.xlsx','B15:E15');
TX3_distance(:,3) = xlsread('7.1.1_constellation_distance_3TX.xlsx','B16:E16');
TX3_distance(:,4) = xlsread('7.1.1_constellation_distance_3TX.xlsx','B17:E17');


TX4_distance(:,1) = xlsread('7.1.1_constellation_distance_3TX.xlsx','B14:E14');
TX4_distance(:,2) = xlsread('7.1.1_constellation_distance_3TX.xlsx','B15:E15');
TX4_distance(:,3) = xlsread('7.1.1_constellation_distance_3TX.xlsx','B16:E16');
TX4_distance(:,4) = xlsread('7.1.1_constellation_distance_3TX.xlsx','B17:E17');



figure(3)

plot(x_1,TX3_distance(1,:),'gv-','MarkerFaceColor','g','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,TX3_distance(2,:),'r>-','MarkerFaceColor','r','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,TX3_distance(3,:),'ks-','MarkerFaceColor','k','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,TX3_distance(4,:),'bh-','MarkerFaceColor','b','LineWidth',3,'MarkerSize',24);
xticks([1 2 3 4])
yticks([0.1 0.15 0.2])
xticklabels(categorical({'2','3','5','7'}));
legend({'BPSK','QPSK','8QAM','Custom'},'FontSize',24,'Orientation','horizontal','NumColumns',2);
xlim([1 4])
ylim([0.08 0.2])
xlabel('Distance(m)','FontSize',36);
ylabel('Deviation','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);



figure(4)

plot(x_1,TX4_distance(1,:),'gv-','MarkerFaceColor','g','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,TX4_distance(2,:),'r>-','MarkerFaceColor','r','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,TX4_distance(3,:),'ks-','MarkerFaceColor','k','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,TX4_distance(4,:),'bh-','MarkerFaceColor','b','LineWidth',3,'MarkerSize',24);
xticks([1 2 3 4])
yticks([0.1 0.15 0.2])
xticklabels(categorical({'2','3','5','7'}));
legend({'BPSK','QPSK','8QAM','Custom'},'FontSize',24,'Orientation','horizontal','NumColumns',2);
xlim([1 4])
ylim([0.08 0.2])
xlabel('Distance(m)','FontSize',36);
ylabel('Deviation','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

T1_distanceP=zeros(4,8);
T1_distanceP_STD=zeros(4,8);


T1_distanceP(:,1) = xlsread('7.1.1_constellation_distance.xlsx','B2:E2');
T1_distanceP(:,2) = xlsread('7.1.1_constellation_distance.xlsx','B3:E3');
T1_distanceP(:,3) = xlsread('7.1.1_constellation_distance.xlsx','B4:E4');
T1_distanceP(:,4) = xlsread('7.1.1_constellation_distance.xlsx','B5:E5');
T1_distanceP(:,5) = xlsread('7.1.1_constellation_distance.xlsx','B6:E6');
T1_distanceP(:,6) = xlsread('7.1.1_constellation_distance.xlsx','B7:E7');
T1_distanceP(:,7) = xlsread('7.1.1_constellation_distance.xlsx','B8:E8');
T1_distanceP(:,8) = xlsread('7.1.1_constellation_distance.xlsx','B9:E9');



T1_distanceP_STD(:,1) = xlsread('7.1.1_constellation_distance.xlsx','K2:N2');
T1_distanceP_STD(:,2) = xlsread('7.1.1_constellation_distance.xlsx','K3:N3');
T1_distanceP_STD(:,3) = xlsread('7.1.1_constellation_distance.xlsx','K4:N4');
T1_distanceP_STD(:,4) = xlsread('7.1.1_constellation_distance.xlsx','K5:N5');
T1_distanceP_STD(:,5) = xlsread('7.1.1_constellation_distance.xlsx','K6:N6');
T1_distanceP_STD(:,6) = xlsread('7.1.1_constellation_distance.xlsx','K7:N7');
T1_distanceP_STD(:,7) = xlsread('7.1.1_constellation_distance.xlsx','K8:N8');
T1_distanceP_STD(:,8) = xlsread('7.1.1_constellation_distance.xlsx','K9:N9');


figure(5)
x_1 = 1:8;%categorical({'BPSK','QPSK','16QAM','Random'});
plot(x_1,T1_distanceP(1,:),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,T1_distanceP(2,:),'r>-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceP(3,:),'ks-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceP(4,:),'bh-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceP_STD(1,:),'gv--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceP_STD(2,:),'r>--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceP_STD(3,:),'ks--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,T1_distanceP_STD(4,:),'bh--','LineWidth',3,'MarkerSize',24);
xticks([1 2 3 4 5 6 7 8 ])
yticks([0 0.2  0.4])
xticklabels(categorical({'40','36','32','28','24','20','16','12'}));
legend({'BPSK(Emulated)','QPSK(Emulated)','8QAM(Emulated)','Custom(Emulated)','BPSK(64QAM)','QPSK(64QAM)','8QAM(64QAM)','Custom(64QAM)'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
xlim([1 8])
ylim([0 0.5])
xlabel('G_{Tx} + G_{Rx}','FontSize',36);
ylabel('Deviation','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);



PRR_2TX=zeros(2,5);
PRR_3TX=zeros(2,5);
PRR_STS=zeros(2,5);
PRR_short=zeros(2,5);
PRR_pluse=zeros(2,5);

PRR_2TX(1,:) = xlsread('7.1.1_constellation_distance.xlsx','S14:S18');
PRR_2TX(2,:) = xlsread('7.1.1_constellation_distance.xlsx','S21:S25');
PRR_Webee(1,:) = xlsread('7.1.1_constellation_distance.xlsx','V14:V18');
PRR_Webee(2,:) = xlsread('7.1.1_constellation_distance.xlsx','V21:V25');

PRR_SDR(1,:) = xlsread('7.1.1_constellation_distance.xlsx','W14:W18');
PRR_SDR(2,:) = xlsread('7.1.1_constellation_distance.xlsx','W21:W25');
PRR_STS(1,:) = xlsread('7.1.1_constellation_distance.xlsx','R14:R18');
PRR_STS(2,:) = xlsread('7.1.1_constellation_distance.xlsx','R21:R25');

PRR_short(1,:) = xlsread('7.1.1_constellation_distance.xlsx','AD14:AD18');
PRR_short(2,:) = xlsread('7.1.1_constellation_distance.xlsx','AE14:AE18');
PRR_short(3,:) = xlsread('7.1.1_constellation_distance.xlsx','AF14:AF18');
PRR_short(4,:) = xlsread('7.1.1_constellation_distance.xlsx','AG14:AG18');

PRR_pulse(1,:) = xlsread('7.1.1_constellation_distance.xlsx','AN14:AN18');
PRR_pulse(2,:) = xlsread('7.1.1_constellation_distance.xlsx','AO14:AO18');
PRR_pulse(3,:) = xlsread('7.1.1_constellation_distance.xlsx','AP14:AP18');
PRR_pulse(4,:) = xlsread('7.1.1_constellation_distance.xlsx','AQ14:AQ18');



figure(6)
x_1 = 1:5;%categorical({'BPSK','QPSK','16QAM','Random'});
plot(x_1,PRR_2TX(1,:),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,PRR_2TX(2,:),'gv--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_Webee(1,:),'ks-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_Webee(2,:),'ks--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_SDR(1,:),'r<-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_SDR(2,:),'r<--','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([0.4 0.6 0.8 1])
xticklabels(categorical({'2','4','6','8','10'}));
legend({'ZuHe(LOS)','ZuHe(NLOS)','WEBee(LOS)','WEBee(LOS)','SDR-Lite(LOS)','SDR-Lite(NLOS)'},'FontSize',24,'Orientation','horizontal','NumColumns',2);
xlim([0.9 5.1])
ylim([0.45 1.32])
xlabel('Distance(m)','FontSize',36);
ylabel('Detection rate','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


figure(7)

plot(x_1,PRR_STS(1,:),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,PRR_STS(2,:),'gv--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_Webee(1,:),'ks-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_Webee(2,:),'ks--','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_SDR(1,:),'r<-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_SDR(2,:),'r<--','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([0.4 0.6 0.8 1])
xticklabels(categorical({'2','4','6','8','10'}));
legend({'ZuHe(LOS)','ZuHe(NLOS)','WEBee(LOS)','WEBee(LOS)','SDR-Lite(LOS)','SDR-Lite(NLOS)'},'FontSize',24,'Orientation','horizontal','NumColumns',2);
xlim([0.9 5.1])
ylim([0.45 1.32])
xlabel('Distance(m)','FontSize',36);
ylabel('Detection rate','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


figure(8)

plot(x_1,PRR_short(1,:),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,PRR_short(2,:),'r*-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_short(3,:),'ks-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_short(4,:),'bh-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,PRR_4TX(1,:),'c<-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,PRR_4TX(2,:),'y^-','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([0.4 0.6 0.8 1]);
xticklabels(categorical({'2','4','6','8','10'}));
legend({'Static','Confined','Blockage','Interference'},'FontSize',24,'Orientation','horizontal','NumColumns',4);
xlim([1 5])
ylim([0.45 1.20])
xlabel('Distance(m)','FontSize',36);
ylabel('Detection rate','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


figure(9)

plot(x_1,PRR_pulse(1,:),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,PRR_pulse(2,:),'r*-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_pulse(3,:),'ks-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,PRR_pulse(4,:),'bh-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,PRR_4TX(1,:),'c<-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,PRR_4TX(2,:),'y^-','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([0.4 0.6 0.8 1])
xticklabels(categorical({'2','4','6','8','10'}));
legend({'Static','Confined','Blockage','Interference'},'FontSize',24,'Orientation','horizontal','NumColumns',4);
xlim([1 5])
ylim([0.45 1.20])
xlabel('Distance(m)','FontSize',36);
ylabel('Detection rate','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);





BER_difference=zeros(5,3);

BER_difference(:,1) = xlsread('Target_TWO_part2.xlsx','I320:I324');
BER_difference(:,2) = xlsread('Target_TWO_part2.xlsx','J320:J324');
BER_difference(:,3) = xlsread('Target_TWO_part2.xlsx','K320:K324');
%T2_Detection_BAND(:,3) = xlsread('Target_TWO.xlsx','N44:P44');


SNR_BAR = [1 2 3 4 5];
figure(13);
hbar1 = bar(SNR_BAR ,BER_difference,0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'BPSK(1/2)','QPSK(1/2)','16QAM(1/2)'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5])
yticks([0  5  10])
xticklabels(categorical({'4','8','12','16','20'}));
xlim([0.5 5.5])
ylim([0 11])
xlabel('SNR(dB)','FontSize',36);
ylabel('BER Difference','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

