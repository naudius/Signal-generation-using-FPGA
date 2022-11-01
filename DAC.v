module 	DAC#(
	parameter WIDTH = 10,
	parameter DEPTH = 1024,
	parameter INIT_F="C:/Users/Willem/Desktop/FYP/Core/RadarApplication/SineLookup.txt"
	)(
	input wire     	   	ipClk, 
	input wire [1:0]  	ipControl,
	input wire		   	ipReset,
	input wire [7:0]   ipStartFreq,
	input wire [7:0]   ipEndFreq,
	input wire [7:0]   ipStep,
	
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
reg [9:0]  Sine = 10'b0;
reg 		upDown = 0;
reg 		upDownTri=0; 
reg [10:0] sineCounter = 1000; // count from 100 to avoid overflow 
reg [7:0] sineStep = 1;
reg [7:0] step =0;
enum{ Busy =0, Stop=1} DacState; //transmitter states

initial begin	
    $readmemb(INIT_F, memory);
end

always@(negedge opSCK) begin
	case (DacState) 
		Busy : begin
			if (ipControl[0] == 0) begin
				DacState    <= Stop;
			end else if (ipControl[0] == 1) begin
				if (bitCounter < 16) begin
					opCS 		<= 0;
					opSDI <= DAC_Data[bitCounter];
					bitCounter <= bitCounter+1;
				end else begin
					opCS <= 1;
					if (ipControl[1] == 1 ) begin
						if (upDownTri == 0) begin
							if (sineStep+step > ipEndFreq) begin
								upDownTri <= ~upDownTri;
								sineStep <= ipEndFreq;
							end else begin
								sineStep <= sineStep+step;
							end
						end else begin
							if (sineStep-step < ipStartFreq) begin
								upDownTri <= ~upDownTri;
								sineStep <= ipStartFreq;
							end else begin
								sineStep <= sineStep-step;
							end
						end
					end else if (ipControl[1] == 0 ) begin
						sineStep <= sineStep+step;
					    if (sineStep > ipEndFreq) begin
						    sineStep <= ipStartFreq;
					    end
					end
					bitCounter 	<= 0;
					if (upDown == 0) begin
						if(sineCounter < 1000+DEPTH-sineStep) begin
							sineCounter <= sineCounter + sineStep;
						end else begin
							sineCounter <= 1000+DEPTH-1;
							upDown <= ~upDown;
						end
					end else if (upDown == 1) begin
						if(sineCounter > 1000+sineStep) begin
							sineCounter <= sineCounter - sineStep;
						end else begin
							sineCounter <= 1000;
							upDown <= ~upDown;
						end
					end
					Sine <= memory[sineCounter-1000];
					cofigBits 	<= 4'b1100;
					DAC_Data 	<= {2'b00,Sine,cofigBits};
				end
			end
		end
		Stop : begin
			opCS 		<= 1; //46 bot
			opSDI <= 0;
			if (ipControl[0] == 1) begin
				sineStep <= ipStartFreq;
				step <= ipStep;
				bitCounter 	<= 0;
				upDown <= 0;
				opCS 		<= 0;
				sineCounter <= 1000;
				Sine <= memory[sineCounter-1000];
				cofigBits 	<= 4'b1100;
				DAC_Data 	<= {2'b00,Sine,cofigBits};
				DacState <= Busy;
			end
		end
		default : DacState <= Stop;
   endcase
end
endmodule
