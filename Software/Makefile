CC := customasm
BIN_DIR := bin
SRC_DIR := src
TEST_SRC_DIR := tests
LIB_SRC_DIR := src/lib
VENV_DIR := .venv
REQ_FILE := requirements_dev
IR_DOCS_DIR := irdocs
DOCS_DIR := docs

TEST_SRCS := $(sort $(wildcard $(TEST_SRC_DIR)/*.asm))
LIB_SRCS := $(sort $(wildcard $(LIB_SRC_DIR)/*.asm))
TEST_BINS := $(patsubst $(TEST_SRC_DIR)/%.asm,$(BIN_DIR)/%.bin,$(TEST_SRCS))
all_tests  :=  $(addsuffix .test, $(basename $(TEST_BINS)))


IR_DOCS := $(patsubst $(TEST_SRC_DIR)/%.asm,$(IR_DOCS_DIR)/%.yml,$(TEST_SRCS))
IR_DOCS += $(patsubst $(LIB_SRC_DIR)/%.asm,$(IR_DOCS_DIR)/%.yml,$(LIB_SRCS))

LUTS := $(BIN_DIR)/sin_lut.dat
INST_SET_OUT := $(SRC_DIR)/instructions.asm
INST_SET_IN := instruction_set.yaml
MEM_MAP_OUT := $(SRC_DIR)/mems.asm
MEM_MAP_DOC := $(DOCS_DIR)/mem_map.svg
MEM_MAP_IN := memory_map.yaml

parse_docs_script = ./scripts/parse_docs.py
coverage_report_script = ./scripts/inst_coverage_report.py
coverage_report = $(DOCS_DIR)/inst_coverage.txt

.PHONY: all deps

all: tests docs

$(VENV_DIR):
	@echo makeing python venv... 
	@python -m venv .venv

deps: $(VENV_DIR)
	@( \
		echo activating venv... && \
		source $(VENV_DIR)/Scripts/activate && \
		echo installing pip-tools... && \
		python -m pip install pip-tools && \
		echo building requirements list... && \
		pip-compile $(REQ_FILE).in -v && \
		echo installing requirements... && \
		pip install -r $(REQ_FILE).txt \
	)

instruction: $(INST_SET_OUT)
$(INST_SET_OUT): $(MEM_MAP_OUT)
	@echo "builing instruction set..."
	@echo "checking yaml syntax..."
	@yamllint -d "{extends: default, rules: {line-length: disable, truthy: disable, new-lines: {type: platform}}}" $(INST_SET_IN)
	python parse_instruction_set.py || exit 1
	@echo ""

luts: $(LUTS)
$(BIN_DIR)/sin_lut.dat:
	@mkdir -p bin
	jupyter nbconvert --execute ./lib_dev/Trig/sin_lut.ipynb --inplace	

tests: $(TEST_BINS)
$(BIN_DIR)/%.bin: $(TEST_SRC_DIR)/%.asm $(LIB_SRCS)
	@mkdir -p $(@D)
	${CC} -f binary -o $@ $<
	@${CC} -f annotated -o $@.annotated -- -f symbols -o $@.symbols $< > /dev/null
	@echo ""
$(TEST_SRCS): instruction luts

test: $(all_tests) 
$(all_tests): %.test : %.bin
	@echo "running test case $<"
	@python sim/cpu_sim.py --no-sim --no-gui -f $< >> /dev/null || exit 1

docs: coverage_report memory_map
$(IR_DOCS_DIR)/%.yml: $(TEST_SRC_DIR)/%.asm
	@mkdir -p $(IR_DOCS_DIR)
	@$(parse_docs_script) $< $@
$(IR_DOCS_DIR)/%.yml: $(LIB_SRC_DIR)/%.asm
	@mkdir -p $(IR_DOCS_DIR)
	@$(parse_docs_script) $< $@

coverage_report: $(coverage_report)
$(coverage_report): $(IR_DOCS)
	@mkdir -p $(DOCS_DIR)
	@echo generating instruction test coverage report...
	@$(coverage_report_script) $(INST_SET_IN) $(IR_DOCS_DIR) > $(coverage_report)

memory_map: $(MEM_MAP_DOC)
$(MEM_MAP_DOC): $(MEM_MAP_IN)
	@echo "builing memory map set..."
	@echo "checking yaml syntax..."
	@yamllint -d "{extends: default, rules: {line-length: disable, new-lines: {type: platform}}}" $(MEM_MAP_IN)
	@mld --format=svg --output=$(MEM_MAP_DOC) $(MEM_MAP_IN)
	@echo ""

$(MEM_MAP_OUT): $(MEM_MAP_IN)
	@echo "builing memory map set..."
	@echo "checking yaml syntax..."
	@yamllint -d "{extends: default, rules: {line-length: disable, new-lines: {type: platform}}}" $(MEM_MAP_IN)
	@python parse_memory_map.py || exit 1
	@echo ""


.PHONY: clean
clean:
	@echo "***cleaning up***"
	@rm -rf $(BIN_DIR)
	@rm -rf $(IR_DOCS_DIR)
	@rm -f $(INST_SET_OUT)
	@rm -f $(MEM_MAP_OUT)
	@echo "done cleaning..."
	@echo ""
