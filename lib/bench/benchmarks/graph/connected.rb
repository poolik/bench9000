# Copyright (c) 2015 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

# Exercise Hash and Set (which is also Hash) insertion and lookup performance.
# Creates a graph with an adjacency map. Finds the connected subgraph from a
# root node, using an Array work list and a visited Set.

require 'set'

size = 100_000

class Node
end

nodes = []

size.times do
  nodes << Node.new
end

adjacency = {}

nodes.each do |node|
  adjacency[node] = nodes.sample(3)
end

def connected(adjacency, root_node)
  visited = Set.new
  to_visit = [root_node]

  while node = to_visit.pop
    unless visited.member? node
      visited.add node
      to_visit.concat adjacency[node]
    end
  end

  visited
end

ADJACENCY = adjacency
ROOT_NODE = nodes.sample

def harness_input
  [ADJACENCY, ROOT_NODE]
end

def harness_sample(input)
  adjacency, root_node = input
  connected(adjacency, root_node)
end

def harness_verify(output)
  output.size <= ADJACENCY.size
end

require 'bench/harness'
