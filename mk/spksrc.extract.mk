### Extract rules
#   Extract the $(DIST_FILE) in $(EXTRACT_PATH)
# Override EXTRACT_PATH to specify path to use instead of $(WORK_DIR)
# Target are executed in the following order:
#  extract_msg_target
#  pre_extract_target   (override with PRE_EXTRACT_TARGET)
#  extract_target       (override with EXTRACT_TARGET)
#  post_extract_target  (override with POST_EXTRACT_TARGET)
EXTRACT_PATH ?= $(WORK_DIR)
# Extract commands
EXTRACT_CMD.tgz = tar -xzpf $(DIST_FILE) -C
EXTRACT_CMD.txz = tar -xpf $(DIST_FILE) -C
EXTRACT_CMD.tar.gz = tar -xzpf $(DIST_FILE) -C
EXTRACT_CMD.tar.bz2 = tar -xjpf $(DIST_FILE) -C
EXTRACT_CMD.tar.xz = tar -xJpf $(DIST_FILE) -C
EXTRACT_CMD.tar.lzma = tar --lzma -xpf $(DIST_FILE) -C
EXTRACT_CMD.tar.lz = tar --lzip -xpf $(DIST_FILE) -C
EXTRACT_CMD.zip = unzip $(DIST_FILE) -d

EXTRACT_CMD = $(EXTRACT_CMD.$(DIST_EXT))


EXTRACT_COOKIE = $(WORK_DIR)/.$(COOKIE_PREFIX)extract_done

ifeq ($(strip $(PRE_EXTRACT_TARGET)),)
PRE_EXTRACT_TARGET = pre_extract_target
else
$(PRE_EXTRACT_TARGET): extract_msg
endif
ifeq ($(strip $(EXTRACT_TARGET)),)
EXTRACT_TARGET = extract_target
else
$(EXTRACT_TARGET): $(PRE_EXTRACT_TARGET)
endif
ifeq ($(strip $(POST_EXTRACT_TARGET)),)
POST_EXTRACT_TARGET = post_extract_target
else
$(POST_EXTRACT_TARGET): $(EXTRACT_TARGET)
endif

.PHONY: extract extract_msg
.PHONY: $(PRE_EXTRACT_TARGET) $(EXTRACT_TARGET) $(POST_EXTRACT_TARGET)

extract_msg:
	@$(MSG) "Extracting for $(NAME)"

pre_extract_target: extract_msg

extract_target: $(PRE_EXTRACT_TARGET)
	@mkdir -p $(EXTRACT_PATH)
	$(EXTRACT_CMD) $(EXTRACT_PATH) 2>/dev/null || ( t=$$(mktemp -d /tmp/XXXXXX) ; mkdir -p $$t && $(EXTRACT_CMD) $$t && mv $$t/* $(EXTRACT_PATH) && rmdir $$t )

post_extract_target: $(EXTRACT_TARGET)

ifeq ($(wildcard $(EXTRACT_COOKIE)),)
extract: $(EXTRACT_COOKIE)

$(EXTRACT_COOKIE): $(POST_EXTRACT_TARGET)
	$(create_target_dir)
	@touch -f $@
else
extract: ;
endif
