#include<stdlib.h>
#include<string.h>
#include <stdio.h>
#include  <math.h>
#include  <time.h>

/*********** * * * * *  *  *   *   *   *  *  *  * * * ***************/

int Nat;
int i;

/********************************************************************/
/************************* Atom Definition **************************/
/********************************************************************/

struct Atom
{
   char Symbol[3];
   float x[3];
};
typedef struct Atom atoms;

/********************************************************************/
/*********************** Molecule Definition ************************/
/********************************************************************/

struct Molecule
{
   atoms *atom;
   int Nat;
};
typedef struct Molecule molecule;


/********************************************************************/
/************************ Function read_xyz *************************/
/**************** Name_Molecule=read_xyz(File.xyz) ******************/
/********** molecule Cysteine; Cysteine=read_xyz(argv[1]); **********/
/********************************************************************/

molecule read_xyz( char *file )
{
   molecule Mol;
   int aux;

   FILE *za=fopen(file, "r");
   FILE *xe=fopen("command", "w");

   fscanf(za,"%i\n",&aux);
   fprintf(xe,"head -%i %s | tail -%i >> aux \n", aux+2, file, aux);
   fclose(xe);

   system("chmod +x command");
   system("./command");

   atoms *_atoms=(atoms *)malloc(aux*sizeof(atoms));

   FILE *yi =fopen("aux", "r");

   for(i=0;i<aux;i++)
   {
      fscanf(yi,"%s %f %f %f\n", _atoms[i].Symbol, &_atoms[i].x[0], &_atoms[i].x[1], &_atoms[i].x[2]);
   }

   Mol.atom=_atoms;

   fclose(yi);
   fclose(za);
   system("rm aux");
   Mol.Nat=aux;

   return Mol;
}

int main(int argc, char *argv[])
{
   int i,l,j,k=0;
   float Distancia;

   molecule cys;
   cys=read_xyz(argv[1]);
   for (i=0;i<cys.Nat;i++)
   {
      if(strcmp(cys.atom[i].Symbol,"N")==0)
      {
         for (j=0;j<cys.Nat;j++)
         {
            if(strcmp(cys.atom[j].Symbol,"H" )==0)
            {
               float suma=0;
               for(l=0;l<3;l++)
               {
                  suma=suma+pow((cys.atom[i].x[l]-cys.atom[j].x[l]),2);
               }
               Distancia=sqrt(suma);
               if(Distancia<1.5)
               {
                  k++;
               }
            }
         }
      }
   }
  if (k>2)
  {printf("T\n");}
  else{printf("F\n");}
  return 0;
}


