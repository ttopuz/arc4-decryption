module tb_init();

// Your testbench goes here.
	reg clk, rst_n, en;
	wire rdy, wren;
	wire [7:0] addr, wrdata;
	integer i;
	
	init init(.clk(clk), .rst_n(rst_n), .en(en), .rdy(rdy), .addr(addr), .wrdata(wrdata), .wren(wren));

	initial begin
		forever begin
			clk = 0; #5;
			clk = 1; #5;
		end
	end

	initial begin
		en = 0;
		rst_n = 0; #10;
		rst_n = 1;
		i = 0;

		// Start
		assert(rdy == 1);
		en = 1; #10;
		en = 0;
		assert(rdy == 0);
		
		assert(addr == 0);
		assert(wrdata == 0);
		assert(wren == 0);
		#25;
		
		for(i = 0; i <= 255; i = i + 1) begin
			assert(i == addr);
			assert(i == wrdata);
			assert(wren == 1);
			#10;
		end
		
		assert(rdy == 1);
		assert(wren == 0);
		$stop;
	end
endmodule: tb_init
