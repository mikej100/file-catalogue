 #!/bin/bash
 #
 # Script to find all fastq files in the higgslab project and print their details to a file named higgs_fastq3.

stage="prod"

if [ "$stage" = "test" ]; then
    base_dir="/project/higgslab/mjenning/proj"
    out_dir="../../workspace/test/raw_output"
    echo "Running in test stage"

elif [ "$stage" = "prod" ]; then
    base_dir="/project/higgslab"
    out_dir="../../workspace/prod/raw_output"
    echo "Running in prod stage"
fi

mkdir -p "$out_dir"
find  $base_dir -type f,l -iregex '.*fastq.*' -fprintf "$out_dir/fastq.txt" '%T+\t%p\t%l\t%s\t%y\n' 
find  $base_dir -type f,l -iregex '.*\.sam\.' -fprintf "$out_dir/sam_details.txt" '%T+\t%p\t%l\t%s\t%y\n' 
find  $base_dir -type f,l -iregex '.*\.bam$' -fprintf "$out_dir/bam_details.txt" '%T+\t%p\t%l\t%s\t%y\n' 
find  $base_dir -type f,l -iregex '.*\.(bw|bed)$' -fprintf "$out_dir/bw_bed_details.txt" '%T+\t%p\t%l\t%s\t%y\n' 

