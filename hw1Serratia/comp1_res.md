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

КАПЕЦ, оказывается snpEff выдаёт три файла. кроме основного 'annotated_comp1_variants.vcf' ещё файлы 'snpeff_genes.txt', 'snpEff_summary.html'. Что-то на полезном.
![image](https://github.com/user-attachments/assets/79442f4a-1e03-472e-9502-5c3d79ef2973)
![image](https://github.com/user-attachments/assets/329e7d3a-47d2-4f8f-abf7-e0e34df445c7)
**если что, кличество эффектов > чем самих снп, потому что напоминаю, что на один снп может приходиться много аннотаций, там сверху в хтмл есть запись, что у меня самих аннотаций 912 тысяч, а снп 81 тысяча. это норм. 
Вот это полезная штука, предполагаю что это можно использовать при подборе эволюционных моделей, когда хотите выстроить какую-то картину эволюционных отношений между оргнизмами. или увидеть какой-то сдвиг странный. 

![image](https://github.com/user-attachments/assets/2e58daed-b1b8-4f64-a3c9-34c5f4d05a94)


### 4. SNP stats per regions

Так, возвращаемся к пониманию, что я сделала. У меня был файл выравнивания .bam. Сейчас я хочу для своих целей из него достать две вещи 1) координаты выравниваний 2) координаты гэпов. Потому я хочу попробовать соеденить мою gff аннотацию референса с этими двумя .bed и посмотреть, на какие гены приходятся гэпы. Потом я достану из .bed в котором данные о выровненных участках только координаты тех генов, которые мне нужны (несколько групп), и достану из аннотирванного vcf файла только записи, относящиеся к этим координатам. Полученные записи можно валидировать другим способом их нахождения: можно извлечь из гфф все названия генов и транскриптов, которые относятся к интересующим меня генам, и потом уже из файла 'snpeff_genes.txt' достать хиты, относящиеся тоько к этой позиции. По числам (надеюсь) должно сойтись. Но будем честны, если мне хватит усердия сегодня ъоть на одно - это уже чудо.

```
bedtools bamtobed -i comp1_algn_sort.bam > aligned_regions.bed
bedmap --echo --echo-map-size aligned_regions.bed > aligned_regions_len.bed
bedtools genomecov -ibam comp1_algn_sort.bam -bga | grep -w '0$' > comp1_aln_gap.bed
bedmap --echo --echo-map-size comp1_aln_gap.bed > comp1_gaps_len.bed
```
ехехехехее, побэда. файл с гэпами и файл с выравниваниями (координатами). 

![image](https://github.com/user-attachments/assets/d23d9bd6-556a-4e20-84d1-4d7f3152b49c)
![image](https://github.com/user-attachments/assets/7ea7c371-b942-41f5-be96-e9546c702329)

Я так поняла, что в целом утилита bedtools+bedops - это мощь. Потому что они видимо цитают все наиболее используемые форматы с координатами, и можно оперировать любыми операциями характерными для множеств. типа пересечения, сочетания и вычитания, относительно любого из множдеств. Это мощно. 
Происходит попытка накинуть гфф на файлы bed - неудачная спойлер. 
```
bedtools intersect -a aligned_regions_len.bed -b reference.gff -wa -wb > aligned_regions_len_annot.bed 
```
Получим такое: 
![image](https://github.com/user-attachments/assets/118bc884-a156-4319-a4da-8849ab925bcc)

Это не варик, потому что я забыла, что в исходной гфф ещё есть первая запись, относящаяся ко всему региону (последовательности), у которой координата от нуля и до нихера себе (до конца). Поэтому, разумеется, у меня каждое выравнивание будет находиться в пределах рвсего референса, а кроме того ещё в одном или нескольких генах, а ещё для каждого гена н-кодонов, короче писец - это нечитаемо. А у и конечно, у гфф же целая гора стобцов и они все тут вот они слева направо.

короче надо, наверное, сначала гфф отформатировать. очевидно, очевидное. господи пожалуйста дай мне мозгов, опять думать как делить, тут мои полномоция всё, чат гпт помоги я не могу уже. Сначала отсекаем строчки, которые не CDS из гфф файла, потом выкидываем колонки. 

```иногда требуется дополнительно передавать разделитель в cut, если он не определяется. носча всё норм. ведь файл не мой а ncbi :)
awk '$3 == "CDS"' GCF_016026735.1_ASM1602673v1_genomic.gff | cut -f1,3,4,5,9 > cds_only.gff
```

Чьорт на вот это `bedtools intersect -a aligned_regions_len.bed -b cds_only.gff -wa -wb > aligned_regions_len_cds.bed` получила ошибку, я её в жизни уже видела, но тогда она меня напугала, а сейчас я не сдамся! я выпила 3 энергетика, конечно, я теперь не сдамся.

![image](https://github.com/user-attachments/assets/822665bf-c806-4d3e-9cd5-b13763bfcf44)

Ладно знгачит, надо переставить колонки. оставляем только формат .bed который прям для бед.
```прикиньте я сама смогла целиком почти сразу правильно придумать преобразование этих полей пробелов табов как же приятно ух, вот это я молодец
awk -F'\t' 'BEGIN {OFS="\t"} $2 == "CDS" {print $1, $3 - 1, $4, $5}' cds_only.gff > cds_only.bed
```
![image](https://github.com/user-attachments/assets/36ee41d1-ac04-41e6-9c3e-c0b96feb2726)

Попытка номер 2 с командой `bedtools intersect -a aligned_regions_len.bed -b cds_only.bed -wa -wb > aligned_regions_len_cds.bed` СРАБОТАЛО!!! а зачем я это делала???
![image](https://github.com/user-attachments/assets/99a7dda0-597a-473d-970c-5d920a208aac)




