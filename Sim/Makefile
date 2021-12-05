CC=customasm
BIN_DIR=bin
TEST_SRC_DIR=tests
TEST_SRCS=$(wildcard $(TEST_SRC_DIR)/*.asm)
TEST_BINS=$(patsubst $(TEST_SRC_DIR)/%.asm,$(BIN_DIR)/%.bin,$(TEST_SRCS))
all-tests := $(addsuffix .test, $(basename $(TEST_BINS)))

all: clean tests

tests: $(TEST_BINS)

$(BIN_DIR)/%.bin: $(TEST_SRC_DIR)/%.asm
	@mkdir -p $(@D)
	${CC} -f binary -o $@ $<
	@${CC} -f annotated -o $@.annotated $< > /dev/null
	@echo ""


test: 
	@for test in $(TEST_BINS); do echo "running $$test case"; python 8B.py --no-sim --no-gui -f $$test >> /dev/null || break; echo ""; done
	

clean:
	@echo "***cleaning up***"
	rm -f $(TEST_BINS)
	rm -f $(addsuffix .annotated,$(TEST_BINS))
	@echo "done cleaning..."
	

.PHONY: all