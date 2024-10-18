CC := customasm
BIN_DIR := bin
SRC_DIR := src
TEST_SRC_DIR := tests
LIB_SRC_DIR := src/lib
VENV_DIR := .venv
REQ_FILE := requirements.in
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
		echo activating venv...; \
		source $(VENV_DIR)/Scripts/activate; \
		echo installing pip-tools...; \
		python -m pip install pip-tools; \
		echo building requirements list...; \
		pip-compile.exe $(REQ_FILE) -v; \
		echo installing requirements...; \
		pip install -r requirements.txt; \
	)

instruction: $(INST_SET_OUT)
$(INST_SET_OUT): $(INST_SET_IN)
	@echo "checking yaml syntax..."
	@yamllint -d "{extends: default, rules: {line-length: disable, truthy: disable}}" instruction_set.yaml
	@echo "builing instruction set..."
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

docs: coverage_report
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



# hdl
ADDR_DECODE_PRJ := hdl_test
ADDR_DECODE_VHD_FILE := $(ADDR_DECODE_PRJ)/$(ADDR_DECODE_PRJ).vhd
ADDR_DECODE_POF_FILE := $(ADDR_DECODE_PRJ)/output_files/$(ADDR_DECODE_PRJ).pof
ADDR_DECODE_JED_FILE := $(ADDR_DECODE_PRJ)/output_files/$(ADDR_DECODE_PRJ).jed

QUARTUS := c:/altera/13.0sp1/quartus/bin64/quartus_sh.exe
POF2JED := C:/POF2JED/bin/POF2JED.exe
CPLD := 1504as

addr_decode: $(ADDR_DECODE_JED_FILE)

$(ADDR_DECODE_POF_FILE): $(ADDR_DECODE_VHD_FILE)
	@echo building VHDL using quartus_sh 
	"$(QUARTUS)" --flow compile $(ADDR_DECODE_PRJ)/$(ADDR_DECODE_PRJ)

$(ADDR_DECODE_JED_FILE): $(ADDR_DECODE_POF_FILE)
	@echo converting POF to JED
	"$(POF2JED)" -i $(ADDR_DECODE_POF_FILE) -device $(CPLD)




clean:
	@echo "***cleaning up***"
	@rm -rf $(BIN_DIR)
	@rm -rf $(IR_DOCS_DIR)
	@rm -f $(INST_SET_OUT)
	@rm -f $(ADDR_DECODE_POF_FILE)
	@rm -f $(ADDR_DECODE_JED_FILE)
	@echo "done cleaning..."
	@echo ""
