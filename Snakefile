# vim: syntax=python expandtab
# Simple Snakemake example


# Adjust the glob pattern to fit your input file names
SAMPLES = glob_wildcards("input/{sample}_1.fq.gz").sample
print("Found the following samples:")
print(SAMPLES)


rule all:
    input:
        expand("output/example_rule/{sample}.gchist.txt.gz", sample=SAMPLES),


rule example_rule:
    """
    Example rule, please modify!
    This uses BBMap's reformat.sh to extract 5 reads from the input files.
    """
    input:
        read1="input/{sample}_1.fq.gz",
        read2="input/{sample}_2.fq.gz",
    output:
        file1="output/example_rule/{sample}_1.head.fq.gz",
        file2="output/example_rule/{sample}_2.head.fq.gz",
        gchist="output/example_rule/{sample}.gchist.txt",
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
            gchist={output.gchist} \
            threads={threads} \
            reads=5 \
            2> {log.stderr} \
            > {log.stdout}
        """


rule compress_gchist:
    """
    Example rule, please modify!
    This uses gzip to compress its input file.
    """
    input:
        gchist=rules.example_rule.output.gchist,
    output:
        gz="output/example_rule/{sample}.gchist.txt.gz",
    log:
        stderr="output/logs/compress_sam/{sample}.stderr",
    threads:
        2
    conda:
        "envs/conda.yaml"
    shell:
        """
        gzip \
            {input.gchist} \
            2> {log.stderr}
        """
