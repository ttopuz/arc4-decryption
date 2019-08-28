module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

	`define T1_STATE_0 			3'd0
	`define T1_STATE_1			3'd1
	`define T1_STATE_2			3'd2
	`define T1_STATE_3			3'd3
	`define T2_STATE_0			3'd4
	`define T2_STATE_1			3'd5
	`define T2_STATE_2			3'd6
			 
	reg en_init, en_ksa, rdy_init, rdy_ksa, wren_init, wren_ksa, wren;
	reg [2:0] state;
	reg [7:0] addr, wrdata;
	reg [7:0] addr_init, addr_ksa, wrdata_init, wrdata_ksa, q;			
	
	s_mem s(.address(addr), .clock(CLOCK_50), .data(wrdata), .wren(wren), .q(q));
	init i(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en_init), .rdy(rdy_init), .addr(addr_init), .wrdata(wrdata_init), .wren(wren_init));
	ksa k(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en_ksa), .rdy(rdy_ksa), .key({14'd0, SW}), .addr(addr_ksa), .rddata(q), .wrdata(wrdata_ksa), .wren(wren_ksa));

    // your code here
	always_ff@(posedge CLOCK_50 or negedge KEY[3]) begin
		if(KEY[3] == 0) begin
			state <= `T1_STATE_1;
			en_ksa <= 0;
			en_init <= 0;
		end
		else begin
			case(state)
				`T1_STATE_0: begin
					state <= `T1_STATE_0;
					en_ksa <= 0;
					en_init <= 0;
				end
				
				`T1_STATE_1: begin
					if(rdy_init == 1) begin
						en_init <= 1;
					end	
					state <= `T1_STATE_2;
				end
				
				`T1_STATE_2: begin
					if(en_init == 1) begin
						en_init = 0;
					end
					state <= `T1_STATE_3; 
				end
				
				`T1_STATE_3: begin
					if(rdy_init == 0) begin
						state <= `T1_STATE_3; 
					end
					else begin
						state <= `T2_STATE_1;
					end
				end
				
				`T2_STATE_0: begin
					state <= `T2_STATE_0;
				end
				
				`T2_STATE_1: begin
					if(rdy_ksa == 1) begin
						en_ksa <= 1;
					end
					state <= `T2_STATE_2;
				end
				
				`T2_STATE_2: begin
					if(en_ksa == 1) begin
						en_ksa = 0;
					end
					state <= `T2_STATE_0;
				end
				
				default: begin
					state <= `T1_STATE_0;
				end
			endcase
		end
	end
	
	assign addr = rdy_init == 0 ? addr_init : rdy_ksa == 0 ? addr_ksa : 8'bzzzzzzzz;
	assign wrdata = rdy_init == 0 ? wrdata_init : rdy_ksa == 0 ? wrdata_ksa : 8'bzzzzzzzz;
	assign wren = rdy_init == 0 ? wren_init : rdy_ksa == 0 ? wren_ksa : 1'bz;
	
endmodule: task2
