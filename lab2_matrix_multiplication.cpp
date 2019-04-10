#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctime>
#include <math.h>
#include <vector>
using namespace std;

#define MAX 1000

typedef vector<int> fila;
typedef vector<fila> matrix;
unsigned t0,t1;

void inicializar(matrix &A){
	
	srand(time(NULL));
	fila B;
	B.reserve(MAX);
	int x;
	for(int i=0;i<MAX;i++){
		B.clear();
		for(int j=0;j<MAX;j++){
			x=int(rand()%10);
			B.push_back(x);
		}
		A.push_back(B);
	}

}
void inicializar0(matrix &A){

	fila B;
	B.reserve(MAX);
	for(int i=0;i<MAX;i++){
		B.clear();
		for(int j=0;j<MAX;j++){
			B.push_back(0);
		}
		A.push_back(B);
	}

}
void inicializar(fila &A){
	A.reserve(MAX);
	srand(time(NULL));
	for(int i=0;i<MAX;i++){
		A.push_back(int(rand()%10));
	}
}
void inicializar0(fila &A){
	A.reserve(MAX);
	for(int i=0;i<MAX;i++){
		A.push_back(0);
	}
}

double func1(matrix A,fila x,fila y){
	t0=0;t1=0;
	t0=clock();
	for(int i=0;i<MAX;i++){
		for(int j=0;j<MAX;j++)
			y[i]+=A[i][j]*x[j];
	}
	t1=clock();
	double time = (double(t1-t0)/CLOCKS_PER_SEC);
	return time ;
}


double func2(matrix A,fila x,fila y){
	t0=0;t1=0;
	t0=clock();
	for(int j=0;j<MAX;j++){
		for(int i=0;i<MAX;i++)
			y[i]+=A[i][j]*x[j];
	}
	t1=clock();
	double time = (double(t1-t0)/CLOCKS_PER_SEC);
	return time ;
}

void imprimir(matrix A){
	for(int i=0;i<MAX;i++){
		for(int j=0;j<MAX;j++)
			cout<<A[i][j];
		cout<<endl;
	}
}


double multiplicacion(matrix A,matrix B){
	
    matrix C;
    inicializar0(C);
    t0=0;t1=0;
	t0=clock();
    for (int i=0;i<MAX;i++){
        for (int j=0;j<MAX;j++){
             C[i][j]=0;
             for(int k=0;k<MAX;k++){
              C[i][j]=C[i][j]+A[i][k]*B[k][j];
              }
              
        }
    }
    t1=clock();
	double time = (double(t1-t0)/CLOCKS_PER_SEC);
	return time ;
}


//http://valgrind.org/gallery/linux_mag.html
double multiplicacion_bloques(matrix A,matrix B){
	matrix C;
    inicializar0(C);
    t0=0;t1=0;
	t0=clock();
	int sum=0;
	int t=sqrt(MAX);
	/*Multiplicacion por bloques*/
	for (int i0=0;i0<MAX;i0+=t){
		for(int j0=0;j0<MAX;j0+=t){
			for(int k0=0;k0<MAX;k0+=t){
				//Multiply AI:I+T, K:K+T and BK:K+T, J:J+T into CI:I+T, J:J+T, that is:
				for(int i=i0;i<min(i0+t,MAX);i++){
					for(int j=j0;j<min(j0+t,MAX);j++){
						sum=0;
						for(int k=k0;k<min(k0+t,MAX);k++){
							sum=sum+A[i][k]*B[k][j];
						}
						C[i][j]=C[i][j]+sum;
					}
				}
			}
		}
	}


	t1=clock();
	double time = (double(t1-t0)/CLOCKS_PER_SEC);
	return time ;
}



int main(){
	matrix A,B;
	fila x,y;
	
	inicializar(A);
	inicializar(B);
	inicializar(x);
	inicializar0(y);
	double temp1,temp2,temp3,temp4;
	//temp1=func1(A,x,y);
	//temp2=func2(A,x,y);
	temp3=multiplicacion(A,B);
	temp4=multiplicacion_bloques(A,B);
	cout<<"PREGUNTA1:"<<temp1<<" - "<<temp2<<endl;
	cout<<"PREGUNTA2:"<<temp3<<endl;
	cout<<"Pregunta3:"<<temp4<<endl;
	return 0;
}
