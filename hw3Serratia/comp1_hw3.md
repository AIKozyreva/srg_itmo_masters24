
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

![image](https://github.com/user-attachments/assets/4cce4792-20cc-4568-a9d7-23d8cf9b1151)

Ниже в качестве примеров представлены ещё два сравнения. Слева  - результаты сравнения промежуточного результтата SPADES на референс. Справа - конечный результат отполированной сборки. Фактически - это разные стадии одноо проекта по сборке полного генома бактерии. Как мы видим, бактерия имеет три плазмиды, как и референс. Только я не нашла, как заставить программу самый тонкий тяж нарисовать между мелкими плазмидами, хотя я даже файл конфига подредактировала. 

```
jupiter name=jupi_plot ref=./177_genomic.fna fa=./assembly.fasta maxBundleSize=500 m=100 labels=both ng=0 linkAlpha=5
```
![image](https://github.com/user-attachments/assets/25f913ce-33ae-497e-87d5-652dbdd7871f)

## 2. RepeatModeler + RepeatMasker
_Installation_
RepeatModeler and RepeatMasker can be installed together as they are often used in conjunction. Ensure to install dependencies like **rmblast**. 
Repeat Modeler - is a de novo transposable element (TE) family identification and modeling package. Repeat Masker - is a program that screens DNA sequences for interspersed repeats and low complexity DNA sequences. The output of the program is a detailed annotation of the repeats that are present in the query sequence as well as a modified version of the query sequence in which all the annotated repeats have been masked (default: replaced by Ns). 
```
conda install -c bioconda rmblast
conda install -c bioconda repeatmodeler repeatmasker
RepeatMasker -h
RepeatModeler -h
_______________________________________________________
_RepeatMasker [-options] <seqfiles(s) in fasta format>_
_______________________________________________________
_RepeatModeler [-options] -database <XDF Database>_
```

Сначала используем `Build Database` для приведения исследуемой фасты в состояние, которое может прочитать программа. При команде ниже БД будет сформироватна в той же папе, где запущена утилита.
`BuildDatabase -name Strain2REVC -dir ./RepMaskDB` --> сгенерит ряд файлов с расширениями `.nhr`, `.nnd`, `.nni`, `.njs`, `.nin`, `.nog`, `.nsq`.   
Затем `RepeatModeler` запускаем на созданной по по моей фаста базе данных. 
`RepeatModeler -database ../Strain2REVC -threads 20 -LTRStruct`
Получаем ряд файлов, в том числе в файлах `consensi.fa`, одержащуюю консенсусы тех последовательностей, кторые были определены программой как отдельное семейство повтором в результтате анализа последовательности. 
![image](https://github.com/user-attachments/assets/22b03871-5517-45f8-acf6-db90536a59ae)
Так же, если порыться в файлах можно найти файл `families-classified` пример ниже. В нём для каждого обнаруженного семейчтва есть координаты каждого вхождения обнаружения этого повтора. 
![image](https://github.com/user-attachments/assets/da33d05f-e5a8-4a75-8bb3-5406a158a4eb)

Затем для обнаружения других повтором запускаем `RepeatMasker` 
