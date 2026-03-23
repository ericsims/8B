# venv
VENV_DIR := .venv
REQ_FILE := requirements_dev
# assembler
CC := customasm
# source files
SRC_DIR := src/
# libs
LIB_SRC_DIR := src/lib/
# tests
TEST_SRC_DIR := tests/
TEST_BIN_DIR := $(TEST_SRC_DIR)bin/
# apps
APPS_SRC_DIR := apps/
APPS_BIN_DIR := $(APPS_SRC_DIR)bin/
# documentation
IR_DOCS_DIR := irdocs/
DOCS_DIR := docs/


# libs
LIB_SRCS := $(sort $(wildcard $(LIB_SRC_DIR)*.asm))

# tests
TEST_SRCS := $(sort $(wildcard $(TEST_SRC_DIR)*.asm))
TEST_BINS := $(patsubst $(TEST_SRC_DIR)%.asm,$(TEST_BIN_DIR)%.bin,$(TEST_SRCS))
all_tests  :=  $(addsuffix .test, $(basename $(TEST_BINS)))

# apps
APPS_SRCS := $(sort $(wildcard $(APPS_SRC_DIR)*.asm))
STATIC_APPS_BINS := $(patsubst $(APPS_SRC_DIR)%.asm,$(APPS_BIN_DIR)%_static.bin,$(APPS_SRCS))
DYNAMIC_APPS_BINS := $(patsubst $(APPS_SRC_DIR)%.asm,$(APPS_BIN_DIR)%.bin,$(APPS_SRCS))

IR_DOCS := $(patsubst $(TEST_SRC_DIR)%.asm,$(IR_DOCS_DIR)%.yml,$(TEST_SRCS))
IR_DOCS += $(patsubst $(LIB_SRC_DIR)%.asm,$(IR_DOCS_DIR)%.yml,$(LIB_SRCS))

LUTS := $(TEST_BIN_DIR)sin_lut.dat
INST_SET_OUT := $(SRC_DIR)instructions.asm
INST_SET_IN := instruction_set.yaml
MEM_MAP_OUT := $(SRC_DIR)mems.asm
MEM_MAP_DOC := $(DOCS_DIR)mem_map.svg
MEM_MAP_IN := memory_map.yaml

parse_docs_script = ./scripts/parse_docs.py
coverage_report_script = ./scripts/inst_coverage_report.py
coverage_report = $(DOCS_DIR)/inst_coverage.txt

.PHONY: all deps

all: tests apps docs

$(VENV_DIR):
	@echo makeing python venv... 
	@python3 -m venv .venv

deps: $(VENV_DIR)
	@( \
		echo activating venv... && \
		. $(VENV_DIR)/bin/activate && \
		echo installing pip-tools... && \
		python -m pip install pip-tools && \
		echo building requirements list... && \
		pip-compile $(REQ_FILE).in -v && \
		echo installing requirements... && \
		pip install -r $(REQ_FILE).txt \
	)

# instruction set
instruction: $(INST_SET_OUT)
$(INST_SET_OUT): $(MEM_MAP_OUT) $(INST_SET_IN)
	@echo "builing instruction set..."
	@echo "checking yaml syntax..."
	@yamllint -d "{extends: default, rules: {line-length: disable, truthy: disable, new-lines: {type: platform}}}" $(INST_SET_IN)
	python parse_instruction_set.py || exit 1
	@echo ""

# memory map
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

# TODO: fix lut generations. make it per lib, and not with jupyter
luts: $(LUTS)
$(TEST_BIN_DIR)/sin_lut.dat:
	@mkdir -p bin
	jupyter nbconvert --execute ./lib_dev/Trig/sin_lut.ipynb --inplace	

# build tests
tests: $(TEST_BINS)
$(TEST_BIN_DIR)%.bin: $(TEST_SRC_DIR)%.asm $(LIB_SRCS) $(INST_SET_OUT)
	mkdir -p $(@D)
	${CC} -f binary -o $@ $<
	@${CC} -f annotated -o $@.annotated -- -f symbols -o $@.symbols $< > /dev/null
	@echo ""
$(TEST_SRCS): instruction

# build RGB565 image for image test
$(TEST_BIN_DIR)1903_test_ra8876_put_img.bin: $(TEST_SRC_DIR)lenna_64_64_rgb565.img
$(TEST_SRC_DIR)lenna_64_64_rgb565.img: $(TEST_SRC_DIR)lenna_64_64.jpg
	ffmpeg -i $(TEST_SRC_DIR)lenna_64_64.jpg -vcodec rawvideo -f rawvideo -pix_fmt rgb565be $(TEST_SRC_DIR)lenna_64_64_rgb565.img -y -loglevel error

# run tests
test: $(all_tests)
$(all_tests): %.test : %.bin
	@echo running test case $<   $(test_flags)
	@python sim/cpu_sim.py --no-sim -f $< --no-gui $(test_flags)

# additional test flags for some unique tests
$(TEST_BIN_DIR)1751_test_sd_card_init_v1.test: test_flags := --diskv1=./sim/virt_disk
$(TEST_BIN_DIR)1752_test_sd_card_init_v2.test: test_flags := --diskv2=./sim/virt_disk
$(TEST_BIN_DIR)1753_test_sd_card_read_block.test: test_flags := --diskv1=./sim/virt_disk
$(TEST_BIN_DIR)1760_test_parse_mbr.test: test_flags := --diskv1=./sim/virt_disk --ignore-uninit-mem
$(TEST_BIN_DIR)1761_test_find_file.test: test_flags := --diskv1=./sim/virt_disk --ignore-uninit-mem
$(TEST_BIN_DIR)1762_test_load_file.test: test_flags := --diskv1=./sim/virt_disk --ignore-uninit-mem
$(TEST_BIN_DIR)1770_test_run_file_from_disk.test: test_flags := --diskv1=./sim/virt_disk --ignore-uninit-mem
$(TEST_BIN_DIR)2002_test_w5300_tcp_client.test: test_flags := --subprocess="printf 'hello back\0' | nc -l 8080"
$(TEST_BIN_DIR)2003_test_w5300_udp_client.test: test_flags := --subprocess="printf 'hello back\0' | nc -u -l 8081"
$(TEST_BIN_DIR)2005_test_w5300_dns.test: test_flags := --ignore-uninit-mem


# build apps
apps: $(STATIC_APPS_BINS) $(DYNAMIC_APPS_BINS)
$(APPS_BIN_DIR)%_static.bin: $(APPS_SRC_DIR)%.asm $(INST_SET_OUT) $(LIB_SRCS) $(INST_SET_OUT)
	mkdir -p $(@D)
	${CC} -f binary -o $@ $<
	@${CC} -f annotated -o $@.annotated -- -f symbols -o $@.symbols $< > /dev/null
	@echo ""
$(APPS_BIN_DIR)%.bin: $(APPS_SRC_DIR)%.asm $(INST_SET_OUT) $(LIB_SRCS) $(INST_SET_OUT)
	mkdir -p $(@D)
	${CC} -dDYNAMIC_LOAD=1 -f binary -o $@ $<
	@${CC} -dDYNAMIC_LOAD=1 -f annotated -o $@.annotated -- -f symbols -o $@.symbols $< > /dev/null
	@echo ""

# documentation
docs: coverage_report memory_map
$(IR_DOCS_DIR)%.yml: $(TEST_SRC_DIR)%.asm
	@mkdir -p $(IR_DOCS_DIR)
	@$(parse_docs_script) $< $@
$(IR_DOCS_DIR)%.yml: $(LIB_SRC_DIR)%.asm
	@mkdir -p $(IR_DOCS_DIR)
	@$(parse_docs_script) $< $@
coverage_report: $(coverage_report)
$(coverage_report): $(IR_DOCS)
	@mkdir -p $(DOCS_DIR)
	@echo generating instruction test coverage report...
	@$(coverage_report_script) $(INST_SET_IN) $(IR_DOCS_DIR) > $(coverage_report)

.PHONY: clean
clean:
	@echo "***cleaning up***"
	@rm -rf $(TEST_BIN_DIR)
	@rm -rf $(APPS_BIN_DIR)
	@rm -rf $(IR_DOCS_DIR)
	@rm -f $(INST_SET_OUT)
	@rm -f $(MEM_MAP_OUT)
	@echo "done cleaning..."
	@echo ""
