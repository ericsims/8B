CC=customasm
BIN_DIR=bin
TEST_SRC_DIR=tests
TEST_SRCS=$(wildcard $(TEST_SRC_DIR)/*.asm)
TEST_BINS=$(patsubst $(TEST_SRC_DIR)/%.asm,$(BIN_DIR)/%.bin,$(TEST_SRCS))
all-tests := $(addsuffix .test, $(basename $(TEST_BINS)))
LUTS="bin/sin_lut.dat"
INST_SET="instructions.asm"

all: clean $(INST_SET) $(LUTS) tests 

"bin/sin_lut.dat":
	@mkdir -p lut
	jupyter nbconvert --execute ./lib_dev/Trig/sin_lut.ipynb --inplace	

tests: $(INST_SET) $(TEST_BINS) $(LUTS)

$(BIN_DIR)/%.bin: $(TEST_SRC_DIR)/%.asm
	@mkdir -p $(@D)
	${CC} -f binary -o $@ $<
	@${CC} -f annotated -o $@.annotated -- -f symbols -o $@.symbols $< > /dev/null
	@echo ""


test:
	@echo "***running test cases***"
	@for test in $(TEST_BINS);\
	do\
		echo "running $$test case";\
		python sim/cpu_sim.py --no-sim --no-gui -f $$test >> /dev/null || exit 1;\
	done;\
	echo "passed test cases..."
	@echo ""

$(INST_SET):
	@echo "***builing instruction set***"
	python parse_instruction_set.py || exit 1
	@echo "done building instruction set..."
	@echo ""



clean:
	@echo "***cleaning up***"
	@rm -f $(LUTS)
	@rm -f $(TEST_BINS)
	@rm -f $(addsuffix .annotated,$(TEST_BINS))
	@rm -f $(INST_SET)
	@echo "done cleaning..."
	@echo ""
	

.PHONY: all