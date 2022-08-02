# erroring when no S2

    Code
      spatial_block_cv(ames_sf)
    Condition
      Error in `spatial_block_cv()`:
      ! `spatial_block_cv()` can only process geographic coordinates when using the s2 geometry library.
      i Reproject your data into a projected coordinate reference system using `sf::st_transform()`.
      i Or install the `s2` package and enable it using `sf::sf_use_s2(TRUE)`.

# systematic assignment -- snake

    Code
      boston_snake
    Output
      #  10-fold spatial block cross-validation 
      # A tibble: 10 x 2
         splits            id    
         <list>            <chr> 
       1 <split [662/20]>  Fold01
       2 <split [617/65]>  Fold02
       3 <split [604/78]>  Fold03
       4 <split [595/87]>  Fold04
       5 <split [581/101]> Fold05
       6 <split [577/105]> Fold06
       7 <split [603/79]>  Fold07
       8 <split [614/68]>  Fold08
       9 <split [630/52]>  Fold09
      10 <split [655/27]>  Fold10

---

    Code
      as.integer(boston_snake$splits[[1]])
    Output
        [1]   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18
       [19]  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36
       [37]  37  38  39  40  41  42  43  44  45  46  47  48  49  50  51  52  53  54
       [55]  55  56  57  58  59  60  62  63  64  65  66  67  68  69  70  71  72  73
       [73]  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88  89  91  93
       [91]  94  95  96  97  98  99 100 101 102 103 104 106 107 108 109 110 112 113
      [109] 114 115 116 117 118 119 120 122 123 124 125 126 127 128 129 130 131 132
      [127] 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150
      [145] 151 152 153 154 155 156 157 158 160 161 162 163 164 165 166 167 168 169
      [163] 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187
      [181] 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205
      [199] 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223
      [217] 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241
      [235] 242 244 245 246 247 248 249 250 251 252 253 254 255 257 258 259 260 261
      [253] 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279
      [271] 280 281 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297
      [289] 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315
      [307] 316 317 318 319 321 322 324 325 326 327 328 329 330 331 332 333 334 335
      [325] 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353
      [343] 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371
      [361] 372 373 374 375 376 377 378 379 380 381 382 383 384 385 386 387 388 390
      [379] 391 392 393 395 396 397 398 399 400 401 402 403 404 405 406 407 408 409
      [397] 410 412 413 414 415 416 417 418 419 420 421 422 424 425 426 427 428 430
      [415] 431 432 433 434 435 436 437 438 439 440 441 442 443 444 445 446 447 448
      [433] 449 450 451 452 453 454 455 457 458 459 460 461 462 463 465 466 467 468
      [451] 469 470 471 472 473 474 475 476 477 478 479 480 481 482 483 484 485 486
      [469] 487 488 489 490 491 492 493 494 495 496 497 498 499 500 501 502 503 504
      [487] 505 506 507 508 509 510 511 512 513 514 515 516 517 518 519 520 521 522
      [505] 523 524 525 526 527 528 529 530 531 532 533 534 535 536 537 538 539 540
      [523] 541 542 543 544 545 546 547 548 549 550 551 552 553 554 555 556 557 558
      [541] 559 560 561 562 563 564 565 566 567 568 569 570 571 572 573 574 575 576
      [559] 577 578 579 580 581 582 583 584 585 586 587 588 590 591 592 593 594 595
      [577] 596 597 598 599 600 601 602 603 604 605 606 607 608 609 610 611 612 613
      [595] 614 615 616 617 618 619 620 621 622 623 624 625 626 627 628 629 630 631
      [613] 632 633 634 635 636 637 638 639 640 641 642 643 644 645 646 647 648 649
      [631] 650 651 652 653 654 655 656 657 658 659 660 661 662 663 664 665 666 667
      [649] 668 670 671 672 673 674 675 676 677 678 679 680 681 682

# bad args

    Code
      spatial_block_cv(ames)
    Condition
      Error in `spatial_block_cv()`:
      ! `spatial_block_cv()` currently only supports `sf` objects.
      i Try converting `data` to an `sf` object via `sf::st_as_sf()`.

---

    Code
      spatial_block_cv(ames_sf, v = c(5, 10))
    Condition
      Error in `spatial_block_cv()`:
      ! `v` must be a single positive integer.

---

    Code
      spatial_block_cv(ames_sf, v = c(5, 10), method = "snake")
    Condition
      Error in `spatial_block_cv()`:
      ! `v` must be a single positive integer.

---

    Code
      spatial_block_cv(ames_sf, method = "snake", relevant_only = FALSE, v = 28)
    Condition
      Warning:
      Not all folds contained blocks with data:
      x 28 folds were requested, but only 27 contain any data.
      x Empty folds were dropped.
      i To avoid this, set `relevant_only = TRUE`.
    Output
      #  27-fold spatial block cross-validation 
      # A tibble: 27 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2790/140]> Fold01
       2 <split [2726/204]> Fold02
       3 <split [2820/110]> Fold03
       4 <split [2877/53]>  Fold04
       5 <split [2851/79]>  Fold05
       6 <split [2877/53]>  Fold06
       7 <split [2886/44]>  Fold07
       8 <split [2736/194]> Fold08
       9 <split [2919/11]>  Fold09
      10 <split [2855/75]>  Fold10
      # ... with 17 more rows
      # i Use `print(n = ...)` to see more rows

---

    Code
      spatial_block_cv(ames_sf, method = "snake", v = 60)
    Condition
      Warning in `spatial_block_cv()`:
      Fewer than 60 blocks available for sampling
      i Setting `v` to 54
    Output
      #  54-fold spatial block cross-validation 
      # A tibble: 54 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2917/13]>  Fold01
       2 <split [2818/112]> Fold02
       3 <split [2926/4]>   Fold03
       4 <split [2929/1]>   Fold04
       5 <split [2896/34]>  Fold05
       6 <split [2905/25]>  Fold06
       7 <split [2900/30]>  Fold07
       8 <split [2928/2]>   Fold08
       9 <split [2929/1]>   Fold09
      10 <split [2923/7]>   Fold10
      # ... with 44 more rows
      # i Use `print(n = ...)` to see more rows

---

    Code
      spatial_block_cv(sf::st_set_crs(ames_sf, sf::NA_crs_))
    Condition
      Warning in `spatial_block_cv()`:
      `spatial_block_cv()` expects your data to have an appropriate coordinate reference system (CRS).
      i If possible, try setting a CRS using `sf::st_set_crs()`.
      i Otherwise, `spatial_block_cv()` will assume your data is in projected coordinates.
    Output
      #  10-fold spatial block cross-validation 
      # A tibble: 10 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2539/391]> Fold01
       2 <split [2647/283]> Fold02
       3 <split [2653/277]> Fold03
       4 <split [2649/281]> Fold04
       5 <split [2644/286]> Fold05
       6 <split [2626/304]> Fold06
       7 <split [2657/273]> Fold07
       8 <split [2779/151]> Fold08
       9 <split [2389/541]> Fold09
      10 <split [2787/143]> Fold10

---

    Code
      spatial_block_cv(ames_sf, v = 60)
    Condition
      Warning in `spatial_block_cv()`:
      Fewer than 60 blocks available for sampling
      i Setting `v` to 54
    Output
      #  54-fold spatial block cross-validation 
      # A tibble: 54 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2745/185]> Fold01
       2 <split [2803/127]> Fold02
       3 <split [2900/30]>  Fold03
       4 <split [2927/3]>   Fold04
       5 <split [2915/15]>  Fold05
       6 <split [2918/12]>  Fold06
       7 <split [2887/43]>  Fold07
       8 <split [2854/76]>  Fold08
       9 <split [2927/3]>   Fold09
      10 <split [2870/60]>  Fold10
      # ... with 44 more rows
      # i Use `print(n = ...)` to see more rows

---

    Code
      spatial_block_cv(boston_canopy, n = 200)
    Message
      Only 1.7% of blocks contain any data
      i Check that your block sizes make sense for your data
    Output
      #  10-fold spatial block cross-validation 
      # A tibble: 10 x 2
         splits           id    
         <list>           <chr> 
       1 <split [613/69]> Fold01
       2 <split [613/69]> Fold02
       3 <split [614/68]> Fold03
       4 <split [614/68]> Fold04
       5 <split [614/68]> Fold05
       6 <split [614/68]> Fold06
       7 <split [614/68]> Fold07
       8 <split [614/68]> Fold08
       9 <split [614/68]> Fold09
      10 <split [614/68]> Fold10

# printing

    #  10-fold spatial block cross-validation 
    # A tibble: 10 x 2
       splits             id    
       <list>             <chr> 
     1 <split [2524/406]> Fold01
     2 <split [2656/274]> Fold02
     3 <split [2476/454]> Fold03
     4 <split [2771/159]> Fold04
     5 <split [2607/323]> Fold05
     6 <split [2762/168]> Fold06
     7 <split [2718/212]> Fold07
     8 <split [2665/265]> Fold08
     9 <split [2642/288]> Fold09
    10 <split [2549/381]> Fold10

