module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    // your code here
    `define DCRACK_STATE_0		4'd0
	`define DCRACK_STATE_1		4'd1
	`define DCRACK_STATE_2		4'd2
	`define DCRACK_STATE_3		4'd3
	`define DCRACK_STATE_4		4'd4
	`define DCRACK_STATE_5		4'd5
	`define DCRACK_STATE_6		4'd6
	`define DCRACK_STATE_7		4'd7
	`define DCRACK_STATE_8		4'd8
	`define DCRACK_STATE_9 		4'd9
	`define DCRACK_STATE_10		4'd10
	
	reg en_c1, en_c2, rdy_c1, rdy_c2, key_valid_c1, key_valid_c2, pt_wren_final;
	reg [3:0] state;
	reg [7:0] ct_addr_c1, ct_addr_c2, ct_rddata_c1, ct_rddata_c2, pt_addr_final, pt_wrdata_final, pt_rddata_final, message_length, i, pt_rddata_final_c1, pt_rddata_final_c2;
	reg [23:0] key_attempt_c1, key_attempt_c2, key_c1, key_c2;
	
    // this memory must have the length-prefixed plaintext if key_valid
	// Final PT goes here
    pt_mem pt(.address(pt_addr_final), .clock(clk), .data(pt_wrdata_final), .wren(pt_wren_final), .q(pt_rddata_final));
	
	// Added new instance of ct_mem for c1
	ct_mem ct_c1(.address(ct_addr_c1), .clock(clk), .data(/*No use*/), .wren(1'b0), .q(ct_rddata_c1));

    // for this task only, you may ADD ports to crack
    crack c1(.clk(clk), .rst_n(rst_n), .en(en_c1), .rdy(rdy_c1), .key(key_c1), .key_valid(key_valid_c1), .ct_addr(ct_addr_c1), .ct_rddata(ct_rddata_c1), .key_attempt(key_attempt_c1), .pt_addr_final(pt_addr_final), .pt_rddata_final(pt_rddata_final_c1)); // Even
    crack c2(.clk(clk), .rst_n(rst_n), .en(en_c2), .rdy(rdy_c2), .key(key_c2), .key_valid(key_valid_c2), .ct_addr(ct_addr_c2), .ct_rddata(ct_rddata_c2), .key_attempt(key_attempt_c2), .pt_addr_final(pt_addr_final), .pt_rddata_final(pt_rddata_final_c2)); // Odd
    
	assign key = key_valid_c1 == 1 ? key_c1 : key_valid_c2 == 1 ? key_c2 : 24'dz;
	assign key_valid = key_valid_c1 == 1 ? key_valid_c1 : key_valid_c2 == 1 ? key_valid_c2 : 1'b0;
	assign ct_addr = ct_addr_c2;
	assign ct_rddata_c2 = ct_rddata;
	
	
    // your code here
	always_ff@(posedge clk or negedge rst_n) begin
		if(rst_n == 0) begin
			state <= `DCRACK_STATE_0;
			rdy <= 1;
			en_c1 <= 0;
			en_c2 <= 0;
			key_attempt_c1 <= 24'd0;
			key_attempt_c2 <= 24'd1;
			i <= 0;
			pt_addr_final <= 0;
			pt_wren_final <= 0;
		end
		else if(rdy == 1 && en == 1) begin
			state <= `DCRACK_STATE_1;
			rdy <= 0;
		end
		else begin
			case(state)
				`DCRACK_STATE_0: begin
					state <= `DCRACK_STATE_0;
					rdy <= 1;
					en_c1 <= 0;
					en_c2 <= 0;
					key_attempt_c1 <= 24'd0;
					key_attempt_c2 <= 24'd1;
					i <= 0;
					pt_addr_final <= 0;
					pt_wren_final <= 0;
				end
				
				`DCRACK_STATE_1: begin
					if(rdy_c1 == 1) begin
						en_c1 <= 1;
					end
					if(rdy_c2 == 1) begin
						en_c2 <= 1;
					end
					state <= `DCRACK_STATE_2;
				end
				
				`DCRACK_STATE_2: begin
					if(en_c1 == 1) begin
						en_c1 <= 0;
					end
					if(en_c2 == 1) begin
						en_c2 <= 0;
					end
					state <= `DCRACK_STATE_3;
				end
				
				`DCRACK_STATE_3: begin
					if(rdy_c1 == 0 || rdy_c2 == 0) begin
						state <= `DCRACK_STATE_3;
					end
					else begin
						state <= `DCRACK_STATE_4;
					end
				end
				
				`DCRACK_STATE_4: begin
					if((key_attempt_c1 != 24'hFFFFFF && key_attempt_c2 != 24'hFFFFFF) && (key_valid_c1 == 0 && key_valid_c2 == 0)) begin
						key_attempt_c1 <= key_attempt_c1 + 2;
						key_attempt_c2 <= key_attempt_c2 + 2;
						state <= `DCRACK_STATE_1;
					end
					else if((key_attempt_c1 == 24'hFFFFFF || key_attempt_c2 == 24'hFFFFFF) && (key_valid_c1 == 0 && key_valid_c2 == 0)) begin
						state <= `DCRACK_STATE_0;
					end
					else begin
						state <= `DCRACK_STATE_5;
					end
				end
				
				`DCRACK_STATE_5: begin
					//rdy <= 1;
					pt_addr_final <= i;
					pt_wren_final <= 0;
					state <= `DCRACK_STATE_6;
				end
				
				`DCRACK_STATE_6: begin
					state <= `DCRACK_STATE_7;
				end
				
				`DCRACK_STATE_7: begin
					pt_wrdata_final <= key_valid_c1 == 1 ? pt_rddata_final_c1 : key_valid_c2 == 1 ? pt_rddata_final_c2 : 7'dz;
					state <= `DCRACK_STATE_8;
				end
				
				`DCRACK_STATE_8: begin
					if(i == 0) begin
						message_length <= pt_wrdata_final;
					end
					state <= `DCRACK_STATE_9;
				end
				
				`DCRACK_STATE_9: begin
					pt_wren_final <= 1;
					if(i < message_length) begin
						i <= i + 1;
						state <= `DCRACK_STATE_5;
					end
					else begin
						state <= `DCRACK_STATE_10;
					end
				end
				
				`DCRACK_STATE_10: begin
					rdy <= 1;
					state <= `DCRACK_STATE_10;
				end
				
				default: begin
					state <= `DCRACK_STATE_0;
					rdy <= 1;
					en_c1 <= 0;
					en_c2 <= 0;
					key_attempt_c1 <= 24'd0;
					key_attempt_c2 <= 24'd1;
					i <= 0;
					pt_addr_final <= 0;
					pt_wren_final <= 0;
				end
			endcase
		end
	end
endmodule: doublecrack
	