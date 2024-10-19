For sample file we have performed quast and busco asessment of genome assembly quality and fullness. Files are in the folder. 

#### Quast
```
quast.py -o ./191024_compare_genomics_hw/quast_res -r ./191024_compare_genomics_hw/ref.fna -g ./191024_compare_genomics_hw/ref.gff -t 80 --eukaryote --large ./191024_compare_genomics_hw/GCA_024498455.1.fna
```

First of all amount of contigs, as well as their sizes and general size, looks alike ref one, so that's nice. 

![image](https://github.com/user-attachments/assets/09cb587c-5210-4c23-82fb-95d12c85bf8c)

There are a lot of missasemblies. They possibly marked in the reverse placement of sample-assembly (because these misasemblies one by one in the genome) in comparision with ref one. Or these can be rearrangement or duplicated sequences, due to plants assembly problems and special features.  

![image](https://github.com/user-attachments/assets/ecc1c1ae-14a4-43b6-859a-49b2a8074b11)

Забавно, что на митохондриальной хромосоме и в хлоропласте почти нет изменений, и все перестройки и дупликации происходят только в геномке. и в нашем случае это релокации.
![image](https://github.com/user-attachments/assets/c2afa60c-ce1d-4121-a119-b48bd4f38dc1)
![image](https://github.com/user-attachments/assets/8a70b664-bca1-4769-8286-c2d511f6f27e)

But  it isn't seem to be any untrimmed seqs, so i won't do anything with this data, and just try to make all possible for myself analysis. 

#### Busco 
```

```
