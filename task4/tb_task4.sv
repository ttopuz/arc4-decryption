`timescale 1ps / 1ps
module tb_task4();

// Your testbench goes here.
// CT preloaded with test1, test2 OK.
	reg clk;
	reg [3:0] KEY;
	reg [9:0] SW;
	reg [7:0] pt_data [0:45];
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	wire [9:0] LEDR;
	integer i;
	
	task4 task4(.CLOCK_50(clk), .KEY(KEY), .SW(SW), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(LEDR));
	
	initial begin
		forever begin
			clk = 0; #5;
			clk = 1; #5;
		end
	end
	
	initial begin
		$readmemh("task4_readmem.txt", pt_data);
		KEY = 4'b0000; #10;
		KEY = 4'b1000;

		#92000;
		
		assert(task4.c.key == 1);
		assert(task4.c.key_valid == 1);
		
		for(i = 0; i <= 45; i = i + 1) begin
			assert(task4.c.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i] == pt_data[i]);
		end
		
		assert(HEX0 == 7'b1111001);
		$stop;
	end
	
endmodule: tb_task4
