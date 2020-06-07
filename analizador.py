   
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style("darkgrid")

Metales=['Au','Ag','Cu']
Rotameros=['Pc','Ph','Pn']

for i in Metales:
    for j in Rotameros:
        en=pd.read_csv(i+"/"+j+"/"+"energias.csv")
        zw=pd.read_csv(i+"/"+j+"/"+"zwitter.csv") 
        #Junta ambos *csv en un mismo DataFrame
        datos=pd.merge(en,zw)
        #Considera solamente aquellos que convergieron y que si quedaron
        #en estado zwitteriónico:
        datos_c=datos.loc[datos.Convergence=='T'].loc[datos.Zwitteriónica=='T']
        #Grafica en un diagrama de dispersión las energías obtenidas
        fig = plt.figure(figsize=(10,8)) 
        fig=plt.title('Cisteína ('+j+') en '+i+'_34')
        fig=plt.xlabel("Configuración")
        fig=plt.ylabel("Energía [eV]")
        fig=plt.plot(datos_c.E,"o")
        #Guarda la figura en automático
        fig=plt.savefig(i+"-"+j+".png")
        #Ordena las energías y toma las 5 mínimas, esto lo escribe en otro *csv
        archivo_min=i+"-"+j+"5min.csv"
        minimos=datos_c.sort_values(by='E')[:5][['Configuration','E']]
        minimos.to_csv(archivo_min,index=False) 





