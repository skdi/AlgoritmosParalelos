#include <stdio.h>
#include <fstream>
#include <iostream>
#define CHANNELS 3 // canales del rgb (red,green,blue)
using namespace std;


// The input image is encoded as unsigned characters [0, 255]
__global__ void colorConvert(float * Pout, float * Pin, int width, int height)
{ 
  //tenemos almenos tantos threads como numero de pixeles
  int Col = threadIdx.x + blockIdx.x * blockDim.x;
  int Row = threadIdx.y + blockIdx.y * blockDim.y;

  //cada thread trabaja la siguiente seccion de codigo
  //comprobacion de que el thread esta dentro de rango
  if (Col < width && Row < height)
  {
    
    //Linealiza (1D) el array 2d de la imagen 
    //row*width salta la fila completa
    int greyOffset = Row*width + Col;

    //poisicion inicial del color del pixel en el Pin array
    int rgbOffset = greyOffset*CHANNELS;

    //obtencion de los valores rgb separados en 3 arrays
    // g y b son las posiciones siguientes de r almecenadas en memoria global como un vector 1D
    float r = Pin[rgbOffset]; // red value for pixel
    float g = Pin[rgbOffset + 1]; // green value for pixel
    float b = Pin[rgbOffset + 2]; // blue value for pixel

    //Conversion de rgb a escala de grises
    Pout[greyOffset] = 0.21f*r + 0.71f*g + 0.07f*b;
  }
}

//Funcion auxiliar para guardar la imagen .dat
void save_data(float o[225][225])
{
  ofstream archivo("gray.dat");
  for (int i = 0; i < 225; ++i)
  {
    for (int j = 0; j < 225; ++j)
    {
          archivo<<o[i][j]<<" ";
    }
    archivo<<endl;
  }
}

void GrayScale(float m[225][225*3],int width, int height)
{
  float o[225][225];
  //tamaño de la imagen de entrada *3 por el rgb
  int size_in = width * (height*3);
  //tamaño de la imagen de salida
  int size_out = width * height;

  //Calculo para el tamaño de la memoria necesaria del host y device
  int memSize_in = size_in * sizeof(float);
  int memSize_out = size_out * sizeof(float);

  //Direcciones donde se almacenaran los datos del device entrada y salida
  float *d_A, *d_B;

  //Separando memoria para la entrada salida del device
  cudaMalloc((void **) &d_A, memSize_in);
  cudaMalloc((void **) &d_B, memSize_out);

  //Copia de memoria del host al device (m imagen entrada host, d_A entrada device)
  cudaMemcpy(d_A, m, memSize_in, cudaMemcpyHostToDevice);

  //Grid 3D (aunque solo se usa 2D) de bloques
  dim3 DimGrid(floor((width-1)/16 + 1), floor((height-1)/16+1), 1);
  //Bloque 3D (aunque solo se usa 2D)de threads
  dim3 DimBlock(16, 16, 1);

  //Llamado al kernel
  colorConvert<<<DimGrid,DimBlock>>>(d_B, d_A, width, height);
 
  //Copia de memoria del device al host (ambos de salida)
  cudaMemcpy(o, d_B, memSize_out, cudaMemcpyDeviceToHost);

  //Liberacion de memoria del device
  cudaFree(d_A);
  cudaFree(d_B);
  //Guardando la data en una imagen (.dat)
  save_data(o);
}


//Funcion auxiliar para la lectura de la data
void leer_data(const char *file, float m[225][225*3])
{
  char buffer[100];
  ifstream archivo2("image.dat");
  for (int ii = 0; ii < 225; ++ii)
  {
    for (int jj = 0; jj < 225; ++jj)
    {
          archivo2>>m[ii][jj*3]>>m[ii][jj*3+1]>>m[ii][jj*3+2];
    }
    archivo2.getline(buffer,100);
  }
}


int main()
{

  int width=225, height=225;
  float m[225][225*3];
  leer_data("lena.dat",m);
  GrayScale(m,width,height);
  printf("HECHO\n");
  return EXIT_SUCCESS;

}
