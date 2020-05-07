import os
e = os.environ

OUTPUT = f"""\
# Data word size
word_size = {e['sram_word_size']}

# Number of words in the memory
num_words = {e['sram_num_words']}

# Technology to use in $OPENRAM_TECH
tech_name = "{e['sram_tech_name']}"

# You can use the technology nominal corner only
nominal_corner_only = True

# Output directory for the results
output_path = "{e['sram_output_path']}"

# Output file base name
output_name = "sram_{e['sram_word_size']}_{e['sram_num_words']}_{e['sram_tech_name']}"
"""

with open('myconfig.py', 'w') as f:
    f.write(OUTPUT)