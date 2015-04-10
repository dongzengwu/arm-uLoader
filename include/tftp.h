#ifndef _TFTP_H
#define _TFTP_H

#define IP_ADDR_FMT		"%hu.%hu.%hu.%hu"
#define get_ipaddr(addr) \
	ip4_addr1(addr), ip4_addr2(addr), ip4_addr3(addr), ip4_addr4(addr)
#define SWAP(block)	\
	((block) >> 8) | ((block) << 8)

extern unsigned int file_size;

extern int tftp(const char *file);

#endif /* _TFTP_H */
