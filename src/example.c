/**
 *  @file
 *  @brief Function source for the console driver.
 *
 *  This contains the source for the console
 *
 *  @author me
 */

#include <stdio.h>
#include <string.h>

char *muh(int count)
{
	/** @TODO moo not so loud */
	char muh[10] = "muh";

	for (int i = 0; i < count; i++)
		puts(muh);

	return strdup(muh);
}
