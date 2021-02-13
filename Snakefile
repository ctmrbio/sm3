# vim: syntax=python expandtab
# Simple Snakemake example


# Adjust the glob pattern to fit your input file names
SAMPLES= glob_wildcards("input/{sample}_1.fq.gz").sample
print("Found the following samples:")
print(SAMPLES)


rule all:
    input:
        expand("output/example_rule/{sample}_1.head.fq.gz", sample=SAMPLES)


rule example_rule:
    """
    Example rule, please modify! 
    This uses BBMap's reformat.sh to extract 2 reads from the input files.
    """
    input:
        read1="input/{sample}_1.fq.gz",
        read2="input/{sample}_2.fq.gz",
    output:
        file1="output/example_rule/{sample}_1.head.fq.gz",
        file2="output/example_rule/{sample}_2.head.fq.gz",
    log:
        stderr="output/logs/example_rule/{sample}.stderr",
        stdout="output/logs/example_rule/{sample}.stdout",
    threads:
        2
    conda:
        "envs/conda.yaml"
    shell:
        """
        reformat.sh \
            in1={input.read1} \
            in2={input.read2} \
            out1={output.file1} \
            out2={output.file2} \
            reads=2 \
            2> {log.stderr} \
            > {log.stdout}
        """
