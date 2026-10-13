# mfdb (7.4-0)

* Email: <mailto:lentinj@shuttlethread.com>
* GitHub mirror: <https://github.com/cran/mfdb>

Run `revdepcheck::revdep_details(, "mfdb")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
     2026-10-13 18:26:29.878779 INFO:mfdb:Dumping table stomach_state
     2026-10-13 18:26:29.879901 INFO:mfdb:Dumping table digestion_stage
     2026-10-13 18:26:29.880957 INFO:mfdb:Dumping table sampling_type
     2026-10-13 18:26:29.881876 INFO:mfdb:Dumping table population
     2026-10-13 18:26:29.882754 INFO:mfdb:Dumping table data_source
     2026-10-13 18:26:29.883627 INFO:mfdb:Dumping table index_type
     2026-10-13 18:26:29.884587 INFO:mfdb:Dumping table port
     2026-10-13 18:26:29.885443 INFO:mfdb:Dumping table trip
     2026-10-13 18:26:29.886366 INFO:mfdb:Dumping table tow
     2026-10-13 18:26:29.887325 INFO:mfdb:Dumping table vessel
     2026-10-13 18:26:29.888179 INFO:mfdb:Dumping table case_study
     2026-10-13 18:26:29.889163 INFO:mfdb:Dumping table survey_index
     2026-10-13 18:26:29.890017 INFO:mfdb:Dumping table division
     2026-10-13 18:26:29.890825 INFO:mfdb:Dumping table sample
     2026-10-13 18:26:29.891778 INFO:mfdb:Dumping table predator
     2026-10-13 18:26:29.892663 INFO:mfdb:Dumping table prey
     > mfdb_cs_restore(mdb_in, dump_path)
     2026-10-13 18:26:30.104165 INFO:mfdb:Restoring table institute
     2026-10-13 18:26:30.166093 WARNING:mfdb:Rolling back transaction...
     Error in .local(conn, name, value, ...) : 
       TransactionContext Error: Current transaction is aborted (please ROLLBACK)
     ℹ Context: rapi_unregister_df
     ℹ Error type: TRANSACTION
     Calls: mfdb_cs_restore -> mfdb_transaction
     Execution halted
     ```

