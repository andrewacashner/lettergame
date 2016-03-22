#! /usr/bin/env ruby

# THE LETTER GAME
# Toddler Typing
#
# Andrew A. Cashner (andrewacashner at gmail), 2014-06/09
# 
# This is a simple game designed for two- to three-year-olds.
# The child can press any of the number or letter keys on the 
# keyboard and see the images of the letter or number in 
# bright colors on the screen and hear the sound of the letter.
# We mask off the other keys so that they cannot do anything harmful
# or confusing.
# PRESSING ESCAPE EXITS.
#
# This software is written in Ruby, using the GOSU 2-D gaming library. 
# Please see the README and LICENSE for more information.
#========================================================================

require 'gosu'

# We set up our simple window and character display using Gosu.

class GameWindow < Gosu::Window

# These constants will simplify code below.
# We set up a window scaled to the full screen, using the built-in
# Gosu constants for screen width and height.
# We set a title for the window and choose a font for display.

	WIDTH 	= Gosu::screen_width 
	HEIGHT 	= Gosu::screen_height 
	TITLE		= "Toddler Typing"
	FONT		= "./font/myLatinModernSansBold.otf"

# We set up the window to be full screen (this is the meaning of "true").
# We create an instance of Gosu's Font class with the height of the full
# window.
#
# We also initialize variables @new_char to store each new character when 
# it is selected, and @last_char to store the previous character for 
# comparison.
# @i will allow us to select a random color to display the character. 
# @play_sound is set to 0 so we start with no sound playing.

	def initialize
		super WIDTH, HEIGHT, true 
		self.caption = TITLE
		@font = Gosu::Font.new(self, FONT, HEIGHT)
		@new_char = @last_char = nil
		@i = 0
		@color_spectrum = 
			[0xFFFF0000, 0XFF00FFFF, 0xFF00FF00, 0xFF0000FF, 
			0xFFFFFF00, 0xFFFF00FF, 0xFF00FFFF]
				# that is: [red, aqua, green, blue, yellow, fuchsia, cyan]
		
		@play_sound = 0 	# do not play = 0; do play = 1
		@voice_max = 3		# 3 voices to choose from; could be reset for more voices
	end

# This method picks up the key presses. 
# Escape exits; otherwise, we pass the key to prepare_char.

	def button_down(id)
		case id
		when Gosu::KbEscape
			close
		else
			prepare_char(id) 
		end
	end

# The prepare_char method prepares a character that was input from 
# the keyboard to be displayed on screen.
# The keyboard input is passed to the method from the button_down
# method, as an integer code ("char_code", apparently not matching 
# ASCII codes).
#
# To avoid needing to know the codes, we first set limits on the 
# ranges of characters (only numerals 0-9 and lower-case letters a-z,
# even though the letters will be displayed upper-case (otherwise
# there would have to be two key presses, which does not make sense
# for a toddler game).
# We get the codes using Gosu's char_to_button_id conversion.
#
# Then we test the code that was input. It is valid for display if
# it is in the numeral range or the lower-case alphabet range.
# We use Gosu's keyboard constants to evaluate if the keycode is
# within the alphanumeric rows of keys.
# These constants are specific to a US QWERTY keyboard.
# *This should be redone in a way that is not implementation-specific.*

# If it is valid, we convert the char_code to a letter using
# Gosu's button_id_to_char method and store the letter in @new_char.
# We convert the lower-case letters to uppercase first.
#
# The class's "display" method will always display the contents of @new_char
# if @new_char is not nil.
# So if our char_code input is not in those ranges, we make @new_char nil.
# 
# When each new character is selected (that is, when @new_char is redefined),
# @play_sound is set to 1 so that #update knows to play a new character sound.
#
# If the character passed the validity test, then we need to find the
# top-left coordinates of the character for display in the draw method.
# The position is half the window width minus half the character width 
# (optained using Gosu's text_width method).
#
# We choose a random color from 0 to 6 from our color_spectrum to be the 
# new color of the letter (even if the same letter is typed repeatedly).
#
# To play the sound of the letter name, we choose a random number for 
# voice 0, 1, or 2 (Dad, Mom, and Son).
# We make the filename for the sound from the audio directory, the directory 
# each voice, and the character name, so "audio/1/B.ogg" is Mom saying "B."
# If the key pressed is not in our range of letters or numbers we play a
# laughing sound.

	def prepare_char(char_code)
	
		row0_lower_limit = self.char_to_button_id("1")
		row0_upper_limit = self.char_to_button_id("0")
		row1_lower_limit = self.char_to_button_id("q")
		row1_upper_limit = self.char_to_button_id("p")
		row2_lower_limit = self.char_to_button_id("a")
		row2_upper_limit = self.char_to_button_id("l")
		row3_lower_limit = self.char_to_button_id("z")
		row3_upper_limit = self.char_to_button_id("m")

		
		if char_code >= row0_lower_limit and char_code <= row0_upper_limit
			@input_type = "num"
		elsif (char_code >= row1_lower_limit and char_code <= row1_upper_limit)
			@input_type = "alpha"
		elsif (char_code >= row2_lower_limit and char_code <= row2_upper_limit)
			@input_type = "alpha"
		elsif (char_code >= row3_lower_limit and char_code <= row3_upper_limit)
			@input_type = "alpha"
		else
			@input_type = "other" 
		end
		
	# Define the new letter to display, or display nothing
	
		case @input_type
			when "num"
				@new_char = self.button_id_to_char(char_code)
			when "alpha"
				@new_char = self.button_id_to_char(char_code).upcase
			else
				@new_char = nil
		end


	# Get coordinates to place letter
		letter_width = @font.text_width(@new_char)
		@top_left_coordinate = WIDTH/2 - letter_width/2 

	# Select color
		@i = Random.rand(7)
		@color = @color_spectrum[@i]

	# Signal okay to play sound
	# Select correct soundfile for this letter, e.g, "audio/1/B.ogg"
		@play_sound = 1
		if @new_char == nil
			@sound_filename = "audio/laugh.ogg"
		else
			@voice = Random.rand(@voice_max)
			@sound_filename = "audio/#{@voice.to_s}/#{@new_char}.ogg"
		end
		@sound = Gosu::Sample.new(self, @sound_filename)

	end

# If we are cleared to play a new sound (because a new character has
# been pressed), then we play the sound and then toggle @play_sound 
# back to off.

	def update
		if @play_sound == 1
			@sound.play
			@play_sound = 0
		end
	end

# The window draws the contents of @new_char in the chosen @font, unless
# @new_char is nil.
# We draw the character at the coordinate set in prepare_char; the other
# parameters are not relevant, except the penultimate, which sets the 
# color of the character as determined in prepare_char.
	
	def draw
		if @new_char != nil
			@font.draw(@new_char, @top_left_coordinate, 0, 0, 
				1, 1, @color, :default)
		end
	end

end # class GameWindow

# This is all we have to do to create a new game.

window = GameWindow.new
window.show

