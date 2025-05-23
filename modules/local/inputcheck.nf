def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

workflow INPUT_CHECK {
    main:
    if(hasExtension(params.input, "csv")){
        ch_input_rows = Channel
            .from(file(params.input))
            .splitCsv(header:true)
            .map { row -> 
                if(row.size()==2) {
                    def id = row.sample
                    def fasta_file = row.fasta ? file(row.fasta, checkiFExists: true): false
 
                    // if (!fasta_file) {
                    //     exit 1, "Invalid input samplesheet: fasta file must be specified."
                    // }
 
                    // if (!hasExtension(fasta_file, ".fasta")) {
                    //     exit 1, "Invalid input samplesheet: The fasta_file column must end with .fasta."
                    // }
 
                    return [meta, fasta]
                } //else {
            //         exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 2."
            //     }  
            // }
 
        ch_fasta_file = ch_input_rows
            .map { id, fasta_file->
                def meta = [:]
                meta.id = id
                return [meta, fasta_file]
            }
    } //else {
    //     exit 1, "Input file must be a CSV."
    // }
 
// Ensure sample IDs are unique
    ch_input_rows
        .map { id, fasta_file-> id }
        .toList()
        .map { ids -> if (ids.size() != ids.unique().size()) { exit 1, "ERROR: input samplesheet contains duplicated sample IDs!" } }
 
    emit:
    fasta_files= ch_fasta_file
}

}
