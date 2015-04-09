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
MODULES		:= example.c tm_stm32f4_usart.c tm_stm32f4_gpio.c

########## config end ############

OUTPUT_DIR	?= bin/
DOCUMENTS_DIR	?= docs/
DEPENDENCY_DIR	?= dep/
OBJECTS_DIR	?= obj/
SOURCE_DIR	?= src/
INCLUDE_DIR	?= include/
SCRIPTS_DIR	?= scripts/
SELF_DIR	:= $(dir $(lastword $(MAKEFILE_LIST)))
PROJECT_DIR	?= $(CURDIR)
PROJECT_DIR	?= $(SELF_DIR)

include $(PROJECT_DIR)/.config

PROG_NAME_NQ	:= $(patsubst "%",%,$(PROG_NAME))
EXECUTABLES	:= $(PROG_NAME_NQ).elf
include_dirs	:= $(INCLUDE_DIR)
source_dirs	:= $(SOURCE_DIR)

BINPATH		:= $(addprefix $(OUTPUT_DIR),$(EXECUTABLES))
FILENAMES	:= $(basename $(EXECUTABLES))
OBJECTS		:= $(addsuffix .o,$(FILENAMES))
SOURCES		:= $(addsuffix .c,$(FILENAMES))

CFLAGS		:= -g -O2 -Wall -Werror -Wextra -std=gnu99 -fdata-sections -ffunction-sections \
		   -Wno-unused-parameter -Wno-uninitialized
LDFLAGS		:= -Wl,--gc-sections
CPPFLAGS	:= -D PROG_NAME=$(patsubst %,\"%\",$(PROG_NAME_NQ))
ASMFLAGS	:= -x assembler-with-cpp

ifeq ($(TARGET),stm32f4)
	CPU		:= cortex-m4
	CC		:= arm-none-eabi-gcc
	OBJCOPY		:= arm-none-eabi-objcopy
	ARCH_DIR	:= $(PROJECT_DIR)/arch/arm/mach-stm32f4x7
	ARCH_SRC_DIR	:= $(ARCH_DIR)/src
	ARCH_INC_DIR	:= $(ARCH_DIR)/include
	CFLAGS		+= -T$(ARCH_SRC_DIR)/stm32_flash.ld
	LDFLAGS		+= -T$(ARCH_SRC_DIR)/stm32_flash.ld
	include_dirs	+= $(ARCH_INC_DIR)/
	include_dirs	+= $(STM_FW_DIR)Utilities/STM32F4-Discovery
	include_dirs	+= $(STM_FW_DIR)Libraries/CMSIS/Include
	include_dirs	+= $(STM_FW_DIR)Libraries/CMSIS/ST/STM32F4xx/Include
	include_dirs	+= $(STM_FW_DIR)Libraries/STM32F4xx_StdPeriph_Driver/inc
	source_dirs	+= $(STM_FW_DIR)Libraries/STM32F4xx_StdPeriph_Driver/src
	C_SOURCES	+= $(ARCH_SRC_DIR)/system_stm32f4xx.c
	C_SOURCES	+= stm32f4_discovery.c stm32f4_discovery_lcd.c stm32f4_discovery_debug.c
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_it.c
	S_SOURCES	+= $(ARCH_SRC_DIR)/startup_stm32f4xx.s
	CPPFLAGS	+= -D STM32F4XX
	CPPFLAGS	+= -D USE_STDPERIPH_DRIVER
	CPPFLAGS	+= -D USE_USART6
	CPPFLAGS	+= -D __TEST__
# CPPFLAGS	+= -D HSE_VALUE=8000000

ifdef CONFIG_MISC
	C_SOURCES	+= $(ARCH_SRC_DIR)/misc.c
endif

ifdef CONFIG_ADC
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_adc.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_CAN
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_can.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_CRC
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_crc.c
endif

ifdef CONFIG_CRYP
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_cryp.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_cryp_aes.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_cryp_des.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_cryp_tdes.c
endif

ifdef CONFIG_DAC
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_dac.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_DBGMCU
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_dbgmcu.c
endif

ifdef CONFIG_DCMI
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_dcmi.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_DMA
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_dma.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_EXTI
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_exti.c
endif

ifdef CONFIG_FLASH
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_flash.c
endif

ifdef CONFIG_FSMC
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_fsmc.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_GPIO
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_gpio.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_HASH
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_hash.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_hash_md5.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_hash_sha1.c
endif

ifdef CONFIG_I2C
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_i2c.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_PWR
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_pwr.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_RNG
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_rng.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_RTC
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_rtc.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_SDIO
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_sdio.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_SDIO
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_spi.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_SYSCFG
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_syscfg.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_TIM
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_tim.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_USART
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_usart.c
endif

ifdef CONFIG_WWDG
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4xx_wwdg.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c
endif

ifdef CONFIG_ETH
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm32f4x7_eth.c \
			   $(ARCH_SRC_DIR)/stm32f4xx_rcc.c \
			   $(ARCH_SRC_DIR)/stm32f4x7_eth_bsp.c
endif

# dep: sdio dma i2c
ifdef CONFIG_EVAL
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm324x7i_eval.c
	CPPFLAGS	+= -D USE_STM324x7I_EVAL
endif

# dep: usart
ifdef CONFIG_SERIAL_DEBUG
	C_SOURCES	+= $(ARCH_SRC_DIR)/serial_debug.c
	CPPFLAGS	+= -D SERIAL_DEBUG
endif

ifdef CONFIG_EVAL_AUDIO_CODEC
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm324x7i_eval_audio_codec.c
endif

ifdef CONFIG_EVAL_FSMC_SRAM
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm324x7i_eval_fsmc_sram.c
endif

ifdef CONFIG_EVAL_IOE
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm324x7i_eval_ioe.c
endif

ifdef CONFIG_EVAL_I2C_EE
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm324x7i_eval_i2c_ee.c
	CPPFLAGS	+= -D USE_DEFAULT_TIMEOUT_CALLBACK
endif

ifdef CONFIG_EVAL_LCD
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm324x7i_eval_lcd.c
	CPPFLAGS	+= -D USE_LCD
endif

ifdef CONFIG_SDIO_SD
	C_SOURCES	+= $(ARCH_SRC_DIR)/stm324x7i_eval_sdio_sd.c
endif
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

DATE		:= `date +"%Y-%m-%d_%H-%M"`
NULLDEVICE	:= /dev/null
RMFILES		:= rm -rf
ALLFILES	:= /*.*

$(shell mkdir $(OBJECTS_DIR)>$(NULLDEVICE) 2>&1)
$(shell mkdir $(OUTPUT_DIR)>$(NULLDEVICE) 2>&1)
$(shell mkdir $(DEPENDENCY_DIR)>$(NULLDEVICE) 2>&1)
ifeq (clean,$(findstring clean, $(MAKECMDGOALS)))
  ifneq ($(filter $(MAKECMDGOALS),all flash doc report),)
    $(shell $(RMFILES) $(OBJECTS_DIR)$(ALLFILES)>$(NULLDEVICE) 2>&1)
    $(shell $(RMFILES) $(OUTPUT_DIR)$(ALLFILES)>$(NULLDEVICE) 2>&1)
    $(shell $(RMFILES) $(DEPENDENCY_DIR)$(ALLFILES)>$(NULLDEVICE) 2>&1)
  endif
endif

C_SOURCES	+= $(PROG_NAME_NQ).c $(MODULES)
C_FILES		:= $(notdir $(C_SOURCES))
S_FILES		:= $(notdir $(S_SOURCES))
C_OBJECTS	:= $(addprefix $(OBJECTS_DIR),$(C_FILES:.c=.o))
S_OBJECTS	:= $(if $(S_SOURCES), $(addprefix $(OBJECTS_DIR),$(S_FILES:.s=.o)))
OBJECTS		:= $(C_OBJECTS) $(S_OBJECTS)

MAKEDEPEND	= $(CC) -MM $(CFLAGS) $(INCLUDEPATHS) $(CPPFLAGS) $< > $(DEPENDENCY_DIR)$*.d

ifdef CONFIG_LWIP
  include $(PROJECT_DIR)/lwip/Makefile
endif

INCLUDEPATHS	:= $(addprefix -I ,$(include_dirs))

vpath %.h $(include_dirs)
vpath %.c $(source_dirs) $(ARCH_SRC_DIR) $(EXP_SRC_DIRS)
vpath %.s $(SOURCE_DIR) $(ARCH_SRC_DIR)
vpath %.sh $(SCRIPTS_DIR)
vpath %.o $(OBJECTS_DIR)
vpath %.d $(DEPENDENCY_DIR)
vpath %.elf $(OUTPUT_DIR)
vpath %.bin $(OUTPUT_DIR)
vpath %.hex $(OUTPUT_DIR)
vpath % $(OUTPUT_DIR)

.SUFFIXES: .elf

.PHONY: clean doc report flash show

all: $(EXECUTABLES)

dependencies	= $(addprefix $(DEPENDENCY_DIR),$(notdir $(OBJECTS:.o=.d)))

ifneq "$(MAKECMDGOALS)" "clean"
  -include $(dependencies)
endif

$(PROG_NAME_NQ).elf: $(OBJECTS)
	@echo "Linking target: $@"
	$(CC) $(LDFLAGS) $^ $(LIBS) -o $(OUTPUT_DIR)$@
	$(OBJCOPY) -O ihex $(OUTPUT_DIR)$(PROG_NAME_NQ).elf $(OUTPUT_DIR)$(PROG_NAME_NQ).hex
	$(OBJCOPY) -O binary $(OUTPUT_DIR)$(PROG_NAME_NQ).elf $(OUTPUT_DIR)$(PROG_NAME_NQ).bin

$(OBJECTS_DIR)%.o: %.c
	@echo "Compiling file: $<"
	$(CC) -c $(CFLAGS) $(INCLUDEPATHS) $(CPPFLAGS) $< -o $(OBJECTS_DIR)$*.o
	@echo "building dependencies for: $<"
	$(MAKEDEPEND)
	@mv -f $(DEPENDENCY_DIR)$*.d $(DEPENDENCY_DIR)$*.d.tmp
	@sed -e 's|.*:|$(OBJECTS_DIR)$*.o:|' < $(DEPENDENCY_DIR)$*.d.tmp > $(DEPENDENCY_DIR)$*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $(DEPENDENCY_DIR)$*.d.tmp | fmt -1 | \
		sed -e 's/^ *//' -e 's/$$/:/' >> $(DEPENDENCY_DIR)$*.d
	@rm -f $(DEPENDENCY_DIR)$*.d.tmp

$(OBJECTS_DIR)%.o: %.s
	@echo "Assembling $<"
	$(CC) $(ASMFLAGS) $(INCLUDEPATHS) -c -o $(OBJECTS_DIR)$(@F) $<

show:
	@echo $(OBJECTS)
	@echo $(C_SOURCES)

doc:
	@cd $(DOCUMENTS_DIR); \
		PROJECT_NAME=$(PROJECT_NAME) doxygen Doxyfile

report:
	@echo "building report"
	@make -C $(DOCUMENTS_DIR)report/latex/

clean:
	-rm -f $(BINPATH) $(OUTPUT_DIR)* $(DEPENDENCY_DIR)*.d $(OBJECTS_DIR)*.o

# Flash the STM32F4
flash: $(EXECUTABLES)
	@$(STLINK)/st-flash write $(OUTPUT_DIR)$(PROG_NAME_NQ).bin 0x8000000

size:
	arm-none-eabi-size $(OUTPUT_DIR)/$(PROG_NAME_NQ).hex
