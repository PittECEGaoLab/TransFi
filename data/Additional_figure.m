clear all
close all

LTF_detection_outdoor=zeros(5,1);
Webee_detection_outdoor=zeros(5,1);
SDR_LITE_detection_outdoor = zeros(5,1);


LTF_detection_outdoor(:,1) = xlsread('Variety_condition_testing.xlsx','P5:P9');

Webee_detection_outdoor(:,1) = xlsread('Variety_condition_testing.xlsx','AG5:AG9');

SDR_LITE_detection_outdoor(:,1) = xlsread('Variety_condition_testing.xlsx','AH5:AH9');

figure(1)
x_1 = 1:5;%categorical({'BPSK','QPSK','16QAM','Random'});
plot(x_1,fliplr(LTF_detection_outdoor'),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,fliplr(Webee_detection_outdoor'),'r>-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,fliplr(SDR_LITE_detection_outdoor'),'b*-','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([0.5  1])
xticklabels(categorical({'10','20','30','40','50'}));
legend({'TransFi','Webee','SDR-Lite'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
xlim([1 5])
ylim([0.5 1.14])
xlabel('Distance(m)','FontSize',36);
ylabel('FRR','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


LTF_detection_corridor=zeros(5,1);
Webee_detection_corridor=zeros(5,1);

LTF_detection_corridor(:,1) = xlsread('Variety_condition_testing.xlsx','P27:P31');

Webee_detection_corridor(:,1) = xlsread('Variety_condition_testing.xlsx','AG27:AG31');

SDR_LITE_detection_corridor(:,1) = xlsread('Variety_condition_testing.xlsx','AH27:AH31');


figure(2)
x_1 = 1:5;%categorical({'BPSK','QPSK','16QAM','Random'});
plot(x_1,fliplr(LTF_detection_corridor'),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,fliplr(Webee_detection_corridor'),'r>-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,fliplr(SDR_LITE_detection_corridor'),'b*-','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([0.5 1])
xticklabels(categorical({'5','10','15','20','25'}));
legend({'TransFi','Webee','SDR-Lite'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
xlim([1 5])
ylim([0.5 1.14])
xlabel('Distance(m)','FontSize',36);
ylabel('FRR','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


BER_Outdoor=zeros(5,3);
BER_Outdoor_MIMO=zeros(5,3);

BER_Outdoor(:,1) = xlsread('Variety_condition_testing.xlsx','J5:J9');
BER_Outdoor(:,2) = xlsread('Variety_condition_testing.xlsx','K5:K9');
BER_Outdoor(:,3) = xlsread('Variety_condition_testing.xlsx','L5:L9');

BER_Outdoor_MIMO(:,1) = xlsread('Variety_condition_testing.xlsx','AA5:AA9');
BER_Outdoor_MIMO(:,2) = xlsread('Variety_condition_testing.xlsx','AB5:AB9');
BER_Outdoor_MIMO(:,3) = xlsread('Variety_condition_testing.xlsx','AC5:AC9');


SNR = [1 2 3 4 5];
figure(3);
hbar1 = bar(SNR ,fliplr([BER_Outdoor BER_Outdoor_MIMO]')',0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'BSPK(Emulation)','QSPK(Emulation)','16QAM(Emulation)','BSPK(MIMO)','QSPK(MIMO)','16QAM(MIMO)'},'FontSize',24,'NumColumns',1);
xticks([1 2 3 4 5])
yticks([0.05 0.1])
xticklabels(categorical({'10','20','30','40','50'}));
xlim([0.5 5.5])
ylim([0 0.12])
xlabel('Distance(m)','FontSize',36);
ylabel('BER','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


BER_Corridor=zeros(5,3);
BER_Corridor_MIMO=zeros(5,3);

BER_Corridor(:,1) = xlsread('Variety_condition_testing.xlsx','J27:J31');
BER_Corridor(:,2) = xlsread('Variety_condition_testing.xlsx','K27:K31');
BER_Corridor(:,3) = xlsread('Variety_condition_testing.xlsx','L27:L31');

BER_Corridor_MIMO(:,1) = xlsread('Variety_condition_testing.xlsx','AA27:AA31');
BER_Corridor_MIMO(:,2) = xlsread('Variety_condition_testing.xlsx','AB27:AB31');
BER_Corridor_MIMO(:,3) = xlsread('Variety_condition_testing.xlsx','AC27:AC31');


figure(4);
hbar2 = bar(SNR ,fliplr([BER_Corridor BER_Corridor_MIMO]')',0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'BSPK(Emulation)','QSPK(Emulation)','16QAM(Emulation)','BSPK(MIMO)','QSPK(MIMO)','16QAM(MIMO)'},'FontSize',24,'NumColumns',1);
xticks([1 2 3 4 5])
yticks([0.05 0.1])
xticklabels(categorical({'5','10','15','20','25'}));
xlim([0.5 5.5])
ylim([0 0.12])
xlabel('Distance(m)','FontSize',36);
ylabel('BER','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


BER_Reflection=zeros(2,3);
BER_Reflection_MIMO=zeros(2,3);

BER_Reflection(:,1) = xlsread('Variety_condition_testing.xlsx','E69:E70');
BER_Reflection(:,2) = xlsread('Variety_condition_testing.xlsx','F69:F70');
BER_Reflection(:,3) = xlsread('Variety_condition_testing.xlsx','G69:G70');

BER_Reflection_MIMO(:,1) = xlsread('Variety_condition_testing.xlsx','J69:J70');
BER_Reflection_MIMO(:,2) = xlsread('Variety_condition_testing.xlsx','K69:K70');
BER_Reflection_MIMO(:,3) = xlsread('Variety_condition_testing.xlsx','L69:L70');

Reflection_x1 = [1 2 3];

figure(5);
hbar2 = bar(Reflection_x1 ,([BER_Reflection;BER_Reflection_MIMO]'),0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'Transfi(Small metal object)','Transfi(Large metal object)','MIMO(Small metal object)','MIMO(Large metal object)'},'FontSize',24,'NumColumns',3);
xticks([1 2 3])
yticks([0.1 0.2 0.3 0.4])
xticklabels(categorical({'BPSK','QPSK','16QAM'}));
xlim([0.5 3.5])
ylim([0 0.48])
xlabel('Modulation','FontSize',36);
ylabel('BER','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


BER_Obstruction =zeros(3,3);
BER_Obstruction_MIMO=zeros(3,3);

BER_Obstruction(:,1) = xlsread('Variety_condition_testing.xlsx','E73:E75');
BER_Obstruction(:,2) = xlsread('Variety_condition_testing.xlsx','F73:F75');
BER_Obstruction(:,3) = xlsread('Variety_condition_testing.xlsx','G73:G75');

BER_Obstruction_MIMO(:,1) = xlsread('Variety_condition_testing.xlsx','J73:J75');
BER_Obstruction_MIMO(:,2) = xlsread('Variety_condition_testing.xlsx','K73:K75');
BER_Obstruction_MIMO(:,3) = xlsread('Variety_condition_testing.xlsx','L73:L75');

Reflection_x1 = [1 2 3];

figure(6);
hbar2 = bar(Reflection_x1 ,([BER_Obstruction;BER_Obstruction_MIMO]'),0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'Transfi(Wood)','Transfi(Concrete)','Transfi(Metal)','MIMO((Wood))','MIMO(Concrete)','MIMO(Metal)'},'FontSize',24,'NumColumns',3);
xticks([1 2 3])
yticks([0.1 0.2 0.3 0.4])
xticklabels(categorical({'BPSK','QPSK','16QAM'}));
xlim([0.5 3.5])
ylim([0 0.48])
xlabel('Modulation','FontSize',36);
ylabel('BER','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


BER_Interference=zeros(2,3);
BER_Interference_MIMO=zeros(2,3);

BER_Interference(:,1) = xlsread('Variety_condition_testing.xlsx','E78:E79');
BER_Interference(:,2) = xlsread('Variety_condition_testing.xlsx','F78:F79');
BER_Interference(:,3) = xlsread('Variety_condition_testing.xlsx','G78:G79');

BER_Interference_MIMO(:,1) = xlsread('Variety_condition_testing.xlsx','J78:J79');
BER_Interference_MIMO(:,2) = xlsread('Variety_condition_testing.xlsx','K78:K79');
BER_Interference_MIMO(:,3) = xlsread('Variety_condition_testing.xlsx','L78:L79');


figure(7);
hbar2 = bar(Reflection_x1 ,([BER_Interference;BER_Interference_MIMO]'),0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'Transfi(Continous)','Transfi(Intermintten)','MIMO(Continous)','MIMO(Intermintten)'},'FontSize',24,'NumColumns',3);
xticks([1 2 3])
yticks([0.2 0.4])
xticklabels(categorical({'BPSK','QPSK','16QAM'}));
xlim([0.5 3.5])
ylim([0 0.58])
xlabel('Modulation','FontSize',36);
ylabel('BER','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);







% Deviation_Outdoor=zeros(5,5);
% BER_outdoor=zeros(5,3);
% Deviation_MIMO_outdoor=zeros(5,3);
% 
% Deviation_Outdoor(:,1) = xlsread('Variety_condition_testing.xlsx','C5:C9');
% Deviation_Outdoor(:,2) = xlsread('Variety_condition_testing.xlsx','D5:D9');
% Deviation_Outdoor(:,3) = xlsread('Variety_condition_testing.xlsx','E5:E9');
% Deviation_Outdoor(:,4) = xlsread('Variety_condition_testing.xlsx','F5:F9');
% Deviation_Outdoor(:,5) = xlsread('Variety_condition_testing.xlsx','G5:G9');
% 
% BER_outdoor(:,1) = xlsread('Variety_condition_testing.xlsx','J5:J9');
% BER_outdoor(:,2) = xlsread('Variety_condition_testing.xlsx','K5:K9');
% BER_outdoor(:,3) = xlsread('Variety_condition_testing.xlsx','L5:L9');
% 
% Deviation_MIMO_outdoor(:,1) = xlsread('Variety_condition_testing.xlsx','U5:U9');
% Deviation_MIMO_outdoor(:,2) = xlsread('Variety_condition_testing.xlsx','V5:V9');
% Deviation_MIMO_outdoor(:,3) = xlsread('Variety_condition_testing.xlsx','W5:W9');
% 
% figure(1)
% x_1 = 1:5;%categorical({'BPSK','QPSK','16QAM','Random'});
% plot(x_1,fliplr(Deviation_Outdoor(:,1)'),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
% hold on
% plot(x_1,fliplr(Deviation_Outdoor(:,2)'),'r>-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Outdoor(:,3)'),'ks-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Outdoor(:,4)'),'bh-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Outdoor(:,5)'),'c+-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_outdoor(:,1)'),'gv--','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_outdoor(:,2)'),'r>--','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_outdoor(:,3)'),'ks--','LineWidth',3,'MarkerSize',24);
% 
% xticks([1 2 3 4 5])
% yticks([0 0.1 0.2 0.3])
% xticklabels(categorical({'10','20','30','40','50'}));
% legend({'BPSK(Emulated)','QPSK(Emulated)','16QAM(Emulated)','8QAM(Emulated)','12QAM(Emulated)','BPSK(MIMO)','QPSK(MIMO)','16QAM(MIMO)'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
% xlim([1 5])
% ylim([0.05 0.25])
% xlabel('Distance(m)','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Minimal distance between constellation points','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% Deviation_Corridor=zeros(5,5);
% BER_Corridor=zeros(5,3);
% Deviation_MIMO_Corridor=zeros(5,3);
% 
% Deviation_Corridor(:,1) = xlsread('Variety_condition_testing.xlsx','C27:C31');
% Deviation_Corridor(:,2) = xlsread('Variety_condition_testing.xlsx','D27:D31');
% Deviation_Corridor(:,3) = xlsread('Variety_condition_testing.xlsx','E27:E31');
% Deviation_Corridor(:,4) = xlsread('Variety_condition_testing.xlsx','F27:F31');
% Deviation_Corridor(:,5) = xlsread('Variety_condition_testing.xlsx','G27:G31');
% 
% BER_Corridor(:,1) = xlsread('Variety_condition_testing.xlsx','J27:J31');
% BER_Corridor(:,2) = xlsread('Variety_condition_testing.xlsx','K27:K31');
% BER_Corridor(:,3) = xlsread('Variety_condition_testing.xlsx','L27:L31');
% 
% Deviation_MIMO_Corridor(:,1) = xlsread('Variety_condition_testing.xlsx','U27:U31');
% Deviation_MIMO_Corridor(:,2) = xlsread('Variety_condition_testing.xlsx','V27:V31');
% Deviation_MIMO_Corridor(:,3) = xlsread('Variety_condition_testing.xlsx','W27:W31');
% 
% figure(2)
% x_1 = 1:5;%categorical({'BPSK','QPSK','16QAM','Random'});
% plot(x_1,fliplr(Deviation_Corridor(:,1)'),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
% hold on
% plot(x_1,fliplr(Deviation_Corridor(:,2)'),'r>-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Corridor(:,3)'),'ks-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Corridor(:,4)'),'bh-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Corridor(:,5)'),'c+-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_Corridor(:,1)'),'gv--','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_Corridor(:,2)'),'r>--','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_Corridor(:,3)'),'ks--','LineWidth',3,'MarkerSize',24);
% 
% xticks([1 2 3 4 5])
% yticks([0 0.1 0.2 0.3])
% xticklabels(categorical({'5','10','15','20','25'}));
% legend({'BPSK(Emulated)','QPSK(Emulated)','16QAM(Emulated)','8QAM(Emulated)','12QAM(Emulated)','BPSK(MIMO)','QPSK(MIMO)','16QAM(MIMO)'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
% xlim([1 5])
% ylim([0.05 0.25])
% xlabel('Distance(m)','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Minimal distance between constellation points','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% Deviation_Indoor=zeros(5,5);
% BER_outdoor=zeros(5,3);
% Deviation_MIMO_outdoor=zeros(5,3);
% 
% Deviation_Indoor(:,1) = xlsread('Variety_condition_testing.xlsx','C45:C49');
% Deviation_Indoor(:,2) = xlsread('Variety_condition_testing.xlsx','D45:D49');
% Deviation_Indoor(:,3) = xlsread('Variety_condition_testing.xlsx','E45:E49');
% Deviation_Indoor(:,4) = xlsread('Variety_condition_testing.xlsx','F45:F49');
% Deviation_Indoor(:,5) = xlsread('Variety_condition_testing.xlsx','G45:G49');
% 
% BER_Indoor(:,1) = xlsread('Variety_condition_testing.xlsx','J45:J49');
% BER_Indoor(:,2) = xlsread('Variety_condition_testing.xlsx','K45:K49');
% BER_Indoor(:,3) = xlsread('Variety_condition_testing.xlsx','L45:L49');
% 
% Deviation_MIMO_Indoor(:,1) = xlsread('Variety_condition_testing.xlsx','U45:U49');
% Deviation_MIMO_Indoor(:,2) = xlsread('Variety_condition_testing.xlsx','V45:V49');
% Deviation_MIMO_Indoor(:,3) = xlsread('Variety_condition_testing.xlsx','W45:W49');
% 
% figure(3)
% x_1 = 1:5;%categorical({'BPSK','QPSK','16QAM','Random'});
% plot(x_1,fliplr(Deviation_Indoor(:,1)'),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
% hold on
% plot(x_1,fliplr(Deviation_Indoor(:,2)'),'r>-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Indoor(:,3)'),'ks-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Indoor(:,4)'),'bh-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_Indoor(:,5)'),'c+-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_Indoor(:,1)'),'gv--','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_Indoor(:,2)'),'r>--','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,fliplr(Deviation_MIMO_Indoor(:,3)'),'ks--','LineWidth',3,'MarkerSize',24);
% 
% xticks([1 2 3 4 5])
% yticks([0 0.1 0.2 0.3])
% xticklabels(categorical({'2','4','6','8','10'}));
% legend({'BPSK(Emulated)','QPSK(Emulated)','16QAM(Emulated)','8QAM(Emulated)','12QAM(Emulated)','BPSK(MIMO)','QPSK(MIMO)','16QAM(MIMO)'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
% xlim([1 5])
% ylim([0.05 0.25])
% xlabel('Distance(m)','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Minimal distance between constellation points','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% Reflection=zeros(2,3);
% Reflection_MIMO=zeros(2,3);
% 
% Reflection(:,1) = xlsread('Variety_condition_testing.xlsx','J69:J70');
% Reflection(:,2) = xlsread('Variety_condition_testing.xlsx','K69:K70');
% Reflection(:,3) = xlsread('Variety_condition_testing.xlsx','L69:L70');
% 
% Reflection_MIMO(:,1) = xlsread('Variety_condition_testing.xlsx','O69:O70');
% Reflection_MIMO(:,2) = xlsread('Variety_condition_testing.xlsx','P69:P70');
% Reflection_MIMO(:,3) = xlsread('Variety_condition_testing.xlsx','Q69:Q70');
% 
% 
% SNR = [1 2 3];
% figure(4);
% hbar1 = bar(SNR ,[Reflection(1,:);Reflection_MIMO(1,:)]',0.8);
% %legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
% 
% legend({'Emulation','MIMO'},'FontSize',24,'NumColumns',3);
% xticks([1 2 3])
% yticks([0.05 0.1  0.15 ])
% xticklabels(categorical({'BPSK','QPSK','16QAM'}));
% xlim([0.5 3.5])
% ylim([0.05 0.17])
% xlabel('Modulation','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Collision detection accuracy at different SIRs','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% 
% figure(5);
% hbar2 = bar(SNR ,[Reflection(2,:);Reflection_MIMO(2,:)]',0.8);
% %legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
% 
% legend({'Emulation','MIMO'},'FontSize',24,'NumColumns',3);
% xticks([1 2 3])
% yticks([0.05 0.1  0.15 ])
% xticklabels(categorical({'BPSK','QPSK','16QAM'}));
% xlim([0.5 3.5])
% ylim([0.05 0.17])
% xlabel('Modulation','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Collision detection accuracy at different SIRs','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% 
% Obstruction=zeros(3,3);
% Obstruction_MIMO=zeros(3,3);
% 
% Obstruction(:,1) = xlsread('Variety_condition_testing.xlsx','J73:J75');
% Obstruction(:,2) = xlsread('Variety_condition_testing.xlsx','K73:K75');
% Obstruction(:,3) = xlsread('Variety_condition_testing.xlsx','L73:L75');
% 
% Obstruction_MIMO(:,1) = xlsread('Variety_condition_testing.xlsx','O73:O75');
% Obstruction_MIMO(:,2) = xlsread('Variety_condition_testing.xlsx','P73:P75');
% Obstruction_MIMO(:,3) = xlsread('Variety_condition_testing.xlsx','Q73:Q75');
% 
% 
% Obstruction_x1 = [1 2 3];
% figure(6);
% hbar3 = bar(Obstruction_x1 ,[Obstruction(1,:);Obstruction_MIMO(1,:)]',0.8);
% %legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
% 
% legend({'Emulation','MIMO'},'FontSize',24,'NumColumns',3);
% xticks([1 2 3])
% yticks([0.05 0.1  0.15 ])
% xticklabels(categorical({'BPSK','QPSK','16QAM'}));
% xlim([0.5 3.5])
% ylim([0.05 0.17])
% xlabel('Modulation','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Collision detection accuracy at different SIRs','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% 
% figure(7);
% hbar4 = bar(Obstruction_x1 ,[Obstruction(2,:);Obstruction_MIMO(2,:)]',0.8);
% %legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
% 
% legend({'Emulation','MIMO'},'FontSize',24,'NumColumns',3);
% xticks([1 2 3])
% yticks([0.05 0.1  0.15 ])
% xticklabels(categorical({'BPSK','QPSK','16QAM'}));
% xlim([0.5 3.5])
% ylim([0.05 0.17])
% xlabel('Modulation','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Collision detection accuracy at different SIRs','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% figure(8);
% hbar5 = bar(Obstruction_x1 ,[Obstruction(3,:);Obstruction_MIMO(3,:)]',0.8);
% %legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
% 
% legend({'Emulation','MIMO'},'FontSize',24,'NumColumns',3);
% xticks([1 2 3])
% yticks([0.05 0.1 0.15 ])
% xticklabels(categorical({'BPSK','QPSK','16QAM'}));
% xlim([0.5 3.5])
% ylim([0.05 0.18])
% xlabel('Modulation','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Collision detection accuracy at different SIRs','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% 
% Interferece=zeros(2,3);
% Interferece_MIMO=zeros(2,3);
% 
% Interferece(:,1) = xlsread('Variety_condition_testing.xlsx','J78:J79');
% Interferece(:,2) = xlsread('Variety_condition_testing.xlsx','K78:K79');
% Interferece(:,3) = xlsread('Variety_condition_testing.xlsx','L78:L79');
% 
% Interferece_MIMO(:,1) = xlsread('Variety_condition_testing.xlsx','O78:O79');
% Interferece_MIMO(:,2) = xlsread('Variety_condition_testing.xlsx','P78:P79');
% Interferece_MIMO(:,3) = xlsread('Variety_condition_testing.xlsx','Q78:Q79');
% 
% 
% Interferece_x1 = [1 2 3];
% figure(9);
% hbar7 = bar(Interferece_x1 ,[Interferece(1,:);Interferece_MIMO(1,:)]',0.8);
% %legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
% 
% legend({'Emulation','MIMO'},'FontSize',24,'NumColumns',3);
% xticks([1 2 3])
% yticks([0.9 0.95  1])
% xticklabels(categorical({'BPSK','QPSK','16QAM'}));
% xlim([0.5 3.5])
% ylim([0.9 1])
% xlabel('Modulation','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Collision detection accuracy at different SIRs','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% 
% figure(10);
% hbar8 = bar(Interferece_x1 ,[Interferece(2,:);Interferece_MIMO(2,:)]',0.8);
% %legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);
% 
% legend({'Emulation','MIMO'},'FontSize',24,'NumColumns',3);
% xticks([1 2 3])
% yticks([0.2 0.3 0.4 ])
% xticklabels(categorical({'BPSK','QPSK','16QAM'}));
% xlim([0.5 3.5])
% ylim([0.18 0.42])
% xlabel('Modulation','FontSize',36);
% ylabel('Deviation','FontSize',36);
% %title('Collision detection accuracy at different SIRs','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);


% Emulate_11QAM_Constellation_Tx1 = [-1.0911 - 0.43644i,(-0.21822 -0.43644i),-0.4364 - 1.0911i,...
%     0.4364 - 1.0911i,(0.43644-0.2182i),1.0911 - 0.4364i,...
%     1.0911 + 0.43644i,(0.21822 +0.43644i),0.43644+1.0911i,...
%     -0.43644+1.09i, -0.43644+0.21822i, -1.0911+0.4364i];
% 
% Emulate_11QAM_Constellation_Tx2 = [(-1.0801 -0.46291i),(-0.1543 -0.4629i),-0.4629 - 1.0801i,...
%     0.46291-1.08i,0.4629 - 0.1543i,1.0801 - 0.4629i,...
%     1.08+0.46291i,0.1543+0.46291i,0.46291+1.08i,...
%     -0.46219+1.08i, -0.462191+0.1543i,-1.0801+0.4629i];
% 
% 
% 
% Emulate_9QAM_Constellation_Tx1 = [0.6546 + 0i,-0.6546 + 0i,0 - 0.6546i,0 + 0.6546i,...
%     -0.65465 + 0.8728i,-0.65465 - 0.8728i, 0.65465 + 0.8728i,0.65465 - 0.8728i];
% 
% Emulate_9QAM_Constellation_Tx2 = [0.7715 + 0.1543i,-0.7715 + 0.1543i,0.1543 - 0.7715i,0.1543 + 0.7715i,...
%     -0.7715 + 0.7715i,-0.7715 - 0.7715i,0.7715 + 0.7715i,0.7715 - 0.7715i];
% 
% combined_11QAM = (Emulate_11QAM_Constellation_Tx1 + Emulate_11QAM_Constellation_Tx2)/2;
% combined_9QAM = (Emulate_9QAM_Constellation_Tx1 + Emulate_9QAM_Constellation_Tx2)/2;
% 
% figure(8)
% scatter(real(combined_11QAM),imag(combined_11QAM),'filled','LineWidth',100);
% hold on
% scatter(real(combined_9QAM),imag(combined_9QAM),'filled','d','LineWidth',100);
% legend({'12QAM','8QAM'},'FontSize',34,'NumColumns',2);
% 
% QPSK_D_MMSE=zeros(10,1);
% QPSK_D_LS=zeros(10,1);
% QPSK_D_MIMO=zeros(10,1);
% 
% QPSK_D_MMSE(:,1) = xlsread('channel_est.xlsx','G10:G19');
% QPSK_D_LS(:,1) = xlsread('channel_est.xlsx','I10:I19');
% QPSK_D_MIMO(:,1) = xlsread('channel_est.xlsx','E23:E32');
% 
% figure(9)
% x_D = 1:10;%categorical({'BPSK','QPSK','16QAM','Random'});
% plot(x_D,QPSK_D_MMSE,'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
% hold on
% plot(x_D,QPSK_D_LS,'r>-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_D,QPSK_D_MIMO,'B+-','LineWidth',3,'MarkerSize',24);
% 
% xticks([1 2 3 4 5 6 7 8 9 10])
% yticks([0 0.05 0.1 0.15 ])
% xticklabels(categorical({'2','4','6','8','10','12','14','16','18','20'}));
% legend({'MMSE','LS','MIMO'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
% xlim([1 10])
% ylim([0.00 0.16])
% xlabel('SNR(dB)','FontSize',36);
% ylabel('BER','FontSize',36);
% %title('Minimal distance between constellation points','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);
% 
% 
% QAM16_D_MMSE=zeros(10,1);
% QAM16_D_LS=zeros(10,1);
% QAM16_D_MIMO=zeros(10,1);
% 
% QAM16_D_MMSE(:,1) = xlsread('channel_est.xlsx','K10:K19');
% QAM16_D_LS(:,1) = xlsread('channel_est.xlsx','M10:M19');
% QAM16_D_MIMO(:,1) = xlsread('channel_est.xlsx','G23:G32');
% 
% figure(10)
% x_D = 1:10;%categorical({'BPSK','QPSK','16QAM','Random'});
% plot(x_D,QAM16_D_MMSE,'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
% hold on
% plot(x_D,QAM16_D_LS,'r>-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_D,QAM16_D_MIMO,'B+-','LineWidth',3,'MarkerSize',24);
% 
% xticks([1 2 3 4 5 6 7 8 9 10])
% yticks([0 0.1 0.2 0.3 0.4 0.5])
% xticklabels(categorical({'2','4','6','8','10','12','14','16','18','20'}));
% legend({'MMSE','LS','MIMO'},'FontSize',36,'Orientation','horizontal','NumColumns',4);
% xlim([1 10])
% ylim([0.00 0.52])
% xlabel('SNR(dB)','FontSize',36);
% ylabel('BER','FontSize',36);
% %title('Minimal distance between constellation points','FontSize',48);
% set(gca,'looseInset',[0 0 0 0],'FontSize',36);



Deviation_H=zeros(4,4);

Deviation_H(:,1) = xlsread('channel_est.xlsx','B41:E41');
Deviation_H(:,2) = xlsread('channel_est.xlsx','H41:K41');
Deviation_H(:,3) = xlsread('channel_est.xlsx','N41:Q41');
Deviation_H(:,4) = xlsread('channel_est.xlsx','T41:W41');


figure(11);
x_d = 1:4;
hbar2 = bar(x_d ,Deviation_H',0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'MMSE','ZF','ZuHe','MIMO'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4])
yticks([0.9 1])
xticklabels(categorical({'LoS','Doppler','Interference','Blockage'}));
xlim([0.5 4.5])
ylim([0.85 1.057])
xlabel('Channel Condition','FontSize',36);
ylabel('{\Delta}d','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

dPhase=zeros(3,4);


dPhase(:,1) = xlsread('channel_est.xlsx','A78:C78');
dPhase(:,2) = xlsread('channel_est.xlsx','A82:C82');
dPhase(:,3) = xlsread('channel_est.xlsx','B74:D74');
dPhase(:,4) = xlsread('channel_est.xlsx','X74:Z74');
dPhase(:,6) = xlsread('channel_est.xlsx','N74:P74');
dPhase(:,5) = xlsread('channel_est.xlsx','T74:V74');


figure(12);
x_d = 1:6;
hbar2 = bar(x_d ,dPhase(2:3,:)',0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'MMSE','ZuHe','MIMO'},'FontSize',48,'NumColumns',3);
xticks([1 2 3 4 5 6])
yticks([0 20 40])
xticklabels(categorical({'Outdoor','Corridor','Indoor','Confined','Blockage','Interference'}));
xlim([0.5 6.5])
ylim([0 41])
xlabel('Channel Condition','FontSize',36);
ylabel('Phase shift','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


df=zeros(6,3);

df(:,1) = xlsread('Variety_condition_testing.xlsx','B85:G85');
df(:,2) = xlsread('Variety_condition_testing.xlsx','B86:G86');
df(:,3) = xlsread('Variety_condition_testing.xlsx','B87:G87');


figure(13);
x_df = 1:6;
hbar2 = bar(x_df ,df(:,1),0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'{\Delta}f'},'FontSize',48,'NumColumns',3);
xticks([1 2 3 4 5 6 ])
yticks([0 10 20 ])
xticklabels(categorical({'Outdoor','Corridor','Indoor','Confined','Blockage','Interference'}));
xlim([0.5 6.5])
ylim([0 21])
xlabel('Channel Condition','FontSize',36);
ylabel('{\Delta}f','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

figure(14);
x_df = 1:6;
hbar2 = bar(x_df ,df(:,3),0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'{\Delta}p'},'FontSize',48,'NumColumns',3);
xticks([1 2 3 4 5 6 ])
yticks([0 50 100])
xticklabels(categorical({'Outdoor','Corridor','Indoor','Confined','Blockage','Interference'}));
xlim([0.5 6.5])
ylim([0 103])
xlabel('Channel Condition','FontSize',36);
ylabel('{\Delta}p','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);



dFR=zeros(2,4);


dFR(:,1) = xlsread('channel_est.xlsx','A86:C86');
dFR(:,2) = xlsread('channel_est.xlsx','D86:E86');
dFR(:,3) = xlsread('channel_est.xlsx','G86:H86');
dFR(:,4) = xlsread('channel_est.xlsx','J86:K86');
dFR(:,5) = xlsread('channel_est.xlsx','M86:N86');
dFR(:,6) = xlsread('channel_est.xlsx','Q86:R86');


figure(15);
x_d = 1:6;
hbar2 = bar(x_d ,dFR',0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'ZuHe','MIMO'},'FontSize',24,'NumColumns',3);
xticks([1 2 3 4 5 6])
yticks([0 300 600])
xticklabels(categorical({'Outdoor','Corridor','Indoor','Confined','Blockage','Interference'}));
xlim([0.5 6.5])
ylim([0 610])
xlabel('Channel Condition','FontSize',36);
ylabel('Frequency shift(Hz)','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

Datarate_Indoor=zeros(5,1);
Datarate_corridor=zeros(5,1);
Datarate_Outdoor=zeros(5,1);

Datarate_Outdoor(:,1) = xlsread('Variety_condition_testing.xlsx','AJ5:AJ9');

Datarate_corridor(:,1) = xlsread('Variety_condition_testing.xlsx','AJ27:AGJ31');

Datarate_indoor(:,1) = xlsread('Variety_condition_testing.xlsx','AJ45:AJ49');


figure(16)
x_1 = 1:5;%categorical({'BPSK','QPSK','16QAM','Random'});
plot(x_1,fliplr(Datarate_Outdoor'),'gv-','LineWidth',3,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,fliplr(Datarate_corridor'),'r>-','LineWidth',3,'MarkerSize',24);
hold on
plot(x_1,fliplr(Datarate_indoor'),'b*-','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([11 12])
xticklabels(categorical({'2','4','6','8','10'}));
legend({'Outdoor','Corridor','Indoor'},'FontSize',36,'Orientation','horizontal','NumColumns',3);
xlim([1 5])
ylim([10.7 12.1])
xlabel('Distance(m)','FontSize',36);
ylabel('Datarate(Mbps)','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);






dPhase1(:,1) = xlsread('channel_est.xlsx','C74:D74');
dPhase1(:,2) = xlsread('channel_est.xlsx','I74:J74');
dPhase1(:,3) = xlsread('channel_est.xlsx','O74:P74');
dPhase1(:,4) = xlsread('channel_est.xlsx','U74:V74');


figure(18);
x_d1 = 1:4;
hbar2 = bar(x_d1 ,dPhase1',0.8);
%legend({'Correctly decoded(Emulated)','Preamble decoded but packet lost(Emulated)','Preamble lost(Emulated)'},'FontSize',24);

legend({'TransFi','Commodity WiFi'},'FontSize',42,'NumColumns',3);
xticks([1 2 3 4])
yticks([0 50 100])
xticklabels(categorical({'Static','With Mobility','Interference','Blockage'}));
xlim([0.5 4.5])
ylim([0 102])
xlabel('Channel Condition','FontSize',36);
ylabel('Phase shift','FontSize',36);
%title('Collision detection accuracy at different SIRs','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

PRR_LSIG(1,:) = xlsread('7.1.1_constellation_distance.xlsx','AI14:AI18');
PRR_LSIG(2,:) = xlsread('7.1.1_constellation_distance.xlsx','AJ14:AJ18');
PRR_LSIG(3,:) = xlsread('7.1.1_constellation_distance.xlsx','AK14:AK18');
PRR_LSIG(4,:) = xlsread('7.1.1_constellation_distance.xlsx','AL14:AL18');


PRR_LLTF(1,:) = xlsread('7.1.1_constellation_distance.xlsx','AN14:AN18');
PRR_LLTF(2,:) = xlsread('7.1.1_constellation_distance.xlsx','AO14:AO18');
PRR_LLTF(3,:) = xlsread('7.1.1_constellation_distance.xlsx','AP14:AP18');
PRR_LLTF(4,:) = xlsread('7.1.1_constellation_distance.xlsx','AQ14:AQ18');



figure(19)
x_1 = 1:5;
plot(x_1,PRR_LLTF(1,:),'gv-','LineWidth',4,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,PRR_LLTF(2,:),'r*-','LineWidth',4,'MarkerSize',24);
hold on
plot(x_1,PRR_LLTF(3,:),'ks-','LineWidth',4,'MarkerSize',24);
hold on
plot(x_1,PRR_LLTF(4,:),'b>-','LineWidth',4,'MarkerSize',24);

% hold on
% plot(x_1,PRR_4TX(1,:),'c<-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,PRR_4TX(2,:),'y^-','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([0.4 0.6 0.8 1]);
xticklabels(categorical({'2','4','6','8','10'}));
legend({'Indoor','Confined','Blockage','Interference'},'FontSize',24,'Orientation','horizontal','NumColumns',2);
xlim([1 5])
ylim([0.50 1.28])
xlabel('Distance(m)','FontSize',36);
ylabel('Detection rate','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

figure(20)
x_1 = 1:5;
plot(x_1,PRR_LSIG(1,:),'gv-','LineWidth',4,'MarkerSize',24);%'MarkerFaceColor','y',
hold on
plot(x_1,PRR_LSIG(2,:),'r*-','LineWidth',4,'MarkerSize',24);
hold on
plot(x_1,PRR_LSIG(3,:),'ks-','LineWidth',4,'MarkerSize',24);
hold on
plot(x_1,PRR_LSIG(4,:),'b>-','LineWidth',4,'MarkerSize',24);

% hold on
% plot(x_1,PRR_4TX(1,:),'c<-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,PRR_4TX(2,:),'y^-','LineWidth',3,'MarkerSize',24);

xticks([1 2 3 4 5])
yticks([0.4 0.6 0.8 1]);
xticklabels(categorical({'2','4','6','8','10'}));
legend({'Indoor','Confined','Blockage','Interference'},'FontSize',24,'Orientation','horizontal','NumColumns',2);
xlim([1 5])
ylim([0.45 1.28])
xlabel('Distance(m)','FontSize',36);
ylabel('Detection rate','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);


BER_OFDMA(:,1) = xlsread('Variety_condition_testing.xlsx','D94:E94');
BER_OFDMA(:,2) = xlsread('Variety_condition_testing.xlsx','F94:G94');
BER_OFDMA(:,3) = xlsread('Variety_condition_testing.xlsx','H94:I94');




figure(21)
x_BER = 1:3;
bar(x_BER,BER_OFDMA',0.8);

% hold on
% plot(x_1,PRR_4TX(1,:),'c<-','LineWidth',3,'MarkerSize',24);
% hold on
% plot(x_1,PRR_4TX(2,:),'y^-','LineWidth',3,'MarkerSize',24);

xticks([1 2 3])
yticks([0 10 20]);
xticklabels(categorical({'BPSK','QPSK','16QAM'}));
legend({'TransFi','Commodity OFDMA'},'FontSize',24,'Orientation','horizontal','NumColumns',2);
xlim([0.6 3.6])
ylim([0 24])
xlabel('1% BER','FontSize',36);
ylabel('SNR','FontSize',36);
%title('Minimal distance between constellation points','FontSize',48);
set(gca,'looseInset',[0 0 0 0],'FontSize',36);

