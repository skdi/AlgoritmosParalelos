#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctime>
#include <math.h>
#include <vector>
#include <mpi.h>
using namespace std;

#define MAX 1000

typedef vector<int> fila;
typedef vector<fila> matrix;
unsigned t0,t1;

double f(double x){
	return 4*x*x;
}

double trap(double left_endpt,double right_endpt,int trap_count,double base_len){
	double estimate, x;
	int i;
	estimate=(f(left_endpt)+f(right_endpt))/2.0;
	for(i=1;i<=trap_count-1;i++){
		x=left_endpt+i*base_len;
		estimate+=f(x);
	}
	estimate=estimate*base_len;
	return estimate;	
}


int main(){
	int my_rank,comm_sz,n=1024,local_n;
	double a=0.0,b=3.0,h, local_a, local_b;
	double local_int, total_int;
	int source;

	MPI_Init(NULL,NULL);//inicializacion del mpi
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);//asignacion de rank a los procesos
	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);//numero de procesos 

	h=(b-a)/n; //ancho del area a integrar
	local_n = n/comm_sz;//numero de trapezoides

	local_a = a + my_rank*local_n*h;//inicio del area a integrar
	local_b = local_a + local_n*h;// fin del area a integrar
	local_int=trap(local_a,local_b,local_n,h);

	if(my_rank!=0){//todos los procesos envian sus calculos al proceso 0 quien lo junta
		MPI_Send(&local_int,1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
	}else{
		total_int = local_int;//sobre escritura del 
		for(source = 1; source < comm_sz; source++){
			MPI_Recv(&local_int,1,MPI_DOUBLE,source,0,MPI_COMM_WORLD, MPI_STATUS_IGNORE);
			total_int+=local_int;
		}
	}
	if(my_rank==0){
		printf("With n = %d trapezoides, el estimado\n",n);
		printf("de la integral desde %f a %f = %.15e\n", a,b,total_int );
	}
	MPI_Finalize();
	return 0;
}
