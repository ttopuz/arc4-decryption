module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
         /* any other ports you need to add */
			 input logic [23:0] key_attempt, input logic [7:0] pt_addr_final, output logic [7:0] pt_rddata_final);

    // For Task 5, you may modify the crack port list above,
    // but ONLY by adding new ports. All predefined ports must be identical.

	`define CRACK_STATE_0		4'd0
	`define CRACK_STATE_1		4'd1
	`define CRACK_STATE_2		4'd2
	`define CRACK_STATE_3		4'd3
	`define CRACK_STATE_4		4'd4
	`define WAIT_PT_1			4'd5
	`define WAIT_PT_2			4'd6
	`define WAIT_PT_3			4'd7
	`define WAIT_PT_4			4'd8
	`define CRACK_STATE_5		4'd9
	`define CRACK_STATE_6		4'd10
	`define CRACK_STATE_7		4'd11
	`define CRACK_STATE_8		4'd12
	`define CRACK_STATE_9		4'd13
	
    // your code here
	reg en_arc4, rdy_arc4, pt_wren_arc4, pt_wren_crack, pt_wren;
	reg [3:0] state;
	reg [7:0] message_length, pt_addr_arc4, pt_wrdata_arc4, pt_addr_crack, i, tmp_char, pt_rddata, pt_addr;
	
	assign pt_addr = rdy_arc4 == 0 ? pt_addr_arc4 : rdy == 0 ? pt_addr_crack : pt_addr_final;
	assign pt_wren = rdy_arc4 == 0 ? pt_wren_arc4 : rdy == 0 ? pt_wren_crack : 1'b0;
	assign pt_rddata_final = pt_rddata;

    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(.address(pt_addr), .clock(clk), .data(pt_wrdata_arc4), .wren(pt_wren), .q(pt_rddata));
    arc4 a4(.clk(clk), .rst_n(rst_n), .en(en_arc4), .rdy(rdy_arc4), .key(key_attempt), .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr_arc4), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata_arc4), .pt_wren(pt_wren_arc4));

    // your code here
	always_ff@(posedge clk or negedge rst_n) begin
		if(rst_n == 0) begin
			state <= `CRACK_STATE_0;
			rdy <= 1;
			i <= 1;
			en_arc4 <= 0;
			key <= 0;
			key_valid <= 0;
		end
		else if(rdy == 1 && en == 1) begin
			state <= `CRACK_STATE_1;
			rdy <= 0;
		end
		else begin
			case(state) 
				`CRACK_STATE_0: begin
					state <= `CRACK_STATE_0;
					rdy <= 1;
					i <= 1;
					en_arc4 <= 0;
					key <= 0;
					key_valid <= 0;
				end
				
				`CRACK_STATE_1: begin
					if(rdy_arc4 == 1) begin
						en_arc4 <= 1;
					end
					state <= `CRACK_STATE_2;
				end
				
				`CRACK_STATE_2: begin
					if(en_arc4 == 1) begin
						en_arc4 <= 0;
					end
					state <= `CRACK_STATE_3;
				end
				
				`CRACK_STATE_3: begin
					if(rdy_arc4 == 0) begin
						state <= `CRACK_STATE_3;
					end
					else begin
						state <= `CRACK_STATE_4;
					end
				end
				
				`CRACK_STATE_4: begin
					state <= `WAIT_PT_1;
					pt_addr_crack <= 0;
					pt_wren_crack <= 0;
				end
				
				`WAIT_PT_1: begin
					state <= `WAIT_PT_2;
				end
				
				`WAIT_PT_2: begin
					state <= `CRACK_STATE_5;
				end
				
				`CRACK_STATE_5: begin
					state <= `CRACK_STATE_6;
					message_length <= pt_rddata;
				end
				
				`CRACK_STATE_6: begin
					state <= `WAIT_PT_3;
					pt_addr_crack <= i;
				end
				
				`WAIT_PT_3: begin
					state <= `WAIT_PT_4;
				end
				
				`WAIT_PT_4: begin
					state <= `CRACK_STATE_7;
				end
				
				`CRACK_STATE_7: begin
					state <= `CRACK_STATE_8;
					tmp_char <= pt_rddata;
				end
				
				`CRACK_STATE_8: begin
					if(tmp_char >= 8'h20 && tmp_char <= 8'h7E && i <= message_length) begin
						state <= `CRACK_STATE_6;
						i <= i + 1;
					end
					else if(i == message_length + 1) begin
						state <= `CRACK_STATE_9;
						key <= key_attempt;
						key_valid <= 1;
					end
					else begin
						state <= `CRACK_STATE_0;
					end
				end
				
				`CRACK_STATE_9: begin
					state <= `CRACK_STATE_9;
					rdy <= 1;
					key <= key_attempt;
					key_valid <= 1;
				end
				
				default: begin
					state <= `CRACK_STATE_0;
					rdy <= 1;
					i <= 1;
					en_arc4 <= 0;
					key <= 0;
					key_valid <= 0;
				end
			endcase
		end
	end
endmodule: crack
