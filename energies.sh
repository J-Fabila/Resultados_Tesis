echo "Configuration,Zwitteriónica"
N=$(ls | grep "Configuration" | wc -l)
for ((i=0;i<$(($N+1));i++))
do
  cd Configuration$i
  echo -n  "$i,"
  to_xyz CONTCAR CONTCAR$i.xyz
  cp ../zwitter .
  Z=$(./zwitter CONTCAR$i.xyz)
  echo  "$Z"
  rm zwitter
  cd ..
done 2> /dev/null

