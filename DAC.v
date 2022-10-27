module 	DAC#(
	parameter WIDTH = 10,
	parameter DEPTH = 4
	)(
	input wire     	   	ipClk, 
	input wire [9:0]	ipData,
	input wire		   	ipReset,
	input wire [1:0]  	ipControl,
	
	output reg   		opLDAC,
	output reg 		   	opSync,
	output wire		   	opSCK,
	output reg			opCS,
	output reg			opSDI
);

ClockDivider DAC_Clk(
  .ipClk( ipClk ),
  .opClk( opSCK)
);

logic [WIDTH-1:0] memory [DEPTH];
reg [4:0] 	bitCounter 	= 0;
reg [3:0]	cofigBits	= 4'b0000; // [{0=Write;1=Ignore},{1=Buff;0=Unbuff},{1=1x;0=2x},{1=Active;0=Shutdown}]
reg [15:0]	DAC_Data   	= 0;
reg [9:0]  Sine = 10'b1111111110;
reg [3:0]  sineCounter = 0;
reg [31:0] sineStep = 1;

enum{ Busy =0, Stop=1} DacState; //transmitter states

always@(negedge opSCK) begin
	case (DacState) 
		Busy : begin
			if (ipControl == 2'b10) begin
				DacState    <= Stop;
			end else if (ipControl == 2'b01) begin
				if (bitCounter < 16) begin
					opSync <= 0;
					opCS 		<= 0;
					opSDI <= DAC_Data[bitCounter];
					bitCounter <= bitCounter+1;
				end else begin
					opCS <= 1;
					opSync <= 1;
					bitCounter 	<= 0;
					if(sineCounter < DEPTH-1) begin
						sineCounter <= sineCounter + sineStep;
					end else begin
						sineCounter <= 0;
					end
					Sine <= memory[sineCounter];
					cofigBits 	<= 4'b1100;
					DAC_Data 	<= {2'b00,Sine,cofigBits};
				end
			end
		end
		Stop : begin
			opCS 		<= 1; //46 bot
			opSync <= 0; //37 top
			opSDI <= 0;
			memory[0] <= 10'b1111111110;
			memory[1] <= 10'b1111111111;
			memory[2] <= 10'b1111111110;	
			memory[3] <= 10'b0000000000;
			if (ipControl == 2'b01) begin
				bitCounter 	<= 0;
				opCS 		<= 0;
				sineCounter <= 0;
				Sine <= memory[sineCounter];
				cofigBits 	<= 4'b1100;
				DAC_Data 	<= {2'b00,Sine,cofigBits};
				DacState <= Busy;
			end
		end
		default : DacState <= Stop;
   endcase
end
endmodule
