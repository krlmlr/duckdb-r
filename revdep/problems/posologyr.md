# posologyr (1.2.8)

* GitHub: <https://github.com/levenc/posologyr>
* Email: <mailto:cyril.leven@chu-brest.fr>
* GitHub mirror: <https://github.com/cran/posologyr>

Run `revdepcheck::revdep_details(, "posologyr")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
       Running ‘testthat.R’
     Running the tests in ‘tests/testthat.R’ failed.
     Complete output:
       > library(rxode2)
       rxode2 5.1.7.1 using 2 threads (see ?getRxThreads)
         no cache: create with `rxCreateCache()`
       > library(posologyr)
       > library(testthat)
       > setRxThreads(2L) #for CRAN, following the advice of mattfidler
       > 
       > test_check("posologyr")
       malloc(): unsorted double linked list corrupted
       Aborted (core dumped)
     ```

