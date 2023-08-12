##########################################################################
# Title:  Plots a directed knowledge graph with labelled nodes and edges
# Author: Andreas Fischer
# Date:   August 12th, 2023
##########################################################################


#***********************
# Variant 1: Graphviz
#***********************

import graphviz
f = graphviz.Digraph(filename = "graphviz_graph.gv")
names = ["A","B","C","D","E","F","G","H"]
positions = ['IT-Ökonom/in\nAusbildung','IT-Ökonom/in', 'Informatiker/in\n(Weiterbildung)', 'Wirtschafts-\ninformatiker/in\n- IT-Systeme','Wirtschafts-\ninformatik\n(grundständig)', 'Informatik\n(grundständig)' ]
colors = ['red','green','red','red','blue','blue']
for name, position, color in zip(names, positions,colors): 
  f.node(name, position, color=color, style = "filled")

f.edge("A","B",label=" QualifiesFor",fontsize="8"); 
f.edge("B","C",label=" QualifiesFor",fontsize="8"); f.edge("B","D",label=" QualifiesFor",fontsize="8"); f.edge("B","E",label=" QualifiesFor",fontsize="8"); f.edge("B","F",label=" QualifiesFor",fontsize="8")
f.view()


#***********************
# Variant 2: NetworkX
#***********************

import networkx as nx
import matplotlib.pyplot as plt
from networkx.drawing.nx_pydot import graphviz_layout
plt.figure(figsize=(6, 6))
n1=["IT-Ökonom/in\nAusbildung", "IT-Ökonom/in",                             "IT-Ökonom/in",               "IT-Ökonom/in",                     "IT-Ökonom/in"]
n2=["IT-Ökonom/in",             "Wirtschafts-\ninformatik\n(grundständig)", "Informatik\n(grundständig)", "Informatiker/in\n(Weiterbildung)", "Wirtschafts-\ninformatiker/in\n- IT-Systeme"]
r1=["QualifiesFor",             "QualifiesFor",                             "QualifiesFor",               "QualifiesFor",                     "QualifiesFor"]
nodes = list(set(n1+n2))
nodes.sort()
print(nodes)
col=["green","red","blue","red","blue","red"] # colors of nodes
G = nx.DiGraph(arrows=True) #nx.Graph()
G.add_nodes_from(nodes)
edges = zip(n1, n2)
G.add_edges_from(edges)
pos = graphviz_layout(G, prog="dot") # 'neato', 'dot', 'twopi', 'fdp', 'sfdp', 'circo'
nx.draw(G, pos=pos, with_labels=True, font_size=9, edgelist=[], node_color="none", bbox=dict(facecolor="white", edgecolor='black', boxstyle='round,pad=0.2', alpha=.7))  
nx.draw_networkx_nodes(G, pos, node_size=6000, node_color=col, alpha=.8)
nx.draw_networkx_edges(G, pos, node_size=6000, arrows=True, arrowsize=20, alpha=1)
#nx.draw_networkx_labels(G, pos, labels={n: n for n in G})
nx.draw_networkx_edge_labels(G, pos, edge_labels=dict([((n1[i], n2[i]), r1[i]) for i in range(0,len(G.edges))]), font_size=7)
plt.margins(.2)
plt.draw() 
plt.savefig('networkx_graph.png')
plt.savefig('networkx_graph.pdf')
plt.show()


