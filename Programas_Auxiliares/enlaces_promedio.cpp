#include<atomicpp.h>

double distancias;
int contador;
double suma;

int main()
{
Cluster clus;
clus.read_xyz("cluster.xyz");
suma=0;
contador=0;
for(i=0;i<clus.Nat;i++)
{
   for(j=0;j<clus.Nat;j++)
   {
      distancias=Atomic_Distance(clus.atom[i],clus.atom[j]);
      if(distancias<2.95 && distancias >1.0)
      {
      contador++;
      suma=distancias+suma;
      }
   }
}
cout<<"Enlace promedio: "<<suma/contador<<endl;
return 0;
}
