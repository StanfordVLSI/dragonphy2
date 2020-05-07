# Data word size
word_size = 144
# Number of words in the memory
num_words = 1024

# Technology to use in $OPENRAM_TECH
tech_name = "freepdk45"

# You can use the technology nominal corner only
nominal_corner_only = True

# Output directory for the results
output_path = "temp"
# Output file base name
output_name = "sram_{0}_{1}_{2}".format(word_size, num_words, tech_name)