
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
Repeat Modeler - is a de novo transposable element (TE) family identification and modeling package. Repeat Masker - is a program that screens DNA sequences for interspersed repeats and low complexity DNA sequences. The output of the program is a detailed annotation of the repeats that are present in the query sequence as well as a modified version of the query sequence in which all the annotated repeats have been masked (default: replaced by Ns).  https://www.animalgenome.org/bioinfo/resources/manuals/RepeatMaskdb.html 
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
Получаем ряд файлов, в том числе в файлах `consensi.fa`, одержащуюю консенсусы тех последовательностей, которые были определены программой как отдельное семейство повтором в результтате анализа последовательности. 
![image](https://github.com/user-attachments/assets/22b03871-5517-45f8-acf6-db90536a59ae)
Так же, если порыться в файлах можно найти файл `families-classified` пример ниже. В нём для каждого обнаруженного семейчтва есть координаты каждого вхождения обнаружения этого повтора. 
![image](https://github.com/user-attachments/assets/da33d05f-e5a8-4a75-8bb3-5406a158a4eb)

Затем для обнаружения других повтором запускаем `RepeatMasker`. 
`RepeatMasker -lib ./RM_3560890.ThuNov141058212024/consensi.fa -pa 4 -small -xsmall -e rmblast -xm -gff -html -q -gc 55 -a -dir ./ ../Strain2_serratia_REVC.fasta`. Движок бластовый, максикрование нижним регистром, создание дополнительных выходных файлов в виде gff и html, `-q` чуть менее чувствительный, но в 2-3 раза быстрее вычислительно метод. `-gc N` это гц состав организма, если значете его, для перерасчёта какой-то там матрицы весов на одном из этапов. `-a` дополнительно создать файл с выравниванием (для построения графика далее), `-dir` задаёт выходную директорию, иначе файлы будут там же, где исследуемая фаста. 

Чтобы построить график Кимуры по данным (циферки в многочисленных файлах вывода. если их посмотреть, вы уидите, что циферки в общем то одинаковые, но по-разному расположены, идля парсинга надо выбирать один формат какой-то, например гфф). Так вот, для осознания циферок надо посттроить график двумя скриптами на perl, первый скрипт создаст из файлa `.align` файл специального формата `.divsum`. Второй скрипт из этого файла построит график. 

```
calcDivergenceFromAlign.pl -s ./Strain2_serratia_REVC.divsum ./Strain2_serratia_REVC.fasta.align
createRepeatLandscape.pl -div ./Strain2_serratia_REVC.divsum -t <title for plot> -g <INT your genome size for % counting>
```
![image](https://github.com/user-attachments/assets/63db41fb-c13b-4a09-8ace-bec698c67663)

-Troubleshooting:
Если возникли проблемы и вы получаете типа "_calcDivergenceFromAlign.pl Can't locate RepeatMaskerConfig.pm in @INC (you may need to install the RepeatMaskerConfig module)_". Это значит, что нужные для исполнения скрипта на перле библиотеки перла лежат в какой-то директории, которая не прописана в вашем системном PATH, надо их туда вписать. Первые команды помогут вам найти нужный файл во всей системе+удостовериться в месте, куда сам репитмаскер установлен чисто на всякий случай. Дальше вносите всё это в PATH в низ файла, тоже чисто на всякий случай. Дальше должно заработать. 

Если не получается вызвать сами .pm скрипты, то просто найдите их в системе и при выхове пропишите полный путь до них. 
```
find / -name "RepeatMaskerConfig.pm" 2>/dev/null  ## допустим, получила /home/kozyreva_ai/miniconda3/envs/RepeatMasker/share/RepeatMasker/RepeatMaskerConfig.pm
which RepeatMasker  ## допустим, получила /home/kozyreva_ai/miniconda3/envs/RepeatMasker/bin/RepeatMasker
nano ~/.bashrc
export REPEATMASKER_DIR=/home/kozyreva_ai/miniconda3/envs/RepeatMasker/bin
export PATH=$REPEATMASKER_DIR:$PATH
export PERL5LIB=/home/kozyreva_ai/miniconda3/envs/RepeatMasker/share/RepeatMasker:$PERL5LIB
source ~/.bashrc
```


## 3. [CIRCOS](https://circos.ca/) - visualizing GC composition

есть инструкция. по ней ничего не работает. без неё тоже. охенный инструмент 10/10 и минус примерно 6 часов рабочего дня. просто охуительный совет, спасибо чел.

