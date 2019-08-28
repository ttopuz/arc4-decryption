module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    // your code here
	`define READY_KSA			4'd0
	`define REQUEST_S_I_KSA		4'd1
	`define GET_S_I_KSA			4'd2
	`define UPDATE_J_KSA		4'd3
	`define REQUEST_S_J_KSA		4'd4
	`define GET_S_J_KSA			4'd5
	`define WRITE_S_I_KSA		4'd6
	`define WRITE_S_J_KSA		4'd7
	`define UPDATE_I_KSA		4'd8
	`define WAIT_S_I_1_KSA		4'd9
	`define WAIT_S_I_2_KSA		4'd10
	`define WAIT_S_J_1_KSA		4'd11
	`define WAIT_S_J_2_KSA		4'd12
	
	reg [3:0] state;
	reg [8:0] i, j;
	reg [7:0] s_i, s_j;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) begin
			state <= `READY_KSA;
			rdy <= 1;
			addr <= 0;
			wrdata <= 0;
			wren <= 0;
			i <= 0;
			j <= 0;
		end
		else if (rdy == 1 && en == 1) begin
			state <= `REQUEST_S_I_KSA;
			rdy <= 0;
		end
		else begin
			case(state)
				`READY_KSA: begin
					state <= `READY_KSA;
					rdy <= 1;
					addr <= 0;
					wrdata <= 0;
					wren <= 0;
					i <= 0;
					j <= 0;
				end
				
				`REQUEST_S_I_KSA: begin
					state <= `WAIT_S_I_1_KSA;
					addr <= i;
				end
				
				`WAIT_S_I_1_KSA: begin
					state <= `WAIT_S_I_2_KSA;
				end
				
				`WAIT_S_I_2_KSA: begin
					state <= `GET_S_I_KSA;
				end
				
				`GET_S_I_KSA: begin
					state <= `UPDATE_J_KSA;
					s_i <= rddata;
				end
				
				`UPDATE_J_KSA: begin
					state <= `REQUEST_S_J_KSA;
					if (i % 3 == 0)
						j <= (j + s_i + key[23:16]) % 256;
					else if (i % 3 == 1)
						j <= (j + s_i + key[15:8]) % 256;
					else
						j <= (j + s_i + key[7:0]) % 256;
				end
				
				`REQUEST_S_J_KSA: begin
					state <= `WAIT_S_J_1_KSA;
					addr <= j;
				end
				
				`WAIT_S_J_1_KSA: begin
					state <= `WAIT_S_J_2_KSA;
				end
				
				`WAIT_S_J_2_KSA: begin
					state <= `GET_S_J_KSA;
				end
				
				`GET_S_J_KSA: begin
					state <= `WRITE_S_I_KSA;
					s_j <= rddata;
				end
				
				`WRITE_S_I_KSA: begin
					state <= `WRITE_S_J_KSA;
					addr <= i;
					wrdata <= s_j;
					wren <= 1;
				end
				
				`WRITE_S_J_KSA: begin
					state <= `UPDATE_I_KSA;
					addr <= j;
					wrdata <= s_i;
					wren <= 1;
				end
				
				`UPDATE_I_KSA: begin
					wren <= 0;
					if(i < 255) begin
						state <= `REQUEST_S_I_KSA;
						i <= i + 1;
					end
					else begin
						state <= `READY_KSA;
						rdy <= 1;
						addr <= 0;
						wrdata <= 0;
					end
				end
				
				default: begin
					state <= `READY_KSA;
					rdy <= 1;
					addr <= 0;
					wrdata <= 0;
					wren <= 0;
				end
			endcase
		end
	end
endmodule: ksa
