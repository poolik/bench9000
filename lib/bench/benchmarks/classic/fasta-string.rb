# Copyright © 2004-2008 Brent Fulgham, 2005-2015 Isaac Gouy
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#   * Neither the name of "The Computer Language Benchmarks Game" nor the name
#     of "The Computer Language Shootout Benchmarks" nor the names of its
#     contributors may be used to endorse or promote products derived from this
#     software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# The Computer Language Benchmarks Game

# http://benchmarksgame.alioth.debian.org/

# Contributed by Sokolov Yura

# Modified by Joseph LaFata

# http://benchmarksgame.alioth.debian.org/u32/program.php?test=fasta&lang=yarv&id=2

ALU =
   "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG"+
   "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA"+
   "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT"+
   "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA"+
   "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG"+
   "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC"+
   "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"

def make_repeat_fasta(src, n)
    l = src.length
    s = src * ((n / l) + 1)
    s.slice!(n, l)
    output = ''
    0.step(s.length-1,60) {|x| output << s[x,60]; output << "\n"}
    output
end

def harness_input
  100_000_000
end

def harness_sample(input)
  make_repeat_fasta(ALU, input)
end

def harness_verify(output)
  output.length == 101666667
end

require 'bench/harness'
