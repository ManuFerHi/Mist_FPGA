//FPGA implementation of Super Breakout arcade game released by Atari in 1978
module super_breakout_mist(
	output        LED,
	output  [5:0] VGA_R,
	output  [5:0] VGA_G,
	output  [5:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        AUDIO_L,
	output        AUDIO_R,
	input         SPI_SCK,
	output        SPI_DO,
	input         SPI_DI,
	input         SPI_SS2,
	input         SPI_SS3,
	input         CONF_DATA0,
	input         CLOCK_27
);

`include "build_id.v"

localparam CONF_STR = {
	"S. Breakout;;",
	"O1,Test Mode,Off,On;",
	"O2,Rotate Controls,Off,On;",
	"O34,Scanlines,Off,25%,50%,75%;",
	"O5,Color,On,Off;",
	"T0,Reset;",
	"V,v1.30.",`BUILD_DATE
	};
    
assign AUDIO_R = AUDIO_L;

wire clk_24, clk_12, clk_6;
wire locked;
pll pll(
	.inclk0(CLOCK_27),
	.c0(clk_24),//24.192
	.c1(clk_12),//12.096
	.locked(locked)
	);

	
wire [63:0] status;
wire  [1:0] buttons;
wire  [1:0] switches;
wire [31:0] joystick_0, joystick_1;
wire        scandoublerD;
wire        ypbpr;
wire        key_pressed;
wire  [7:0] key_code;
wire        key_strobe;
wire        no_csync;
wire  [7:0] audio;
wire			video;
wire  [2:0] r,g;
wire  [1:0] b;
wire 			hs, vs;

super_breakout super_breakout(
	.clk_12(clk_12),
	.Reset_n(~(status[0] | buttons[1])),			
	.HS(hs),
	.VS(vs),
	.Video_O(video),
	.Video_RGB({r,g,b}),
	.Audio_O(audio),
	.Coin1_I(~m_coin1),
	.Coin2_I(~m_coin2),
	.Start1_I(~m_one_player),
	.Start2_I(~m_two_players),
	.Select1_I(~m_fireB),
	.Select2_I(~m_fire2B),
	.Enc_A(steer[1]),
	.Enc_B(steer[0]),
	.Pot_Comp1_I(),
	.Slam_I(~m_tilt),
	.Serve_I(~(m_fireA | m_fire2A)),
	.Test_I(~status[1]),	
	.Lamp1_O(),
	.Lamp2_O(),
	.Serve_LED_O(LED),
	.Counter_O()
	);
	
dac #(
	.C_bits(8))
dac_l(
	.clk_i(clk_24),
	.res_n_i(1),
	.dac_i(audio),
	.dac_o(AUDIO_L)
	);

mist_video #(
	.COLOR_DEPTH(3), 
	.SD_HCNT_WIDTH(9)) 
mist_video(
	.clk_sys        ( clk_24           ),
	.SPI_SCK        ( SPI_SCK          ),
	.SPI_SS3        ( SPI_SS3          ),
	.SPI_DI         ( SPI_DI           ),
	.R(~status[5] ? r : {video,video,video}),
	.G(~status[5] ? g : {video,video,video}),
	.B(~status[5] ? {b,1'b0} : {video,video,video}),
	.HSync          ( hs               ),
	.VSync          ( vs               ),
	.VGA_R          ( VGA_R            ),
	.VGA_G          ( VGA_G            ),
	.VGA_B          ( VGA_B            ),
	.VGA_VS         ( VGA_VS           ),
	.VGA_HS         ( VGA_HS           ),
	.scanlines      (scandoublerD ? 2'b00 : status[4:3]),
//	.rotate         ( { 1'b1, rotate } ),
//	.ce_divider     ( 1'b1             ),
	.blend          ( status[6]        ),
	.scandoubler_disable(scandoublerD  ),
	.no_csync       ( no_csync         ),
	.ypbpr          ( ypbpr            )
	);
	
user_io #(
	.STRLEN(($size(CONF_STR)>>3)))
user_io(
	.clk_sys        (clk_24         ),
	.conf_str       (CONF_STR       ),
	.SPI_CLK        (SPI_SCK        ),
	.SPI_SS_IO      (CONF_DATA0     ),
	.SPI_MISO       (SPI_DO         ),
	.SPI_MOSI       (SPI_DI         ),
	.buttons        (buttons        ),
	.switches       (switches       ),
	.scandoubler_disable (scandoublerD	  ),
	.ypbpr          (ypbpr          ),
	.no_csync       (no_csync       ),
	.key_strobe     (key_strobe     ),
	.key_pressed    (key_pressed    ),
	.key_code       (key_code       ),
	.joystick_0     (joystick_0     ),
	.joystick_1     (joystick_1     ),
	.status         (status         )
	);

wire [1:0] steer;
joy2quad steer1(
	.CLK(clk_24),
	.clkdiv('d22500),	
	.right(m_right | m_right2),
	.left(m_left | m_left2),	
	.steer(steer)
	);
	
wire m_up, m_down, m_left, m_right, m_fireA, m_fireB, m_fireC, m_fireD, m_fireE, m_fireF;
wire m_up2, m_down2, m_left2, m_right2, m_fire2A, m_fire2B, m_fire2C, m_fire2D, m_fire2E, m_fire2F;
wire m_tilt, m_coin1, m_coin2, m_coin3, m_coin4, m_one_player, m_two_players, m_three_players, m_four_players;

arcade_inputs inputs (
	.clk         ( clk_24      ),
	.key_strobe  ( key_strobe  ),
	.key_pressed ( key_pressed ),
	.key_code    ( key_code    ),
	.joystick_0  ( joystick_0  ),
	.joystick_1  ( joystick_1  ),
//	.rotate      ( rotate      ),
//	.orientation ( 2'b11       ),
	.joyswap     ( 1'b0        ),
	.oneplayer   ( 1'b0        ),
	.controls    ( {m_tilt, m_coin4, m_coin3, m_coin2, m_coin1, m_four_players, m_three_players, m_two_players, m_one_player} ),
	.player1     ( {m_fireF, m_fireE, m_fireD, m_fireC, m_fireB, m_fireA, m_up, m_down, m_left, m_right} ),
	.player2     ( {m_fire2F, m_fire2E, m_fire2D, m_fire2C, m_fire2B, m_fire2A, m_up2, m_down2, m_left2, m_right2} )
);
	

endmodule 