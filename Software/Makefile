CC := customasm
BIN_DIR := bin
SRC_DIR := src
TEST_SRC_DIR := tests
VENV_DIR := .venv
REQ_FILE := requirements.in
DOC_DIR := docs/test_inter/
DOC_CONV := scripts/asm4doxy.pl

TEST_SRCS := $(sort $(wildcard $(TEST_SRC_DIR)/*.asm))
TEST_BINS := $(patsubst $(TEST_SRC_DIR)/%.asm,$(BIN_DIR)/%.bin,$(TEST_SRCS))
DOC_FILES := $(patsubst $(TEST_SRC_DIR)/%.asm,$(DOC_DIR)/%-asm.c,$(TEST_SRCS))
all_tests  :=  $(addsuffix .test, $(basename $(TEST_BINS)))
all_tests_gui  :=  $(addsuffix .gui.test, $(basename $(TEST_BINS)))

LUTS := $(BIN_DIR)/sin_lut.dat
INST_SET_OUT := $(SRC_DIR)/instructions.asm
INST_SET_IN := instruction_set.yaml

.PHONY: all deps

all: tests

$(VENV_DIR):
	@echo makeing python venv... 
	@python -m venv .venv

deps: $(VENV_DIR)
	@echo installing python packages...
	( \
		source $(VENV_DIR)/Scripts/activate; \
		python -m pip install pip-tools; \
		pip-compile.exe $(REQ_FILE); \
		pip install -r requirements.txt; \
	)

instruction: $(INST_SET_OUT)
$(INST_SET_OUT): $(INST_SET_IN)
	@echo "***builing instruction set***"
	python parse_instruction_set.py || exit 1
	@echo "done building instruction set..."
	@echo ""

luts: $(LUTS)
$(BIN_DIR)/sin_lut.dat:
	@mkdir -p bin
	jupyter nbconvert --execute ./lib_dev/Trig/sin_lut.ipynb --inplace	

tests: $(TEST_BINS)
$(BIN_DIR)/%.bin: $(TEST_SRC_DIR)/%.asm
	@mkdir -p $(@D)
	${CC} -f binary -o $@ $<
	@${CC} -f annotated -o $@.annotated -- -f symbols -o $@.symbols $< > /dev/null
	@echo ""
$(TEST_SRCS): instruction luts

test: $(all_tests) 
$(all_tests): %.test : %.bin
	@echo "running test case $<"
	@python sim/cpu_sim.py --no-sim --no-gui -f $< >> /dev/null || exit 1

test_gui: $(all_tests_gui) 
$(all_tests_gui): %.gui.test : %.bin
	@echo "running test case $<"
	@python sim/cpu_sim.py --no-sim --exit-on-halt -f $< >> /dev/null || exit 1

.PHONY: doxygen
asm4doxy: $(DOC_FILES)
$(DOC_DIR)/%-asm.c: $(TEST_SRC_DIR)/%.asm
	@mkdir -p $(DOC_DIR)
	@echo "doc $<"
	@cd $(DOC_DIR) && $(CURDIR)/$(DOC_CONV) ../../$^

doxygen: asm4doxy
	@echo generate doxygen
	@doxygen

clean:
	@echo "***cleaning up***"
	@rm -r $(DOC_DIR)
	@rm -f $(LUTS)
	@rm -f $(TEST_BINS)
	@rm -f $(addsuffix .annotated,$(TEST_BINS))
	@rm -f $(INST_SET_OUT)
	@echo "done cleaning..."
	@echo ""

# run:
# make clean && make -j8 && make test -j8