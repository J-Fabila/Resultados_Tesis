########################################################################
############################### INPUT ##################################
########################################################################


#***************************** SISTEMA ********************************#

                #Se puede proporcionar el archivo DOSCAR y entonces este
                #script lo leerá de ahi, en ese caso se deja   Efermi*=0
EfermiUp=0
EfermiDown=0

#***************************** GNUPLOT ********************************#

Title=Ir_{2}               #Gnuplot generará un .png llamado 'Title.png'
                              #La imagen generada tendrá el mismo título
AutomaticRange=false              #Utiliza el rango automático de gnuplot
                        #Si 'true' entonces se  inhabilita lo siguiente:
xmin=-6          #Cota mínima del rango en X de la gráfica que generará
xmax=6           #Cota máxima del rango en X de la gráfica que generará

NombreScript=Script_gplot  #Se genera un script llamado 'NombreScript'
          #ése es modificable. Si la gráfica no es de agrado simplemente
                       #se   cambian los parámetros en él escritos, pero
   #ya no es necesario volver a correr el presente programa. Sino que se
     #ejecuta '$~ gnuplot NombreScript' con 'NombreScript' ya modificado
                 #generando un nuevo .png con los parámetros modificados


#########################################################################
############################ TERMINA INPUT ##############################
#########################################################################


###### Se obtienen las energias ##########
grep  "energy" PROCAR  | awk '{print $5}' > energias  #PROCAR-->$1
###### Se obtiene el número de átomos #####
Nat=$(head -1 poscar.xyz )
###### Se obtienen los elementos ##########
to_xyz POSCAR > poscar.xyz
tail -$Nat poscar.xyz | awk '{print $1}' > elementos

##### Obtiene la energía de Fermi #########
if [ -f DOSCAR ]
then
   EfermiUp=$(head -6 DOSCAR | tail -1 | awk '{print $4}')
   EfermiDown=$(head -6 DOSCAR | tail -1 | awk '{print $4}')
fi
##### Se generan todos los archivos individuales listos para graficar ###

for ((i=1;i<$(($Nat+1));i++))
do

   # Desglosa los archivos por átomo por orbital por espín
   grep -A $Nat "ion " PROCAR  | grep " $i " | awk '{print $2}' > #atomo_$i_orbital_s aux
   grep -A $Nat "ion " PROCAR  | grep " $i " | awk '{print $3}' > #atomo_$i_orbital_p aux
   grep -A $Nat "ion " PROCAR  | grep " $i " | awk '{print $4}' > #atomo_$i_orbital_d aux

############ AGREGAR LO DEL SPIN DOWN :grep -A $(($Nat*2)) la primeramitad es up
########### la segunda mitad es down debajo de cada ion.
 > atomo${i}_orbitals_up.aux
 > atomo${i}_orbitals_down.aux

 > atomo${i}_orbitalp_up.aux
 > atomo${i}_orbitalp_down.aux

 > atomo${i}_orbitald_up.aux
 > atomo${i}_orbitald_down.aux

   # Desplaza el cero a la energía de Fermi
   echo "awk '{print \$1-$EfermiUp}' atomo${i}_orbitals_up.aux " | bash > atomo${i}_orbital_s_up
   echo "awk '{print \$1-$EfermiDown}' atomo${i}_orbitals_down.aux " | bash > atomo${i}_orbital_s_down

   echo "awk '{print \$1-$EfermiUp}' atomo${i}_orbitalp_up.aux " | bash > atomo${i}_orbital_p_up
   echo "awk '{print \$1-$EfermiDown}' atomo${i}_orbitalp_down.aux " | bash > atomo${i}_orbital_p_down

   echo "awk '{print \$1-$EfermiUp}' atomo${i}_orbitald_up.aux " | bash > atomo${i}_orbital_d_up
   echo "awk '{print \$1-$EfermiDown}' atomo${i}_orbitald_down.aux " | bash > atomo${i}_orbital_d_down

   # Junta la información con el tipo de atomo y las energías
   paste energias atomo${i}_orbital_s_up > atomo${i}_orbital_s_up.dat
   paste energias atomo${i}_orbital_s_down > atomo${i}_orbital_s_down.dat

   paste energias atomo${i}_orbital_p_up > atomo${i}_orbital_p_up.dat
   paste energias  atomo${i}_orbital_p_down > atomo${i}_orbital_p_down.dat

   paste energias atomo${i}_orbital_d_up > atomo${i}_orbital_d_up.dat
   paste energias atomo${i}_orbital_d_down > atomo${i}_orbital_d_down.dat

   # Elimina archivos residuales (auxiliares)
   rm atomo${i}_orbital_s_up.aux atomo${i}_orbital_s_up
   rm atomo${i}_orbital_s_down.aux atomo${i}_orbital_s_down

   rm atomo${i}_orbital_p_up.aux atomo${i}_orbital_p_up
   rm atomo${i}_orbital_p_down.aux atomo${i}_orbital_p_down

   rm atomo${i}_orbital_d_up.aux atomo${i}_orbital_d_up
   rm atomo${i}_orbital_d_down.aux atomo${i}_orbital_d_down

done


#***********************************************************************#
#                      ESCRIBE SCRIPTS PARA GNUPLOT                     #
#***********************************************************************#

echo "set terminal pngcairo size 1024,768 enhanced font 'Helvetica, 35'
set output '$Title.png'" > $NombreScript
echo -n "set title \"" >> $NombreScript
echo -n "$Title" >> $NombreScript
echo "\" font \"Helvetica, 35\"">> $NombreScript
echo "set xlabel 'E-E_f (eV)'  font \"Helvetica, 35\"
set ylabel 'PDOS (Estados/eV)' font \"Helvetica, 25\"
set xtics font \"Helvetica, 35\"
set yzeroaxis lt -1 lw 3
set noytics " >> $NombreScript


if [ $AutomaticRange = false ]
then
echo "
set xrange [$xmin:$xmax]
">> $NombreScript
fi



echo "set style fill transparent solid 0.3 noborder ">> $NombreScript
echo -n "plot  " >> $NombreScript


for ((l=1;l<$(($Nat+1));l++))
do

#   multiplicidad=$( ls $prefix.pdos.pdos_atm#$l\(* | wc -l ) #Cuenta el numero de orbitales tiene el l-esimo atomo
   for j in _s _p _d
   do
      fileup=  .dat
      filedown=  .dat

#*********************Parser que determina el tipo de Átomo**********************#

      tipo=$( head -$i elementos | tail -1 )

#*********************************************************************#
#                     Asigna colores                                  #
#********************************************************************#
      color=$(grep "$tipo" colores | grep "$j" | awk '{print $2}')

#**************************** Spin up ************************************#

        echo -n "\"$fileup\" u 1:2 w filledcurve below lt rgb " >> $NombreScript
        echo -n " \"$color\" notitle, " >> $NombreScript

#*************************** Spin down ***********************************#

        echo -n "\"$filedown\" u 1:2  w filledcurve below lt rgb " >> $NombreScript
        echo -n " \"$color\" notitle, " >> $NombreScript

   done
done 2>/dev/null
gnuplot $NombreScript


echo "Se utilizaron los siguientes colores"
cat colores
