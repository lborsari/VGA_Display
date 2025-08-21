`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE 3829
// Engineer: Leo Borsari
//
// Create Date: 02/10/2025 07:27:45 PM
// Design Name: VGA Display Selector
// Module Name: vga_display_select
// Project Name: ECE 3829 Lab 2
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Selector for VGA port
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_display_select(
    input clk_25M, //25MHz clock input
    input block_down, //input to select moving block mode
    input [2:0] sel, //mode selector switch inputs
    input [10:0] x, //x pixel
    input [10:0] y, //y pixel
    input active, //active signal from VGA controller

    output [11:0] color //color to output to VGA controller
);

    reg [11:0] color_q; //internal color storage
    reg R_W = 1'b1; //red or white boolean register
    reg [3:0] mode; //mode selection register
    reg [31:0] count; //for flexible count values
    reg slow_clk = 1'b0; //slow clock for block shift
    reg [8:0] block_pos = 9'd0; //position of moving block


    localparam
    //terminal count
    C_MAX_COUNT = 6_250_000 - 1, //max count for 1/2 2Hz clock period from 25MHz

    //local color parameters
    BLACK = 12'h000,
    BLUE = 12'h00F,
    GREEN = 12'h0F0,
    CYAN = 12'h0FF,
    RED = 12'hF00,
    MAGENTA = 12'hF0F,
    YELLOW = 12'hFF0,
    WHITE = 12'hFFF,

    //local mode parameters
    MODE_YELLOW = 4'b0000,
    MODE_BARS = 4'b0001,
    MODE_STRIPE = 4'b010,
    MODE_GREEN_BLOCK = 4'b0100,
    MODE_MOVING_BLOCK = 4'b1000,

    //screen dim
    VGA_MAX_H = 639,
    VGA_MAX_V = 479;

    assign color = active ? color_q : 12'b0; //when active, set color output to value stored in color register

//Posedge 25MHz clock
    always @ (posedge clk_25M) begin

        if(x == 0) //at x = 0, set R_W to 1 (red)
            R_W <= 1'b1; //set color to red
        else if((x+1) % 16 == 0) //every 16 pix, flip colors
            R_W <= ~R_W;

        if(block_down) begin
            mode <= MODE_MOVING_BLOCK;
            if(count == C_MAX_COUNT) begin
                count <= 0;
                slow_clk <= !slow_clk; //toggle slow clock 
            end else
                count <= count +1;
        end
        else
            mode <= {1'b0, sel}; //if not moving block mode, mode is determined by switch inputs


    end

//Posedge slow clock
    always @ (posedge slow_clk) begin
        if(block_pos == VGA_MAX_V)
            block_pos <= 32; // wrap around
        else
            block_pos <= block_pos + 9'd32; //move the block down
    end

//Combinational Logic
    always @ (mode or R_W or x or y or block_pos) begin

        case (mode)

            MODE_YELLOW : begin //set screen to full yellow
                color_q = YELLOW;
            end

            MODE_BARS : begin //draw vertical bars to the screen alternating red and white (each bar 16 pix wide)
                if(R_W)
                    color_q = RED;
                else
                    color_q = WHITE;

            end

            MODE_STRIPE : begin
                if(y > (VGA_MAX_V - 32)) // horizontal blue stripe 32-pixels wide at bottom of screen
                    color_q = BLUE;
                else
                    color_q = BLACK;
            end

            MODE_GREEN_BLOCK : begin
                if((y < 127) && (x > (VGA_MAX_H - 128))) //128x128 green block in top right corner
                    color_q = GREEN;

                else
                    color_q = BLACK; //black screen
            end

            MODE_MOVING_BLOCK : begin 
                if(((y > block_pos) && (y < block_pos + 32)) && ((x > 303) && (x < 335))) //bounding box for block
                    color_q = RED;
                else
                    color_q = BLUE; //fill the rest of the screen blue
            end

            default : begin
                color_q = YELLOW; //defaults to yellow
            end
        endcase
    end




endmodule
