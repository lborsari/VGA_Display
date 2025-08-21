`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI ECE3829
// Engineer: Leo Borsari
// 
// Create Date: 01/22/2025 06:32:08 PM
// Design Name: Seven Seg
// Module Name: seven_seg
// Project Name: Lab 2
// Target Devices: Basys3 Dev Board
// Tool Versions: 2021.1
// Description: Drives the seven segment display by cycling through displaying the anodes 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created asdf sdf 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_seg(
    input clk_25M, //25MHz input
    input reset_n, //active low reset
    input [3:0] A, //number for first disp
    input [3:0] B, //number for second disp
    input [3:0] C, // number for third disp
    input [3:0] D, //number for fourth disp

    output reg [6:0] segment, //output to segmets
    output reg [3:0] anode //anode bus
);

    reg [3:0] mux_out; //mux to tell what number to communicate to disp
    reg [3:0] sel = 4'b0111; //initialize internal selector bus
    reg [8:0] count_reg; //count storage for timer


    parameter
    C_MAX_COUNT = 500 - 1, //max count for 500Hz clock
    ZERO = 7'b0111111,
    ONE = 7'b0000110,
    TWO = 7'b1011011,
    THREE = 7'b1001111,
    FOUR = 7'b1100110,
    FIVE = 7'b1101101,
    SIX = 7'b1111101,
    SEVEN = 7'b0000111,
    EIGHT = 7'b1111111,
    NINE = 7'b1100111,
    HEX_A = 7'b1110111,
    HEX_B = 7'b1111100,
    HEX_C = 7'b0111001,
    HEX_D = 7'b1011110,
    HEX_E = 7'b1111001,
    HEX_F = 7'b1110001;


    assign update = (count_reg == C_MAX_COUNT); //update the disp at terminal count



 // Timer construction
    always @ (posedge clk_25M or negedge reset_n) begin
        if(!reset_n) begin //active low reset
            count_reg <= 9'b0;
        end
        else if(count_reg == C_MAX_COUNT + 1) begin
            count_reg <= 9'b0;
        end
        else begin
            count_reg <= count_reg + 9'b1;
        end
    end

// Display logic
    always @ (posedge clk_25M or negedge reset_n) begin
        if (!reset_n) begin
            sel <= 4'b1110;
            anode <= 4'b1111;
        end
        else if (update) begin

            sel <= {sel[2:0], sel[3]}; //shift register for continuous updating

            case(sel)
                4'b0111 : begin
                    anode = sel;
                    mux_out = A; //disp 1
                end
                4'b1011 : begin
                    anode = sel;
                    mux_out = B; //disp 2
                end
                4'b1101 : begin
                    anode = sel;
                    mux_out = C; //disp 3
                end
                4'b1110 : begin
                    anode = sel;
                    mux_out = D; //disp 4
                end
                default : begin
                    anode = sel;
                    mux_out = A;
                end
            endcase

            case(mux_out) //tells what to display to A, B, C or D
                4'b0: segment = ~ZERO;
                4'h1: segment = ~ONE;
                4'h2: segment = ~TWO;
                4'h3: segment = ~THREE;
                4'h4: segment = ~FOUR;
                4'h5: segment = ~FIVE;
                4'h6: segment = ~SIX;
                4'h7: segment = ~SEVEN;
                4'h8: segment = ~EIGHT;
                4'h9: segment = ~NINE;
                4'hA: segment = ~HEX_A;
                4'hB: segment = ~HEX_B;
                4'hC: segment = ~HEX_C;
                4'hD: segment = ~HEX_D;
                4'hE: segment = ~HEX_E;
                4'hF: segment = ~HEX_F;
                default : segment = ~ZERO;
            endcase
        end
    end







endmodule








