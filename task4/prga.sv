module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
	`define READY_PRGA						5'd0
	`define REQUEST_MESSAGE_LENGTH_PRGA		5'd1
	`define WAIT_MESSAGE_LENGTH_1_PRGA		5'd2
	`define WAIT_MESSAGE_LENGTH_2_PRGA		5'd3
	`define GET_MESSAGE_LENGTH_PRGA			5'd4
	`define UPDATE_I_PRGA					5'd5
	`define REQUEST_S_I_PRGA				5'd6
	`define WAIT_S_I_1_PRGA					5'd7
	`define WAIT_S_I_2_PRGA					5'd8
	`define GET_S_I_PRGA					5'd9
	`define UPDATE_J_PRGA					5'd10
	`define REQUEST_S_J_PRGA				5'd11
	`define WAIT_S_J_1_PRGA					5'd12
	`define WAIT_S_J_2_PRGA					5'd13
	`define GET_S_J_PRGA					5'd14
	`define WRITE_S_I_PRGA					5'd15
	`define WRITE_S_J_PRGA					5'd16
	`define REQUEST_S_NEW_PRGA				5'd17
	`define WAIT_S_NEW_1_PRGA				5'd18
	`define WAIT_S_NEW_2_PRGA				5'd19
	`define GET_S_NEW_PRGA					5'd20
	`define UPDATE_K_PRGA					5'd21
	`define REQUEST_CIPHERTEXT_K_PRGA		5'd22
	`define WAIT_CIPHERTEXT_K_1_PRGA		5'd23
	`define WAIT_CIPHERTEXT_K_2_PRGA		5'd24
	`define GET_CIPHERTEXT_K_PRGA			5'd25
	`define UPDATE_PLAINTEXT_K_PRGA			5'd26
	`define WRITE_PLAINTEXT_K_PRGA			5'd27
	`define UPDATE_K_2_PRGA					5'd28
	`define WRITE_1ST_BYTE_PT_PRGA			5'd29
	
	reg [4:0] state;
	reg [8:0] i, j, k;
	reg [7:0] s_i, s_j, message_length, ciphertext_k, plaintext_k;
	reg [7:0] pad[0:255];
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) begin
			state <= `READY_PRGA;
			rdy <= 1;
			s_addr <= 0;
			s_wrdata <= 0;
			s_wren <= 0;
			ct_addr <= 0;
			pt_addr <= 0;
			pt_wrdata <= 0;
			pt_wren <= 0;
			i <= 0;
			j <= 0;
			k <= 0;
			s_i <= 0;
			s_j <= 0;
			message_length <= 0;
		end
		
		else if (rdy == 1 && en == 1) begin
			state <= `REQUEST_MESSAGE_LENGTH_PRGA;
			rdy <= 0;
		end
		
		else begin
			case(state) 
				`READY_PRGA: begin
					state <= `READY_PRGA;
					rdy <= 1;
					s_addr <= 0;
					s_wrdata <= 0;
					s_wren <= 0;
					ct_addr <= 0;
					pt_addr <= 0;
					pt_wrdata <= 0;
					pt_wren <= 0;
					i <= 0;
					j <= 0;
					k <= 0;
					s_i <= 0;
					s_j <= 0;
					message_length <= 0;
				end
				
				// Get message_length
				`REQUEST_MESSAGE_LENGTH_PRGA: begin
					state <= `WAIT_MESSAGE_LENGTH_1_PRGA;
				end
				
				`WAIT_MESSAGE_LENGTH_1_PRGA: begin
					state <= `WAIT_MESSAGE_LENGTH_2_PRGA;
				end
				
				`WAIT_MESSAGE_LENGTH_2_PRGA: begin
					state <= `GET_MESSAGE_LENGTH_PRGA;
				end
				
				`GET_MESSAGE_LENGTH_PRGA: begin
					state <= `UPDATE_I_PRGA;
					message_length <= ct_rddata;
				end
				
				// i = (i+1) mod 256
				`UPDATE_I_PRGA: begin
					state <= `REQUEST_S_I_PRGA;
					i <= (i + 1) % 256;
				end
				
				`REQUEST_S_I_PRGA: begin
					state <= `WAIT_S_I_1_PRGA;
					s_addr <= i;
				end
				
				`WAIT_S_I_1_PRGA: begin
					state <= `WAIT_S_I_2_PRGA;
				end
				
				`WAIT_S_I_2_PRGA: begin
					state <= `GET_S_I_PRGA;
				end
				
				// j = (j+s[i]) mod 256
				`GET_S_I_PRGA: begin
					state <= `UPDATE_J_PRGA;
					s_i <= s_rddata;
				end
				
				`UPDATE_J_PRGA: begin
					state <= `REQUEST_S_J_PRGA;
					j <= (j + s_i) % 256;
				end
				
				`REQUEST_S_J_PRGA: begin
					state <= `WAIT_S_J_1_PRGA;
					s_addr <= j;
				end
				
				`WAIT_S_J_1_PRGA: begin
					state <= `WAIT_S_J_2_PRGA;
				end
				
				`WAIT_S_J_2_PRGA: begin
					state <= `GET_S_J_PRGA;
				end
				
				`GET_S_J_PRGA: begin
					state <= `WRITE_S_I_PRGA;
					s_j <= s_rddata;
				end
				
				// swap values of s[i] and s[j]
				`WRITE_S_I_PRGA: begin
					state <= `WRITE_S_J_PRGA;
					s_addr <= i;
					s_wrdata <= s_j;
					s_wren <= 1;
				end
				
				`WRITE_S_J_PRGA: begin
					state <= `REQUEST_S_NEW_PRGA;
					s_addr <= j;
					s_wrdata <= s_i;
					s_wren <= 1;
				end	
				
				// pad[k] = s[(s[i]+s[j]) mod 256]
				`REQUEST_S_NEW_PRGA: begin
					state <= `WAIT_S_NEW_1_PRGA;
					s_addr <= (s_i + s_j) % 256;
					s_wren <= 0;
				end
				
				`WAIT_S_NEW_1_PRGA: begin
					state <= `WAIT_S_NEW_2_PRGA;
				end
				
				`WAIT_S_NEW_2_PRGA: begin
					state <= `GET_S_NEW_PRGA;
				end
				
				`GET_S_NEW_PRGA: begin
					state <= `UPDATE_K_PRGA;
					pad[k] <= s_rddata;
				end
				
				`UPDATE_K_PRGA: begin
					if(k < message_length - 1) begin
						state <= `UPDATE_I_PRGA;
						k <= k + 1;
					end
					else begin
						state <= `WRITE_1ST_BYTE_PT_PRGA;
						k <= 1;
					end
				end
				
				`WRITE_1ST_BYTE_PT_PRGA: begin
					state <= `REQUEST_CIPHERTEXT_K_PRGA;
					pt_addr <= 0;
					pt_wrdata <= message_length;
					pt_wren <= 1;
				end
				
				`REQUEST_CIPHERTEXT_K_PRGA: begin
					state <= `WAIT_CIPHERTEXT_K_1_PRGA;
					ct_addr <= k;
					pt_wren <= 0;
				end
				
				`WAIT_CIPHERTEXT_K_1_PRGA: begin
					state <= `WAIT_CIPHERTEXT_K_2_PRGA;
				end
				
				`WAIT_CIPHERTEXT_K_2_PRGA: begin
					state <= `GET_CIPHERTEXT_K_PRGA;
				end
				
				`GET_CIPHERTEXT_K_PRGA: begin
					state <= `UPDATE_PLAINTEXT_K_PRGA;
					ciphertext_k <= ct_rddata;
				end
				
				`UPDATE_PLAINTEXT_K_PRGA: begin
					state <= `WRITE_PLAINTEXT_K_PRGA;
					plaintext_k <= pad[k-1] ^ ciphertext_k;
				end
				
				`WRITE_PLAINTEXT_K_PRGA: begin
					state <= `UPDATE_K_2_PRGA;
					pt_addr <= k;
					pt_wrdata <= plaintext_k;
					pt_wren <= 1;
				end
				
				`UPDATE_K_2_PRGA: begin
					if(k < message_length) begin
						state <= `REQUEST_CIPHERTEXT_K_PRGA;
						k <= k + 1;
					end
					else begin
						state <= `READY_PRGA;
						rdy <= 1;
						s_addr <= 0;
						s_wrdata <= 0;
						s_wren <= 0;
						ct_addr <= 0;
						pt_addr <= 0;
						pt_wrdata <= 0;
						pt_wren <= 0;
						i <= 0;
						j <= 0;
						k <= 0;
						s_i <= 0;
						s_j <= 0;
						message_length <= 0;
					end
				end
				
				default: begin
					state <= `READY_PRGA;
					rdy <= 1;
					s_addr <= 0;
					s_wrdata <= 0;
					s_wren <= 0;
					ct_addr <= 0;
					pt_addr <= 0;
					pt_wrdata <= 0;
					pt_wren <= 0;
					i <= 0;
					j <= 0;
					k <= 0;
					s_i <= 0;
					s_j <= 0;
					message_length <= 0;
				end
			endcase
		end
	end
endmodule: prga
