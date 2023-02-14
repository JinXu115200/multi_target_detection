module add_rectangular
#
(
    parameter [9:0] IMG_HDISP   = 10'd640   ,
    parameter [9:0] IMG_VDISP   = 10'd480
) 
(
    input   wire                sys_clk                     ,
    input   wire                sys_rst_n                   ,
    input   wire                per_frame_vsync             ,
    input   wire                per_frame_href              ,
    input   wire                per_frame_clken             ,
    input   wire  [7:0]         per_img_red                 ,
    input   wire  [7:0]         per_img_green               ,
    input   wire  [7:0]         per_img_blue                ,
    input   wire  [40:0]        target_pos_in  [15:0]       ,

    output  reg                 post_frame_vsync            ,
    output  reg                 post_frame_href             ,
    output  reg                 post_frame_clken            , 
    output  reg  [7:0]          post_img_red                ,
    output  reg  [7:0]          post_img_green              ,
    output  reg  [7:0]          post_img_blue      
);
//reg definition
reg [9:0] x_cnt;
reg [9:0] y_cnt;    

//wire defination
wire [9:0]  x_min_0, x_min_1, x_min_2, x_min_3, x_min_4,
            x_min_5, x_min_6, x_min_7, x_min_8, x_min_9,
            x_min_10, x_min_11, x_min_12, x_min_13, x_min_14, x_min_15;

wire [9:0]  x_max_0, x_max_1, x_max_2, x_max_3, x_max_4,
            x_max_5, x_max_6, x_max_7, x_max_8, x_max_9,
            x_max_10, x_max_11, x_max_12, x_max_13, x_max_14, x_max_15;

wire [9:0]  y_min_0, y_min_1, y_min_2, y_min_3, y_min_4,
            y_min_5, y_min_6, y_min_7, y_min_8, y_min_9,
            y_min_10, y_min_11, y_min_12, y_min_13, y_min_14, y_min_15;

wire [9:0]  y_max_0, y_max_1, y_max_2, y_max_3, y_max_4,
            y_max_5, y_max_6, y_max_7, y_max_8, y_max_9,
            y_max_10, y_max_11, y_max_12, y_max_13, y_max_14, y_max_15;

assign x_min_0 =  (target_pos_in [0 ] [40] == 1'b1) ? target_pos_in [0 ] [9:0] : 10'd0;
assign x_min_1 =  (target_pos_in [1 ] [40] == 1'b1) ? target_pos_in [1 ] [9:0] : 10'd0;
assign x_min_2 =  (target_pos_in [2 ] [40] == 1'b1) ? target_pos_in [2 ] [9:0] : 10'd0;
assign x_min_3 =  (target_pos_in [3 ] [40] == 1'b1) ? target_pos_in [3 ] [9:0] : 10'd0;
assign x_min_4 =  (target_pos_in [4 ] [40] == 1'b1) ? target_pos_in [4 ] [9:0] : 10'd0;
assign x_min_5 =  (target_pos_in [5 ] [40] == 1'b1) ? target_pos_in [5 ] [9:0] : 10'd0;
assign x_min_6 =  (target_pos_in [6 ] [40] == 1'b1) ? target_pos_in [6 ] [9:0] : 10'd0;
assign x_min_7 =  (target_pos_in [7 ] [40] == 1'b1) ? target_pos_in [7 ] [9:0] : 10'd0;
assign x_min_8 =  (target_pos_in [8 ] [40] == 1'b1) ? target_pos_in [8 ] [9:0] : 10'd0;
assign x_min_9 =  (target_pos_in [9 ] [40] == 1'b1) ? target_pos_in [9 ] [9:0] : 10'd0;
assign x_min_10 = (target_pos_in [10] [40] == 1'b1) ? target_pos_in [10] [9:0] : 10'd0;
assign x_min_11 = (target_pos_in [11] [40] == 1'b1) ? target_pos_in [11] [9:0] : 10'd0;
assign x_min_12 = (target_pos_in [12] [40] == 1'b1) ? target_pos_in [12] [9:0] : 10'd0;
assign x_min_13 = (target_pos_in [13] [40] == 1'b1) ? target_pos_in [13] [9:0] : 10'd0;
assign x_min_14 = (target_pos_in [14] [40] == 1'b1) ? target_pos_in [14] [9:0] : 10'd0;
assign x_min_15 = (target_pos_in [15] [40] == 1'b1) ? target_pos_in [15] [9:0] : 10'd0;

assign x_max_0 =  (target_pos_in [0 ] [40] == 1'b1) ? target_pos_in [0 ] [29:20] : 10'd0;
assign x_max_1 =  (target_pos_in [1 ] [40] == 1'b1) ? target_pos_in [1 ] [29:20] : 10'd0;
assign x_max_2 =  (target_pos_in [2 ] [40] == 1'b1) ? target_pos_in [2 ] [29:20] : 10'd0;
assign x_max_3 =  (target_pos_in [3 ] [40] == 1'b1) ? target_pos_in [3 ] [29:20] : 10'd0;
assign x_max_4 =  (target_pos_in [4 ] [40] == 1'b1) ? target_pos_in [4 ] [29:20] : 10'd0;
assign x_max_5 =  (target_pos_in [5 ] [40] == 1'b1) ? target_pos_in [5 ] [29:20] : 10'd0;
assign x_max_6 =  (target_pos_in [6 ] [40] == 1'b1) ? target_pos_in [6 ] [29:20] : 10'd0;
assign x_max_7 =  (target_pos_in [7 ] [40] == 1'b1) ? target_pos_in [7 ] [29:20] : 10'd0;
assign x_max_8 =  (target_pos_in [8 ] [40] == 1'b1) ? target_pos_in [8 ] [29:20] : 10'd0;
assign x_max_9 =  (target_pos_in [9 ] [40] == 1'b1) ? target_pos_in [9 ] [29:20] : 10'd0;
assign x_max_10 = (target_pos_in [10] [40] == 1'b1) ? target_pos_in [10] [29:20] : 10'd0;
assign x_max_11 = (target_pos_in [11] [40] == 1'b1) ? target_pos_in [11] [29:20] : 10'd0;
assign x_max_12 = (target_pos_in [12] [40] == 1'b1) ? target_pos_in [12] [29:20] : 10'd0;
assign x_max_13 = (target_pos_in [13] [40] == 1'b1) ? target_pos_in [13] [29:20] : 10'd0;
assign x_max_14 = (target_pos_in [14] [40] == 1'b1) ? target_pos_in [14] [29:20] : 10'd0;
assign x_max_15 = (target_pos_in [15] [40] == 1'b1) ? target_pos_in [15] [29:20] : 10'd0;

assign y_min_0 =  (target_pos_in [0 ] [40] == 1'b1) ? target_pos_in [0 ] [19:10] : 10'd0;
assign y_min_1 =  (target_pos_in [1 ] [40] == 1'b1) ? target_pos_in [1 ] [19:10] : 10'd0;
assign y_min_2 =  (target_pos_in [2 ] [40] == 1'b1) ? target_pos_in [2 ] [19:10] : 10'd0;
assign y_min_3 =  (target_pos_in [3 ] [40] == 1'b1) ? target_pos_in [3 ] [19:10] : 10'd0;
assign y_min_4 =  (target_pos_in [4 ] [40] == 1'b1) ? target_pos_in [4 ] [19:10] : 10'd0;
assign y_min_5 =  (target_pos_in [5 ] [40] == 1'b1) ? target_pos_in [5 ] [19:10] : 10'd0;
assign y_min_6 =  (target_pos_in [6 ] [40] == 1'b1) ? target_pos_in [6 ] [19:10] : 10'd0;
assign y_min_7 =  (target_pos_in [7 ] [40] == 1'b1) ? target_pos_in [7 ] [19:10] : 10'd0;
assign y_min_8 =  (target_pos_in [8 ] [40] == 1'b1) ? target_pos_in [8 ] [19:10] : 10'd0;
assign y_min_9 =  (target_pos_in [9 ] [40] == 1'b1) ? target_pos_in [9 ] [19:10] : 10'd0;
assign y_min_10 = (target_pos_in [10] [40] == 1'b1) ? target_pos_in [10] [19:10] : 10'd0;
assign y_min_11 = (target_pos_in [11] [40] == 1'b1) ? target_pos_in [11] [19:10] : 10'd0;
assign y_min_12 = (target_pos_in [12] [40] == 1'b1) ? target_pos_in [12] [19:10] : 10'd0;
assign y_min_13 = (target_pos_in [13] [40] == 1'b1) ? target_pos_in [13] [19:10] : 10'd0;
assign y_min_14 = (target_pos_in [14] [40] == 1'b1) ? target_pos_in [14] [19:10] : 10'd0;
assign y_min_15 = (target_pos_in [15] [40] == 1'b1) ? target_pos_in [15] [19:10] : 10'd0;

assign y_max_0 =  (target_pos_in [0 ] [40] == 1'b1) ? target_pos_in [0 ] [39:30] : 10'd0;
assign y_max_1 =  (target_pos_in [1 ] [40] == 1'b1) ? target_pos_in [1 ] [39:30] : 10'd0;
assign y_max_2 =  (target_pos_in [2 ] [40] == 1'b1) ? target_pos_in [2 ] [39:30] : 10'd0;
assign y_max_3 =  (target_pos_in [3 ] [40] == 1'b1) ? target_pos_in [3 ] [39:30] : 10'd0;
assign y_max_4 =  (target_pos_in [4 ] [40] == 1'b1) ? target_pos_in [4 ] [39:30] : 10'd0;
assign y_max_5 =  (target_pos_in [5 ] [40] == 1'b1) ? target_pos_in [5 ] [39:30] : 10'd0;
assign y_max_6 =  (target_pos_in [6 ] [40] == 1'b1) ? target_pos_in [6 ] [39:30] : 10'd0;
assign y_max_7 =  (target_pos_in [7 ] [40] == 1'b1) ? target_pos_in [7 ] [39:30] : 10'd0;
assign y_max_8 =  (target_pos_in [8 ] [40] == 1'b1) ? target_pos_in [8 ] [39:30] : 10'd0;
assign y_max_9 =  (target_pos_in [9 ] [40] == 1'b1) ? target_pos_in [9 ] [39:30] : 10'd0;
assign y_max_10 = (target_pos_in [10] [40] == 1'b1) ? target_pos_in [10] [39:30] : 10'd0;
assign y_max_11 = (target_pos_in [11] [40] == 1'b1) ? target_pos_in [11] [39:30] : 10'd0;
assign y_max_12 = (target_pos_in [12] [40] == 1'b1) ? target_pos_in [12] [39:30] : 10'd0;
assign y_max_13 = (target_pos_in [13] [40] == 1'b1) ? target_pos_in [13] [39:30] : 10'd0;
assign y_max_14 = (target_pos_in [14] [40] == 1'b1) ? target_pos_in [14] [39:30] : 10'd0;
assign y_max_15 = (target_pos_in [15] [40] == 1'b1) ? target_pos_in [15] [39:30] : 10'd0;

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if (sys_rst_n == 1'b0)
    begin
        x_cnt <= 10'd0;
        y_cnt <= 10'd0;
    end
    else if (per_frame_vsync == 1'b0)
    begin
        x_cnt <= 10'd0;
        y_cnt <= 10'd0;
    end
    else if (per_frame_clken == 1'b1)
    begin
        if (x_cnt < IMG_HDISP - 1'b1)
            begin
                x_cnt <= x_cnt + 1'b1;
                y_cnt <= y_cnt;
            end
        else
        begin
            x_cnt <= 10'd0;
            y_cnt <= y_cnt + 1'b1;
        end
    end
end

reg frame_valid;

always@(posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        frame_valid <= 1'b0;
    else if (y_cnt == 10'd480 && x_cnt == 10'd0 && per_frame_vsync == 1'b0)
        frame_valid <= 1'b1;
    else
        frame_valid <= frame_valid;

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if (sys_rst_n == 1'b0)
    begin
        post_frame_vsync <= 1'b0;
        post_frame_href  <= 1'b0;
        post_frame_clken <= 1'b0;
        post_img_red     <= 8'd0;
        post_img_green   <= 8'd0;
        post_img_blue    <= 8'd0;
    end
    else if (frame_valid == 1'b1)
    begin
        post_frame_vsync <= per_frame_vsync ;
        post_frame_href  <= per_frame_href  ;
        post_frame_clken <= per_frame_clken ;
        if (((x_cnt > x_min_0) && (x_cnt < x_max_0)) && ((y_cnt == y_min_0) || (y_cnt == y_max_0)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_0) && (y_cnt < y_max_0)) && ((x_cnt == x_min_0) || (x_cnt == x_max_0)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_1) && (x_cnt < x_max_1)) && ((y_cnt == y_min_1) || (y_cnt == y_max_1)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_1 ) && (y_cnt < y_max_1)) && ((x_cnt == x_min_1) || (x_cnt == x_max_1)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_2) && (x_cnt < x_max_2)) && ((y_cnt == y_min_2) || (y_cnt == y_max_2)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_2 ) && (y_cnt < y_max_2)) && ((x_cnt == x_min_2) || (x_cnt == x_max_2)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_3) && (x_cnt < x_max_3)) && ((y_cnt == y_min_3) || (y_cnt == y_max_3)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_3 ) && (y_cnt < y_max_3)) && ((x_cnt == x_min_3) || (x_cnt == x_max_3)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_4) && (x_cnt < x_max_4)) && ((y_cnt == y_min_4) || (y_cnt == y_max_4)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_4 ) && (y_cnt < y_max_4)) && ((x_cnt == x_min_4) || (x_cnt == x_max_4)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_5) && (x_cnt < x_max_5)) && ((y_cnt == y_min_5) || (y_cnt == y_max_5)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_5 ) && (y_cnt < y_max_5)) && ((x_cnt == x_min_5) || (x_cnt == x_max_5)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_6) && (x_cnt < x_max_6)) && ((y_cnt == y_min_6) || (y_cnt == y_max_6)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_6 ) && (y_cnt < y_max_6)) && ((x_cnt == x_min_6) || (x_cnt == x_max_6)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_7) && (x_cnt < x_max_7)) && ((y_cnt == y_min_7) || (y_cnt == y_max_7)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_7 ) && (y_cnt < y_max_7)) && ((x_cnt == x_min_7) || (x_cnt == x_max_7)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_8) && (x_cnt < x_max_8)) && ((y_cnt == y_min_8) || (y_cnt == y_max_8)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_8 ) && (y_cnt < y_max_8)) && ((x_cnt == x_min_8) || (x_cnt == x_max_8)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_9) && (x_cnt < x_max_9)) && ((y_cnt == y_min_9) || (y_cnt == y_max_9)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_9 ) && (y_cnt < y_max_9)) && ((x_cnt == x_min_9) || (x_cnt == x_max_9)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_10) && (x_cnt < x_max_10)) && ((y_cnt == y_min_10) || (y_cnt == y_max_10)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_10 ) && (y_cnt < y_max_10)) && ((x_cnt == x_min_10) || (x_cnt == x_max_10)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_11) && (x_cnt < x_max_11)) && ((y_cnt == y_min_11) || (y_cnt == y_max_11)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_11 ) && (y_cnt < y_max_11)) && ((x_cnt == x_min_11) || (x_cnt == x_max_11)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_12) && (x_cnt < x_max_12)) && ((y_cnt == y_min_12) || (y_cnt == y_max_12)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_12 ) && (y_cnt < y_max_12)) && ((x_cnt == x_min_12) || (x_cnt == x_max_12)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_13) && (x_cnt < x_max_13)) && ((y_cnt == y_min_13) || (y_cnt == y_max_13)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_13 ) && (y_cnt < y_max_13)) && ((x_cnt == x_min_13) || (x_cnt == x_max_13)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_14) && (x_cnt < x_max_14)) && ((y_cnt == y_min_14) || (y_cnt == y_max_14)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_14 ) && (y_cnt < y_max_14)) && ((x_cnt == x_min_14) || (x_cnt == x_max_14)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((x_cnt > x_min_15) && (x_cnt < x_max_15)) && ((y_cnt == y_min_15) || (y_cnt == y_max_15)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else if (((y_cnt > y_min_15 ) && (y_cnt < y_max_15)) && ((x_cnt == x_min_15) || (x_cnt == x_max_15)))
            begin
                post_img_red   <= 8'd255;
                post_img_green <= 8'd0;
                post_img_blue  <= 8'd0;
            end
        else 
            begin
                post_img_red  <= per_img_red  ;
                post_img_green<= per_img_green;
                post_img_blue <= per_img_blue ;
            end   
    end
	else
        begin
            post_img_red  <= per_img_red  ;
            post_img_green<= per_img_green;
            post_img_blue <= per_img_blue ;
        end 
end

endmodule