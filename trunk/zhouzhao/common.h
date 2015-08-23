#ifndef COMMON_H
#define COMMON_H

#include "Gz.h"
#include "math.h"

#define SMALL_NUM 0.00000001

class Ray
{
public:
	GzCoord origin;
	GzCoord direction;
	Ray(){};
	Ray(GzCoord aOrigin, GzCoord aDirection);
};

class Triangle
{
public:
	GzCoord vertexList[3]; 
	GzCoord normalList[3];
	GzTextureIndex uvList[3];

	Triangle(){};
	Triangle(GzCoord aVertexList[], GzCoord aNormalList[], GzTextureIndex aUVList[]);

	void setVertexList(GzCoord aVertexList[]);
	void setNormalList(GzCoord aNormalList[]);
	void setUVList(GzTextureIndex aUVList[]);
};

class Plane
{
public:
	GzCoord normal;
	float distance; //distance from origin to the plane
	GzCoord vertexList[3];

	Plane(){};
	Plane(GzCoord aNormal, float aDistance);
	Plane(GzCoord aVertexList[]);

	int findIntersectPoint(Ray& aRay, GzCoord aPoint);
	bool checkPointInTriangle(GzCoord aPoint);
};

bool vectorZero(GzCoord vector);

void vectorConstruct(GzCoord vector1, GzCoord vector2, GzCoord vector); //vector = vector2 - vector1
void vectorNormalize(GzCoord vector);
float vectorDotProduct(GzCoord vector1, GzCoord vector2); //return vector1 * vector2
void vectorCrossProduct(GzCoord vector1, GzCoord vector2, GzCoord product); //product = vector1 x vector2
void vectorScale(float scale, GzCoord vector);
void vectorScale(float scale, GzCoord vector1, GzCoord vector2);

float vectorTransform(GzCoord vector, float w, GzMatrix matrix);
void matrixMultiply(GzMatrix matrixA, GzMatrix matrixB, GzMatrix matrixC);

void vectorAdd(GzCoord vector1, GzCoord vector2);
void vectorAdd(GzCoord vector1, GzCoord vector2, GzCoord vector3);
void vectorMultiply(GzCoord vector1, GzCoord vector2);
void vectorMultiply(GzCoord vector1, GzCoord vector2, GzCoord vector3);

float vectorLength(GzCoord vector);
//added by yiqian
float vectorDistance(GzCoord vector1, GzCoord vector2);//distance between 2 vectors
//float vectorLength(GzCoord vector);
void interpolation(GzCoord* Pos, GzCoord* Nor, GzCoord intersect,GzCoord result);


#endif