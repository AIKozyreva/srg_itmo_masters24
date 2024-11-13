
## 1. Попробуем визуализировать сравнения геномов. Случайного штамма и референсной Serratia rubidaea. 

Инструмент (https://github.com/JustinChu/JupiterPlot). Установка вообще не была простой если что. Ставится исключительно на что-то, имеющее gpu.

```
conda install bioconda::jupiterplot
#опционально: conda install -n your_env gcc_linux-64
```

Картинка повыше - результат сравнения перевёрной в revc сборки штамма на референсную серацию. На второй картинке первичное сравнение всё с тем же референсном всё той же сборки штамма, но до в прямой ориентации. 
```
jupiter name=jupi_plot_comp1 ref=./Ref_Serratia.fna fa=./Strain2_serratia_REVC.fasta labels=both
jupiter name=2jupi_plot_comp1 ref=./Ref_Serratia.fna fa=./Strain2_serratia.fna
```

![image](https://github.com/user-attachments/assets/ec2fdbd1-6667-4381-a0ce-af5a5975148f)
![image](https://github.com/user-attachments/assets/eb1a484e-5783-47fd-a184-181f5e710ab1)

Ниже в качестве примеров представлены ещё два сравнения. Слева  - результаты сравнения промежуточного результтата SPADES на референс. Справа - конечный результат отполированной сборки. Фактически - это разные стадии одноо проекта по сборке полного генома бактерии. Как мы видим, бактерия имеет три плазмиды, как и референс. Только я не нашла, как заставить программу самый тонкий тяж нарисовать между мелкими плазмидами, хотя я даже файл конфига подредактировала. 

```
jupiter name=jupi_plot ref=./177_genomic.fna fa=./assembly.fasta maxBundleSize=500 m=100 labels=both ng=0 linkAlpha=5
```

![image](https://github.com/user-attachments/assets/bc1d4f9d-f43b-4e21-a1e4-d21644d01e6f)
