# Rduckhts (2.0.0.0.1.9)

* GitHub: <https://github.com/RGenomicsETL/duckhts>
* Email: <mailto:sounkoutoure@gmail.com>
* GitHub mirror: <https://github.com/cran/Rduckhts>

Run `revdepcheck::revdep_details(, "Rduckhts")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       
       test_bcf.R....................  258 tests OK [E::bgzf_read_block] Invalid BGZF header at offset 447
       [E::bgzf_read] Read block operation failed with error 2 after 0 of 32 bytes
       Error: rapi_execute: Invalid Input Error: read_bcf: failed to read or parse BCF/VCF record (error_type: INVALID_INPUT)
       Execution halted
     ```

## In both

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

