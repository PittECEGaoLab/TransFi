function [outputs_mat1,outputs_mat]= weight_bit(start_node, trellis_map)%#codegen
    
%     This section is used to compute the different weights at the 6 bit
%     64QAM constellation
%     bit_input = de2bi(0:1:63);
%     bit_modulated = wlanConstellationMap(reshape(bit_input',[],1),6);
%     scatter(real(bit_modulated),imag(bit_modulated));
% 
%     shift_bit1 = ~bit_input(:,1);
%     bit_input_shift1 =[shift_bit1 bit_input(:,2:6)];
%     bit_modulated_shitf1 = wlanConstellationMap(reshape(bit_input_shift1',[],1),6);
%     distance1 = mean(abs(bit_modulated_shitf1 - bit_modulated));
% 
%     shift_bit2 = ~bit_input(:,2);
%     bit_input_shift2 =[ bit_input(:,1) shift_bit2 bit_input(:,3:6)];
%     bit_modulated_shitf2 = wlanConstellationMap(reshape(bit_input_shift2',[],1),6);
%     distance2 = mean(abs(bit_modulated_shitf2 - bit_modulated));
% 
%     shift_bit3 = ~bit_input(:,3);
%     bit_input_shift3 =[ bit_input(:,1:2) shift_bit3 bit_input(:,4:6)];
%     bit_modulated_shitf3 = wlanConstellationMap(reshape(bit_input_shift3',[],1),6);
%     distance3 = mean(abs(bit_modulated_shitf3 - bit_modulated));
% 
%     shift_bit4 = ~bit_input(:,4);
%     bit_input_shift4 =[bit_input(:,1:3) shift_bit4 bit_input(:,5:6)];
%     bit_modulated_shitf4 = wlanConstellationMap(reshape(bit_input_shift4',[],1),6);
%     distance4 = mean(abs(bit_modulated_shitf4 - bit_modulated));
% 
%     shift_bit5 = ~bit_input(:,5);
%     bit_input_shift5 =[bit_input(:,1:4) shift_bit5 bit_input(:,6)];
%     bit_modulated_shitf5 = wlanConstellationMap(reshape(bit_input_shift5',[],1),6);
%     distance5 = mean(abs(bit_modulated_shitf5 - bit_modulated));
% 
%     shift_bit6 = ~bit_input(:,6);
%     bit_input_shift6 =[bit_input(:,1:5) shift_bit6];
%     bit_modulated_shitf6 = wlanConstellationMap(reshape(bit_input_shift6',[],1),6);
%     distance6 = mean(abs(bit_modulated_shitf6 - bit_modulated));
% 
%     percentage1 = distance1/(distance1 + distance2 + distance3 + distance4 + distance5 + distance6);
%     percentage2 = distance2/(distance1 + distance2 + distance3 + distance4 + distance5 + distance6);
%     percentage3 = distance3/(distance1 + distance2 + distance3 + distance4 + distance5 + distance6);
%     percentage4 = distance4/(distance1 + distance2 + distance3 + distance4 + distance5 + distance6);
%     percentage5 = distance5/(distance1 + distance2 + distance3 + distance4 + distance5 + distance6);
%     percentage6 = distance6/(distance1 + distance2 + distance3 + distance4 + distance5 + distance6);
% 
% 
%     bit_input_shift12 =[shift_bit1 shift_bit2 bit_input(:,3:6)];
%     bit_modulated_shitf12 = wlanConstellationMap(reshape(bit_input_shift12',[],1),6);
%     distance12 = mean(abs(bit_modulated_shitf12 - bit_modulated));
% 
%     bit_input_shift13 =[shift_bit1 bit_input(:,2) shift_bit3 bit_input(:,4:6)];
%     bit_modulated_shitf13 = wlanConstellationMap(reshape(bit_input_shift13',[],1),6);
%     distance13 = mean(abs(bit_modulated_shitf13 - bit_modulated));
% 
%     bit_input_shift14 =[shift_bit1 bit_input(:,2:3) shift_bit4 bit_input(:,5:6)];
%     bit_modulated_shitf14 = wlanConstellationMap(reshape(bit_input_shift14',[],1),6);
%     distance14 = mean(abs(bit_modulated_shitf14 - bit_modulated));
% 
%     bit_input_shift15 =[shift_bit1 bit_input(:,2:4) shift_bit5 bit_input(:,6)];
%     bit_modulated_shitf15 = wlanConstellationMap(reshape(bit_input_shift15',[],1),6);
%     distance15 = mean(abs(bit_modulated_shitf15 - bit_modulated));
% 
%     bit_input_shift16 =[shift_bit1 bit_input(:,2:5) shift_bit6];
%     bit_modulated_shitf16 = wlanConstellationMap(reshape(bit_input_shift16',[],1),6);
%     distance16 = mean(abs(bit_modulated_shitf16 - bit_modulated));
% 
%     bit_input_16 = de2bi(0:1:15);
%     bit_modulated_16 = wlanConstellationMap(reshape(bit_input_16',[],1),4);
% 
%     shift_bit1_16 = ~bit_input_16(:,1);
%     bit_input_shift1_16 =[shift_bit1_16 bit_input_16(:,2:4)];
%     bit_modulated_shitf1_16 = wlanConstellationMap(reshape(bit_input_shift1_16',[],1),4);
%     distance1_16 = mean(abs(bit_modulated_shitf1_16 - bit_modulated_16));
% 
%     shift_bit2_16 = ~bit_input_16(:,2);
%     bit_input_shift2_16 =[ bit_input_16(:,1) shift_bit2_16 bit_input_16(:,3:4)];
%     bit_modulated_shitf2_16 = wlanConstellationMap(reshape(bit_input_shift2_16',[],1),4);
%     distance2_16 = mean(abs(bit_modulated_shitf2_16 - bit_modulated_16));
% 
%     shift_bit3_16 = ~bit_input_16(:,3);
%     bit_input_shift3_16 =[ bit_input_16(:,1:2) shift_bit3_16 bit_input_16(:,4)];
%     bit_modulated_shitf3_16 = wlanConstellationMap(reshape(bit_input_shift3_16',[],1),4);
%     distance3_16 = mean(abs(bit_modulated_shitf3_16 - bit_modulated_16));
% 
%     shift_bit4_16 = ~bit_input_16(:,4);
%     bit_input_shift4_16 =[bit_input_16(:,1:3) shift_bit4_16];
%     bit_modulated_shitf4_16 = wlanConstellationMap(reshape(bit_input_shift4_16',[],1),4);
%     distance4_16 = mean(abs(bit_modulated_shitf4_16 - bit_modulated_16));


    % commcnv_plotnextstates(trellis.nextStates);
%     ini_states = de2bi(0:1:63);
%     for i = 1:64  
%         A1(i,1) = bitxor(bitxor(bitxor(bitxor(1,ini_states(i,2)),ini_states(i,3)),ini_states(i,5)),ini_states(i,6));
%         A0(i,1) = bitxor(bitxor(bitxor(bitxor(0,ini_states(i,1)),ini_states(i,2)),ini_states(i,3)),ini_states(i,6));
%         Next_state1(i,:) = [1,ini_states(i,1:5)];
%         Next_state0(i,:) = [0,ini_states(i,1:5)]; 
%     
%         B0(i,1) = bitxor(bitxor(bitxor(bitxor(0,ini_states(i,2)),ini_states(i,3)),ini_states(i,5)),ini_states(i,6));
%         B1(i,1) = bitxor(bitxor(bitxor(bitxor(1,ini_states(i,1)),ini_states(i,2)),ini_states(i,3)),ini_states(i,6));
%     
%     end
%     Output1 = [ini_states A1 B1 Next_state1]; %Output code when input 1
%     Output0 = [ini_states A0 B0 Next_state0]; %Output code when input 0

    %input_seq = randi(2,1,312)-1;

   
     
    next_states = start_node;
    input_bits = 10;
    outputs_mat = zeros(2^(input_bits/2),input_bits/2);
    %weight_mat = zeros(2^(input_bits/2),input_bits/2);
    outputs_mat1 = zeros(2^(input_bits/2),input_bits/2);
    outputs_mat_bits = zeros(2^(input_bits/2),input_bits);
    for j = 1:5    
        current_states = next_states+1;%,'stable');
        %current_bits = bi2de(encoder_input(:,2*j-1:2*j));
        %weight0 = encoder_input(2,2*j-1) + encoder_input(2,2*j);
        %weight1 = encoder_input(2,2*j-1) + encoder_input(3,2*j);
        %weight2 = encoder_input(3,2*j-1) + encoder_input(2,2*j);
        %weight3 = encoder_input(3,2*j-1) + encoder_input(3,2*j);
       % weight_array = [weight0 weight1 weight2 weight3];
        next_states = reshape([trellis_map(2,current_states);trellis_map(5,current_states)],1,[]);
        output_rep = repmat([0 1],1,2^(j-1));
        outputs_mat(:,j) = reshape(repmat(output_rep,2^(input_bits/2)/length(output_rep),1),1,[]);
        outputs_combined = reshape([trellis_map(3,current_states);trellis_map(6,current_states)],1,[]);
        outputs_combined_flip = bi2de(flip(de2bi(outputs_combined),2))';
        %match_location = find( current_bits == outputs_combined_flip(2,1));
        outputs_mat1(:,j) = reshape(repmat(outputs_combined_flip,2^(input_bits/2-1)/length(current_states),1),[],1); 
        outputs_mat_bits(:,(j-1)*2+1:2*j) = de2bi(outputs_mat1(:,j));
        %weight_mat(:,j)  = reshape(repmat([weight_array(1,trellis_map(3,current_states)+1) weight_array(1,trellis_map(6,current_states)+1)],2^(input_bits/2-1)/length(current_states),1),[],1);
    end
    
    outputs_mat1 = [outputs_mat_bits next_states'];
    
