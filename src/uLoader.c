#include "stm32f4xx.h"
#include "tm_stm32f4_usart.h"
/* #define __TEST__ */
#ifdef __TEST__
#include "stm32f4x7_eth.h"
#include "netconf.h"
#include "uLoader.h"
#include "serial_debug.h"
#endif

#define ENV_SYSCORECLK		"SYSCORECLK"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

static inline int parser(const char *command, const size_t maxbuf);
static inline int cmd_echo(const char *command, const size_t maxbuf);
static inline int printenv(const char **env);

extern char **environ;

int _write(int file, char *ptr, int len)
{
	int n = 0;

	(void) file;
	for (; len > 0; --len) {
		if (*ptr == '\n')
			TM_USART_Putc(USART6, '\r');

		TM_USART_Putc(USART6, *ptr);
		ptr++;
		n++;
	}

	return n;
}

int _read(int file, char *ptr, int len)
{
	int n = 4;

	(void) file;
	/* for (; len > 0; --len) { */
	/* 	*ptr = 'a'; */
	/* 	break; */
	/* 	if (n != 0) */
	/* 		break; */

	/* 	n++; */
	/* 	*ptr = TM_USART_Getc(USART6); */
	/* 	if (*ptr == '\r') { */
	/* 		*ptr = '\n'; */
	/* 		break; */
	/* 	} */

	/* 	ptr++; */
	/* } */

	return n;
}

#define SYSTEMTICK_PERIOD_MS  10

/*--------------- LCD Messages ---------------*/
#if defined (STM32F40XX)
#define MESSAGE1   "    STM32F40/41x     "
#elif defined (STM32F427X)
#define MESSAGE1   "     STM32F427x      "
#endif
#define MESSAGE2   "  STM32F-4 Series   "
#define MESSAGE3   "   Webserver Demo   "
#define MESSAGE4   "                    "

/* this variable is used to create a time reference incremented by 10ms */
#ifdef __TEST__
__IO uint32_t LocalTime = 0;
uint32_t timingdelay;

void LCD_LED_Init(void);
void assert_failed(uint8_t* file, uint32_t line);
#endif
static void ms_delay(int ms);

/* RCC_ClocksTypeDef RCC_Clocks; */
//Flash orange LED at about 1hz
int main(void)
{
	environ = calloc(1, sizeof(char *));
	*environ = NULL;
	/* is atm called at startupscript */
	/* SystemInit(); */
	/* NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4); */
	/* RCC_GetClocksFreq(&RCC_Clocks); */
#ifdef SERIAL_DEBUG
	DebugComPort_Init();
	printf("hallo welt\r\n");
#endif

	/* Initialize LCD and Leds */
	LCD_LED_Init();

	/* configure ethernet (GPIOs, clocks, MAC, DMA) */
	ETH_BSP_Config();

	/* Initilaize the LwIP stack */
	LwIP_Init();

	TM_USART_Init(USART6, TM_USART_PinsPack_1, 115200);

	/* RCC->AHB1ENR |= RCC_AHB1ENR_GPIODEN;  // enable the clock to GPIOD */
	/* GPIOD->MODER = (1 << 26);             // set pin 13 to be general purpose output */

	setbuf(stdout, NULL);
	char buffer[64] = {};
	int ret;

	printf("\r%s> ", PROG_NAME);
	for (;;) {
		/* check if any packet received */
		if (ETH_CheckFrameReceived()) {
			/* process received ethernet packet */
			LwIP_Pkt_Handle();
		}

		/* handle periodic timers for LwIP */
		LwIP_Periodic_Handle(LocalTime);
		/* sys_check_timeouts(); */

		/* TM_USART_Puts(USART6, "Hallo Welt\r\n"); */
		if (TM_USART_Gets(USART6, buffer, 64) != 0) {
			parser(buffer, sizeof(buffer));

			printf("\r%s> ", PROG_NAME);
		}
		/* ret = scanf("%s", buffer); */
		/* printf("chars read: %i\n", ret); */
		/* buffer[0] = TM_USART_Getc(USART6); */
		/* printf("zeichen: %c\n", buffer[0]); */

		ms_delay(500);
		/* GPIOD->ODR ^= (1 << 13);           // Toggle the pin */
	}

	free(environ);

	return EXIT_SUCCESS;
}

static inline int parser(const char *command, const size_t maxbuf)
{
	if (strncmp(command, "echo ", 5) == 0)
		cmd_echo(command, maxbuf);
	else if (strncmp(command, "printenv", 8) == 0)
		printenv((const char **) environ);
	else if (strncmp(command, "env", 3) == 0)
		printenv((const char **) environ);
	else
		printf("unknown command: %.*s\n",
			maxbuf, command);

	return 0;
}

static inline int cmd_echo(const char *command, const size_t maxbuf)
{
	/* TODO implement environ + loop over it */
	if (strncmp(command + 5, "$" ENV_SYSCORECLK, sizeof(ENV_SYSCORECLK)) == 0) {
		printf("SYSCORECLK: %u\n",
			(unsigned int) SystemCoreClock);
	} else {
		printf("%.5s%s\n", command, "$" ENV_SYSCORECLK);
		printf("%s\n", command + 5);
	}

	return 0;
}

static inline int printenv(const char **env)
{
	int i = 0;

	SystemCoreClockUpdate();

	printf("%s=%u\n",
		ENV_SYSCORECLK, (unsigned int) SystemCoreClock);
	printf("%s=%u\n",
		"HSE_VALUE", (unsigned int) HSE_VALUE);

	while (env[i])
		printf("%s\n", env[i++]);

	return 0;
}

#ifdef __TEST__
/**
 * @brief  Inserts a delay time.
 * @param  nCount: number of 10ms periods to wait for.
 * @retval None
 */
void Delay(uint32_t nCount)
{
	/* Capture the current local time */
	timingdelay = LocalTime + nCount;

	/* wait until the desired delay finish */
	while (timingdelay > LocalTime) {};
}

/**
  * @brief  Initializes the STM324xG-EVAL's LCD and LEDs resources
  * @param  None
  * @retval None
  */
void LCD_LED_Init(void)
{
#ifdef USE_LCD
	/* Initialize the STM324xG-EVAL's LCD */
	STM32f4_Discovery_LCD_Init();
#endif

#ifdef USE_LCD
	/* Clear the LCD */
	LCD_Clear(Black);

	/* Set the LCD Back Color */
	LCD_SetBackColor(Black);

	/* Set the LCD Text Color */
	LCD_SetTextColor(White);

	/* Display message on the LCD*/
	LCD_DisplayStringLine(Line0, (uint8_t*)MESSAGE1);
	LCD_DisplayStringLine(Line1, (uint8_t*)MESSAGE2);
	LCD_DisplayStringLine(Line2, (uint8_t*)MESSAGE3);
	LCD_DisplayStringLine(Line3, (uint8_t*)MESSAGE4);
#endif
}

#ifdef  USE_FULL_ASSERT

/**
 * @brief  Reports the name of the source file and the source line number
 *   where the assert_param error has occurred.
 * @param  file: pointer to the source file name
 * @param  line: assert_param error line source number
 * @retval None
 */
void assert_failed(uint8_t* file, uint32_t line)
{
	/* User can add his own implementation to report the file name and line number,
	 * ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

	/* Infinite loop */
	while (1) {};
}
#endif
#endif

//Quick hack, approximately 1ms delay
static void ms_delay(int ms)
{
	while (ms-- > 0) {
		volatile int x=5971;
		while (x-- > 0)
			__asm("nop");
	}
}

/**
  * @brief  Updates the system local time
  * @param  None
  * @retval None
  */
void Time_Update(void)
{
	LocalTime += SYSTEMTICK_PERIOD_MS;
}
