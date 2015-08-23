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

bool vectorZero(GzCoord vector){

	if(vector[0] == 0 && vector[1] == 0 && vector[2] == 0){
		return true;
	}else{
		return false;
	}
}

void vectorAdd(GzCoord vector1, GzCoord vector2){
	vector1[0] = vector1[0] + vector2[0];
	vector1[1] = vector1[1] + vector2[1];
	vector1[2] = vector1[2] + vector2[2];
}

void vectorAdd(GzCoord vector1, GzCoord vector2, GzCoord vector3){
	vector3[0] = vector1[0] + vector2[0];
	vector3[1] = vector1[1] + vector2[1];
	vector3[2] = vector1[2] + vector2[2];
}

void vectorMultiply(GzCoord vector1, GzCoord vector2){
	vector1[0] = vector1[0] * vector2[0];
	vector1[1] = vector1[1] * vector2[1];
	vector1[2] = vector1[2] * vector2[2];
}

void vectorMultiply(GzCoord vector1, GzCoord vector2, GzCoord vector3){
	vector3[0] = vector1[0] * vector2[0];
	vector3[1] = vector1[1] * vector2[1];
	vector3[2] = vector1[2] * vector2[2];
}

void vectorConstruct(GzCoord vector1, GzCoord vector2, GzCoord vector){
	vector[0] = vector2[0] - vector1[0];
	vector[1] = vector2[1] - vector1[1];
	vector[2] = vector2[2] - vector1[2];
}

void vectorNormalize(GzCoord vector){
	float length = sqrt(vector[0]*vector[0] + vector[1]*vector[1] + vector[2]*vector[2]);
	vector[0] = vector[0]/length;
	vector[1] = vector[1]/length;
	vector[2] = vector[2]/length;
}

float vectorDotProduct(GzCoord vector1, GzCoord vector2){
	return vector1[0]*vector2[0] + vector1[1]*vector2[1] + vector1[2]*vector2[2];
}

void vectorCrossProduct(GzCoord vector1, GzCoord vector2, GzCoord product){
	product[0] = vector1[1]*vector2[2] - vector1[2]*vector2[1];
	product[1] = vector1[2]*vector2[0] - vector1[0]*vector2[2];
	product[2] = vector1[0]*vector2[1] - vector1[1]*vector2[0];
}

void vectorScale(float scale, GzCoord vector){
	vector[0] = vector[0] * scale;
	vector[1] = vector[1] * scale;
	vector[2] = vector[2] * scale;
}

void vectorScale(float scale, GzCoord vector1, GzCoord vector2){
	vector2[0] = vector1[0] * scale;
	vector2[1] = vector1[1] * scale;
	vector2[2] = vector1[2] * scale;
}

float vectorTransform(GzCoord vector, float w, GzMatrix matrix){
	float vector0 = matrix[0][0]*vector[0] + matrix[0][1]*vector[1] + matrix[0][2]*vector[2] + matrix[0][3]*w;
	float vector1 = matrix[1][0]*vector[0] + matrix[1][1]*vector[1] + matrix[1][2]*vector[2] + matrix[1][3]*w;
	float vector2 = matrix[2][0]*vector[0] + matrix[2][1]*vector[1] + matrix[2][2]*vector[2] + matrix[2][3]*w;
	float temp = matrix[3][0]*vector[0] + matrix[3][1]*vector[1] + matrix[3][2]*vector[2] + matrix[3][3]*w;
	vector[0] = vector0;
	vector[1] = vector1;
	vector[2] = vector2;
	return temp;
}

void matrixMultiply(GzMatrix matrixA, GzMatrix matrixB, GzMatrix matrixC){
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

float vectorLength(GzCoord vector){

	return sqrt(vector[0]*vector[0] + vector[1]*vector[1] + vector[2]*vector[2]); 
}

float vectorDistance(GzCoord vector1, GzCoord vector2)
{
	float distance = 0;

	for(int i=0;i<3;i++)
	{
		distance += (vector1[i]-vector2[i])*(vector1[i]-vector2[i]);
	}

	return sqrt(distance);
}

void interpolation(GzCoord* Pos, GzCoord* Nor, GzCoord intersect,GzCoord result)
{
	/*
	   Pos are position of three vertices
	   Nor are normal/color of three vertices
	   intersect is the postion of intersection point
	   result is the results of interpolation

	   Calculate the intersection of two lines.
	   line 1: x = x0 + (x0 - xt)m, y = y0 + (y0 - yt)m, z = z0 + (z0 - zt)m
	   line 2: x = x1 + (x1 - x2)n, y = y1 + (y1 - y2)n, z = z1 + (z1 - z2)n
	*/
	//GzCoord intersectPos4;
	//GzCoord intersectPos5;
	GzCoord intersectPos6;
	GzCoord intersectNor4;
	GzCoord intersectNor5;
	//line 1: x = A + Bm
	GzCoord A;
	A[0]= Pos[0][0];A[1]= Pos[0][1];A[2]= Pos[0][2];
	GzCoord B;
	vectorConstruct(intersect, A, B);
	//line 2: x = C + Dn
	GzCoord C;
	C[0]= Pos[1][0];C[1]= Pos[1][1];C[2]= Pos[1][2];
	GzCoord D;
	vectorConstruct(Pos[2], C, D);

	//find the intesection of two line
	float n = (B[1]*C[0]-B[1]*A[0]-C[1]*B[0]+A[1]*B[0])/(D[1]*B[0]-B[1]*D[0]);
	float m = (C[1]-A[1])/B[1] + D[1]/B[1]*n;

	for(int i=0;i<3;i++)
	{
	    intersectPos6[i] = Pos[0][i] + (Pos[0][i] - intersect[i])*m;
	}

	float factor1 = vectorDistance(Pos[0],intersect)/vectorDistance(Pos[0],intersectPos6);

	for(int i=0;i<3;i++)
	{
	    //intersectPos4[i] = factor1*Pos[1][i] + (1-factor1)*Pos[0][i];
		//intersectPos5[i] = factor1*Pos[2][i] + (1-factor1)*Pos[0][i];
		intersectNor4[i] = factor1*Nor[1][i] + (1-factor1)*Nor[0][i];
		intersectNor5[i] = factor1*Nor[2][i] + (1-factor1)*Nor[0][i];
	}

	float factor2 = vectorDistance(Pos[1],intersectPos6)/vectorDistance(Pos[1],Pos[2]);

	for(int i=0;i<3;i++)
	{
	    result[i] = factor2*intersectNor5[i] + (1-factor2)*intersectNor4[i];
	}
}
