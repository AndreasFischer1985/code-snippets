##########################################################
# Title: How to build graphs and subgraphs using networkx
# Author: Dr. Andreas Fischer
# Date: 9.7.2024
##########################################################

import networkx as nx
import matplotlib.pyplot as plt


# Create a Directed Graph (DiGraph):
#-----------------------------------

DG=nx.DiGraph()
DG.add_nodes_from([1,2,3,4,5])
DG.add_edges_from([(1,2),(2,3),(3,4),(2,3),(2,5),(3,5)])


# Determine nodes that can be reached with no more than 2 hops:
#--------------------------------------------------------------

path_lengths=nx.single_source_shortest_path_length(DG, source=1, cutoff=2)
#{1: 0, 2: 1, 3: 2, 5: 2}
nodes_within_2_hops=[node for node, length in path_lengths.items() if length <=2]
#[1, 2, 3, 5]


# Create subgraph based on these nodes:
#--------------------------------------

#connected_nodes=[1]+list(nx.neighbors(DG,1))
connected_nodes=nodes_within_2_hops
connected_nodes
subgraph=nx.DiGraph()
for node in connected_nodes:
  subgraph.add_node(node)

for node in connected_nodes:
  for neighbor in connected_nodes:
    if node != neighbor and DG.has_edge(node,neighbor):
      subgraph.add_edge(node,neighbor)


# Inspect results:
#-----------------

DG.nodes()
DG.edges()
subgraph.nodes()
subgraph.edges()

nx.draw(subgraph, with_labels=True)
plt.draw()
plt.savefig("networkx_sugraph.png")

#import pydot
#nx.nx_pydot.to_pydot(subgraph)

