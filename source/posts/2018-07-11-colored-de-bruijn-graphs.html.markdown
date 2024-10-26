---
title: "Colored de Bruijn Graphs"
date: 2018-07-11
tags: "BIOINFORMATICS"
---

I have really wanted to write this post for a long time, but seem to only now
get around to it. For more than a year now my research in the
[Computational Sciences Lab (CSL)](http://bioresearch.byu.edu/) at [Brigham Young University (BYU)](https://byu.edu) we have been
researching various applications of the Colored de Bruijn Graph (CdBG). It all
started when we explored some novel phylogenetic reconstruction methods in the
CS 601R class during Winter semester 2017. We (or at least, I) kept being drawn
back to CdBG's and their potential for phylogeny reconstruction. Here are some
of the things that I have learned along the way!


## Related Work {#related-work}

As with most scientific endeavors, this project certainly stands on the
shoulders of giants. Some of these giants include the following papers and their
respective authors. I think that they have done amazing work and I admire their
methods.

-   [De novo assembly and genotyping of variants using colored de Bruijn graphs](http://dx.doi.org/10.1038/ng.1028)
    :: Zamin Iqbal et al.'s original paper introducing the CdBG's application to
    Bioinformatics. Even though their implementation isn't very efficient, it
    established the usefulness of the data structure in the Bioinformatic
    community.
-   [TwoPaCo: an efficient algorithm to build the compacted de Bruijn graph from
    many complete genomes](http://dx.doi.org/10.1093/bioinformatics/btw609) :: Ilia Minkin et al.'s work on discovering bubbles
    within the CdBG structure, which influenced our thinking and guided our
    work.
-   [An assembly and alignment-free method of phylogeny reconstruction from
    next-generation sequencing data](http://dx.doi.org/10.1186/s12864-015-1647-5) :: Huan Fan et al.'s application of a
    fantastic distance based phylogenetic tree reconstruction algorithm that I
    have found to be very accurate (and talk about fast). I love the simplicity
    of their model of evolution (based on the [Jaccard Index](https://en.wikipedia.org/wiki/Jaccard%5Findex)), I find that it is
    very elegant.


## Motivation {#motivation}

We want to use the CdBG to reconstruct phylogenetic trees because it is very
efficient computationally. The CdBG can be constructed in \\(O(n)\\) time and space
and it can utilize whole genome sequences, which is a shortcoming of many of the
traditional phylogenetic tree reconstruction algorithms.

Furthermore, we also figured that the CdBG contains more information than many
of the kmer counting methods, and if they can perform so well then the CdBG will
only be able to perform better because it not only stored the kmers (as nodes in
the graph), but it also stores the context in which those kmers occur (as edges
where \\(k - 1\\) basepairs overlap on either end of the kmer).


## Our Contribution {#our-contribution}


### `kleuren` {#kleuren}

In order to prove our hypothesis, we did what every self-respecting Computer
Scientist would do, we wrote a program to figure out if it worked. We call our
program [`kleuren`](https://github.com/Colelyman/kleuren), which is Dutch for "colors" (referring to the colors in the
CdBG).

`kleuren` works by finding _bubble_ regions of the CdBG. A bubble is defined as
a subgraph of the CdBG that consists of a start and end node that are present in
\\(n\\) or more colors, and there are multiple paths connecting the start node to
the end node; where \\(n\\) is a given parameter and is no greater than the total
number of colors in the CdBG and a path is simply a traversal from one node to
another.

After the bubbles are found, they are aligned through Multiple Sequence
Alignment (MSA) via [MAFFT](https://mafft.cbrc.jp/alignment/software/) and then each MSA block is concatenated to form a
supermatrix. The supermatrix is then fed into a Maximum-Likelihood program
([IQ-TREE](http://www.iqtree.org/)) to reconstruct the phylogenetic tree of the taxa.


### How Bubbles are Found {#how-bubbles-are-found}

`kleuren` uses fairly simple and straightforward algorithms to find
the bubbles, which is broken up into two steps: Finding the End Node
and Extending the Paths.


#### Finding the End Node {#finding-the-end-node}

`kleuren` iterates over the super-set (the union of all kmers from all
taxa) as potential start nodes (in a dBG the nodes are kmers, thus
\\(node == kmer\\)). Given a kmer, it is queried in the CdBG and the number
of taxa (or colors, thus \\(taxon == color\\)) is calculated to determine if
the number of colors for that kmer, \\(c\\), is greater than or equal to \\(n\\),
where \\(n\\) is a parameter provided by the user.

If \\(c \geq n\\) then the node is a valid start node and a breadth-first
search is performed starting from this node until another node is
found where the number of colors that it contains is greater than or
equal to \\(n\\), which then becomes the end node.


#### Extending the Paths {#extending-the-paths}

After an end node is discovered, the sequence of each path between the
start and end nodes must be calculated. In order to discover a path in
a dBG, one must _collapse_ edges by appending the last nucleotide of
the next node to the previous node's sequence. For example, if a node
is `ACT -> CTG`, then the collapsed sequence will turn out to be
`ACTG`.

This is implemented as at most \\(c\\) depth-first searches, where \\(c\\) is
the number of colors. The number of depth-first searches decreases as
the number of paths with shared colors increases.


## Further Reading {#further-reading}

If you are interested in the details of our algorithm and would like to see some
results, please check out our paper [Whole Genome Phylogenetic Tree
Reconstruction Using Colored de Bruijn Graphs](https://ieeexplore.ieee.org/document/8251300/) ([preprint](https://arxiv.org/abs/1709.00164)). We are currently
working on extending `kleuren` to improve its efficiency.
