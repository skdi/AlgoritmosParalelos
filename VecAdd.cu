#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda.h>
#include <ctime>
#include <time.h>
#include <cuda_runtime.h>
 

// Kernel CUDA, cada thread trabaja con un elemento de C
__global__ void vecAdd(double *a, double *b, double *c, int n)
{
    // Obtencion del thread id global (en el device)
    int id = blockIdx.x*blockDim.x+threadIdx.x;
 
    //Comprobacion de no salirse de los limites
    if (id < n)
        c[id] = a[id] + b[id];
}
 

int main( int argc, char* argv[] )
{
    // Tamaño de los vectores
    int n = 100000;
 
    // Vectores de entrada del host
    double *h_a;
    double *h_b;
    // Vector de salida del host
    double *h_c;
 
    // vectores de entrada del device
    double *d_a;
    double *d_b;
    // Vector de salida del device
    double *d_c;
 
    // Tamaño en bytes de cada vector
    size_t bytes = n*sizeof(double);
 
    // Seperando memoria para cada vector del host
    h_a = (double*)malloc(bytes);
    h_b = (double*)malloc(bytes);
    h_c = (double*)malloc(bytes);
 
    // Separando memoria para cada vector del device
    //direccion del puntero de la variable, tamaño de memoria a separar
    cudaMalloc((void**)&d_a, bytes);
    //cudaMalloc(&d_a, bytes);
    cudaMalloc((void**)&d_b, bytes);
    cudaMalloc((void**)&d_c, bytes);
 
    int i;
    // Inicializacion de los vectores de entrada del host
    for( i = 0; i < n; i++ ) {
        h_a[i] = sin(i)*sin(4*i);
        h_b[i] = cos(i)*cos(i);
        //printf("%d,%d \n",h_a[i],h_b[i]);
    }
 
    // Copia de los vectores del host al device
    //puntero destino,puntero fuente,numero de bytes a copiar,tipo de copia
    cudaMemcpy( d_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy( d_b, h_b, bytes, cudaMemcpyHostToDevice);
    //printf("%d,%d \n",d_a[1],d_b[1]);
 
    int blockSize, gridSize;
 
    // numero de threads por bloque
    blockSize = 1024;
 
    // Numero de bloques en el grid
    gridSize = (int)ceil((float)n/blockSize);
 
    //Toma de tiempo
    //unsigned double timer = 0.0;
    //cutCreateTimer (& timer ) ;
	//cutStartTimer ( timer ) ;


    // Ejecucion del kernel
    vecAdd<<<gridSize, blockSize>>>(d_a, d_b, d_c, n);
 	

    //cudaThreadSynchronize () ;
	//cutStopTimer ( timer ) ;
	//printf (" CUDA execution time = %f ms\n", cutGetTimerValue ( timer ) ) ;

    // Copia del resultado al host
    cudaMemcpy( h_c, d_c, bytes, cudaMemcpyDeviceToHost);
 	//printf("HOLA%d \n",h_c[100000-1]);


    // Suma del vector y promedio del mismo
    double sum = 0;
    for(i=0; i<n; i++){
    	//printf("%d \n",h_c[i]);
        sum += h_c[i];

    }
    
    printf("final result: %f\n", sum/(double)n);
 
    // Liberando memoria del device
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
 
    // Liberando memoria del Host
    free(h_a);
    free(h_b);
    free(h_c);
 
    return 0;
}
