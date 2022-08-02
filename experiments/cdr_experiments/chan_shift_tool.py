from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
import sys, termios
from pynput.keyboard import Key, Listener
from dragonphy import *
import time

THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]

file_name = str(get_file(f'data/channel_sparam/{sparam_file_list[0]}'))

f_sig = 12e9
f_clk = 12e9 + 1e5



class KeyHandler:
	def __init__(self, f_sig, file_name):
		self.key_list = []
		self.chan     = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=800000,
                   				s4p=file_name, zs=50, zl=50)
		self.time, self.pulse = self.chan.get_pulse_resp(f_sig=f_sig, resp_depth=100, t_delay=0)
		self.f_sig = f_sig
		cursor_position = np.argmax(self.pulse)
		num_of_precursors = 4
		self.adjust_delay = 0
		self.delay = -self.time[cursor_position] + num_of_precursors*1.0/(f_sig)
		self.time, self.pulse = self.chan.get_pulse_resp(f_sig=f_sig, resp_depth=32, t_delay=self.delay)

		plt.ion()
		self.fig 		= plt.figure()
		self.ax 		= self.fig.add_subplot(111)
		self.plotline, 	= self.ax.plot(self.time, self.pulse)
		plt.pause(0.001)

	def insert(self, key):
		self.key_list.insert(0, key)
	def on_press(self, key):
		self.insert(key)
	def on_release(self, key):
		if key == Key.esc:
			return False
	def __str__(self):
		return " ".join(str(self.key_list))
	def __len__(self):
		return len(self.key_list)
	def escape(self):
		return Key.esc in self.key_list
	def next_action(self):
		if len(self.key_list) > 0:
			new_key = self.key_list.pop(-1)
			if new_key == Key.right:
				self.adjust_delay += 1e-12
			elif new_key == Key.left:
				self.adjust_delay -= 1e-12
			elif new_key == Key.esc:
				return False
			if new_key in {Key.right, Key.left}:
				self.time, self.pulse = self.chan.get_pulse_resp(f_sig=f_sig, resp_depth=32, t_delay=self.delay + np.mod(self.adjust_delay, 1/self.f_sig))
				self.ax.clear()
				self.ax.plot(self.time, self.pulse)
				plt.pause(0.001)

		return True



key_handler = KeyHandler(f_sig, file_name)

listener = Listener(on_press=key_handler.on_press, on_release=key_handler.on_release)
listener.start()

while key_handler.next_action():
	time.sleep(0.001)

termios.tcflush(sys.stdin, termios.TCIOFLUSH)
print(key_handler)
