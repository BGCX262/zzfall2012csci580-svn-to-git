/* Texture functions for cs580 GzLib	*/
#include    "stdafx.h" 
#include	"stdio.h"
#include	"Gz.h"
#include "math.h"

GzColor	*image;
int xs, ys;
int reset = 1;

//for procedural texturing
int xSize = 100;
int ySize = 100;
int boardSize = 10;

/* Image texture function */
int tex_fun(float u, float v, GzColor color)
{
  unsigned char		pixel[3];
  unsigned char     dummy;
  char  		foo[8];
  int   		i, j, k;
  FILE			*fd;

  if (reset) {          /* open and load texture file */
    fd = fopen ("texture", "rb");
    if (fd == NULL) {
      fprintf (stderr, "texture file not found\n");
      exit(-1);
    }
    fscanf (fd, "%s %d %d %c", foo, &xs, &ys, &dummy);
    image = (GzColor*)malloc(sizeof(GzColor)*(xs+1)*(ys+1));
    if (image == NULL) {
      fprintf (stderr, "malloc for texture image failed\n");
      exit(-1);
    }

    for (i = 0; i < xs*ys; i++) {	/* create array of GzColor values */
      fread(pixel, sizeof(pixel), 1, fd);
      image[i][RED] = (float)((int)pixel[RED]) * (1.0 / 255.0);
      image[i][GREEN] = (float)((int)pixel[GREEN]) * (1.0 / 255.0);
      image[i][BLUE] = (float)((int)pixel[BLUE]) * (1.0 / 255.0);
      }

    reset = 0;          /* init is done */
	fclose(fd);
  }

/* bounds-test u,v to make sure nothing will overflow image array bounds */
/* determine texture cell corner values and perform bilinear interpolation */
/* set color to interpolated GzColor value and return */

  if(u < 0 || u > 1.0 || v < 0 || v > 1.0){
	  return GZ_FAILURE;
  }else{
	  u = u * (xs - 1);
	  v = v * (ys - 1);
	  int left = floor(u);
	  int right = ceil(u);
	  int top = floor(v);
	  int bottom = ceil(v);
	  float s = u - (float)left;
	  float t = v - (float)top;
	  for(k = 0; k < 3; k++){
		  float colorA = image[top*xs+left][k];
		  float colorB = image[top*xs+right][k];
		  float colorC = image[bottom*xs+right][k];
		  float colorD = image[bottom*xs+left][k];
		  color[k] = s*t*colorC + (1.0 - s)*t*colorD + 
			  s*(1.0 - t)*colorB + (1.0 - s)*(1.0 - t)*colorA;
	  }
  }

  return GZ_SUCCESS;
}


/* Procedural texture function */
int ptex_fun(float u, float v, GzColor color)
{
	float colorTemp;
	if(u < 0 || u > 1.0 || v < 0 || v > 1.0){
		return GZ_FAILURE;
	}else{
		u = u * (xSize - 1);
		v = v * (ySize - 1);
		int x = u / boardSize;
		int y = v / boardSize;
		if((x%2 == 0 && y%2 == 0) || (x%2 == 1 && y%2 == 1)){
			colorTemp = 0.0;
		}else{
			colorTemp = 1.0;
		}

		for(int k = 0; k < 3; k++){
			color[k] = colorTemp;
		}
	}

	return GZ_SUCCESS;
}
