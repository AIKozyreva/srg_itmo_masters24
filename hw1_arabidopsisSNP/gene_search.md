We will analyse the AT2G28210 (ACA2) gene, which is alpha carbonic anhydrase 2 coding. Other names aare: alpha carbonic anhydrase 2, ATACA2, T3B23.12, T3B23_12.

Information about gene was found in ensembl.plants 
Gene page is: https://plants.ensembl.org/Arabidopsis_thaliana/Gene/Summary?g=AT2G28210;r=2:12029666-12033096;t=AT2G28210.1;db=core 

Throuh this page we will find out placement of this gene in ref genome. It is on the 2 chromosome. `Chromosome 2: 12,029,666-12,033,096 forward strand.`
Nice, we also can see it on the screenshot below. 
![image](https://github.com/user-attachments/assets/3e97023b-b782-49b9-b47b-15e88ca63b0f)

Traanscript looks like below and consists of `Exons: 7, Coding exons: 7, Transcript length: 1,303 bps` 
![image](https://github.com/user-attachments/assets/5f710b01-ef57-4cc7-84c6-0b2c9aff0cea)

Okay, that means i can extract from the reference assembly only Chr 2 data, align my assembly on this ref Chr 2, only for aligned data perform more accurate analysis. (because i don't want to parse such large gff as the whole ref gff, whatfor??)

Let's extract Chromosome 2 from ref fasta. Firstly let's chech ref.fasta headers, they have to be alright as it's ncbi refseq data for one of the most common model organism among the plants.
![image](https://github.com/user-attachments/assets/44b221b3-f3d9-4d2d-ac62-9193f68a7ac3)
nice, let's extract chr2 data into new file Chr2_ref.fna
```
sed -n '/^>NC_003071.7/,/^>/p' файл.fasta | sed '$d' > Chr2_ref.fna
```

BUT, there was another way to make a visualization through IGV web, after _indexing by samtools_ ref files andf results of alignment whole sample genome against the whole ref genome by _minimap2_ to make an visualization, with is, by the way, uncapable to say somewthing helpful and for me extremely unpleasant, (спасибо дура так сказать), but it's the option to see snp and misassemlies of all sorts.

```
minimap2 -t 16 -a ./ref.fna ./GCA_024498455.1.fna | samtools view -bS | samtools sort -o GCA_024498455.1_sorted.bam; samtools index GCA_024498455.1_sorted.bam
samtools faidx ./191024_compare_genomics_hw/ref.fna
```

![image](https://github.com/user-attachments/assets/317f5834-312b-46d9-9651-897922958523)
