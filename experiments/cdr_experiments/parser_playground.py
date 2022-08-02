from pyparsing import *


def printPlus(s, loc, tokens):
	print(f'plus occured at {loc} in {s}')

LBRACE, RBRACE = map(Literal, "{}")

PLUS, MINUS, DIVIDE, MULTIPLY = map(Literal, "+-/*")

BINOP = PLUS | MINUS | DIVIDE | MULTIPLY
INTEG = Word(nums)
FLOAT = Forward()
EXPONENT = Combine(Literal('e') + (FLOAT | INTEG))
FLOAT <<= Combine(INTEG + '.' + Optional(INTEG + Optional(EXPONENT))) | Combine(INTEG + Optional(EXPONENT))
VALUE = FLOAT | INTEG 
VARIABLE = Word(alphas)

ARITH = Forward()
ARITH  <<= (VARIABLE | VALUE ) + BINOP + Group(ARITH | VARIABLE | VALUE )

BLOCK = Forward()
BLOCK <<= Suppress(LBRACE) + Group(OneOrMore(BLOCK | Group(ARITH | VARIABLE | VALUE))) + Suppress(RBRACE)

HELLO = Literal("hello") | Literal("hi")

print(BLOCK.parseString("{ { works { works } } hi { bye + 1e9 * 2 / 3 - 4 + 5 + 1e2.3 { yes }} hello}"))

for item in BLOCK.scanString("asda\n { { works { works } } hi { bye + 1.24 * 2 / 3 - 4 + 5  { yes }} hello} asd as { hi} "):
	print(item)

print(list(HELLO.scanString("asda\n { { works { works } } hi { bye + 1 * 2 / 3 - 4 + 5  { yes }} hello} asd as { hi} ")))


