#include "common.h"

Ray::Ray(GzCoord aOrigin, GzCoord aDirection){
	for(int i = 0; i < 3; i++){
		origin[i] = aOrigin[i];
		direction[i] = aDirection[i];
	}
}

Triangle::Triangle(GzCoord aVertexList[], GzCoord aNormalList[], GzTextureIndex aUVList[]){
	for(int i = 0; i < 3; i++){
		for(int j = 0; j < 3; j++){
			vertexList[i][j] = aVertexList[i][j];
			normalList[i][j] = aNormalList[i][j];
			if(j != 2){
				uvList[i][j] = aUVList[i][j];
			}
		}
	}
}

void Triangle::setVertexList(GzCoord aVertexList[]){
	for(int i = 0; i < 3; i++){
		for(int j = 0; j < 3; j++){
			vertexList[i][j] = aVertexList[i][j];
		}
	}
}

void Triangle::setNormalList(GzCoord aNormalList[]){
	for(int i = 0; i < 3; i++){
		for(int j = 0; j < 3; j++){
			normalList[i][j] = aNormalList[i][j];
		}
	}
}

void Triangle::setUVList(GzTextureIndex aUVList[]){
	for(int i = 0; i < 3; i++){
		for(int j = 0; j < 2; j++){
			uvList[i][j] = aUVList[i][j];
		}
	}
}

Plane::Plane(GzCoord aNormal, float aDistance){
	for(int i = 0; i < 3; i++) normal[i] = aNormal[i];
	distance = aDistance;
}

Plane::Plane(GzCoord aVertexList[]){
	GzCoord temp1, temp2;
	for(int i = 0; i < 3; i++){
		for(int j = 0; j < 3; j++){
			vertexList[i][j] = aVertexList[i][j];
		}
	}

	vectorConstruct(vertexList[0], vertexList[1], temp1);
	vectorConstruct(vertexList[0], vertexList[2], temp2);
	vectorCrossProduct(temp1, temp2, normal);
	vectorNormalize(normal);

	distance = vectorDotProduct(normal, vertexList[0]);
}

int Plane::findIntersectPoint(Ray& aRay, GzCoord aPoint){

	GzCoord w0, temp;

	if(vectorZero(normal)) return -1; //triangle degenerate to a point

	vectorConstruct(vertexList[0], aRay.origin, w0);
	float a = -vectorDotProduct(normal, w0);
	float b = vectorDotProduct(normal, aRay.direction);

	if(fabs(b) < SMALL_NUM){ //ray is parallel to triangle
		if(a == 0){
			return 2; //ray lies in triangle plane
		}else{
			return 0; //ray disjoint from triangle plane
		}
	}

	float r = a/b;
	if(r < 0.0) return 0; //ray goes away from triangle

	vectorScale(r, aRay.direction, temp);
	vectorAdd(aRay.origin, temp, aPoint);

	return 1; //one intersect point 
}

bool Plane::checkPointInTriangle(GzCoord aPoint){
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

	return sqrt(vector[0]*vector[0] + vector[1]*vector[1] + vector[2]*vector[2]); 
}