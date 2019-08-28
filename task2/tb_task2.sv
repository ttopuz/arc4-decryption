`timescale 1ps / 1ps
module tb_task2();

// Your testbench goes here.
	reg clk;
	reg [3:0] KEY;
	reg [9:0] SW;
	reg [7:0]s_data [0:255];
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	wire [9:0] LEDR;
	integer i;
	
	task2 task2(.CLOCK_50(clk), .KEY(KEY), .SW(SW), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(LEDR));
	
	initial begin
		forever begin
			clk = 0; #5;
			clk = 1; #5;
		end
	end
	
	initial begin
		$readmemh("task2_readmem.txt", s_data);
	
		SW = 10'h33C;
		KEY = 4'b0000; #10;
		KEY = 4'b1000;

		#33400;
		
		for(i = 0; i <= 255; i = i + 1) begin
			assert(task2.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] == s_data[i]);
		end
		
		$stop;
	end
endmodule: tb_task2
