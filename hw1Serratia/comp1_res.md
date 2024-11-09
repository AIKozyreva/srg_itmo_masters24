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

1. Alignment
```
minimap2 -map-ont -a -o comp1_alignment.sam Ref_Serratia_rubidaea_dataset/GCF_016026735.1/Ref_GCF_016026735.1_ASM1602673v1_genomic.fna Serratia_rubidaea_strain2_dataset/GCF_900638005.1/rubi2_GCF_900638005.1_53550_B01_genomic.fna
```
```
samtools view -b comp1_res/comp1_alignment.sam -o comp1_res/comp1_algn.bam
samtools sort -o comp1_res/comp1_algn_sort.bam  comp1_res/comp1_algn.bam
samtools flagstats comp1_res/comp1_algn_sort.bam
```
![image](https://github.com/user-attachments/assets/14de4b45-fc0a-4e9e-9bbf-ce7d8a0a6d2e)

2. creating VCF (snp calling)

```
bcftools mpileup -Ou -f ../Ref_Serratia_rubidaea_dataset/GCF_016026735.1/Ref_GCF_016026735.1_ASM1602673v1_genomic.fna comp1_algn_sort.bam | bcftools call -mv -Ov --ploidy 1 -o ./comp1_variants.vcf
```

3. SNP annotation



4. SNP stats per regions

