# irelink (0.0.1)

* GitHub: <https://github.com/christopherkenny/irelink>
* Email: <mailto:ctkenny@proton.me>
* GitHub mirror: <https://github.com/cran/irelink>

Run `revdepcheck::revdep_details(, "irelink")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
         'test-il_count_pairs.R:158:1', 'test-il_estimate.R:236:1',
         'test-il_score_pairs.R:81:1', 'test-il_score_pairs.R:94:1',
         'test-sql-profile.R:83:1', 'test-sql-profile.R:98:1',
         'test-stage6-plan.R:80:1', 'test-stage6-plan.R:87:1',
         'test-stage6-plan.R:98:1', 'test-stage6-plan.R:119:1',
         'test-stage6-plan.R:141:1', 'test-stage6-plan.R:163:1'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-sql-clustering.R:314:3'): SQL best_link with source_dataset matches R tie handling ──
       Expected `unname(sql_map["A"])` to equal `unname(sql_map["C"])`.
       Differences:
       `actual`:   "cluster_A"
       `expected`: "cluster_B"
       
       ── Failure ('test-sql-clustering.R:316:3'): SQL best_link with source_dataset matches R tie handling ──
       Expected `sql_map[c("A", "B", "C")] == sql_map["A"]` to equal `r_map[c("A", "B", "C")] == r_map["A"]`.
       Differences:
       `actual`:   TRUE FALSE FALSE
       `expected`: TRUE FALSE TRUE 
       
       
       [ FAIL 2 | WARN 0 | SKIP 22 | PASS 1155 ]
       Error:
       ! Test failures.
       Execution halted
     ```

