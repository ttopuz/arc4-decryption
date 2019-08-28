module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

	// your code here
	
	`define READY_INIT			3'd0
	`define WRITE_MEM_INIT		3'd1
	`define UPDATE_S_INIT		3'd2
	
	reg [2:0] state;
	reg [8:0] i;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (rst_n == 0) begin
			state <= `READY_INIT;
			rdy <= 1;
			addr <= 0;
			wrdata <= 0;
			wren <= 0;
			i <= 0;
		end
		else if (rdy == 1 && en == 1) begin
			state <= `WRITE_MEM_INIT;
			rdy <= 0;
		end
		else begin
			case (state)
				`READY_INIT: begin
					state <= `READY_INIT;
					rdy <= 1;
					addr <= 0;
					wrdata <= 0;
					wren <= 0;
					i <= 0;
				end
				
				`WRITE_MEM_INIT: begin
					state <= `UPDATE_S_INIT;
				end
				
				`UPDATE_S_INIT: begin
					if (i <= 255) begin
						state <= `UPDATE_S_INIT;
						addr <= i;
						wrdata <= i;
						wren <= 1;
						i <= i + 1;
					end
					else begin
						state <= `READY_INIT;
						rdy <= 1;
						addr <= 0;
						wrdata <= 0;
						wren <= 0;
					end
				end
				default: begin
					state <= `READY_INIT;
					rdy <= 1;
					addr <= 0;
					wrdata <= 0;
					wren <= 0;
				end
			endcase
		end
	end
endmodule: init