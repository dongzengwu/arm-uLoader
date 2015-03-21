LWIP_SRC_DIR	:= $(PROJECT_DIR)/lwip/core
LWIP_INC_DIR	+= $(PROJECT_DIR)/lwip/include

# COREFILES, CORE4FILES: The minimum set of files needed for lwIP.
COREFILES	:= $(LWIP_SRC_DIR)/core/mem.c $(LWIP_SRC_DIR)/core/memp.c $(LWIP_SRC_DIR)/core/netif.c \
	$(LWIP_SRC_DIR)/core/pbuf.c $(LWIP_SRC_DIR)/core/raw.c \
	$(LWIP_SRC_DIR)/core/stats.c $(LWIP_SRC_DIR)/core/sys.c \
	$(LWIP_SRC_DIR)/core/tcp.c $(LWIP_SRC_DIR)/core/tcp_in.c \
	$(LWIP_SRC_DIR)/core/tcp_out.c $(LWIP_SRC_DIR)/core/udp.c $(LWIP_SRC_DIR)/core/dhcp.c \
	$(LWIP_SRC_DIR)/core/init.c $(LWIP_SRC_DIR)/core/timers.c $(LWIP_SRC_DIR)/core/def.c

CORE4FILES	:= $(LWIP_SRC_DIR)/core/ipv4/icmp.c $(LWIP_SRC_DIR)/core/ipv4/ip.c \
	$(LWIP_SRC_DIR)/core/ipv4/inet.c $(LWIP_SRC_DIR)/core/ipv4/ip_addr.c \
	$(LWIP_SRC_DIR)/core/ipv4/ip_frag.c $(LWIP_SRC_DIR)/core/ipv4/inet_chksum.c 

# NETIFFILES: Files implementing various generic network interface functions.'
NETIFFILES	:= $(LWIP_SRC_DIR)/netif/etharp.c netconf.c ethernetif.c

# LWIPFILES: All the above.
LWIPFILES	:= $(COREFILES) $(CORE4FILES) $(NETIFFILES)

SOURCES		+= $(LWIPFILES)
OBJECTS		+= $(addprefix $(OBJECTS_DIR),$(notdir $(LWIPFILES:.c=.o)))
include_dirs	+= $(LWIP_INC_DIR) $(LWIP_INC_DIR)/ipv4
EXP_SRC_DIRS	+= $(LWIP_SRC_DIR) $(LWIP_SRC_DIR)/ipv4 $(LWIP_SRC_DIR)/../netif
CFLAGS		+= -Wno-unused-but-set-variable -Wno-address -Wno-unused-parameter
