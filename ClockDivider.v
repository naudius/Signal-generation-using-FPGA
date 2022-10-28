module ClockDivider#(
    parameter DIVISOR=5
	)(
	input  wire ipClk,
	output reg  opClk
);

//output reg	opClk = 0;
reg [31:0] 	clkCounter = 0;

always@(posedge ipClk) begin
	if (clkCounter == DIVISOR) begin
		opClk <= !opClk;
		clkCounter <= 0;
	end else begin
		clkCounter <= clkCounter+1;
    end
end 
endmodule
