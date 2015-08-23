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

typedef struct {
	GzCoord vertexList[3];
	GzCoord normalList[3];
	GzTextureIndex uvList[3];
} TriangleCUDA;

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

extern bool vectorZero(GzCoord vector);
extern void vectorConstruct(GzCoord vector1, GzCoord vector2, GzCoord vector); //vector = vector2 - vector1
extern void vectorNormalize(GzCoord vector);
extern float vectorDotProduct(GzCoord vector1, GzCoord vector2); //return vector1 * vector2
extern void vectorCrossProduct(GzCoord vector1, GzCoord vector2, GzCoord product); //product = vector1 x vector2
extern void vectorScale(float scale, GzCoord vector);
extern void vectorScale(float scale, GzCoord vector1, GzCoord vector2);

extern float vectorTransform(GzCoord vector, float w, GzMatrix matrix);
extern void matrixMultiply(GzMatrix matrixA, GzMatrix matrixB, GzMatrix matrixC);

extern void vectorAdd(GzCoord vector1, GzCoord vector2);
extern void vectorAdd(GzCoord vector1, GzCoord vector2, GzCoord vector3);
extern void vectorMultiply(GzCoord vector1, GzCoord vector2);
extern void vectorMultiply(GzCoord vector1, GzCoord vector2, GzCoord vector3);
extern float vectorLength(GzCoord vector);

#endif