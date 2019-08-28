module task5(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
	`define ZERO		7'b1000000
	`define ONE			7'b1111001
	`define TWO			7'b0100100
	`define THREE		7'b0110000
	`define FOUR		7'b0011001
	`define FIVE		7'b0010010
	`define SIX			7'b0000010
	`define SEVEN		7'b1111000
	`define EIGHT		7'b0000000
	`define NINE		7'b0010000
	`define A			7'b0001000
	`define B			7'b0000011
	`define C			7'b1000110
	`define D			7'b0100001
	`define E			7'b0000110
	`define F			7'b0001110
	`define DASH		7'b0111111
	`define BLANK		7'b1111111
	`define T5_STATE_0	3'd0
	`define T5_STATE_1	3'd1
	`define T5_STATE_2	3'd2
	`define T5_STATE_3	3'd3
	`define T5_STATE_4	3'd4
	`define T5_STATE_5	3'd5
	
	reg [2:0] state;
	reg [7:0] ct_addr_c2, ct_rddata_c2;
	reg en, rdy, key_valid;
	reg [23:0] key;
	
	// ct_mem for c2
    ct_mem ct(.address(ct_addr_c2), .clock(CLOCK_50), .data(/*No use*/), .wren(1'b0), .q(ct_rddata_c2));
    doublecrack dc(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en), .rdy(rdy), .key(key), .key_valid(key_valid), .ct_addr(ct_addr_c2), .ct_rddata(ct_rddata_c2));

    // your code here
	always_ff@(posedge CLOCK_50 or negedge KEY[3]) begin
		if(KEY[3] == 0) begin
			state <= `T5_STATE_1;
			en <= 0;
			HEX0 <= `BLANK;
			HEX1 <= `BLANK;
			HEX2 <= `BLANK;
			HEX3 <= `BLANK;
			HEX4 <= `BLANK;
			HEX5 <= `BLANK;
		end
		else begin
			case(state) 
				`T5_STATE_0: begin
					state <= `T5_STATE_0;
					en <= 0;
					HEX0 <= `BLANK;
					HEX1 <= `BLANK;
					HEX2 <= `BLANK;
					HEX3 <= `BLANK;
					HEX4 <= `BLANK;
					HEX5 <= `BLANK;
				end
				
				`T5_STATE_1: begin
					if(rdy == 1) begin
						en <= 1;
					end	
					state <= `T5_STATE_2;
				end
				
				`T5_STATE_2: begin
					if(en == 1) begin
						en <= 0;
					end
					state <= `T5_STATE_4; 
				end
				
				`T5_STATE_4: begin
					if(rdy == 0) begin
						state <= `T5_STATE_4;
					end
					else begin
						if(key_valid == 1) begin
							case (key[3:0])
								4'd0: HEX0 <= `ZERO;
								4'd1: HEX0 <= `ONE;
								4'd2: HEX0 <= `TWO;
								4'd3: HEX0 <= `THREE;
								4'd4: HEX0 <= `FOUR;
								4'd5: HEX0 <= `FIVE;
								4'd6: HEX0 <= `SIX;
								4'd7: HEX0 <= `SEVEN;
								4'd8: HEX0 <= `EIGHT;
								4'd9: HEX0 <= `NINE;
								4'd10: HEX0 <= `A;
								4'd11: HEX0 <= `B;
								4'd12: HEX0 <= `C;
								4'd13: HEX0 <= `D;
								4'd14: HEX0 <= `E;
								4'd15: HEX0 <= `F;
								default: HEX0 <= `BLANK;
							endcase
							
							case (key[7:4])
								4'd0: HEX1 <= `ZERO;
								4'd1: HEX1 <= `ONE;
								4'd2: HEX1 <= `TWO;
								4'd3: HEX1 <= `THREE;
								4'd4: HEX1 <= `FOUR;
								4'd5: HEX1 <= `FIVE;
								4'd6: HEX1 <= `SIX;
								4'd7: HEX1 <= `SEVEN;
								4'd8: HEX1 <= `EIGHT;
								4'd9: HEX1 <= `NINE;
								4'd10: HEX1 <= `A;
								4'd11: HEX1 <= `B;
								4'd12: HEX1 <= `C;
								4'd13: HEX1 <= `D;
								4'd14: HEX1 <= `E;
								4'd15: HEX1 <= `F;
								default: HEX0 <= `BLANK;
							endcase
							
							case (key[11:8])
								4'd0: HEX2 <= `ZERO;
								4'd1: HEX2 <= `ONE;
								4'd2: HEX2 <= `TWO;
								4'd3: HEX2 <= `THREE;
								4'd4: HEX2 <= `FOUR;
								4'd5: HEX2 <= `FIVE;
								4'd6: HEX2 <= `SIX;
								4'd7: HEX2 <= `SEVEN;
								4'd8: HEX2 <= `EIGHT;
								4'd9: HEX2 <= `NINE;
								4'd10: HEX2 <= `A;
								4'd11: HEX2 <= `B;
								4'd12: HEX2 <= `C;
								4'd13: HEX2 <= `D;
								4'd14: HEX2 <= `E;
								4'd15: HEX2 <= `F;
								default: HEX2 <= `BLANK;
							endcase
							
							case (key[15:12])
								4'd0: HEX3 <= `ZERO;
								4'd1: HEX3 <= `ONE;
								4'd2: HEX3 <= `TWO;
								4'd3: HEX3 <= `THREE;
								4'd4: HEX3 <= `FOUR;
								4'd5: HEX3 <= `FIVE;
								4'd6: HEX3 <= `SIX;
								4'd7: HEX3 <= `SEVEN;
								4'd8: HEX3 <= `EIGHT;
								4'd9: HEX3 <= `NINE;
								4'd10: HEX3 <= `A;
								4'd11: HEX3 <= `B;
								4'd12: HEX3 <= `C;
								4'd13: HEX3 <= `D;
								4'd14: HEX3 <= `E;
								4'd15: HEX3 <= `F;
								default: HEX3 <= `BLANK;
							endcase
							
							case (key[19:16])
								4'd0: HEX4 <= `ZERO;
								4'd1: HEX4 <= `ONE;
								4'd2: HEX4 <= `TWO;
								4'd3: HEX4 <= `THREE;
								4'd4: HEX4 <= `FOUR;
								4'd5: HEX4 <= `FIVE;
								4'd6: HEX4 <= `SIX;
								4'd7: HEX4 <= `SEVEN;
								4'd8: HEX4 <= `EIGHT;
								4'd9: HEX4 <= `NINE;
								4'd10: HEX4 <= `A;
								4'd11: HEX4 <= `B;
								4'd12: HEX4 <= `C;
								4'd13: HEX4 <= `D;
								4'd14: HEX4 <= `E;
								4'd15: HEX4 <= `F;
								default: HEX4 <= `BLANK;
							endcase
							
							case (key[23:20])
								4'd0: HEX5 <= `ZERO;
								4'd1: HEX5 <= `ONE;
								4'd2: HEX5 <= `TWO;
								4'd3: HEX5 <= `THREE;
								4'd4: HEX5 <= `FOUR;
								4'd5: HEX5 <= `FIVE;
								4'd6: HEX5 <= `SIX;
								4'd7: HEX5 <= `SEVEN;
								4'd8: HEX5 <= `EIGHT;
								4'd9: HEX5 <= `NINE;
								4'd10: HEX5 <= `A;
								4'd11: HEX5 <= `B;
								4'd12: HEX5 <= `C;
								4'd13: HEX5 <= `D;
								4'd14: HEX5 <= `E;
								4'd15: HEX5 <= `F;
								default: HEX5 <= `BLANK;
							endcase
						end
						else begin
							HEX0 <= `DASH;
							HEX1 <= `DASH;
							HEX2 <= `DASH;
							HEX3 <= `DASH;
							HEX4 <= `DASH;
							HEX5 <= `DASH;
						end
						state <= `T5_STATE_5;
					end
				end
				
				`T5_STATE_5: begin
					state <= `T5_STATE_5;
					en <= 0;
				end
				
				default: begin
					state <= `T5_STATE_0;
					en <= 0;
					HEX0 <= `BLANK;
					HEX1 <= `BLANK;
					HEX2 <= `BLANK;
					HEX3 <= `BLANK;
					HEX4 <= `BLANK;
					HEX5 <= `BLANK;
				end
			endcase
		end
	end
endmodule: task5
