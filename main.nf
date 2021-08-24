//reads: 's3://nextflow-tower-sixing-asset/raw/*_R{1,2}.f*q.gz'
//nextflow run main.nf --reads '/home/sih13/Downloads/fastq/*_R{1,2}.f*q.gz'

params.threads = 16
params.reads = "$baseDir/data/*_R{1,2}.f*q.gz"
params.outdir = 'results'

println "BINNING   PIPELINE    "
println "================================="
println "reads              : ${params.reads}"

Channel.fromFilePairs(params.reads, checkIfExists: true).set{ read_pairs }  //read_pairs.view()

process fastp {

    publishDir params.outdir, mode: 'copy' 

    container "dgg32/fastp"

    input:
    tuple sample_id, file(reads) from read_pairs

    output:
    tuple sample_id, file('*.fastq.gz') into fastp_out_ch

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} \
    -o ${sample_id}_trim_R1.fastq.gz -O ${sample_id}_trim_R2.fastq.gz \
    --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -g --detect_adapter_for_pe -l 100 -w ${params.threads}
    """
}


