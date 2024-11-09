Downloading data: 

0. Installing tools

**BCFtools (with samtools and htslib)**
```
conda install -c bioconda samtools
```
okay, then
```
git clone --recurse-submodules https://github.com/samtools/htslib.git
git clone https://github.com/samtools/bcftools.git
#sudo apt install autoconf
autoheader && autoconf && ./configure --enable-libgsl --enable-perl-filters #here i have got an error about perl plugins, so i have just disable them
#and then i had to install packeges one by one, because an errors, which you can't resolve besides such downloading
#sudo apt install libgsl0-dev
#sudo apt-get install liblzma-dev
#sudo apt-get install libbz2-dev
#sudo apt-get install libcurl4-gnutls-dev
make
sudo make install
export BCFTOOLS_PLUGINS=/home/kozyr_home/bcftools/plugins
```

**SnpEFF**

```
wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip
unzip snpEff_latest_core.zip
cd snpEff/
sudo apt install openjdk-21-jdk #да, вам нужна джава, причём очень новая, 16 и 17 мне не подошли :) 
sudo update-alternatives --config java #это когда у вас несколько джав (угадайте как я узналоа, что 16 и 17 не подойдут), можно выбрать приоритетную -> выбрала 21.
java -jar snpEff.jar #вызов "-help" для snpEff
```

### 1. Alignment
```
minimap2 -map-ont -a -o comp1_alignment.sam Ref_Serratia_rubidaea_dataset/GCF_016026735.1/Ref_GCF_016026735.1_ASM1602673v1_genomic.fna Serratia_rubidaea_strain2_dataset/GCF_900638005.1/rubi2_GCF_900638005.1_53550_B01_genomic.fna
```
```
samtools view -b comp1_res/comp1_alignment.sam -o comp1_res/comp1_algn.bam
samtools sort -o comp1_res/comp1_algn_sort.bam  comp1_res/comp1_algn.bam
samtools flagstats comp1_res/comp1_algn_sort.bam
```
![image](https://github.com/user-attachments/assets/14de4b45-fc0a-4e9e-9bbf-ce7d8a0a6d2e)

### 2. creating VCF (snp calling)

```
bcftools mpileup -Ou -f ../Ref_Serratia_rubidaea_dataset/GCF_016026735.1/Ref_GCF_016026735.1_ASM1602673v1_genomic.fna comp1_algn_sort.bam | bcftools call -mv -Ov --ploidy 1 -o ./comp1_variants.vcf
```

### 3. SNP annotation

Так, для меня аннотация vcf - это подписывания регионов, где обнаружена заметна, значениями из референсной gff. Планирую сделать так: сделаю из референсной gff базу данных для snpEff, потому прогоню аннотацию с использованием этой бд, получу аннотированную vcf. Дальше из референсной gff найду все интересующие меня гены (видать их будет много), для каждой группы интереса скорее всего сделаю bed файл (?? или нет), потом посмотрю, можно ли сделать пересечение интервалов для vcf и bed файла, если да - то будет несколько маленьких vcf с по группам генов интереса. Если нет, то придётся как-то vcf форматировать или по аннотации вытаскивать нужное, но я чёта не хочу так делать, это надо на питоне думать чёта. 
UPD: создание кастомной базы данных это конечно та ещё клоунада, спустя 40 минут тыканья в кнопки вроде чёта есть по референсной гфф.

**Создачие кастомной бд для аннотации с помощью SnpEff**
Сначала идём в директорию, куда распаковали архив с версией snpEff. У меня он в home стоит, поэтому идём туда.
Важный нюанс, когда делаете кастомную бд - обязательно файлы генома и его аннотации должны лежать в определённом месте и называться определённым образом. Всё покажу ниже. 

Итак, чтобы создать кастомную БД для аннотации с помощью snpEff "3 простых условия" (ну 6):
1) Идётё в **~/snpeff**, там ищите или создаёте папку database
2) В папке **~/snpeff/database** создаёте папку своего таксона, у меня это было '_Serratia_rubidaea1_'
3) В папку **~/snpeff/database/Serratia_rubidaea1** помещаете минимум 2 файла: нуклеотидную фасту генома вашего организма (с именем sequence.fasta)+ гфф с аннотацией этого организма (с именем genes.gff). фактически в прекрасном мире будущего это тоже самое, что присутсвует в файле .gbk, но тут прога хочет два файла ничё не поделать. Понятно, что именно то, что написано в вашем файле аннотации - вы увидите в проаннотированной vcf, если там ничего не написано, то ну сори, найдите гфф получше. 
4) А теперь ещё нюанс. Вам надо открыть или создать папку **~/snpeff/database/genomes/Serratia_rubidaea1** и вот туда надо сложить файл 'Serratia_rubidaea1.fa', который на самом деле у меня был просто копией '~/snpeff/database/Serratia_rubidaea1/sequence.fasta' я не знаю поч, может первая фаста должна была быть не фаста, хотя вроде она, но короче при создании бд прога точно юзает фасту из папки genomes, а не из той папки, куда вы gff положили. ну..ладна :) работает и слава богу :))))))
5) Снова идём в `~/snpeff` там видим файл '.config'. В нём лежит очень много строк {а точнее 86 355 строк в версии SnpEff 4.3t (build 2017-11-24)}. Это база данных снпэфа, где у него в общем прописаны типа "индексы" для разных геномов. Если полистать, то увидите, что геномы в бд этой проги набирали с разных источников. В общем, для каждого генома либо две либо три строки: само название; путь до места, где лежат файлы; и время доступа. Вам надо внести данные для той базы, которую вы там надобавляли в виде файлов. То есть: название моей БД == название папки, которую я создала в  шаге 2), и оно же является именем файла в шаге 4). Для второй строчки вы должны прописать путь до папочки куда клали файлы в шаге 3). После добавления не забудьте сохранить обновлённый файл конфига.

Пример бд для таксона Felis_catus из NCBI (прописан по умолчанию в snpeff.config). 
```
Felis_catus.genome : Felis_catus
Felis_catus.reference : ftp://ftp.ncbi.nih.gov/genomes/Felis_catus/
Felis_catus.retrieval_date : 2017-10-24
```
Для создания кастомной бд надо сделать минимум как две первые записи, но для своего таксона. У меня вот такие строчки получились:
```
Serratia_rubidaea1.genome : Serratia_rubidaea1
Serratia_rubidaea1.reference : /home/kozyreva_ai/snpEff/data/Serratia_rubidaea1
```
6) запускаете команду для создания кастомной бд. У меня такая `java -jar ~/snpEff/snpEff.jar build -gff3 -v Serratia_rubidaea1`

**Аннотация .vcf с помощью SnpEff**

```
java -jar ~/snpEff/snpEff.jar ann Serratia_rubidaea1 comp1_variants.vcf > annotated_comp1_variants.vcf
```

Итак, мы получили:
![image](https://github.com/user-attachments/assets/8b16597f-a450-4ea4-80ed-4856416fa563)

Ну мёд ну медятина, а как это читать??? 
Ну лана, сча найдём.
так. тяжелооо. короче я поняла, как читать unit записи. а дальше чёта сложно. их много для одного снп, потому что 1) они могут иметь отношение к перекрывающимся генам (?? сомнительно ну окэй); 2) если у гена несколько транскриптом может быть, то снп может иметь разное значение для разного транскрипта (ну похоже на правду). Ладно я удолетворена этим знанием. Unit аннотации читать вот так:

![image](https://github.com/user-attachments/assets/cb26c296-229f-4732-bd48-30f0b24d7faf)
![image](https://github.com/user-attachments/assets/fb512fdf-7381-494c-976c-982a67aaeec0)
![image](https://github.com/user-attachments/assets/4ecb7812-c285-4e39-9909-035395d58261)

> Тип варианта
upstream_gene_variant: Вариант расположен перед началом гена (в направлении транскрипции).
downstream_gene_variant: Вариант после конца гена.
synonymous_variant: Синонимичный вариант (не изменяет аминокислоту).
missense_variant: Несинонимичный (изменяет аминокислоту).
stop_gained: Преждевременная остановка трансляции (образуется стоп-кодон).
frameshift_variant: Вставка/делеция, меняющая рамку считывания.

> Оценка значимости SNP
MODIFIER: Незначительное или неизвестное влияние (влияет на некодирующие регионы или удалённые регуляторные элементы).
LOW: Низкое влияние (например, синонимичный вариант).
MODERATE: Умеренное влияние (например, missense_variant).
HIGH: Высокое влияние (например, stop_gained или frameshift_variant).

> Идентификатор гена
Короткие имена: как alaC, указывающее на название или функцию гена.
ID из баз данных: такие как I6G83_RS23475, где ID обычно уникален для конкретного организма или эксперимента.
Иногда генам присваиваются более общеупотребимые обозначения, как lacZ или BRCA1.

> Последствия на белковую последовательность
p.Ile343Ile: Синонимичный вариант, не меняющий аминокислоту (в данном случае, изолейцин на позиции 343).
p.Gly12Asp: Несинонимичная замена аминокислоты, где глицин заменяется на аспарагиновую кислоту.
p.Tyr34*: Стоп-кодон в позиции 34, прерывающий трансляцию.
p.Val45fs: Смещение рамки считывания (frameshift) на 45-й позиции, меняющий весь последующий белок.


### 4. SNP stats per regions

