# vim: syntax=python expandtab
# Simple Snakemake example

# SETTINGS
INPUT_DIR = "input"
MPA3_DBPATH = "/db/metaphlan3"


# Adjust the glob pattern to fit your input file names
SAMPLES = glob_wildcards(f"{INPUT_DIR}/{{sample}}_1.fq.gz").sample
print("Found the following samples:")
print(SAMPLES)


rule all:
    input:
        "output/metaphlan3/merged_abundance_table.txt"


rule download_mpa3_db:
    """
    Download MetaPhlAn3 database if it doesn't already exist.
    """
    output:
        bt2_db=f"{MPA3_DBPATH}/mpa_v30_CHOCOPhlAn_201901.1.bt2",
    log:
        stderr="output/logs/metaphlan3/download_db.stderr",
        stdout="output/logs/metaphlan3/download_db.stdout",
    threads:
        8
    conda:
        "envs/conda.yaml"
    shell:
        """
        metaphlan \
            --install \
            --index mpa_v30_CHOCOPhlAn_201901 \
            --bowtie2db db/mpa3 \
            --nproc {threads} \
            2> {log.stderr} \
            > {log.stdout}
        """


rule metaphlan3:
    """
    Create metaphlan3 profile for each sample
    """
    input:
        db=rules.download_mpa3_db.output.bt2_db,
        read1=f"{INPUT_DIR}/{{sample}}_1.fq.gz",
        read2=f"{INPUT_DIR}/{{sample}}_2.fq.gz",
    output:
        bt2out="output/metaphlan3/{sample}.bowtie2.bz2",
        profile="output/metaphlan3/{sample}.mpa_profile.txt",
    log:
        stderr="output/logs/metaphlan3/{sample}.stderr",
        stdout="output/logs/metaphlan3/{sample}.stdout",
    threads:
        8
    conda:
        "envs/conda.yaml"
    params: 
        dbpath=MPA3_DBPATH,
    shell:
        """
        metaphlan \
            {input.read1},{input.read2} \
	        --bowtie2out {output.bt2out} \
            -o {output.profile} \
            --bowtie2db {params.dbpath} \
	        --input_type fastq \
            --nproc {threads} \
            2> {log.stderr} \
            > {log.stdout}
        """


rule merge_metaphlan_tables:
    """
    Merge all sample profiles into one large table.
    """
    input:
        profiles=expand("output/metaphlan3/{sample}.mpa_profile.txt", sample=SAMPLES),
    output:
        merged="output/metaphlan3/merged_abundance_table.txt",
    log:
        stderr="output/logs/metaphlan3/merge_tables.stderr",
    threads:
        1
    conda:
        "envs/conda.yaml"
    shell:
        """
        merge_metaphlan_tables.py \
            {input.profiles} \
            > {output.merged} \
            2> {log.stderr} \
        """
