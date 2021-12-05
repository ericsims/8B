CC=customasm
BIN_DIR=bin
TEST_SRC_DIR=tests
TEST_SRCS=$(wildcard $(TEST_SRC_DIR)/*.asm)
TEST_BINS=$(patsubst $(TEST_SRC_DIR)/%.asm,$(BIN_DIR)/%.bin,$(TEST_SRCS))
all-tests := $(addsuffix .test, $(basename $(TEST_BINS)))
LUTS = "lut/sin_lut.dat"

all: tests $(LUTS)

"lut/sin_lut.dat": "lut/sin_lut.dat"
	@mkdir -p lut
	jupyter nbconvert --execute sin_lut.ipynb --inplace	

tests: $(TEST_BINS)

$(BIN_DIR)/%.bin: $(TEST_SRC_DIR)/%.asm
	@mkdir -p $(@D)
	${CC} -f binary -o $@ $<
	@${CC} -f annotated -o $@.annotated $< > /dev/null
	@echo ""


test:
	@echo "***running test cases***"
	@for test in $(TEST_BINS);\
	do\
		echo "running $$test case";\
		python 8B.py --no-sim --no-gui -f $$test >> /dev/null || exit 1;\
	done;\
	echo "passed test cases..."
	@echo ""
	

clean:
	@echo "***cleaning up***"
	@rm -f $(LUTS)
	@rm -f $(TEST_BINS)
	@rm -f $(addsuffix .annotated,$(TEST_BINS))
	@echo "done cleaning..."
	@echo ""
	

.PHONY: all