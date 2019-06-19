#include <stdio.h>
#include <fstream>
#include <iostream>
#define BLUR_SIZE 3
using namespace std;

__global__
void blurKernel(float * in, float * out, int w, int h)
{
  //Obtencion de los datos del thread en X y Y
  int Col = blockIdx.x * blockDim.x + threadIdx.x;
  int Row = blockIdx.y * blockDim.y + threadIdx.y;

  //Comprobando que el thread este dentro de los limites
  if (Col < w && Row < h)
  {
    int pixVal = 0;
    int pixels = 0;

    //Calculando el promedio del valor de la sub matriz del pixel de 2xBLUR_SIZE x 2xBLUR_SIZE
    //EJE Y
    for(int blurRow = -BLUR_SIZE; blurRow < BLUR_SIZE+1; ++blurRow)
    {
      //EJE X
      for(int blurCol = -BLUR_SIZE; blurCol < BLUR_SIZE+1; ++blurCol)
      {
        //Calculo de la posicion actual
        int curRow = Row + blurRow;
        int curCol = Col + blurCol;

        //Comprobacion de los limites
        if(curRow > -1 && curRow < h && curCol > -1 && curCol < w)
        {
          //Linealizando la sub matriz de 2xBLUR_SIZE x 2xBLUR_SIZE
          //Estos valores seran usados para el promedio 
          pixVal += in[curRow * w + curCol];
          pixels++; // Contador del numero de pixeles usados para el blur
        }
      }
    }
    // Write our new pixel value out
    // Escribiendo el nuevo valor del pixel segun el promedio de los datos calculados anteriormente
    //Acceso lineal a la memoria para la salida
    out[Row * w + Col] = (float)(pixVal / pixels);
  }
}


//Funcion auxiliar para guardar la data en una imagen .dat
void save_data(float r[225][225], float g[225][225], float b[225][225])
{
  ofstream archivo("bluur.dat");
  for (int i = 0; i < 225; ++i)
  {
    for (int j = 0; j < 225; ++j)
    {
          archivo<<r[i][j]<<" "<<g[i][j]<<" "<<b[i][j]<<" ";
    }
    archivo<<endl;
  }
}


void Blur(float r[225][225], float g[225][225], float b[225][225], int width, int height)
{
  //Vectores de salida rgb
  float o_r[225][225];
  float o_g[225][225];
  float o_b[225][225];

  //tamaño de imagen
  int size = width * height;

  //cantidad de memoria necesaria
  int memSize = size * sizeof(float);

  //Direcciones de memoria del device
  float *d_A, *d_B;

  //Separando memoria en el device
  cudaMalloc((void **) &d_A, memSize);
  cudaMalloc((void **) &d_B, memSize);

  //COLOR ROJO
  //Copia del host al device
  cudaMemcpy(d_A, r, memSize, cudaMemcpyHostToDevice);

  //Grid 3D (aunque solo se usa 2D) de bloques
  dim3 DimGrid(floor((width-1)/16 + 1), floor((height-1)/16+1), 1);
  //Bloque 3D de threads
  dim3 DimBlock(16, 16, 1);
  //Llamado al kernel
  blurKernel<<<DimGrid,DimBlock>>>(d_A, d_B, width, height);
  //Copia de memoria del device al host (Salida Roja)
  cudaMemcpy(o_r, d_B, memSize, cudaMemcpyDeviceToHost);


  //COLOR VERDE
  cudaMemcpy(d_A, g, memSize, cudaMemcpyHostToDevice);

  //Llamado al kernel
  blurKernel<<<DimGrid,DimBlock>>>(d_A, d_B, width, height);
  //Copia de memoria del device al host (Salida Verde)
  cudaMemcpy(o_g, d_B, memSize, cudaMemcpyDeviceToHost);

  //Copia del host al device
  cudaMemcpy(d_A, b, memSize, cudaMemcpyHostToDevice);



  //COLOR AZUL
  //Llamado al kernel 
  blurKernel<<<DimGrid,DimBlock>>>(d_A, d_B, width, height);

  //Copia del device al host (salida Azul)
  cudaMemcpy(o_b, d_B, memSize, cudaMemcpyDeviceToHost);

  //Liberando memoria del device
  cudaFree(d_A);
  cudaFree(d_B);
  //Guardar la data en imagen .dat
  save_data(o_r,o_g,o_b);
}


//Funcion de apoyo para la lectura de la imagen
void leer_data(const char *file, float r[225][225], float g[225][225], float b[225][225])
{
  char buffer[100];
  ifstream archivo2("lena.dat");
  for (int ii = 0; ii < 225; ++ii)
  {
    for (int jj = 0; jj < 225; ++jj)
    {
          archivo2>>r[ii][jj]>>g[ii][jj]>>b[ii][jj];
    }
    archivo2.getline(buffer,100);
  }
}


int main()
{
  int width=225, height=225;
  float r[225][225];
  float g[225][225];
  float b[225][225];
  leer_data("lena.dat",r,g,b);
  Blur(r,g,b,width,height);
  printf("HECHO\n");
  return EXIT_SUCCESS;
}
