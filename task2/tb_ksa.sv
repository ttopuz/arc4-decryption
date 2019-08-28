module tb_ksa();

// Your testbench goes here.

// Since ksa relies on rddata input and rddata input relies on s_mem, I will just test if the handshake microprotocol works
	reg clk, rst_n, en;
	reg [23:0] key;
	reg [7:0] rddata;
	wire rdy, wren;
	wire [7:0] addr, wrdata;
	integer i;
	
	ksa ksa(.clk(clk), .rst_n(rst_n), .en(en), .rdy(rdy), .key(key), .addr(addr), .rddata(rddata), .wrdata(wrdata), .wren(wren));
	
	initial begin
		forever begin
			clk = 0; #5;
			clk = 1; #5;
		end
	end
	
	initial begin
		// Init
		key = 24'h00033C;
		en = 0;
		rst_n = 0; #5;
		rst_n = 1; #5;
		
		// Start
		assert(rdy == 1);
		en = 1; #10; 
		en = 0;
		assert(rdy == 0);
		
		#30800;
		
		assert(rdy == 1);
		assert(wren == 0);
		$stop;
	end
	
endmodule: tb_ksa
