module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
	
	// Task 1 states
	`define T1_STATE_0		3'd0
	`define T1_STATE_1		3'd1
	`define T1_STATE_2		3'd2
	
	reg en, rdy, wren;
	reg [2:0] state;
	wire [7:0] addr, wrdata, q;
	
	// Modules instantiation
	init i(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en), .rdy(rdy), .addr(addr), .wrdata(wrdata), .wren(wren));
    s_mem s(.address(addr), .clock(CLOCK_50), .data(wrdata), .wren(wren), .q(q));

    // your code here
	always_ff@(posedge CLOCK_50 or negedge KEY[3]) begin
		if(KEY[3] == 0) begin
			state <= `T1_STATE_1;
			en <= 0;
		end
		else begin
			case(state)
				`T1_STATE_0: begin
					state <= `T1_STATE_0;
					en <= 0;
				end
				
				`T1_STATE_1: begin
					if(rdy == 1) begin
						en <= 1;
					end	
					state <= `T1_STATE_2;
				end
				
				`T1_STATE_2: begin
					if(en == 1) begin
						en <= 0;
					end
					state <= `T1_STATE_0; 
				end
				
				default: begin
					state <= `T1_STATE_0;
				end
			endcase
		end
	end
endmodule: task1
