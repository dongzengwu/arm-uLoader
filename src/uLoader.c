#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "stm32f4xx.h"
#ifdef __TEST__
#include "stm32f4x7_eth.h"
#include "netconf.h"
#include "uLoader.h"
#endif
/* #include "serial_debug.h" */

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

//Flash orange LED at about 1hz
int main(void)
{
	/* NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4); */
#ifdef SERIAL_DEBUG
	DebugComPort_Init();
#endif

	/* Initialize LCD and Leds */
	/* LCD_LED_Init(); */

	/* configure ethernet (GPIOs, clocks, MAC, DMA) */
	/* ETH_BSP_Config(); */

	/* Initilaize the LwIP stack */
	/* LwIP_Init(); */

	RCC->AHB1ENR |= RCC_AHB1ENR_GPIODEN;  // enable the clock to GPIOD
	GPIOD->MODER = (1 << 26);             // set pin 13 to be general purpose output

	for (;;) {
		/* check if any packet received */
		/* if (ETH_CheckFrameReceived()) { */
		/* 	#<{(| process received ethernet packet |)}># */
		/* 	LwIP_Pkt_Handle(); */
		/* } */

		/* handle periodic timers for LwIP */
		/* LwIP_Periodic_Handle(LocalTime); */

		ms_delay(500);
		GPIOD->ODR ^= (1 << 13);           // Toggle the pin
	}

	return EXIT_SUCCESS;
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
  * @brief  Updates the system local time
  * @param  None
  * @retval None
  */
void Time_Update(void)
{
	LocalTime += SYSTEMTICK_PERIOD_MS;
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
	STM324xG_LCD_Init();
#endif

	/* Initialize STM324xG-EVAL's LEDs */
	STM_EVAL_LEDInit(LED1);
	STM_EVAL_LEDInit(LED2);
	STM_EVAL_LEDInit(LED3);
	STM_EVAL_LEDInit(LED4);

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
