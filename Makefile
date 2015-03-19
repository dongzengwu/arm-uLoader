########## config start ##########

PROJECT_NAME	:= "uLoader"
# name of created binary
PROG_NAME	:= $(PROJECT_NAME)
# name of target device
TARGET		:= stm32f4
# STM firmware/library path
STM_FW_DIR	:= $(HOME)/stm32_discovery_arm_gcc/STM32F4-Discovery_FW_V1.1.0/
# stlink path for programming/debugging tools
STLINK		:= $(HOME)/stlink/
# all extra source files go here
MODULES		:= example.c

########## config end ############

OUTPUT_DIR	?= bin/
DOCUMENTS_DIR	?= docs/
DEPENDENCY_DIR	?= dep/
OBJECTS_DIR	?= obj/
SOURCE_DIR	?= src/
INCLUDE_DIR	?= include/
SCRIPTS_DIR	?= scripts/
PROJECT_DIR	?= $(OUTPUT_DIR)../

PROG_NAME_NQ	:= $(patsubst "%",%,$(PROG_NAME))
EXECUTABLES	:= $(PROG_NAME_NQ).elf
include_dirs	:= $(INCLUDE_DIR) $(PROJECT_DIR)lwip/include/

BINPATH		:= $(addprefix $(OUTPUT_DIR),$(EXECUTABLES))
FILENAMES	:= $(basename $(EXECUTABLES))
OBJECTS		:= $(addsuffix .o,$(FILENAMES))
SOURCES		:= $(addsuffix .c,$(FILENAMES))

CFLAGS		:= -g -O3 -Wall -Werror -Wextra -std=gnu99 -fdata-sections -ffunction-sections
LDFLAGS		:= -Wl,--gc-sections
CPPFLAGS	:= -D PROG_NAME=$(patsubst %,\"%\",$(PROG_NAME_NQ))
ASMFLAGS	:= -x assembler-with-cpp

ifeq ($(TARGET),stm32f4)
	CPU		:= cortex-m4
	CC		:= arm-none-eabi-gcc
	OBJCOPY		:= arm-none-eabi-objcopy
	ARCH_DIR	:= $(PROJECT_DIR)arch/arm/mach-stm32f4x7
	ARCH_SRC_DIR	:= $(ARCH_DIR)/src/
	ARCH_INC_DIR	:= $(ARCH_DIR)/include/
	CFLAGS		+= -T$(ARCH_SRC_DIR)stm32_flash.ld
	LDFLAGS		+= -T$(ARCH_SRC_DIR)stm32_flash.ld
	include_dirs	+= $(STM_FW_DIR)Utilities/STM32F4-Discovery
	include_dirs	+= $(STM_FW_DIR)Libraries/CMSIS/Include
	include_dirs	+= $(STM_FW_DIR)Libraries/CMSIS/ST/STM32F4xx/Include
	include_dirs	+= $(STM_FW_DIR)Libraries/STM32F4xx_StdPeriph_Driver/inc
	include_dirs	+= $(ARCH_INC_DIR)/
	C_SOURCES	+= $(ARCH_SRC_DIR)/system_stm32f4xx.c
	S_SOURCES	+= $(ARCH_SRC_DIR)/startup_stm32f4xx.s
endif

CPU		?= cortex-m3

CC		?= gcc
CFLAGS		+= -Wno-unused-variable -Wno-missing-field-initializers
CFLAGS		+= -mlittle-endian -mthumb -mcpu=$(CPU) -mthumb-interwork
CFLAGS		+= -mfloat-abi=hard -mfpu=fpv4-sp-d16
LDFLAGS		+= -mlittle-endian -mthumb -mcpu=$(CPU) -mthumb-interwork
LDFLAGS		+= -mfloat-abi=hard -mfpu=fpv4-sp-d16
ASMFLAGS	+= -mlittle-endian -mthumb -mcpu=$(CPU) -mthumb-interwork
ASMFLAGS	+= -mfloat-abi=hard -mfpu=fpv4-sp-d16

LIBS		:= -Wl,--start-group -lgcc -lc -lnosys -Wl,--end-group

INCLUDEPATHS	:= $(addprefix -I ,$(include_dirs))

DATE		:= `date +"%Y-%m-%d_%H-%M"`
NULLDEVICE	:= /dev/null
RMFILES		:= rm -rf
ALLFILES	:= /*.*

$(shell mkdir $(OBJECTS_DIR)>$(NULLDEVICE) 2>&1)
$(shell mkdir $(OUTPUT_DIR)>$(NULLDEVICE) 2>&1)
$(shell mkdir $(DEPENDENCY_DIR)>$(NULLDEVICE) 2>&1)
ifeq (clean,$(findstring clean, $(MAKECMDGOALS)))
  ifneq ($(filter $(MAKECMDGOALS),all burn doc report),)
    $(shell $(RMFILES) $(OBJECTS_DIR)$(ALLFILES)>$(NULLDEVICE) 2>&1)
    $(shell $(RMFILES) $(OUTPUT_DIR)$(ALLFILES)>$(NULLDEVICE) 2>&1)
    $(shell $(RMFILES) $(DEPENDENCY_DIR)$(ALLFILES)>$(NULLDEVICE) 2>&1)
  endif
endif

vpath %.h $(include_dirs) $(ARCH_INC_DIR)
vpath %.c $(SOURCE_DIR) $(ARCH_SRC_DIR)
vpath %.s $(SOURCE_DIR) $(ARCH_SRC_DIR)
vpath %.sh $(SCRIPTS_DIR)
vpath %.o $(OBJECTS_DIR)
vpath %.d $(DEPENDENCY_DIR)
vpath %.elf $(OUTPUT_DIR)
vpath %.bin $(OUTPUT_DIR)
vpath %.hex $(OUTPUT_DIR)
vpath % $(OUTPUT_DIR)

.SUFFIXES: .elf

C_SOURCES	+= $(PROG_NAME_NQ).c $(MODULES)
C_FILES		:= $(notdir $(C_SOURCES))
S_FILES		:= $(notdir $(S_SOURCES))
C_OBJECTS	:= $(addprefix $(OBJECTS_DIR),$(C_FILES:.c=.o))
S_OBJECTS	:= $(if $(S_SOURCES), $(addprefix $(OBJECTS_DIR),$(S_FILES:.s=.o)))
OBJECTS		:= $(C_OBJECTS) $(S_OBJECTS)

all: $(EXECUTABLES)

$(PROG_NAME_NQ).elf: $(OBJECTS)
	@echo "Linking target: $@"
	$(CC) $(LDFLAGS) $^ $(LIBS) -o $(OUTPUT_DIR)$@
	$(OBJCOPY) -O ihex $(OUTPUT_DIR)$(PROG_NAME_NQ).elf $(OUTPUT_DIR)$(PROG_NAME_NQ).hex
	$(OBJCOPY) -O binary $(OUTPUT_DIR)$(PROG_NAME_NQ).elf $(OUTPUT_DIR)$(PROG_NAME_NQ).bin

$(OBJECTS_DIR)%.o: %.c
	@echo "Building file: $<"
	$(CC) $(CFLAGS) $(INCLUDEPATHS) $(CPPFLAGS) -c -o $(OBJECTS_DIR)$(@F) $<

$(OBJECTS_DIR)%.o: %.s
	@echo "Assembling $<"
	$(CC) $(ASMFLAGS) $(INCLUDEPATHS) -c -o $(OBJECTS_DIR)$(@F) $<

.PHONY: clean doc report burn

doc:
	@cd $(DOCUMENTS_DIR); \
		PROJECT_NAME=$(PROJECT_NAME) doxygen Doxyfile

report:
	@echo "building report"
	@make -C $(DOCUMENTS_DIR)report/latex/

clean:
	-rm -f $(BINPATH) $(OUTPUT_DIR)* $(DEPENDENCY_DIR)*.d $(OBJECTS_DIR)*.o

# Flash the STM32F4
burn: $(EXECUTABLES)
	$(STLINK)/st-flash write $(PROG_NAME_NQ).bin 0x8000000

dependencies	= $(addprefix $(DEPENDENCY_DIR),$(subst .c,.d,$(SOURCES)))

ifneq "$(MAKECMDGOALS)" "clean"
	-include $(dependencies)
endif

$(DEPENDENCY_DIR)%.d: %.c
	@$(CC) -M $(INCLUDEPATHS) $(CPPFLAGS) $< > $@.$$$$;			\
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@;	\
	rm -f $@.$$$$
