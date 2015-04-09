#include "tftp.h"
#include "lwip/udp.h"

#include <string.h>

#define IP_ADDR_FMT		"%hu.%hu.%hu.%hu"
#define get_ipaddr(addr) \
	ip4_addr1(addr), ip4_addr2(addr), ip4_addr3(addr), ip4_addr4(addr)
#define SWAP(block)	\
	((block) >> 8) | ((block) << 8)

static inline int tftp_init(void);
static inline int tftp_deinit(void);
static inline int tftp_rrq(const char *file);
static inline int tftp_ack(struct ip_addr *destAddr,
				unsigned short *port,
				unsigned short block);
static inline void tftp_recv(void *arg, struct udp_pcb *pcb,
				struct pbuf *p,
				struct ip_addr *addr, u16_t port);

static struct udp_pcb *tftp_upcb;
unsigned int file_size = 0;

extern int tftp(const char *file)
{
	tftp_init();
	tftp_rrq(file);

	return 0;
}

static inline  int tftp_init(void)
{

	file_size = 0;
	tftp_upcb = udp_new();
	udp_bind(tftp_upcb, IP_ADDR_ANY, 0);
	/* udp_connect(tftp_upcb, &destAddr, 69); */
	udp_recv(tftp_upcb, tftp_recv, NULL);

	return 0;
}

static inline  int tftp_deinit(void)
{
	udp_remove(tftp_upcb);

	return 0;
}

static inline  int tftp_rrq(const char *file)
{
	if (!file)
		return -1;

	char msg[512 + 4] = {};
	int len = 0;

	memcpy(msg + len, "\x00", 1);
	len++;
	memcpy(msg + len, "\x01", 1);
	len++;
	memcpy(msg + len, file, strlen(file));
	len+=10;
	memcpy(msg + len, "\x00", 1);
	len++;
	memcpy(msg + len, "octet", 5);
	len+=5;
	memcpy(msg + len, "\x00", 1);
	len++;

	struct pbuf* p = pbuf_alloc(PBUF_TRANSPORT, len, PBUF_RAM);
	memcpy(p->payload, msg, len);

	struct ip_addr destAddr;

	IP4_ADDR(&destAddr, 192, 168, 1, 22);

	/* udp_send(tftp_upcb, p); */
	udp_sendto(tftp_upcb, p, &destAddr, 69);

	pbuf_free(p);

	return 0;
}

static inline int
tftp_ack(struct ip_addr *destAddr, unsigned short *port,
		unsigned short block)
{
	if (!destAddr || !port)
		return -1;

	char msg[4] = {};
	int len = 0;
	unsigned short swapped = SWAP(block);

	memcpy(msg + len, "\x00\x04", 2);
	len+=2;
	memcpy(msg + len, (void *) &swapped, 2);
	len+=2;

	struct pbuf* p = pbuf_alloc(PBUF_TRANSPORT, len, PBUF_RAM);
	memcpy(p->payload, msg, len);
	udp_sendto(tftp_upcb, p, destAddr, *port);

	pbuf_free(p);

	return 0;
}

static inline void tftp_recv(void *arg, struct udp_pcb *pcb,
				struct pbuf *p,
				struct ip_addr *addr, u16_t port)
{
	unsigned short type = SWAP(*(unsigned short *) p->payload);
	unsigned short block;

	printf("receive %i byte from " IP_ADDR_FMT ":%hu\n",
		p->tot_len, get_ipaddr(addr), port);

	switch (type) {
	case 0x0003:
		/* DATA */
		block = SWAP(*(unsigned short *) (p->payload + 2));

		puts("DATA package");
		printf("block: %hu\n", block);
		tftp_ack(addr, &port, block);
		/* 2 byte type + 2 byte block number */
		file_size+=p->tot_len - 4;

		break;
	case 0x0004:
		/* ACK */
		puts("ACK package");
		break;
	case 0x0005:
		/* ERROR */
		puts("ERROR package");
		break;
	default:
		/* unknown */
		puts("unknown package");
		break;
	}

	pbuf_free(p);

	if (p->tot_len < 512 + 4) {
		printf("done with receiving\n");
		printf("file size is: %i byte\n", file_size);

		tftp_deinit();
	}
}
