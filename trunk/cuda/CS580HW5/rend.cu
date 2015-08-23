/* CS580 Homework 3 */

#include	"stdafx.h"
#include	"stdio.h"
#include	"math.h"
#include	"Gz.h"
#include	"rend.h"
#include	"book.h"
#include	"cuda.h"

#include <limits.h>

__host__ __device__ short ctoi(float color);
__host__ __device__ bool vectorZero(GzCoord vector);
__host__ __device__ void vectorConstruct(GzCoord vector1, GzCoord vector2, GzCoord vector); //vector = vector2 - vector1
__host__ __device__ void vectorNormalize(GzCoord vector);
__host__ __device__ float vectorDotProduct(GzCoord vector1, GzCoord vector2); //return vector1 * vector2
__host__ __device__ void vectorCrossProduct(GzCoord vector1, GzCoord vector2, GzCoord product); //product = vector1 x vector2
__host__ __device__ void vectorScale(float scale, GzCoord vector);
__host__ __device__ void vectorScale(float scale, GzCoord vector1, GzCoord vector2);

__host__ __device__ float vectorTransform(GzCoord vector, float w, GzMatrix matrix);
__host__ __device__ void matrixMultiply(GzMatrix matrixA, GzMatrix matrixB, GzMatrix matrixC);

__host__ __device__ void vectorAdd(GzCoord vector1, GzCoord vector2);
__host__ __device__ void vectorAdd(GzCoord vector1, GzCoord vector2, GzCoord vector3);
__host__ __device__ void vectorMultiply(GzCoord vector1, GzCoord vector2);
__host__ __device__ void vectorMultiply(GzCoord vector1, GzCoord vector2, GzCoord vector3);
__host__ __device__ float vectorLength(GzCoord vector);

int GzRotXMat(float degree, GzMatrix mat)
{
// Create rotate matrix : rotate along x axis
// Pass back the matrix using mat value

	mat[0][0] = 1.0;
	mat[0][1] = 0.0;
	mat[0][2] = 0.0;
	mat[0][3] = 0.0;

	mat[1][0] = 0.0;
	mat[1][1] = cos(PIII/180*degree);
	mat[1][2] = -sin(PIII/180*degree);
	mat[1][3] = 0.0;

	mat[2][0] = 0.0;
	mat[2][1] = sin(PIII/180*degree);
	mat[2][2] = cos(PIII/180*degree);
	mat[2][3] = 0.0;

	mat[3][0] = 0.0;
	mat[3][1] = 0.0;
	mat[3][2] = 0.0;
	mat[3][3] = 1.0;
	
	return GZ_SUCCESS;
}


int GzRotYMat(float degree, GzMatrix mat)
{
// Create rotate matrix : rotate along y axis
// Pass back the matrix using mat value

	mat[0][0] = cos(PIII/180*degree);
	mat[0][1] = 0.0;
	mat[0][2] = sin(PIII/180*degree);
	mat[0][3] = 0.0;

	mat[1][0] = 0.0;
	mat[1][1] = 1.0;
	mat[1][2] = 0.0;
	mat[1][3] = 0.0;

	mat[2][0] = -sin(PIII/180*degree);
	mat[2][1] = 0.0;
	mat[2][2] = cos(PIII/180*degree);
	mat[2][3] = 0.0;

	mat[3][0] = 0.0;
	mat[3][1] = 0.0;
	mat[3][2] = 0.0;
	mat[3][3] = 1.0;

	return GZ_SUCCESS;
}


int GzRotZMat(float degree, GzMatrix mat)
{
// Create rotate matrix : rotate along z axis
// Pass back the matrix using mat value

	mat[0][0] = cos(PIII/180*degree);
	mat[0][1] = -sin(PIII/180*degree);
	mat[0][2] = 0.0;
	mat[0][3] = 0.0;

	mat[1][0] = sin(PIII/180*degree);
	mat[1][1] = cos(PIII/180*degree);
	mat[1][2] = 0.0;
	mat[1][3] = 0.0;

	mat[2][0] = 0.0;
	mat[2][1] = 0.0;
	mat[2][2] = 1.0;
	mat[2][3] = 0.0;

	mat[3][0] = 0.0;
	mat[3][1] = 0.0;
	mat[3][2] = 0.0;
	mat[3][3] = 1.0;

	return GZ_SUCCESS;
}


int GzTrxMat(GzCoord translate, GzMatrix mat)
{
// Create translation matrix
// Pass back the matrix using mat value

	mat[0][0] = 1.0;
	mat[0][1] = 0.0;
	mat[0][2] = 0.0;
	mat[0][3] = translate[0];

	mat[1][0] = 0.0;
	mat[1][1] = 1.0;
	mat[1][2] = 0.0;
	mat[1][3] = translate[1];

	mat[2][0] = 0.0;
	mat[2][1] = 0.0;
	mat[2][2] = 1.0;
	mat[2][3] = translate[2];

	mat[3][0] = 0.0;
	mat[3][1] = 0.0;
	mat[3][2] = 0.0;
	mat[3][3] = 1.0;

	return GZ_SUCCESS;
}


int GzScaleMat(GzCoord scale, GzMatrix mat)
{
// Create scaling matrix
// Pass back the matrix using mat value

	mat[0][0] = scale[0];
	mat[0][1] = 0.0;
	mat[0][2] = 0.0;
	mat[0][3] = 0.0;

	mat[1][0] = 0.0;
	mat[1][1] = scale[1];
	mat[1][2] = 0.0;
	mat[1][3] = 0.0;

	mat[2][0] = 0.0;
	mat[2][1] = 0.0;
	mat[2][2] = scale[2];
	mat[2][3] = 0.0;

	mat[3][0] = 0.0;
	mat[3][1] = 0.0;
	mat[3][2] = 0.0;
	mat[3][3] = 1.0;

	return GZ_SUCCESS;
}


//----------------------------------------------------------
// Begin main functions

int GzNewRender(GzRender **render, GzRenderClass renderClass, GzDisplay	*display)
{
/*  
- malloc a renderer struct 
- keep closed until all inits are done 
- setup Xsp and anything only done once 
- span interpolator needs pointer to display 
- check for legal class GZ_Z_BUFFER_RENDER 
- init default camera 
*/ 
	GzRender* oneRender = NULL;

	//malloc a new renderer struct
	oneRender = (GzRender*)malloc(sizeof(GzRender));

	if(oneRender == NULL || renderClass != GZ_Z_BUFFER_RENDER){
		return GZ_FAILURE;
	}else{
		//keep render close until all inits are done
		oneRender->renderClass = renderClass;
		oneRender->display = display;
		oneRender->matlevel = -1; //matrix index is initialized to -1
		oneRender->numlights = 0; //light index is inialized to 0

		oneRender->triangleBuffer = new vector<Triangle>();
		oneRender->numTriangle = 0;

		//setup Xsp;
		oneRender->Xsp[0][0] = display->xres/2.0;
		oneRender->Xsp[0][1] = 0.0;
		oneRender->Xsp[0][2] = 0.0;
		oneRender->Xsp[0][3] = display->xres/2.0;

		oneRender->Xsp[1][0] = 0.0;
		oneRender->Xsp[1][1] = -display->yres/2.0;
		oneRender->Xsp[1][2] = 0.0;
		oneRender->Xsp[1][3] = display->yres/2.0;

		oneRender->Xsp[2][0] = 0.0;
		oneRender->Xsp[2][1] = 0.0;
		oneRender->Xsp[2][2] = tan((PIII/180)*DEFAULT_FOV/2.0) * INT_MAX;
		oneRender->Xsp[2][3] = 0.0;

		oneRender->Xsp[3][0] = 0.0;
		oneRender->Xsp[3][1] = 0.0;
		oneRender->Xsp[3][2] = 0.0;
		oneRender->Xsp[3][3] = 1.0;

		//init default camera
		oneRender->camera.FOV = DEFAULT_FOV;
		oneRender->camera.lookat[0] = 0.0;
		oneRender->camera.lookat[1] = 0.0;
		oneRender->camera.lookat[2] = 0.0;
		oneRender->camera.position[0] = DEFAULT_IM_X;
		oneRender->camera.position[1] = DEFAULT_IM_Y;
		oneRender->camera.position[2] = DEFAULT_IM_Z;
		oneRender->camera.worldup[0] = 0.0;
		oneRender->camera.worldup[1] = 1.0;
		oneRender->camera.worldup[2] = 0.0;

		oneRender->open = 1;
	}

	*render = oneRender;

	return GZ_SUCCESS;

}


int GzFreeRender(GzRender *render)
{
/* 
-free all renderer resources
*/
	if(render == NULL){
		return GZ_FAILURE;
	}else{
		free(render);
	}

	return GZ_SUCCESS;
}


int GzBeginRender(GzRender *render)
{
/*  
- set up for start of each frame - clear frame buffer 
- compute Xiw and projection xform Xpi from camera definition 
- init Ximage - put Xsp at base of stack, push on Xpi and Xiw 
- now stack contains Xsw and app can push model Xforms if it want to. 
*/ 

	unsigned short x, y;
	GzDisplay* display;

	float xCoord[3];
	float yCoord[3];
	float zCoord[3];

	if(render == NULL){
		return GZ_FAILURE;
	}else{	
		display = render->display;
	}

	//clear frame buffer
	for(y = 0; y < display->yres; y++){
		for(x = 0; x < display->xres; x++){
			display->fbuf[ARRAY(x,y)].red = 0x0fff;
			display->fbuf[ARRAY(x,y)].green = 0x0fff;
			display->fbuf[ARRAY(x,y)].blue = 0x0fff;
			display->fbuf[ARRAY(x,y)].alpha = 1;
			display->fbuf[ARRAY(x,y)].z = 0;
		}
	}

	render->Xsp[0][0] = display->xres/2.0;
	render->Xsp[0][1] = 0.0;
	render->Xsp[0][2] = 0.0;
	render->Xsp[0][3] = display->xres/2.0;

	render->Xsp[1][0] = 0.0;
	render->Xsp[1][1] = -display->yres/2.0;
	render->Xsp[1][2] = 0.0;
	render->Xsp[1][3] = display->yres/2.0;

	render->Xsp[2][0] = 0.0;
	render->Xsp[2][1] = 0.0;
	render->Xsp[2][2] = tan((PIII/180)*render->camera.FOV/2.0) * INT_MAX;
	render->Xsp[2][3] = 0.0;

	render->Xsp[3][0] = 0.0;
	render->Xsp[3][1] = 0.0;
	render->Xsp[3][2] = 0.0;
	render->Xsp[3][3] = 1.0;

	//compute Xpi
	render->camera.Xpi[0][0] = 1.0;
	render->camera.Xpi[0][1] = 0.0;
	render->camera.Xpi[0][2] = 0.0;
	render->camera.Xpi[0][3] = 0.0;

	render->camera.Xpi[1][0] = 0.0;
	render->camera.Xpi[1][1] = 1.0;
	render->camera.Xpi[1][2] = 0.0;
	render->camera.Xpi[1][3] = 0.0;

	render->camera.Xpi[2][0] = 0.0;
	render->camera.Xpi[2][1] = 0.0;
	render->camera.Xpi[2][2] = 1.0;
	render->camera.Xpi[2][3] = 0.0;

	render->camera.Xpi[3][0] = 0.0;
	render->camera.Xpi[3][1] = 0.0;
	render->camera.Xpi[3][2] = tan((PIII/180)*render->camera.FOV/2.0);
	render->camera.Xpi[3][3] = 1.0;

	//compute Xiw
	vectorConstruct(render->camera.position, render->camera.lookat, zCoord);
	vectorNormalize(zCoord);
	float temp = vectorDotProduct(render->camera.worldup, zCoord);
	vectorScale(temp, zCoord);
	vectorConstruct(zCoord, render->camera.worldup, yCoord); //correct one
	vectorNormalize(yCoord);
	vectorScale(1/temp, zCoord);
	vectorCrossProduct(yCoord, zCoord, xCoord);

	render->camera.Xiw[0][0] = xCoord[0];
	render->camera.Xiw[0][1] = xCoord[1];
	render->camera.Xiw[0][2] = xCoord[2];
	render->camera.Xiw[0][3] = -1 * vectorDotProduct(xCoord, render->camera.position);

	render->camera.Xiw[1][0] = yCoord[0];
	render->camera.Xiw[1][1] = yCoord[1];
	render->camera.Xiw[1][2] = yCoord[2];
	render->camera.Xiw[1][3] = -1 * vectorDotProduct(yCoord, render->camera.position);

	render->camera.Xiw[2][0] = zCoord[0];
	render->camera.Xiw[2][1] = zCoord[1];
	render->camera.Xiw[2][2] = zCoord[2];
	render->camera.Xiw[2][3] = -1 *vectorDotProduct(zCoord, render->camera.position);

	render->camera.Xiw[3][0] = 0.0;
	render->camera.Xiw[3][1] = 0.0;
	render->camera.Xiw[3][2] = 0.0;
	render->camera.Xiw[3][3] = 1.0;

	//init stack
	GzPushMatrix(render, render->Xsp);
	GzPushMatrix(render, render->camera.Xpi);
	GzPushMatrix(render, render->camera.Xiw);

	return GZ_SUCCESS;
}

int GzPutCamera(GzRender *render, GzCamera *camera)
{
/*
- overwrite renderer camera structure with new camera definition
*/
	int i, j;

	if(render == NULL || camera == NULL){
		return GZ_FAILURE;
	}
/*
	for(i = 0; i < 4; i++){
		for(j = 0; j < 4; j++){
			render->camera.Xiw[i][j] = camera->Xiw[i][j];
			render->camera.Xpi[i][j] = camera->Xpi[i][j];
		}
	}
*/
	for(i = 0; i < 3; i++){
		render->camera.lookat[i] = camera->lookat[i];
		render->camera.position[i] = camera->position[i];
		render->camera.worldup[i] = camera->worldup[i];
	}

	render->camera.FOV = camera->FOV;
	return GZ_SUCCESS;	
}

int GzPushMatrix(GzRender *render, GzMatrix	matrix)
{
/*
- push a matrix onto the Ximage stack
- check for stack overflow
*/
	int i, j;
	GzMatrix dummy = {
		1.0, 0.0, 0.0, 0.0,
		0.0, 1.0, 0.0, 0.0,
		0.0, 0.0, 1.0, 0.0,
		0.0, 0.0, 0.0, 1.0
	};

	GzMatrix temp = {
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0
	};
	float k;

	if(render->matlevel+1 == MATLEVELS){
		return GZ_FAILURE;
	}

	(render->matlevel)++;

	if(render->matlevel == 0){
		for(i = 0; i < 4; i++){
			for(j = 0; j < 4; j++){
				render->Ximage[render->matlevel][i][j] = matrix[i][j];
				render->Xnorm[render->matlevel][i][j] = dummy[i][j];
				render->Xraytrace[render->matlevel][i][j] = dummy[i][j];
			}
		}
	}else{
		matrixMultiply(render->Ximage[(render->matlevel)-1], matrix, render->Ximage[render->matlevel]);
		if(render->matlevel == 1){
			matrixMultiply(render->Xnorm[(render->matlevel)-1], dummy, render->Xnorm[render->matlevel]);
			matrixMultiply(render->Xraytrace[(render->matlevel)-1], dummy, render->Xraytrace[render->matlevel]);
		}else{
			for(i = 0; i < 4; i++){
				for(j = 0; j < 4; j++){
					temp[i][j] = matrix[i][j];
				}
			}
			//remove the translation
			temp[0][3] = 0.0;
			temp[1][3] = 0.0;
			temp[2][3] = 0.0;

			//normalize the rotation
			k = 1/sqrt(temp[0][0]*temp[0][0] + temp[0][1]*temp[0][1] + temp[0][2]*temp[0][2] + temp[0][3]*temp[0][3]);
			for(i = 0; i < 3; i++){
				for(j = 0; j < 3; j++){
					temp[i][j] = temp[i][j] * k;
				}
			}

			//push matrix into Xnorm stack
			matrixMultiply(render->Xnorm[(render->matlevel)-1], temp, render->Xnorm[render->matlevel]);
			matrixMultiply(render->Xraytrace[(render->matlevel)-1], matrix, render->Xraytrace[render->matlevel]);
		}
	}

	return GZ_SUCCESS;
}

int GzPopMatrix(GzRender *render)
{
/*
- pop a matrix off the Ximage stack
- check for stack underflow
*/
	if(render->matlevel-1 == -1){
		return GZ_FAILURE;
	}

	render->matlevel--;

	return GZ_SUCCESS;
}

void copyDirectionalLightParam(GzRender *render, int index, GzLight *light){
	for(int i = 0; i < 3; i++){
		render->lights[index].direction[i] = light->direction[i];
		render->lights[index].color[i] = light->color[i];
	}
}

void copyAmbientLightParam(GzRender *render, GzLight *light){
	for(int i = 0; i < 3; i++){
		render->ambientlight.direction[i] = light->direction[i];
		render->ambientlight.color[i] = light->color[i];
	}
}

void copyCoefficient(GzRender *render, int type, float *coef){
	for(int i = 0; i < 3; i++){
		if(type == GZ_DIFFUSE_COEFFICIENT){
			render->Kd[i] = coef[i];
		}else if(type == GZ_AMBIENT_COEFFICIENT){
			render->Ka[i] = coef[i];
		}else if(type == GZ_SPECULAR_COEFFICIENT){
			render->Ks[i] = coef[i];
		}
	}
}

int GzPutAttribute(GzRender	*render, int numAttributes, GzToken	*nameList, 
	GzPointer	*valueList) /* void** valuelist */
{
/*
- set renderer attribute states (e.g.: GZ_RGB_COLOR default color)
- later set shaders, interpolaters, texture maps, and lights
*/
	if(render == NULL || nameList == NULL || valueList == NULL){
		return GZ_FAILURE;
	}

	for(int i = 0; i < numAttributes; i++){
		if(nameList[i] == GZ_RGB_COLOR){
			render->flatcolor[0] = *((float*)valueList[i]);
			render->flatcolor[1] = *((float*)valueList[i] + 1);
			render->flatcolor[2] = *((float*)valueList[i] + 2);
		}else if(nameList[i] == GZ_DIRECTIONAL_LIGHT){
			copyDirectionalLightParam(render, render->numlights, (GzLight*)valueList[i]);
			render->numlights++;
		}else if(nameList[i] == GZ_AMBIENT_LIGHT){
			copyAmbientLightParam(render, (GzLight*)valueList[i]);
		}else if(nameList[i] == GZ_DIFFUSE_COEFFICIENT){
			copyCoefficient(render, GZ_DIFFUSE_COEFFICIENT, (float*)valueList[i]);
		}else if(nameList[i] == GZ_AMBIENT_COEFFICIENT){
			copyCoefficient(render, GZ_AMBIENT_COEFFICIENT, (float*)valueList[i]);
		}else if(nameList[i] == GZ_SPECULAR_COEFFICIENT){
			copyCoefficient(render, GZ_SPECULAR_COEFFICIENT, (float*)valueList[i]);
		}else if(nameList[i] == GZ_DISTRIBUTION_COEFFICIENT){
			render->spec = *((float*)valueList[i]);
		}else if(nameList[i] == GZ_INTERPOLATE){
			if(*((int*)valueList[i]) == GZ_COLOR){
				render->interp_mode = GZ_COLOR;
			}else if(*((int*)valueList[i]) == GZ_NORMALS){
				render->interp_mode = GZ_NORMALS;
			}else if(*((int*)valueList[i]) == GZ_FLAT){
				render->interp_mode = GZ_FLAT;
			}
		}else if(nameList[i] == GZ_TEXTURE_MAP){
			render->tex_fun = (GzTexture)valueList[i];
		}
	}

	return GZ_SUCCESS;
}

void bubbleSort(float* vertexArray[], int size){

	bool swap = true;
	int j = 0;
	float* temp;
	
	while(swap){
		swap = false;
		j++;
		for(int i = 0; i < size-j; i++){
			if(vertexArray[i][1] > vertexArray[i+1][1]){
				temp = vertexArray[i];
				vertexArray[i] = vertexArray[i+1];
				vertexArray[i+1] = temp;
				swap = true;
			}
		}
	}

	//handle the case of top edge
	if(vertexArray[0][1] == vertexArray[1][1]){
		if(vertexArray[0][0] > vertexArray[1][0]){
			temp = vertexArray[0];
			vertexArray[0] = vertexArray[1];
			vertexArray[1] = temp;
		}
	}

	//handle the case of bottom edge
	if(vertexArray[1][1] == vertexArray[2][1]){
		if(vertexArray[1][0] > vertexArray[2][0]){
			temp = vertexArray[1];
			vertexArray[1] = vertexArray[2];
			vertexArray[2] = temp;
		}
	}
}

void bubbleSort(float* vertexArray[], int size, float* colorArray[], float* normalArray[], float* uvArray[]){

	bool swap = true;
	int j = 0;
	float* temp;
	
	while(swap){
		swap = false;
		j++;
		for(int i = 0; i < size-j; i++){
			if(vertexArray[i][1] > vertexArray[i+1][1]){
				//flip vertex array
				temp = vertexArray[i];
				vertexArray[i] = vertexArray[i+1];
				vertexArray[i+1] = temp;

				//flip color ptr array
				temp = colorArray[i];
				colorArray[i] = colorArray[i+1];
				colorArray[i+1] = temp;

				//flip normal array
				temp = normalArray[i];
				normalArray[i] = normalArray[i+1];
				normalArray[i+1] = temp;

				//flip UV array
				temp = uvArray[i];
				uvArray[i] = uvArray[i+1];
				uvArray[i+1] = temp;

				swap = true;
			}
		}
	}

	//handle the case of top edge
	if(vertexArray[0][1] == vertexArray[1][1]){
		if(vertexArray[0][0] > vertexArray[1][0]){
			temp = vertexArray[0];
			vertexArray[0] = vertexArray[1];
			vertexArray[1] = temp;
		}
	}

	//handle the case of bottom edge
	if(vertexArray[1][1] == vertexArray[2][1]){
		if(vertexArray[1][0] > vertexArray[2][0]){
			temp = vertexArray[1];
			vertexArray[1] = vertexArray[2];
			vertexArray[2] = temp;
		}
	}
}

int GzSaveTriangle(GzRender *render, int numParts, GzToken *nameList, GzPointer *valueList){

	int i, j;
	float* vertexArray[3];
	float* normalArray[3];
	float* uvArray[3];

	Triangle* aTriangle = new Triangle();

	for(i = 0; i < numParts; i++){
		if(nameList[i] == GZ_POSITION){
			for(j = 0; j < 3; j++){
				vertexArray[j] = (float*)valueList[i] + j*3;
				vectorTransform(vertexArray[j], 1.0, render->Xraytrace[render->matlevel]);
			}
			aTriangle->setVertexList((GzCoord*)valueList[i]);
		}else if(nameList[i] == GZ_NORMAL){
			for(j = 0; j < 3; j++){
				normalArray[j] = (float*)valueList[i] + j*3;
				vectorTransform(normalArray[j], 1.0, render->Xnorm[render->matlevel]);
			}
			aTriangle->setNormalList((GzCoord*)valueList[i]);
		}else if(nameList[i] == GZ_TEXTURE_INDEX){
			aTriangle->setUVList((GzTextureIndex*)valueList[i]);
		}
	}

	render->triangleBuffer->push_back(*aTriangle);
	render->numTriangle = render->numTriangle + 1;

	return GZ_SUCCESS;
}

__host__ __device__ float triangleArea(GzCoord vertexA, GzCoord vertexB, GzCoord vertexC){

	GzCoord vectorBA = {0.0, 0.0, 0.0};
	GzCoord vectorCA = {0.0, 0.0, 0.0};
	GzCoord product = {0.0, 0.0, 0.0};

	vectorConstruct(vertexA, vertexB, vectorBA);
	vectorConstruct(vertexA, vertexC, vectorCA);
	vectorCrossProduct(vectorBA, vectorCA, product);

	return vectorLength(product)/2.0;
}

__host__ __device__ float vertexDistance(GzCoord vertexA, GzCoord vertexB){

	GzCoord tmp = {0.0, 0.0, 0.0};
	vectorConstruct(vertexA, vertexB, tmp);
	return vectorLength(tmp);
}

__device__ void GzPutFrameBuffer(GzPixel* fbuf, int offset, 
								GzIntensity r, GzIntensity g, GzIntensity b, GzIntensity a, GzDepth z){

	if(fbuf[offset].z == 0 || z < fbuf[offset].z){

		//clamp the red color
		if(r > 4095){
			fbuf[offset].red = 4095;
		}else if(r < 0){
			fbuf[offset].red = 0;
		}else{
			fbuf[offset].red = r;
		}

		//clamp the green color
		if(g > 4095){
			fbuf[offset].green = 4095;
		}else if(g < 0){
			fbuf[offset].green = 0;
		}else{
			fbuf[offset].green = g;
		}

		//clamp the blue color
		if(b > 4095){
			fbuf[offset].blue = 4095;
		}else if(b < 0){
			fbuf[offset].blue = 0;
		}else{
			fbuf[offset].blue = b;
		}

		fbuf[offset].alpha = a;
		fbuf[offset].z = z;
	}
}


__device__ int findIntersectPoint(GzCoord origin, GzCoord direction, GzCoord normal, GzCoord* vertexList, GzCoord aPoint){

	GzCoord w0, temp;

	if(vectorZero(normal)) return -1; //triangle degenerate to a point

	vectorConstruct(vertexList[0], origin, w0);
	float a = -vectorDotProduct(normal, w0);
	float b = vectorDotProduct(normal, direction);

	if(fabs(b) < SMALL_NUM){ //ray is parallel to triangle
		if(a == 0){
			return 2; //ray lies in triangle plane
		}else{
			return 0; //ray disjoint from triangle plane
		}
	}

	float r = a/b;
	if(r < 0.0) return 0; //ray goes away from triangle

	vectorScale(r, direction, temp);
	vectorAdd(origin, temp, aPoint);

	return 1; //one intersect point 
}

__device__ bool checkPointInTriangle(GzCoord* vertexList, GzCoord aPoint){
	GzCoord vector0, vector1, vector2;

	//compute vectors
	vectorConstruct(vertexList[0], vertexList[2], vector0);
	vectorConstruct(vertexList[0], vertexList[1], vector1);
	vectorConstruct(vertexList[0], aPoint, vector2);

	//compute dot products
	float dot00 = vectorDotProduct(vector0, vector0);
	float dot01 = vectorDotProduct(vector0, vector1);
	float dot02 = vectorDotProduct(vector0, vector2);
	float dot11 = vectorDotProduct(vector1, vector1);
	float dot12 = vectorDotProduct(vector1, vector2);

	//compute barycentric coordinates
	float invDenom = 1.0/(dot00*dot11 - dot01*dot01);
	float u = (dot11*dot02 - dot01*dot12) * invDenom;
	float v = (dot00*dot12 - dot01*dot02) * invDenom;

	//check if point is in the triangle
	return (u >= 0) && (v >= 0) && (u + v < 1.0);
}

__global__ void kernel(TriangleCUDA* triBuffer, GzPixel* frameBuffer, GzRenderCUDA* render, float originZ){

	int x, y, i, j, k, it, offset;
	GzCoord origin = {0.0, 0.0, 0.0};
	GzCoord screenPoint = {0.0, 0.0, 0.0};
	GzCoord rayDirection = {0.0, 0.0, 0.0};
	GzCoord intersection = {0.0, 0.0, 0.0};
	GzCoord interNormal = {0.0, 0.0, 0.0};

	GzCoord eVector = {0.0, 0.0, -1.0};
	GzCoord rVector = {0.0, 0.0, 0.0};
	GzCoord tempVector1 = {0.0, 0.0, 0.0};
	GzCoord tempVector2 = {0.0, 0.0, 0.0};
	GzCoord tempVector3 = {0.0, 0.0, 0.0};
	GzCoord sumVector1 = {0.0, 0.0, 0.0};
	GzCoord sumVector2 = {0.0, 0.0, 0.0};
	GzCoord color = {0.0, 0.0, 0.0};
	float resultNL, resultNE, resultRE, result;

	//plane
	GzCoord normal = {0.0, 0.0, 0.0};
	GzCoord temp1 = {0.0, 0.0, 0.0};
	GzCoord temp2 = {0.0, 0.0, 0.0};
	float distance;
	
	origin[2] = originZ;
	x = blockIdx.x * blockDim.x + threadIdx.x;
	y = blockIdx.y * blockDim.y + threadIdx.y;
	offset = y * blockDim.x * gridDim.x + x;

	screenPoint[0] = (float)x/256.0 - 0.5;
	screenPoint[1] = (float)y/256.0 - 0.5; 
	vectorConstruct(origin, screenPoint, rayDirection);
	vectorNormalize(rayDirection);
			
	for(k = 0; k < render->numTriangle; k++){

		vectorConstruct(triBuffer[k].vertexList[0], triBuffer[k].vertexList[1], temp1);
		vectorConstruct(triBuffer[k].vertexList[0], triBuffer[k].vertexList[2], temp2);
		vectorCrossProduct(temp1, temp2, normal);
		vectorNormalize(normal);
		distance = vectorDotProduct(normal, triBuffer[k].vertexList[0]);
				
		if(findIntersectPoint(origin, rayDirection, normal, triBuffer[k].vertexList, intersection) == 1){
			if(checkPointInTriangle(triBuffer[k].vertexList, intersection)){

				//interpalate the normal at intersection point
				float areaTotal = triangleArea(triBuffer[k].vertexList[0], triBuffer[k].vertexList[1], triBuffer[k].vertexList[2]);
				float area01 = triangleArea(intersection, triBuffer[k].vertexList[0], triBuffer[k].vertexList[1]);
				float area02 = triangleArea(intersection, triBuffer[k].vertexList[0], triBuffer[k].vertexList[2]);
				float area12 = triangleArea(intersection, triBuffer[k].vertexList[1], triBuffer[k].vertexList[2]);

				interNormal[0] = (area12/areaTotal)*triBuffer[k].normalList[0][0] + 
					(area02/areaTotal)*triBuffer[k].normalList[1][0] + (area01/areaTotal)*triBuffer[k].normalList[2][0];
				interNormal[1] = (area12/areaTotal)*triBuffer[k].normalList[0][1] + 
					(area02/areaTotal)*triBuffer[k].normalList[1][1] + (area01/areaTotal)*triBuffer[k].normalList[2][1];
				interNormal[2] = (area12/areaTotal)*triBuffer[k].normalList[0][2] +
					(area02/areaTotal)*triBuffer[k].normalList[1][2] + (area01/areaTotal)*triBuffer[k].normalList[2][2];
						
						
				//calculate the shading at intersection point using Phone shading

				for(it = 0; it < render->numlights; it++){
					resultNL = vectorDotProduct(interNormal, render->lights[it].direction);
					resultNE = vectorDotProduct(interNormal, eVector);

					if(resultNL * resultNE > 0){
						if(resultNL < 0 && resultNE < 0){
							//flip normal
							interNormal[0] = -interNormal[0];
							interNormal[1] = -interNormal[1];
							interNormal[2] = -interNormal[2];
							resultNL = vectorDotProduct(interNormal, render->lights[it].direction);
							resultNE = vectorDotProduct(interNormal, eVector);
						}

						vectorScale(2*resultNL, interNormal);
						vectorConstruct(render->lights[it].direction, interNormal, rVector);
						vectorScale(1/(2*resultNL), interNormal);
						resultRE = vectorDotProduct(rVector, eVector) < 0 ? 0 : vectorDotProduct(rVector, eVector);
						result = pow(resultRE, render->spec);
						vectorScale(result, render->lights[it].color, sumVector1);
						vectorAdd(tempVector1, sumVector1);
				
						vectorScale(resultNL, render->lights[it].color, sumVector2);
						vectorAdd(tempVector2, sumVector2);
					}
				}

				vectorMultiply(tempVector1, render->Ks);
				vectorMultiply(tempVector2, render->Kd);
				vectorMultiply(render->ambientlight.color, render->Ka, tempVector3);

				vectorAdd(color, tempVector1);
				vectorAdd(color, tempVector2);
				vectorAdd(color, tempVector3);

				for(it = 0; it < 3; it++){
					if(color[it] > 1.0) color[it] = 1.0;
				}

				//update the color of pixel in frame buffer
				GzPutFrameBuffer(frameBuffer, offset, ctoi(color[0]), ctoi(color[1]), ctoi(color[2]),
					1, vertexDistance(origin, intersection));
			}
		}
	}

	return;	

}

int GzRayTraceCUDA(GzRender *render){

	TriangleCUDA* triBuffer_host;
	TriangleCUDA* triBuffer_device;

	GzPixel* frameBuffer_device;

	GzRenderCUDA* render_host;
	GzRenderCUDA* render_device;

	Triangle aTriangle;

	cudaEvent_t start, stop;

	HANDLE_ERROR(cudaEventCreate(&start));
	HANDLE_ERROR(cudaEventCreate(&stop));
	HANDLE_ERROR(cudaEventRecord(start, 0));

	float origin = -1.0/tan((PIII/180)*render->camera.FOV/2.0);

	triBuffer_host = (TriangleCUDA*)malloc(render->numTriangle*sizeof(TriangleCUDA));
	render_host = (GzRenderCUDA*)malloc(sizeof(GzRenderCUDA));

	HANDLE_ERROR(cudaMalloc((void**)&triBuffer_device, render->numTriangle*sizeof(TriangleCUDA)));
	HANDLE_ERROR(cudaMalloc((void**)&frameBuffer_device, (render->display->xres)*(render->display->yres)*sizeof(GzPixel)));
	HANDLE_ERROR(cudaMalloc((void**)&render_device, sizeof(GzRenderCUDA)));

	for(int i = 0; i < render->numTriangle; i++){
		aTriangle = render->triangleBuffer->at(i);
		for(int j = 0; j < 3; j++){
			for(int k = 0; k < 3; k++){
				triBuffer_host[i].vertexList[j][k] = aTriangle.vertexList[j][k];
				triBuffer_host[i].normalList[j][k] = aTriangle.normalList[j][k];
				if(k != 2){
					triBuffer_host[i].uvList[j][k] = aTriangle.uvList[j][k];
				}
			}
		}
	}

	render_host->numlights = render->numlights;
	render_host->spec = render->spec;
	render_host->numTriangle = render->numTriangle;
	for(int i = 0; i < render->numlights; i++){
		for(int j = 0; j < 3; j++){
			render_host->lights[i].direction[j] = render->lights[i].direction[j];
			render_host->lights[i].color[j] = render->lights[i].color[j];
		}
	}
	for(int i = 0; i < 3; i++){
		render_host->ambientlight.direction[i] = render->ambientlight.direction[i];
		render_host->ambientlight.color[i] = render->ambientlight.color[i];
		render_host->Ka[i] = render->Ka[i];
		render_host->Kd[i] = render->Kd[i];
		render_host->Ks[i] = render->Ks[i];
	}

	HANDLE_ERROR(cudaMemcpy(triBuffer_device, triBuffer_host, render->numTriangle*sizeof(TriangleCUDA), cudaMemcpyHostToDevice));
	HANDLE_ERROR(cudaMemcpy(render_device, render_host, sizeof(GzRenderCUDA), cudaMemcpyHostToDevice));
	HANDLE_ERROR(cudaMemcpy(frameBuffer_device, render->display->fbuf, (render->display->xres)*(render->display->yres)*sizeof(GzPixel),
		cudaMemcpyHostToDevice));

	dim3 grids(render->display->xres/DIM, render->display->yres/DIM);
	dim3 blocks(DIM, DIM);

	kernel<<<grids, blocks>>>(triBuffer_device, frameBuffer_device, render_device, origin);

	HANDLE_ERROR(cudaMemcpy(render->display->fbuf, frameBuffer_device, 
	(render->display->xres)*(render->display->yres)*sizeof(GzPixel), cudaMemcpyDeviceToHost));

	HANDLE_ERROR(cudaEventRecord(stop, 0));
	HANDLE_ERROR(cudaEventSynchronize(stop));
	float time;
	HANDLE_ERROR(cudaEventElapsedTime(&time, start, stop));
	printf("Time to render: %3.1f ms\n", time);
	
	HANDLE_ERROR(cudaFree(triBuffer_device));
	HANDLE_ERROR(cudaFree(frameBuffer_device));
	HANDLE_ERROR(cudaFree(render_device));
	
	free(triBuffer_host);
	free(render_host);

	return GZ_SUCCESS;
}

int GzRayTraceRender(GzRender *render){

	int i, j, k, it;
	GzCoord origin = {0.0, 0.0, -1.0/tan((PIII/180)*render->camera.FOV/2.0)};
	GzCoord screenPoint = {0.0, 0.0, 0.0};
	GzCoord rayDirection = {0.0, 0.0, 0.0};
	GzCoord intersection = {0.0, 0.0, 0.0};
	GzCoord interNormal = {0.0, 0.0, 0.0};

	GzCoord eVector = {0.0, 0.0, -1.0};
	GzCoord rVector = {0.0, 0.0, 0.0};
	GzCoord tempVector1 = {0.0, 0.0, 0.0};
	GzCoord tempVector2 = {0.0, 0.0, 0.0};
	GzCoord tempVector3 = {0.0, 0.0, 0.0};
	GzCoord sumVector1 = {0.0, 0.0, 0.0};
	GzCoord sumVector2 = {0.0, 0.0, 0.0};
	GzCoord color = {0.0, 0.0, 0.0};
	float resultNL, resultNE, resultRE, result;

	for(i = 0; i < render->display->yres; i++){
		for(j = 0; j < render->display->xres; j++){
			screenPoint[0] = (float)j/(float)(render->display->xres) - 0.5;
			screenPoint[1] = (float)i/(float)(render->display->yres) - 0.5; 
			vectorConstruct(origin, screenPoint, rayDirection);
			vectorNormalize(rayDirection);

			Ray* aRay = new Ray(origin, rayDirection);
			
			for(k = 0; k < render->triangleBuffer->size(); k++){
				Triangle aTriangle = render->triangleBuffer->at(k);
				Plane* aPlane = new Plane(aTriangle.vertexList);
				
				if(aPlane->findIntersectPoint(*aRay, intersection) == 1){
					if(aPlane->checkPointInTriangle(intersection)){

						//interpalate the normal at intersection point
						float areaTotal = triangleArea(aPlane->vertexList[0], aPlane->vertexList[1], aPlane->vertexList[2]);
						float area01 = triangleArea(intersection, aPlane->vertexList[0], aPlane->vertexList[1]);
						float area02 = triangleArea(intersection, aPlane->vertexList[0], aPlane->vertexList[2]);
						float area12 = triangleArea(intersection, aPlane->vertexList[1], aPlane->vertexList[2]);

						interNormal[0] = (area12/areaTotal)*aTriangle.normalList[0][0] + 
							(area02/areaTotal)*aTriangle.normalList[1][0] + (area01/areaTotal)*aTriangle.normalList[2][0];
						interNormal[1] = (area12/areaTotal)*aTriangle.normalList[0][1] + 
							(area02/areaTotal)*aTriangle.normalList[1][1] + (area01/areaTotal)*aTriangle.normalList[2][1];
						interNormal[2] = (area12/areaTotal)*aTriangle.normalList[0][2] +
							(area02/areaTotal)*aTriangle.normalList[1][2] + (area01/areaTotal)*aTriangle.normalList[2][2];
						
						
						//calculate the shading at intersection point using Phone shading
						for(it = 0; it < 3; it++){
							tempVector1[it] = 0.0;
							tempVector2[it] = 0.0;
							color[it] = 0.0;
						}

						for(it = 0; it < render->numlights; it++){
							resultNL = vectorDotProduct(interNormal, render->lights[it].direction);
							resultNE = vectorDotProduct(interNormal, eVector);

							if(resultNL * resultNE > 0){
								if(resultNL < 0 && resultNE < 0){
									//flip normal
									interNormal[0] = -interNormal[0];
									interNormal[1] = -interNormal[1];
									interNormal[2] = -interNormal[2];
									resultNL = vectorDotProduct(interNormal, render->lights[it].direction);
									resultNE = vectorDotProduct(interNormal, eVector);
								}

								vectorScale(2*resultNL, interNormal);
								vectorConstruct(render->lights[it].direction, interNormal, rVector);
								vectorScale(1/(2*resultNL), interNormal);
								resultRE = vectorDotProduct(rVector, eVector) < 0 ? 0 : vectorDotProduct(rVector, eVector);
								result = pow(resultRE, render->spec);
								vectorScale(result, render->lights[it].color, sumVector1);
								vectorAdd(tempVector1, sumVector1);
				
								vectorScale(resultNL, render->lights[it].color, sumVector2);
								vectorAdd(tempVector2, sumVector2);
							}
						}

						vectorMultiply(tempVector1, render->Ks);
						vectorMultiply(tempVector2, render->Kd);
						vectorMultiply(render->ambientlight.color, render->Ka, tempVector3);

						vectorAdd(color, tempVector1);
						vectorAdd(color, tempVector2);
						vectorAdd(color, tempVector3);

						for(it = 0; it < 3; it++){
							if(color[it] > 1.0) color[it] = 1.0;
						}

						//update the color of pixel in frame buffer
						GzPutDisplay(render->display, j, i, ctoi(color[0]), ctoi(color[1]), ctoi(color[2]),
							1, vertexDistance(aRay->origin, intersection));
					}
				}

				delete aPlane;
			}

			delete aRay;
		}
	}

	return GZ_SUCCESS;
}

int GzPutTriangle(GzRender	*render, int numParts, GzToken *nameList, 
				  GzPointer	*valueList)
/* numParts : how many names and values */
{
/*  
- pass in a triangle description with tokens and values corresponding to 
      GZ_POSITION:3 vert positions in model space 
- Xform positions of verts  
- Clip - just discard any triangle with verts behind view plane 
       - test for triangles with all three verts off-screen 
- invoke triangle rasterizer  
*/
	float* vertexArray[3];
	GzDDA ddaArray[3];
	GzDDA* leftEdge;
	GzDDA* rightEdge;
	GzDDA spanDDA;

	int i, j, k, x, y;
	float deltaY, deltaX, w;
	GzDisplay* display;
	float deltaY23;

	//shading variables
	float* normalArray[3];
	float colorArray[3][3] = {
		0.0, 0.0, 0.0,
		0.0, 0.0, 0.0,
		0.0, 0.0, 0.0
	};
	GzColor pixelColor = {0.0, 0.0, 0.0};

	GzCoord eVector = {0.0, 0.0, -1.0};
	GzCoord rVector = {0.0, 0.0, 0.0};
	GzCoord tempVector1 = {0.0, 0.0, 0.0};
	GzCoord tempVector2 = {0.0, 0.0, 0.0};
	GzCoord tempVector3 = {0.0, 0.0, 0.0};
	GzCoord sumVector1 = {0.0, 0.0, 0.0};
	GzCoord sumVector2 = {0.0, 0.0, 0.0};
	float resultNL, resultNE, resultRE, result;
	float* colorPtrArray[3];

	//texturing variables
	float* uvArray[3];
	GzColor kColor = {0.0, 0.0, 0.0};
	float uTemp, vTemp, vzPrime1, vzPrime2;

	for(i = 0; i < 3; i++) colorPtrArray[i] = &colorArray[i][0];
	if(render == NULL || nameList == NULL || valueList == NULL){
		return GZ_FAILURE;
	}
	display = render->display;

	if(render->interp_mode == GZ_FLAT){
		for(i = 0; i < numParts; i++){
			if(nameList[i] != GZ_NULL_TOKEN){
				if(nameList[i] == GZ_POSITION){

					//inialize the vertexArray
					for(j = 0; j < 3; j++){
						vertexArray[j] = (float*)valueList[i] + j*3;
					}

					for(j = 0; j < 3; j++){
						w = 1.0;
						w = vectorTransform(vertexArray[j], w, render->Ximage[render->matlevel]);
						if(vertexArray[j][2] < 0){
							return GZ_SUCCESS; //ignore the triangle which has vertex behind the camera
						}
						vertexArray[j][0] = vertexArray[j][0]/w;
						vertexArray[j][1] = vertexArray[j][1]/w;
						vertexArray[j][2] = vertexArray[j][2]/w;
					}

					//invoke the scan line rasterizer
					//sort the vertices based on Y coordinates
					bubbleSort(vertexArray, 3);
				
					//initialize the DDA0 for 1-2 edge
					for(j = 0; j < 3; j++){
						ddaArray[0].start[j] = vertexArray[0][j];
						ddaArray[0].end[j] = vertexArray[1][j];
						ddaArray[0].current[j] = vertexArray[0][j];
					}
					if(vertexArray[1][1] != vertexArray[0][1]){
						ddaArray[0].slopeX = (vertexArray[1][0]-vertexArray[0][0])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeZ = (vertexArray[1][2]-vertexArray[0][2])/(vertexArray[1][1]-vertexArray[0][1]);
					}

					//inialize the DDA1 for 1-3 edge
					for(j = 0; j < 3; j++){
						ddaArray[1].start[j] = vertexArray[0][j];
						ddaArray[1].end[j] = vertexArray[2][j];
						ddaArray[1].current[j] = vertexArray[0][j];
					}
					ddaArray[1].slopeX = (vertexArray[2][0]-vertexArray[0][0])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeZ = (vertexArray[2][2]-vertexArray[0][2])/(vertexArray[2][1]-vertexArray[0][1]);

					//inialize the DDA2 for 2-3 edge
					for(j = 0; j < 3; j++){
						ddaArray[2].start[j] = vertexArray[1][j];
						ddaArray[2].end[j] = vertexArray[2][j];
						ddaArray[2].current[j] = vertexArray[1][j];
					}
					if(vertexArray[2][1] != vertexArray[1][1]){
						ddaArray[2].slopeX = (vertexArray[2][0]-vertexArray[1][0])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeZ = (vertexArray[2][2]-vertexArray[1][2])/(vertexArray[2][1]-vertexArray[1][1]);
					}

					deltaY = ceil(vertexArray[0][1]) - vertexArray[0][1];
					deltaY23 = ceil(vertexArray[1][1]) - vertexArray[1][1];
					if(vertexArray[1][1] != vertexArray[0][1]){
						//assign left or right edges
						if(ddaArray[0].slopeX < ddaArray[1].slopeX){
							leftEdge = &(ddaArray[0]);
							rightEdge = &(ddaArray[1]);
						}else{
							leftEdge = &(ddaArray[1]);
							rightEdge = &(ddaArray[0]);
						}

						//advance 1-2 DDA0 current position to top ceilling position
						ddaArray[0].current[0] = ddaArray[0].current[0] + ddaArray[0].slopeX * deltaY;
						ddaArray[0].current[1] = ddaArray[0].current[1] + deltaY;
						ddaArray[0].current[2] = ddaArray[0].current[2] + ddaArray[0].slopeZ * deltaY;

						//advance 1-3 DDA1 current position to top ceilling position
						ddaArray[1].current[0] = ddaArray[1].current[0] + ddaArray[1].slopeX * deltaY;
						ddaArray[1].current[1] = ddaArray[1].current[1] + deltaY;
						ddaArray[1].current[2] = ddaArray[1].current[2] + ddaArray[1].slopeZ * deltaY;

						//advance 2-3 DDA2 current position to top ceilling position
						ddaArray[2].current[0] = ddaArray[2].current[0] + ddaArray[2].slopeX * deltaY23;
						ddaArray[2].current[1] = ddaArray[2].current[1] + deltaY23;
						ddaArray[2].current[2] = ddaArray[2].current[2] + ddaArray[2].slopeZ * deltaY23;
					}else{
						leftEdge = &(ddaArray[1]);
						rightEdge = &(ddaArray[2]);

						//advance 2-3 DDA2 current position to top ceiling position
						ddaArray[2].current[0] = ddaArray[2].current[0] + ddaArray[2].slopeX * deltaY;
						ddaArray[2].current[1] = ddaArray[2].current[1] + deltaY;
						ddaArray[2].current[2] = ddaArray[2].current[2] + ddaArray[2].slopeZ * deltaY;
					}		

					while(ddaArray[1].current[1] <= vertexArray[2][1] && ddaArray[1].current[1] < 257 ){

						//switch from 1-2 edge to 2-3 edge
						if(ddaArray[0].current[1] >= vertexArray[1][1] && vertexArray[1][1] != vertexArray[0][1]){
							if(ddaArray[0].slopeX < ddaArray[1].slopeX){
								leftEdge = &(ddaArray[2]);
							}else{
								rightEdge = &(ddaArray[2]);
							}
						}

						//inialize the span DDA
						for(j = 0; j < 3; j++){
							spanDDA.start[j] = leftEdge->current[j];
							spanDDA.end[j] = rightEdge->current[j];
							spanDDA.current[j] = leftEdge->current[j];
						}

						spanDDA.slopeX = 0.0f;
						spanDDA.slopeZ = (rightEdge->current[2]-leftEdge->current[2])/(rightEdge->current[0]-leftEdge->current[0]);

						//advance span DDA current position to left-most covered pixel
						deltaX = ceil(leftEdge->current[0]) - leftEdge->current[0];
						spanDDA.current[0] = spanDDA.current[0] + deltaX;
						spanDDA.current[2] = spanDDA.current[2] + spanDDA.slopeZ * deltaX;

						while(spanDDA.current[0] <= spanDDA.end[0]){
							//write color value into the frame buffer
							x = spanDDA.current[0];
							y = spanDDA.current[1];
							GzPutDisplay(render->display, x, y, ctoi(render->flatcolor[0]), ctoi(render->flatcolor[1]), ctoi(render->flatcolor[2]),
									1, spanDDA.current[2]);

							//update span DDA current position
							(spanDDA.current[0])++;
							spanDDA.current[2] = spanDDA.current[2] + spanDDA.slopeZ;
						}

						//update left and right edge current position
						leftEdge->current[0] = leftEdge->current[0] + leftEdge->slopeX;
						(leftEdge->current[1])++;
						leftEdge->current[2] = leftEdge->current[2] + leftEdge->slopeZ;

						rightEdge->current[0] = rightEdge->current[0] + rightEdge->slopeX;
						(rightEdge->current[1])++;
						rightEdge->current[2] = rightEdge->current[2] + rightEdge->slopeZ;
					}
				}
			}
		}
	}else{
		//shading code 

		for(i = 0; i < numParts; i++){
			if(nameList[i] == GZ_POSITION){
				//initialize the vertexArray
				for(j = 0; j < 3; j++){
					vertexArray[j] = (float*)valueList[i] + j*3;
				}

			}else if(nameList[i] == GZ_NORMAL){
				//initialize the normalArray
				for(j = 0; j < 3; j++){
					normalArray[j] = (float*)valueList[i] + j*3;
				}
			}else if(nameList[i] == GZ_TEXTURE_INDEX){
				//initialize the uvArray
				for(j = 0; j < 3; j++){
					uvArray[j] = (float*)valueList[i] + j*2;
				}
			}
		}

		//transform vertex with Ximage
		for(j = 0; j < 3; j++){
			w = 1.0;
			w = vectorTransform(vertexArray[j], w, render->Ximage[render->matlevel]);
/*			if(vertexArray[j][2] < 0){
				return GZ_SUCCESS; //ignore the triangle which has vertex behind the camera
			}
*/
			vertexArray[j][0] = vertexArray[j][0]/w;
			vertexArray[j][1] = vertexArray[j][1]/w;
			vertexArray[j][2] = vertexArray[j][2]/w;

			//warp process: transform uv of vertex to UV
			vzPrime1 = vertexArray[j][2]/((float)INT_MAX - vertexArray[j][2]);
			uvArray[j][0] = uvArray[j][0]/(vzPrime1 + 1.0);
			uvArray[j][1] = uvArray[j][1]/(vzPrime1 + 1.0);

		}

		//transform normal with Xn
		for(j = 0; j < 3; j++){
			w = 1.0;
			w = vectorTransform(normalArray[j], w, render->Xnorm[render->matlevel]);
		}

		if(render->interp_mode == GZ_COLOR){ //for Gauraud shading
			//compute color at each vertex
			for(i = 0; i < 3; i++){
				for(j = 0; j < 3; j++){
					tempVector1[j] = 0.0;
					tempVector2[j] = 0.0;
				}
				for(j = 0; j < render->numlights; j++){
					resultNL = vectorDotProduct(normalArray[i], render->lights[j].direction);
					resultNE = vectorDotProduct(normalArray[i], eVector);

					if(resultNL * resultNE > 0){
						if(resultNL < 0 && resultNE < 0){
							//flip normal
							normalArray[i][0] = -normalArray[i][0];
							normalArray[i][1] = -normalArray[i][1];
							normalArray[i][2] = -normalArray[i][2];
							resultNL = vectorDotProduct(normalArray[i], render->lights[j].direction);
							resultNE = vectorDotProduct(normalArray[i], eVector);
						}

						vectorScale(2*resultNL, normalArray[i]);
						vectorConstruct(render->lights[j].direction, normalArray[i], rVector);
						vectorScale(1/(2*resultNL), normalArray[i]);
						resultRE = vectorDotProduct(rVector, eVector) < 0 ? 0 : vectorDotProduct(rVector, eVector);
						result = pow(resultRE, render->spec);
						vectorScale(result, render->lights[j].color, sumVector1);
						vectorAdd(tempVector1, sumVector1);
				
						vectorScale(resultNL, render->lights[j].color, sumVector2);
						vectorAdd(tempVector2, sumVector2);
					}
				}

//				vectorMultiply(tempVector1, render->Ks);
//				vectorMultiply(tempVector2, render->Kd);
//				vectorMultiply(render->ambientlight.color, render->Ka, tempVector3);

				vectorAdd(colorArray[i], tempVector1);
				vectorAdd(colorArray[i], tempVector2);
				vectorAdd(colorArray[i], render->ambientlight.color);

				for(j = 0; j < 3; j++){
					if(colorArray[i][j] > 1.0) colorArray[i][j] = 1.0;
				}
			}

			
			//rasterize while interpolating RGB color
					//invoke the scan line rasterizer
					//sort the vertices based on Y coordinates
			bubbleSort(vertexArray, 3, colorPtrArray, normalArray, uvArray);
				
					//initialize the DDA0 for 1-2 edge
					for(j = 0; j < 3; j++){
						ddaArray[0].start[j] = vertexArray[0][j];
						ddaArray[0].end[j] = vertexArray[1][j];
						ddaArray[0].current[j] = vertexArray[0][j];

						ddaArray[0].startColor[j] = colorPtrArray[0][j];
						ddaArray[0].endColor[j] = colorPtrArray[1][j];
						ddaArray[0].currentColor[j] = colorPtrArray[0][j];

						if(j != 2){
							ddaArray[0].startUV[j] = uvArray[0][j];
							ddaArray[0].endUV[j] = uvArray[1][j];
							ddaArray[0].currentUV[j] = uvArray[0][j];
						}
					}
					if(vertexArray[1][1] != vertexArray[0][1]){
						ddaArray[0].slopeX = (vertexArray[1][0]-vertexArray[0][0])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeZ = (vertexArray[1][2]-vertexArray[0][2])/(vertexArray[1][1]-vertexArray[0][1]);

						ddaArray[0].slopeR = (colorPtrArray[1][0]-colorPtrArray[0][0])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeG = (colorPtrArray[1][1]-colorPtrArray[0][1])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeB = (colorPtrArray[1][2]-colorPtrArray[0][2])/(vertexArray[1][1]-vertexArray[0][1]);

						ddaArray[0].slopeU = (uvArray[1][0]-uvArray[0][0])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeV = (uvArray[1][1]-uvArray[0][1])/(vertexArray[1][1]-vertexArray[0][1]);
					}

					//inialize the DDA1 for 1-3 edge
					for(j = 0; j < 3; j++){
						ddaArray[1].start[j] = vertexArray[0][j];
						ddaArray[1].end[j] = vertexArray[2][j];
						ddaArray[1].current[j] = vertexArray[0][j];

						ddaArray[1].startColor[j] = colorPtrArray[0][j];
						ddaArray[1].endColor[j] = colorPtrArray[2][j];
						ddaArray[1].currentColor[j] = colorPtrArray[0][j];

						if(j != 2){
							ddaArray[1].startUV[j] = uvArray[0][j];
							ddaArray[1].endUV[j] = uvArray[2][j];
							ddaArray[1].currentUV[j] = uvArray[0][j];
						}
					}
					ddaArray[1].slopeX = (vertexArray[2][0]-vertexArray[0][0])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeZ = (vertexArray[2][2]-vertexArray[0][2])/(vertexArray[2][1]-vertexArray[0][1]);

					ddaArray[1].slopeR = (colorPtrArray[2][0]-colorPtrArray[0][0])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeG = (colorPtrArray[2][1]-colorPtrArray[0][1])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeB = (colorPtrArray[2][2]-colorPtrArray[0][2])/(vertexArray[2][1]-vertexArray[0][1]);

					ddaArray[1].slopeU = (uvArray[2][0]-uvArray[0][0])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeV = (uvArray[2][1]-uvArray[0][1])/(vertexArray[2][1]-vertexArray[0][1]);

					//inialize the DDA2 for 2-3 edge
					for(j = 0; j < 3; j++){
						ddaArray[2].start[j] = vertexArray[1][j];
						ddaArray[2].end[j] = vertexArray[2][j];
						ddaArray[2].current[j] = vertexArray[1][j];

						ddaArray[2].startColor[j] = colorPtrArray[1][j];
						ddaArray[2].endColor[j] = colorPtrArray[2][j];
						ddaArray[2].currentColor[j] = colorPtrArray[1][j];

						if(j != 2){
							ddaArray[2].startUV[j] = uvArray[1][j];
							ddaArray[2].endUV[j] = uvArray[2][j];
							ddaArray[2].currentUV[j] = uvArray[1][j];
						}
					}
					if(vertexArray[2][1] != vertexArray[1][1]){
						ddaArray[2].slopeX = (vertexArray[2][0]-vertexArray[1][0])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeZ = (vertexArray[2][2]-vertexArray[1][2])/(vertexArray[2][1]-vertexArray[1][1]);

						ddaArray[2].slopeR = (colorPtrArray[2][0]-colorPtrArray[1][0])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeG = (colorPtrArray[2][1]-colorPtrArray[1][1])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeB = (colorPtrArray[2][2]-colorPtrArray[1][2])/(vertexArray[2][1]-vertexArray[1][1]);

						ddaArray[2].slopeU = (uvArray[2][0]-uvArray[1][0])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeV = (uvArray[2][1]-uvArray[1][1])/(vertexArray[2][1]-vertexArray[1][1]);
					}

					deltaY = ceil(vertexArray[0][1]) - vertexArray[0][1];
					deltaY23 = ceil(vertexArray[1][1]) - vertexArray[1][1];
					if(vertexArray[1][1] != vertexArray[0][1]){
						//assign left or right edges
						if(ddaArray[0].slopeX < ddaArray[1].slopeX){
							leftEdge = &(ddaArray[0]);
							rightEdge = &(ddaArray[1]);
						}else{
							leftEdge = &(ddaArray[1]);
							rightEdge = &(ddaArray[0]);
						}

						//advance 1-2 DDA0 current position to top ceilling position
						ddaArray[0].current[0] = ddaArray[0].current[0] + ddaArray[0].slopeX * deltaY;
						ddaArray[0].current[1] = ddaArray[0].current[1] + deltaY;
						ddaArray[0].current[2] = ddaArray[0].current[2] + ddaArray[0].slopeZ * deltaY;

						ddaArray[0].currentColor[0] = ddaArray[0].currentColor[0] + ddaArray[0].slopeR * deltaY;
						ddaArray[0].currentColor[1] = ddaArray[0].currentColor[1] + ddaArray[0].slopeG * deltaY;
						ddaArray[0].currentColor[2] = ddaArray[0].currentColor[2] + ddaArray[0].slopeB * deltaY;

						ddaArray[0].currentUV[0] = ddaArray[0].currentUV[0] + ddaArray[0].slopeU * deltaY;
						ddaArray[0].currentUV[1] = ddaArray[0].currentUV[1] + ddaArray[0].slopeV * deltaY;

						//advance 1-3 DDA1 current position to top ceilling position
						ddaArray[1].current[0] = ddaArray[1].current[0] + ddaArray[1].slopeX * deltaY;
						ddaArray[1].current[1] = ddaArray[1].current[1] + deltaY;
						ddaArray[1].current[2] = ddaArray[1].current[2] + ddaArray[1].slopeZ * deltaY;

						ddaArray[1].currentColor[0] = ddaArray[1].currentColor[0] + ddaArray[1].slopeR * deltaY;
						ddaArray[1].currentColor[1] = ddaArray[1].currentColor[1] + ddaArray[1].slopeG * deltaY;
						ddaArray[1].currentColor[2] = ddaArray[1].currentColor[2] + ddaArray[1].slopeB * deltaY;

						ddaArray[1].currentUV[0] = ddaArray[1].currentUV[0] + ddaArray[1].slopeU * deltaY;
						ddaArray[1].currentUV[1] = ddaArray[1].currentUV[1] + ddaArray[1].slopeV * deltaY;

						//advance 2-3 DDA2 current position to top ceilling position
						ddaArray[2].current[0] = ddaArray[2].current[0] + ddaArray[2].slopeX * deltaY23;
						ddaArray[2].current[1] = ddaArray[2].current[1] + deltaY23;
						ddaArray[2].current[2] = ddaArray[2].current[2] + ddaArray[2].slopeZ * deltaY23;

						ddaArray[2].currentColor[0] = ddaArray[2].currentColor[0] + ddaArray[2].slopeR * deltaY23;
						ddaArray[2].currentColor[1] = ddaArray[2].currentColor[1] + ddaArray[2].slopeG * deltaY23;
						ddaArray[2].currentColor[2] = ddaArray[2].currentColor[2] + ddaArray[2].slopeB * deltaY23;

						ddaArray[2].currentUV[0] = ddaArray[2].currentUV[0] + ddaArray[2].slopeU * deltaY23;
						ddaArray[2].currentUV[1] = ddaArray[2].currentUV[1] + ddaArray[2].slopeV * deltaY23;
					}else{
						leftEdge = &(ddaArray[1]);
						rightEdge = &(ddaArray[2]);

						//advance 2-3 DDA2 current position to top ceiling position
						ddaArray[2].current[0] = ddaArray[2].current[0] + ddaArray[2].slopeX * deltaY;
						ddaArray[2].current[1] = ddaArray[2].current[1] + deltaY;
						ddaArray[2].current[2] = ddaArray[2].current[2] + ddaArray[2].slopeZ * deltaY;
					}		

					while(ddaArray[1].current[1] <= vertexArray[2][1] && ddaArray[1].current[1] < 257 ){

						//switch from 1-2 edge to 2-3 edge
						if(ddaArray[0].current[1] >= vertexArray[1][1] && vertexArray[1][1] != vertexArray[0][1]){
							if(ddaArray[0].slopeX < ddaArray[1].slopeX){
								leftEdge = &(ddaArray[2]);
							}else{
								rightEdge = &(ddaArray[2]);
							}
						}

						//inialize the span DDA
						for(j = 0; j < 3; j++){
							spanDDA.start[j] = leftEdge->current[j];
							spanDDA.end[j] = rightEdge->current[j];
							spanDDA.current[j] = leftEdge->current[j];

							spanDDA.startColor[j] = leftEdge->currentColor[j];
							spanDDA.endColor[j] = rightEdge->currentColor[j];
							spanDDA.currentColor[j] = leftEdge->currentColor[j];

							if(j != 2){
								spanDDA.startUV[j] = leftEdge->currentUV[j];
								spanDDA.endUV[j] = rightEdge->currentUV[j];
								spanDDA.currentUV[j] = leftEdge->currentUV[j];
							}
						}

						spanDDA.slopeX = 0.0f;
						spanDDA.slopeZ = (rightEdge->current[2]-leftEdge->current[2])/(rightEdge->current[0]-leftEdge->current[0]);

						spanDDA.slopeR = (rightEdge->currentColor[0]-leftEdge->currentColor[0])/(rightEdge->current[0]-leftEdge->current[0]);
						spanDDA.slopeG = (rightEdge->currentColor[1]-leftEdge->currentColor[1])/(rightEdge->current[0]-leftEdge->current[0]);
						spanDDA.slopeB = (rightEdge->currentColor[2]-leftEdge->currentColor[2])/(rightEdge->current[0]-leftEdge->current[0]);

						spanDDA.slopeU = (rightEdge->currentUV[0]-leftEdge->currentUV[0])/(rightEdge->current[0]-leftEdge->current[0]);
						spanDDA.slopeV = (rightEdge->currentUV[1]-leftEdge->currentUV[1])/(rightEdge->current[0]-leftEdge->current[0]);

						//advance span DDA current position to left-most covered pixel
						deltaX = ceil(leftEdge->current[0]) - leftEdge->current[0];
						spanDDA.current[0] = spanDDA.current[0] + deltaX;
						spanDDA.current[2] = spanDDA.current[2] + spanDDA.slopeZ * deltaX;

						spanDDA.currentColor[0] = spanDDA.currentColor[0] + spanDDA.slopeR * deltaX;
						spanDDA.currentColor[1] = spanDDA.currentColor[1] + spanDDA.slopeG * deltaX;
						spanDDA.currentColor[2] = spanDDA.currentColor[2] + spanDDA.slopeB * deltaX;

						spanDDA.currentUV[0] = spanDDA.currentUV[0] + spanDDA.slopeU * deltaX;
						spanDDA.currentUV[1] = spanDDA.currentUV[1] + spanDDA.slopeV * deltaX;

						while(spanDDA.current[0] <= spanDDA.end[0]){

							//Gauraud shading unwarp process
							float vzPrime2 = spanDDA.current[2]/((float)INT_MAX - spanDDA.current[2]);
							render->tex_fun(spanDDA.currentUV[0]*(vzPrime2 + 1.0), spanDDA.currentUV[1]*(vzPrime2 + 1.0), kColor);
							vectorMultiply(kColor, spanDDA.currentColor);

							//write color value into the frame buffer
							x = spanDDA.current[0];
							y = spanDDA.current[1];
							GzPutDisplay(render->display, x, y, ctoi(kColor[0]), ctoi(kColor[1]), ctoi(kColor[2]),
									1, spanDDA.current[2]);

							//update span DDA current position
							(spanDDA.current[0])++;
							spanDDA.current[2] = spanDDA.current[2] + spanDDA.slopeZ;

							spanDDA.currentColor[0] = spanDDA.currentColor[0] + spanDDA.slopeR;
							spanDDA.currentColor[1] = spanDDA.currentColor[1] + spanDDA.slopeG;
							spanDDA.currentColor[2] = spanDDA.currentColor[2] + spanDDA.slopeB;

							spanDDA.currentUV[0] = spanDDA.currentUV[0] + spanDDA.slopeU;
							spanDDA.currentUV[1] = spanDDA.currentUV[1] + spanDDA.slopeV;
						}

						//update left and right edge current position
						leftEdge->current[0] = leftEdge->current[0] + leftEdge->slopeX;
						(leftEdge->current[1])++;
						leftEdge->current[2] = leftEdge->current[2] + leftEdge->slopeZ;

						leftEdge->currentColor[0] = leftEdge->currentColor[0] + leftEdge->slopeR;
						leftEdge->currentColor[1] = leftEdge->currentColor[1] + leftEdge->slopeG;
						leftEdge->currentColor[2] = leftEdge->currentColor[2] + leftEdge->slopeB;

						leftEdge->currentUV[0] = leftEdge->currentUV[0] + leftEdge->slopeU;
						leftEdge->currentUV[1] = leftEdge->currentUV[1] + leftEdge->slopeV;

						rightEdge->current[0] = rightEdge->current[0] + rightEdge->slopeX;
						(rightEdge->current[1])++;
						rightEdge->current[2] = rightEdge->current[2] + rightEdge->slopeZ;

						rightEdge->currentColor[0] = rightEdge->currentColor[0] + rightEdge->slopeR;
						rightEdge->currentColor[1] = rightEdge->currentColor[1] + rightEdge->slopeG;
						rightEdge->currentColor[2] = rightEdge->currentColor[2] + rightEdge->slopeB;

						rightEdge->currentUV[0] = rightEdge->currentUV[0] + rightEdge->slopeU;
						rightEdge->currentUV[1] = rightEdge->currentUV[1] + rightEdge->slopeV;
					}

		}else if(render->interp_mode == GZ_NORMALS){ //for Phong shading
			//rasterize while interpolating normals
					bubbleSort(vertexArray, 3, colorPtrArray, normalArray, uvArray);
				
					//initialize the DDA0 for 1-2 edge
					for(j = 0; j < 3; j++){
						ddaArray[0].start[j] = vertexArray[0][j];
						ddaArray[0].end[j] = vertexArray[1][j];
						ddaArray[0].current[j] = vertexArray[0][j];

						ddaArray[0].startNormal[j] = normalArray[0][j];
						ddaArray[0].endNormal[j] = normalArray[1][j];
						ddaArray[0].currentNormal[j] = normalArray[0][j];

						if(j != 2){
							ddaArray[0].startUV[j] = uvArray[0][j];
							ddaArray[0].endUV[j] = uvArray[1][j];
							ddaArray[0].currentUV[j] = uvArray[0][j];
						}
					}
					if(vertexArray[1][1] != vertexArray[0][1]){
						ddaArray[0].slopeX = (vertexArray[1][0]-vertexArray[0][0])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeZ = (vertexArray[1][2]-vertexArray[0][2])/(vertexArray[1][1]-vertexArray[0][1]);

						ddaArray[0].slopeNX = (normalArray[1][0]-normalArray[0][0])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeNY = (normalArray[1][1]-normalArray[0][1])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeNZ = (normalArray[1][2]-normalArray[0][2])/(vertexArray[1][1]-vertexArray[0][1]);

						ddaArray[0].slopeU = (uvArray[1][0]-uvArray[0][0])/(vertexArray[1][1]-vertexArray[0][1]);
						ddaArray[0].slopeV = (uvArray[1][1]-uvArray[0][1])/(vertexArray[1][1]-vertexArray[0][1]);
					}

					//inialize the DDA1 for 1-3 edge
					for(j = 0; j < 3; j++){
						ddaArray[1].start[j] = vertexArray[0][j];
						ddaArray[1].end[j] = vertexArray[2][j];
						ddaArray[1].current[j] = vertexArray[0][j];

						ddaArray[1].startNormal[j] = normalArray[0][j];
						ddaArray[1].endNormal[j] = normalArray[2][j];
						ddaArray[1].currentNormal[j] = normalArray[0][j];

						if(j != 2){
							ddaArray[1].startUV[j] = uvArray[0][j];
							ddaArray[1].endUV[j] = uvArray[2][j];
							ddaArray[1].currentUV[j] = uvArray[0][j];
						}
					}
					ddaArray[1].slopeX = (vertexArray[2][0]-vertexArray[0][0])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeZ = (vertexArray[2][2]-vertexArray[0][2])/(vertexArray[2][1]-vertexArray[0][1]);

					ddaArray[1].slopeNX = (normalArray[2][0]-normalArray[0][0])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeNY = (normalArray[2][1]-normalArray[0][1])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeNZ = (normalArray[2][2]-normalArray[0][2])/(vertexArray[2][1]-vertexArray[0][1]);

					ddaArray[1].slopeU = (uvArray[2][0]-uvArray[0][0])/(vertexArray[2][1]-vertexArray[0][1]);
					ddaArray[1].slopeV = (uvArray[2][1]-uvArray[0][1])/(vertexArray[2][1]-vertexArray[0][1]);

					//inialize the DDA2 for 2-3 edge
					for(j = 0; j < 3; j++){
						ddaArray[2].start[j] = vertexArray[1][j];
						ddaArray[2].end[j] = vertexArray[2][j];
						ddaArray[2].current[j] = vertexArray[1][j];

						ddaArray[2].startNormal[j] = normalArray[1][j];
						ddaArray[2].endNormal[j] = normalArray[2][j];
						ddaArray[2].currentNormal[j] = normalArray[1][j];

						if(j != 2){
							ddaArray[2].startUV[j] = uvArray[1][j];
							ddaArray[2].endUV[j] = uvArray[2][j];
							ddaArray[2].currentUV[j] = uvArray[1][j];
						}
					}
					if(vertexArray[2][1] != vertexArray[1][1]){
						ddaArray[2].slopeX = (vertexArray[2][0]-vertexArray[1][0])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeZ = (vertexArray[2][2]-vertexArray[1][2])/(vertexArray[2][1]-vertexArray[1][1]);

						ddaArray[2].slopeNX = (normalArray[2][0]-normalArray[1][0])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeNY = (normalArray[2][1]-normalArray[1][1])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeNZ = (normalArray[2][2]-normalArray[1][2])/(vertexArray[2][1]-vertexArray[1][1]);

						ddaArray[2].slopeU = (uvArray[2][0]-uvArray[1][0])/(vertexArray[2][1]-vertexArray[1][1]);
						ddaArray[2].slopeV = (uvArray[2][1]-uvArray[1][1])/(vertexArray[2][1]-vertexArray[1][1]);
					}

					deltaY = ceil(vertexArray[0][1]) - vertexArray[0][1];
					deltaY23 = ceil(vertexArray[1][1]) - vertexArray[1][1];
					if(vertexArray[1][1] != vertexArray[0][1]){
						//assign left or right edges
						if(ddaArray[0].slopeX < ddaArray[1].slopeX){
							leftEdge = &(ddaArray[0]);
							rightEdge = &(ddaArray[1]);
						}else{
							leftEdge = &(ddaArray[1]);
							rightEdge = &(ddaArray[0]);
						}

						//advance 1-2 DDA0 current position to top ceilling position
						ddaArray[0].current[0] = ddaArray[0].current[0] + ddaArray[0].slopeX * deltaY;
						ddaArray[0].current[1] = ddaArray[0].current[1] + deltaY;
						ddaArray[0].current[2] = ddaArray[0].current[2] + ddaArray[0].slopeZ * deltaY;

						ddaArray[0].currentNormal[0] = ddaArray[0].currentNormal[0] + ddaArray[0].slopeNX * deltaY;
						ddaArray[0].currentNormal[1] = ddaArray[0].currentNormal[1] + ddaArray[0].slopeNY * deltaY;
						ddaArray[0].currentNormal[2] = ddaArray[0].currentNormal[2] + ddaArray[0].slopeNZ * deltaY;

						ddaArray[0].currentUV[0] = ddaArray[0].currentUV[0] + ddaArray[0].slopeU * deltaY;
						ddaArray[0].currentUV[1] = ddaArray[0].currentUV[1] + ddaArray[0].slopeV * deltaY;

						//advance 1-3 DDA1 current position to top ceilling position
						ddaArray[1].current[0] = ddaArray[1].current[0] + ddaArray[1].slopeX * deltaY;
						ddaArray[1].current[1] = ddaArray[1].current[1] + deltaY;
						ddaArray[1].current[2] = ddaArray[1].current[2] + ddaArray[1].slopeZ * deltaY;

						ddaArray[1].currentNormal[0] = ddaArray[1].currentNormal[0] + ddaArray[1].slopeNX * deltaY;
						ddaArray[1].currentNormal[1] = ddaArray[1].currentNormal[1] + ddaArray[1].slopeNY * deltaY;
						ddaArray[1].currentNormal[2] = ddaArray[1].currentNormal[2] + ddaArray[1].slopeNZ * deltaY;

						ddaArray[1].currentUV[0] = ddaArray[1].currentUV[0] + ddaArray[1].slopeU * deltaY;
						ddaArray[1].currentUV[1] = ddaArray[1].currentUV[1] + ddaArray[1].slopeV * deltaY;

						//advance 2-3 DDA2 current position to top ceilling position
						ddaArray[2].current[0] = ddaArray[2].current[0] + ddaArray[2].slopeX * deltaY23;
						ddaArray[2].current[1] = ddaArray[2].current[1] + deltaY23;
						ddaArray[2].current[2] = ddaArray[2].current[2] + ddaArray[2].slopeZ * deltaY23;

						ddaArray[2].currentNormal[0] = ddaArray[2].currentNormal[0] + ddaArray[2].slopeNX * deltaY23;
						ddaArray[2].currentNormal[1] = ddaArray[2].currentNormal[1] + ddaArray[2].slopeNY * deltaY23;
						ddaArray[2].currentNormal[2] = ddaArray[2].currentNormal[2] + ddaArray[2].slopeNZ * deltaY23;

						ddaArray[2].currentUV[0] = ddaArray[2].currentUV[0] + ddaArray[2].slopeU * deltaY23;
						ddaArray[2].currentUV[1] = ddaArray[2].currentUV[1] + ddaArray[2].slopeV * deltaY23;
					}else{
						leftEdge = &(ddaArray[1]);
						rightEdge = &(ddaArray[2]);

						//advance 2-3 DDA2 current position to top ceiling position
						ddaArray[2].current[0] = ddaArray[2].current[0] + ddaArray[2].slopeX * deltaY;
						ddaArray[2].current[1] = ddaArray[2].current[1] + deltaY;
						ddaArray[2].current[2] = ddaArray[2].current[2] + ddaArray[2].slopeZ * deltaY;
					}		

					while(ddaArray[1].current[1] <= vertexArray[2][1] && ddaArray[1].current[1] < 257 ){

						//switch from 1-2 edge to 2-3 edge
						if(ddaArray[0].current[1] >= vertexArray[1][1] && vertexArray[1][1] != vertexArray[0][1]){
							if(ddaArray[0].slopeX < ddaArray[1].slopeX){
								leftEdge = &(ddaArray[2]);
							}else{
								rightEdge = &(ddaArray[2]);
							}
						}

						//inialize the span DDA
						for(j = 0; j < 3; j++){
							spanDDA.start[j] = leftEdge->current[j];
							spanDDA.end[j] = rightEdge->current[j];
							spanDDA.current[j] = leftEdge->current[j];

							spanDDA.startNormal[j] = leftEdge->currentNormal[j];
							spanDDA.endNormal[j] = rightEdge->currentNormal[j];
							spanDDA.currentNormal[j] = leftEdge->currentNormal[j];

							if(j != 2){
								spanDDA.startUV[j] = leftEdge->currentUV[j];
								spanDDA.endUV[j] = rightEdge->currentUV[j];
								spanDDA.currentUV[j] = leftEdge->currentUV[j];
							}
						}

						spanDDA.slopeX = 0.0f;
						spanDDA.slopeZ = (rightEdge->current[2]-leftEdge->current[2])/(rightEdge->current[0]-leftEdge->current[0]);

						spanDDA.slopeNX = (rightEdge->currentNormal[0]-leftEdge->currentNormal[0])/(rightEdge->current[0]-leftEdge->current[0]);
						spanDDA.slopeNY = (rightEdge->currentNormal[1]-leftEdge->currentNormal[1])/(rightEdge->current[0]-leftEdge->current[0]);
						spanDDA.slopeNZ = (rightEdge->currentNormal[2]-leftEdge->currentNormal[2])/(rightEdge->current[0]-leftEdge->current[0]);

						spanDDA.slopeU = (rightEdge->currentUV[0]-leftEdge->currentUV[0])/(rightEdge->current[0]-leftEdge->current[0]);
						spanDDA.slopeV = (rightEdge->currentUV[1]-leftEdge->currentUV[1])/(rightEdge->current[0]-leftEdge->current[0]);

						//advance span DDA current position to left-most covered pixel
						deltaX = ceil(leftEdge->current[0]) - leftEdge->current[0];
						spanDDA.current[0] = spanDDA.current[0] + deltaX;
						spanDDA.current[2] = spanDDA.current[2] + spanDDA.slopeZ * deltaX;
						
						spanDDA.currentNormal[0] = spanDDA.currentNormal[0] + spanDDA.slopeNX * deltaX;
						spanDDA.currentNormal[1] = spanDDA.currentNormal[1] + spanDDA.slopeNY * deltaX;
						spanDDA.currentNormal[2] = spanDDA.currentNormal[2] + spanDDA.slopeNZ * deltaX;

						spanDDA.currentUV[0] = spanDDA.currentUV[0] + spanDDA.slopeU * deltaX;
						spanDDA.currentUV[1] = spanDDA.currentUV[1] + spanDDA.slopeV * deltaX;

						while(spanDDA.current[0] <= spanDDA.end[0]){

							//Phong shading unwarp process: transform UV back to uv
							vzPrime2 = spanDDA.current[2]/((float)INT_MAX - spanDDA.current[2]);
							uTemp = spanDDA.currentUV[0]*(vzPrime2+1.0);
							vTemp = spanDDA.currentUV[1]*(vzPrime2+1.0);
							render->tex_fun(uTemp, vTemp, kColor);
							for(j = 0; j < 3; j++){
								render->Kd[j] = kColor[j];
								render->Ka[j] = kColor[j];
							}

							//write color value into the frame buffer
							x = spanDDA.current[0];
							y = spanDDA.current[1];

							//compute color at each pixel
							for(j = 0; j < 3; j++){
								tempVector1[j] = 0.0;
								tempVector2[j] = 0.0;
								pixelColor[j] = 0.0;
							}
							vectorNormalize(spanDDA.currentNormal);

							for(j = 0; j < render->numlights; j++){
								resultNL = vectorDotProduct(spanDDA.currentNormal, render->lights[j].direction);
								resultNE = vectorDotProduct(spanDDA.currentNormal, eVector);

								if(resultNL * resultNE > 0){
									if(resultNL < 0 && resultNE < 0){
										spanDDA.currentNormal[0] = -1 * spanDDA.currentNormal[0];
										spanDDA.currentNormal[1] = -1 * spanDDA.currentNormal[1];
										spanDDA.currentNormal[2] = -1 * spanDDA.currentNormal[2];
										resultNL = vectorDotProduct(spanDDA.currentNormal, render->lights[j].direction);
										resultNE = vectorDotProduct(spanDDA.currentNormal, eVector);
									}

									vectorScale(2*resultNL, spanDDA.currentNormal);
									vectorConstruct(render->lights[j].direction, spanDDA.currentNormal, rVector);
									vectorScale(1/(2*resultNL), spanDDA.currentNormal);
									resultRE = vectorDotProduct(rVector, eVector) < 0 ? 0 : vectorDotProduct(rVector, eVector);
									result = pow(resultRE, render->spec);
									vectorScale(result, render->lights[j].color, sumVector1);
									vectorAdd(tempVector1, sumVector1);

									vectorScale(resultNL, render->lights[j].color, sumVector2);
									vectorAdd(tempVector2, sumVector2);
								}
							}

							vectorMultiply(tempVector1, render->Ks);
							vectorMultiply(tempVector2, render->Kd);
							vectorMultiply(render->ambientlight.color, render->Ka, tempVector3);

							vectorAdd(pixelColor, tempVector1);
							vectorAdd(pixelColor, tempVector2);
							vectorAdd(pixelColor, tempVector3);

							GzPutDisplay(render->display, x, y, ctoi(pixelColor[0]), ctoi(pixelColor[1]), ctoi(pixelColor[2]),
									1, spanDDA.current[2]);

							//update span DDA current position
							(spanDDA.current[0])++;
							spanDDA.current[2] = spanDDA.current[2] + spanDDA.slopeZ;

							spanDDA.currentNormal[0] = spanDDA.currentNormal[0] + spanDDA.slopeNX;
							spanDDA.currentNormal[1] = spanDDA.currentNormal[1] + spanDDA.slopeNY;
							spanDDA.currentNormal[2] = spanDDA.currentNormal[2] + spanDDA.slopeNZ;

							spanDDA.currentUV[0] = spanDDA.currentUV[0] + spanDDA.slopeU;
							spanDDA.currentUV[1] = spanDDA.currentUV[1] + spanDDA.slopeV;
						}

						//update left and right edge current position
						leftEdge->current[0] = leftEdge->current[0] + leftEdge->slopeX;
						(leftEdge->current[1])++;
						leftEdge->current[2] = leftEdge->current[2] + leftEdge->slopeZ;

						leftEdge->currentNormal[0] = leftEdge->currentNormal[0] + leftEdge->slopeNX;
						leftEdge->currentNormal[1] = leftEdge->currentNormal[1] + leftEdge->slopeNY;
						leftEdge->currentNormal[2] = leftEdge->currentNormal[2] + leftEdge->slopeNZ;

						leftEdge->currentUV[0] = leftEdge->currentUV[0] + leftEdge->slopeU;
						leftEdge->currentUV[1] = leftEdge->currentUV[1] + leftEdge->slopeV;

						rightEdge->current[0] = rightEdge->current[0] + rightEdge->slopeX;
						(rightEdge->current[1])++;
						rightEdge->current[2] = rightEdge->current[2] + rightEdge->slopeZ;

						rightEdge->currentNormal[0] = rightEdge->currentNormal[0] + rightEdge->slopeNX;
						rightEdge->currentNormal[1] = rightEdge->currentNormal[1] + rightEdge->slopeNY;
						rightEdge->currentNormal[2] = rightEdge->currentNormal[2] + rightEdge->slopeNZ;

						rightEdge->currentUV[0] = rightEdge->currentUV[0] + rightEdge->slopeU;
						rightEdge->currentUV[1] = rightEdge->currentUV[1] + rightEdge->slopeV;
					}


		}
	}

	return GZ_SUCCESS;
}

/* NOT part of API - just for general assistance */

__host__ __device__ short	ctoi(float color)		/* convert float color to GzIntensity short */
{
//	if (color > 1.0) color = 1.0;
	return(short)((int)(color * ((1 << 12) - 1)));
}


 __host__ __device__ bool vectorZero(GzCoord vector){

	if(vector[0] == 0 && vector[1] == 0 && vector[2] == 0){
		return true;
	}else{
		return false;
	}
}

 __host__ __device__ void vectorAdd(GzCoord vector1, GzCoord vector2){
	vector1[0] = vector1[0] + vector2[0];
	vector1[1] = vector1[1] + vector2[1];
	vector1[2] = vector1[2] + vector2[2];
}

 __host__ __device__ void vectorAdd(GzCoord vector1, GzCoord vector2, GzCoord vector3){
	vector3[0] = vector1[0] + vector2[0];
	vector3[1] = vector1[1] + vector2[1];
	vector3[2] = vector1[2] + vector2[2];
}

 __host__ __device__ void vectorMultiply(GzCoord vector1, GzCoord vector2){
	vector1[0] = vector1[0] * vector2[0];
	vector1[1] = vector1[1] * vector2[1];
	vector1[2] = vector1[2] * vector2[2];
}

 __host__ __device__ void vectorMultiply(GzCoord vector1, GzCoord vector2, GzCoord vector3){
	vector3[0] = vector1[0] * vector2[0];
	vector3[1] = vector1[1] * vector2[1];
	vector3[2] = vector1[2] * vector2[2];
}

 __host__ __device__ void vectorConstruct(GzCoord vector1, GzCoord vector2, GzCoord vector){
	vector[0] = vector2[0] - vector1[0];
	vector[1] = vector2[1] - vector1[1];
	vector[2] = vector2[2] - vector1[2];
}

 __host__ __device__ void vectorNormalize(GzCoord vector){
	float length = sqrt(vector[0]*vector[0] + vector[1]*vector[1] + vector[2]*vector[2]);
	vector[0] = vector[0]/length;
	vector[1] = vector[1]/length;
	vector[2] = vector[2]/length;
}

 __host__ __device__ float vectorDotProduct(GzCoord vector1, GzCoord vector2){
	return vector1[0]*vector2[0] + vector1[1]*vector2[1] + vector1[2]*vector2[2];
}

 __host__ __device__ void vectorCrossProduct(GzCoord vector1, GzCoord vector2, GzCoord product){
	product[0] = vector1[1]*vector2[2] - vector1[2]*vector2[1];
	product[1] = vector1[2]*vector2[0] - vector1[0]*vector2[2];
	product[2] = vector1[0]*vector2[1] - vector1[1]*vector2[0];
}

 __host__ __device__ void vectorScale(float scale, GzCoord vector){
	vector[0] = vector[0] * scale;
	vector[1] = vector[1] * scale;
	vector[2] = vector[2] * scale;
}

 __host__ __device__ void vectorScale(float scale, GzCoord vector1, GzCoord vector2){
	vector2[0] = vector1[0] * scale;
	vector2[1] = vector1[1] * scale;
	vector2[2] = vector1[2] * scale;
}

 __host__ __device__ float vectorTransform(GzCoord vector, float w, GzMatrix matrix){
	float vector0 = matrix[0][0]*vector[0] + matrix[0][1]*vector[1] + matrix[0][2]*vector[2] + matrix[0][3]*w;
	float vector1 = matrix[1][0]*vector[0] + matrix[1][1]*vector[1] + matrix[1][2]*vector[2] + matrix[1][3]*w;
	float vector2 = matrix[2][0]*vector[0] + matrix[2][1]*vector[1] + matrix[2][2]*vector[2] + matrix[2][3]*w;
	float temp = matrix[3][0]*vector[0] + matrix[3][1]*vector[1] + matrix[3][2]*vector[2] + matrix[3][3]*w;
	vector[0] = vector0;
	vector[1] = vector1;
	vector[2] = vector2;
	return temp;
}

 __host__ __device__ void matrixMultiply(GzMatrix matrixA, GzMatrix matrixB, GzMatrix matrixC){
	int i, j, k;
	float temp;

	for(i = 0; i < 4; i++){
		for(j = 0; j < 4; j++){
			temp = 0.0;
			for(k = 0; k < 4; k++){
				temp+=matrixA[i][k]*matrixB[k][j];
			}
			matrixC[i][j] = temp;
		}
	}
}

 __host__ __device__ float vectorLength(GzCoord vector){

	 return sqrtf(vector[0]*vector[0] + vector[1]*vector[1] + vector[2]*vector[2]); 
}
