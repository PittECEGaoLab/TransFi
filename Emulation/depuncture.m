function [encoder_input_bit] = depuncture(input_seg)

datarate= 5/6;
if datarate == 5/6
    temp_mat = reshape(input_seg,6,length(input_seg)/6);
   % temp_mat_distance =reshape(distance_mat',6,52*2);
   % distance_input_mat = [temp_mat_distance(1:3,:);zeros(2,52*2);temp_mat_distance(4:5,:);zeros(2,52*2);temp_mat_distance(6,:)];
   % distance_input = reshape(distance_input_mat,1,[]);

%         distance_mat1 = rand(10,52);
%         distance_mat1(4:5,:) = 0;
%         distance_mat1(8:9,:) = 0; 

    encoder_input_mat = [temp_mat(1:3,:);zeros(2,length(input_seg)/6)+5;temp_mat(4:5,:);zeros(2,length(input_seg)/6)+5;temp_mat(6,:)];
    encoder_input_bit = reshape(encoder_input_mat,1,[]);
    %distance_array = reshape(distance_input,1,[]);
    %distance_array1 = reshape(distance_mat1,1,[]);

    %encoder_input = encoder_input_bit;%; distance_array]; %distance_array1];
end
