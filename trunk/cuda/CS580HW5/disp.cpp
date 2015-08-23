/*   CS580 HW   */
#include    "stdafx.h"  
#include	"Gz.h"
#include	"disp.h"


int GzNewFrameBuffer(char** framebuffer, int width, int height)
{
/* create a framebuffer:
 -- allocate memory for framebuffer : (sizeof)GzPixel x width x height
 -- pass back pointer 
*/
	//check the bound of width
	if(width > MAXXRES || width < 0){
		return GZ_FAILURE;
	}

	//check the bound of height
	if(height > MAXYRES || height < 0){
		return GZ_FAILURE;
	}

	//allocate array of pixels
	char* temp = (char*)malloc(width * height * sizeof(GzPixel));

	if(temp == NULL){
		return GZ_FAILURE;
	}else{
		*framebuffer = temp;
	}

	return GZ_SUCCESS;
}

int GzNewDisplay(GzDisplay	**display, GzDisplayClass dispClass, int xRes, int yRes)
{

/* create a display:
  -- allocate memory for indicated class and resolution
  -- pass back pointer to GzDisplay object in display
*/
	char* framebuffer = NULL;
	GzDisplay* oneDisplay;

	//check the bound of x resolution
	if(xRes > MAXXRES || xRes < 0){
		return GZ_FAILURE;
	}

	//check the bound of y resolution
	if(yRes > MAXYRES || yRes < 0){
		return GZ_FAILURE;
	}

	//allocate new frame buffer
	GzNewFrameBuffer(&framebuffer, xRes, yRes);

	//allocate new display
	oneDisplay = (GzDisplay*)malloc(sizeof(GzDisplay));

	if(oneDisplay == NULL){
		return GZ_FAILURE;
	}else{
		oneDisplay->dispClass = GZ_RGBAZ_DISPLAY; //default display class is dispClass
		oneDisplay->fbuf = (GzPixel*)framebuffer;
		oneDisplay->open = 1; // the display is initialized to be opened
		oneDisplay->xres = xRes;
		oneDisplay->yres = yRes;
		*display = oneDisplay;
	}

	return GZ_SUCCESS;
}


int GzFreeDisplay(GzDisplay	*display)
{
/* clean up, free memory */

	if(display == NULL){
		return GZ_FAILURE;
	}else{
		free(display->fbuf); //deallocate frame buffer
		free(display); //deallocate display
	}

	return GZ_SUCCESS;
}


int GzGetDisplayParams(GzDisplay *display, int *xRes, int *yRes, GzDisplayClass	*dispClass)
{
/* pass back values for an open display */

	if(display == NULL){
		return GZ_FAILURE;
	}else{
		*xRes = display->xres;
		*yRes = display->yres;
		*dispClass = display->dispClass;
	}

	return GZ_SUCCESS;
}


int GzInitDisplay(GzDisplay	*display)
{
/* set everything to some default values - start a new frame */

	unsigned short x,  y;

	if(display == NULL){
		return GZ_FAILURE;
	}

	//initialize the frame buffer to be white
	for(y = 0; y < display->yres; y++){
		for(x = 0; x < display->xres; x++){
			display->fbuf[ARRAY(x,y)].red = 0x0fff;
			display->fbuf[ARRAY(x,y)].green = 0x0fff;
			display->fbuf[ARRAY(x,y)].blue = 0x0fff;
			display->fbuf[ARRAY(x,y)].alpha = 1;
			display->fbuf[ARRAY(x,y)].z = 0;
		}
	}

	return GZ_SUCCESS;
}


int GzPutDisplay(GzDisplay *display, int i, int j, GzIntensity r, GzIntensity g, GzIntensity b, GzIntensity a, GzDepth z)
{
/* write pixel values into the display */

	if(i >= display->xres || i < 0) return GZ_SUCCESS; //ignore the i and j which are not in bound
	if(j >= display->yres || j < 0) return GZ_SUCCESS;

	if(display->fbuf[ARRAY(i,j)].z == 0 || z < display->fbuf[ARRAY(i,j)].z){

		//clamp the red color
		if(r > 4095){
			display->fbuf[ARRAY(i,j)].red = 4095;
		}else if(r < 0){
			display->fbuf[ARRAY(i,j)].red = 0;
		}else{
			display->fbuf[ARRAY(i,j)].red = r;
		}

		//clamp the green color
		if(g > 4095){
			display->fbuf[ARRAY(i,j)].green = 4095;
		}else if(g < 0){
			display->fbuf[ARRAY(i,j)].green = 0;
		}else{
			display->fbuf[ARRAY(i,j)].green = g;
		}

		//clamp the blue color
		if(b > 4095){
			display->fbuf[ARRAY(i,j)].blue = 4095;
		}else if(b < 0){
			display->fbuf[ARRAY(i,j)].blue = 0;
		}else{
			display->fbuf[ARRAY(i,j)].blue = b;
		}

		display->fbuf[ARRAY(i,j)].alpha = a;
		display->fbuf[ARRAY(i,j)].z = z;
	}

	return GZ_SUCCESS;
}


int GzGetDisplay(GzDisplay *display, int i, int j, GzIntensity *r, GzIntensity *g, GzIntensity *b, GzIntensity *a, GzDepth *z)
{
	/* pass back pixel value in the display */
	/* check display class to see what vars are valid */

	if(i >= display->xres || i < 0) return GZ_SUCCESS; //ignore the i and j which are not in bound
	if(j >= display->yres || j < 0) return GZ_SUCCESS;

	if(display == NULL){
		return GZ_FAILURE;
	}else{
		*r = display->fbuf[ARRAY(i,j)].red;
		*g = display->fbuf[ARRAY(i,j)].green;
		*b = display->fbuf[ARRAY(i,j)].blue;
		*a = display->fbuf[ARRAY(i,j)].alpha;
		*z = display->fbuf[ARRAY(i,j)].z;
	}

	return GZ_SUCCESS;
}


int GzFlushDisplay2File(FILE* outfile, GzDisplay *display)
{

	/* write pixels to ppm file based on display class -- "P6 %d %d 255\r" */
	unsigned short x,  y;
	char color[3];

	if(outfile == NULL || display == NULL){
		return GZ_FAILURE;
	}else{
		fprintf(outfile, "P6 %d %d 255\n", display->xres, display->yres); //write the header of ppm file
		for(y = 0; y < display->yres; y++){
			for(x = 0; x < display->xres; x++){
				color[0] = (display->fbuf[ARRAY(x,y)].red)>>4;
				color[1] = (display->fbuf[ARRAY(x,y)].green)>>4;
				color[2] = (display->fbuf[ARRAY(x,y)].blue)>>4;
				fwrite(color, sizeof(color[0]), sizeof(color)/sizeof(color[0]), outfile);
			}
		}
	}

	return GZ_SUCCESS;
}

int GzFlushDisplay2FrameBuffer(char* framebuffer, GzDisplay *display)
{

	/* write pixels to framebuffer: 
		- Put the pixels into the frame buffer

		- Caution: store the pixel to the frame buffer as the order of blue, green, and red 
		- Not red, green, and blue !!!
	*/

	unsigned short x, y;
	char* buffer = NULL;
	int count = 0;

	if(framebuffer == NULL || display == NULL){
		return GZ_FAILURE;
	}else{
		buffer = (char*)malloc(display->xres*display->yres*3);
		for(y = 0; y < display->yres; y++){
			for(x = 0; x < display->xres; x++){
				buffer[count++] = (display->fbuf[ARRAY(x,y)].blue)>>4;
				buffer[count++] = (display->fbuf[ARRAY(x,y)].green)>>4;
				buffer[count++] = (display->fbuf[ARRAY(x,y)].red)>>4;
			}
		}
	}

	memcpy(framebuffer, buffer, display->xres*display->yres*3);

	return GZ_SUCCESS;
}