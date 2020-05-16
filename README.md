# HashLink vs HashLink/C vs native benchmark

I wrote a benchmark to compare the performance of the Haxe HashLink VM vs HashLink converted to C vs a native C/C++ HashLink extension.

The benchmark generates 128 times a 1024x1024 OpenSimplex noise map. The original source code was written in Java, and can be found [here](https://gist.github.com/KdotJPG/b1270127455a94ac5d19). It has been ported to Haxe and C/C++.

Here are the results of the benchmark (ran on a laptop i7-7500U with 16GB, HashLink 1.11.0):

|| Time (seconds) | Relative time |
| --- | --- | --- |
| Native | 3.88 | 1.00 |
| HashLink/C | 5.91 | 1.52 |
| HashLink | 16.76 | 4.32 |
| Native Debug | 48.16 | 12.41 |

(Note that the timings can vary a little bit between tests and these numbers are averaged values)

