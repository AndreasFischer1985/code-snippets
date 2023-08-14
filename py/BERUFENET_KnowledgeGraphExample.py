#############################################################################
# Title:  Scrape data and plot a directed knowledge graph based on BERUFENET
# Author: Andreas Fischer
# Date:   August 12th, 2023
# Last update: August 15h, 2023
#############################################################################

path="/home/af/Dokumente/Py/knowledgeGraph/"


#*******************************************************************************
# Get list of occupations on BERUFENET (id & title) and save it to a csv-file 
#********************************************************************************
import requests
import json

response0=json.loads(requests.get("https://rest.arbeitsagentur.de/infosysbub/bnet/pc/v1/berufe?page=0&suchwoerter=*",  headers={"X-API-Key":"d672172b-f3ef-4746-b659-227c39d95acf"}).content)
totalPages=response0['page']['totalPages']

responses=[json.loads(requests.get("https://rest.arbeitsagentur.de/infosysbub/bnet/pc/v1/berufe?page="+str(p)+"&suchwoerter=*",  headers={"X-API-Key":"d672172b-f3ef-4746-b659-227c39d95acf"}).content) 
  for p in range(0,totalPages)]

berufe=[]
for i in range(0,len(responses)):
  berufe=berufe+responses[i]['_embedded']['berufSucheList']

len(berufe) #3571 at Aug 12th
ids=[berufe[i]['id'] for i in range(0,len(berufe))]
shortTitles=[berufe[i]['kurzBezeichnungNeutral'] for i in range(0,len(berufe))]

z=zip(ids,shortTitles)
with open(path+'berufe.csv', 'w', newline='') as f:
  writer = csv.writer(f)
  writer.writerow(['id', 'title'])    
  for r in [x for x in z]:
    writer.writerow(r)


#*******************************************************************************
# Get details for each opccupation on BERUFENET and save them to a json-file  
#********************************************************************************

import time

def getDetails(url):
  tries = 0
  while True:
    try:
      response = requests.get(url,  headers={"X-API-Key":"d672172b-f3ef-4746-b659-227c39d95acf"})
      print(url)
      return response
    except Exception as e:
      print("Error:", e)
      time.sleep(2 ** tries) # Wait for two times longer each time we fail
      tries += 1 

details=[json.loads(getDetails("https://rest.arbeitsagentur.de/infosysbub/bnet/pc/v1/berufe/"+str(i)).content) 
  for i in ids]

with open(path+"details.json", "w") as f:
  json.dump(details, f)


#*****************************************************************
# Extract relevant information on occupations and their relations
#*****************************************************************

import re
import csv
import json

with open(path+"details.json", "r") as f: 
   details = json.load(f)

#details[0][0]['aufstiegsweiterbildungen']
#details[0][0]['infofelder'][0] #'id': 'b30-1'

l=[len(details[i]) for i in range(0,len(details))]

ids=[]
for i in range(0,len(details)):
  if(len(details[i])==1): ids.append([details[i][0]['id']])
  if(len(details[i])==2): ids.append([details[i][0]['id'],details[i][1]['id']])

if(False): # check if every entry has at least one valid id
  min([len(i) for i in ids])
  x=[len(str(i[0])) for i in ids]
  x.index(min(x))
  ids[x.index(min(x))]

codenr=[]
for i in range(0,len(details)):
  if(len(details[i])==1): codenr.append([details[i][0]['codenr']])
  if(len(details[i])==2): codenr.append([details[i][0]['codenr'],details[i][1]['codenr']])

kldb2010=[]
for i in range(0,len(details)):
  if(len(details[i])==1): kldb2010.append([details[i][0]['kldb2010']])
  if(len(details[i])==2): kldb2010.append([details[i][0]['kldb2010'],details[i][1]['kldb2010']])

kurzbezeichnung=[]
for i in range(0,len(details)):
  if(len(details[i])==1): kurzbezeichnung.append([details[i][0]['kurzBezeichnungNeutral']])
  if(len(details[i])==2): kurzbezeichnung.append([details[i][0]['kurzBezeichnungNeutral'],details[i][1]['kurzBezeichnungNeutral']])

aufstiegsweiterbildungen=[] # CVET for occupation/work
for i in range(0,len(details)):
  if(len(details[i])==1): aufstiegsweiterbildungen.append(details[i][0]['aufstiegsweiterbildungen'])
  if(len(details[i])==2): aufstiegsweiterbildungen.append(details[i][1]['aufstiegsweiterbildungen'])

zugangsberufe=[] # prerequisite occupations for occupation/work
for i in range(0,len(details)):
  if(len(details[i])==1): 
    check=False
    for j in range(0,len(details[i][0]['infofelder'])):
      if(details[i][0]['infofelder'][j]['id']=='b30-1'): 
        zugangsberufe=zugangsberufe+[details[i][0]['infofelder'][j]['content']]
        check=True
    if(check==False): zugangsberufe=zugangsberufe+[""]
  if(len(details[i])==2): 
    check=False
    for j in range(0,len(details[i][1]['infofelder'])):
      if(details[i][1]['infofelder'][j]['id']=='b30-1'): 
        zugangsberufe=zugangsberufe+[details[i][1]['infofelder'][j]['content']]
        check=True
    if(check==False): zugangsberufe=zugangsberufe+[""]

#for each entry in zugangsberufe extract IDs from formulations such as 'ba-berufepool-extsysref data-idref="14217"':
zugangsberufeIDs=[[re.sub('(data-idref=|")','',x) for x in re.findall('data-idref="[0-9]*"',z)] for z in zugangsberufe] 

relations1csv=[] 
for i in range(0,len(details)):
  if (len(zugangsberufeIDs[i])>0): relations1csv=relations1csv+[(str(z)," qualifiesFor ",str(ids[i][-1])) for z in zugangsberufeIDs[i]]

len(relations1csv)

#for each entry in aufstiegsweiterbildungen extract IDs such as aufstiegsweiterbildungen[0][0]['id']:
aufstiegsweiterbildungenIDs=[[x['id'] for x in a] for a in aufstiegsweiterbildungen]

relations2csv=[] 
for i in range(0,len(details)):
  if (len(aufstiegsweiterbildungenIDs[i])>0): relations2csv=relations2csv+[(str(ids[i][-1])," qualifiesFor ",str(a)) for a in aufstiegsweiterbildungenIDs[i]]

len(relations2csv)

with open(path+'relations1.csv', 'w', newline='') as f:
  writer = csv.writer(f)
  writer.writerow(['node1', 'relation', 'node2'])    
  for r in relations1csv:
    writer.writerow(r)

with open(path+'relations2.csv', 'w', newline='') as f:
  writer = csv.writer(f)
  writer.writerow(['node1', 'relation', 'node2'])    
  for r in relations2csv:
    writer.writerow(r)

with open(path+'relations.csv', 'w', newline='') as f:
  writer = csv.writer(f)
  writer.writerow(['node1', 'relation', 'node2'])    
  for r in relations1csv:
    writer.writerow(r)
  for r in relations2csv:
    writer.writerow(r)
    
z=zip(l,ids,codenr,kldb2010,kurzbezeichnung,aufstiegsweiterbildungen,zugangsberufe,aufstiegsweiterbildungenIDs,zugangsberufeIDs)
with open(path+'berufeInfos.csv', 'w', newline='') as f:
  writer = csv.writer(f)
  writer.writerow(['l','ids','codenr','kldb2010','kurzbezeichnung','aufstiegsweiterbildungen','zugangsberufe','aufstiegsweiterbildungenIDs','zugangsberufeIDs'])    
  for r in [x for x in z]:
    writer.writerow(r)


#***********************
# Variant 1: Graphviz
#***********************

import graphviz
import csv
relations=[]
with open(path+'relations.csv', newline='') as csvfile:
    doc = csv.reader(csvfile, delimiter=',', quotechar=' ')
    for row in doc:
        relations.append(row)

myRelations=[]
for r in relations: # select all relations of "IT-economist" (id 15322 & 15323)
  if(r[0]=="15323" or r[2]=="15323" or r[0]=="15322" or r[2]=="15322"): myRelations.append(r)

#myRelations=relations[1:500]

f = graphviz.Digraph(filename = path+"graphviz_graph.gv")
names = list(set([r[0] for r in myRelations]+[r[2] for r in myRelations]))
labels = names
colors = ["white" for n in names]

#names = ["A","B","C","D","E","F","G","H"]
#labels = ['IT-Ökonom/in\nAusbildung','IT-Ökonom/in', 'Informatiker/in\n(Weiterbildung)', 'Wirtschafts-\ninformatiker/in\n- IT-Systeme','Wirtschafts-\ninformatik\n(grundständig)', 'Informatik\n(grundständig)' ]
#colors = ['red','green','red','red','blue','blue']
#f.edge("A","B",label=" QualifiesFor",fontsize="8"); f.edge("B","C",label=" QualifiesFor",fontsize="8"); f.edge("B","D",label=" QualifiesFor",fontsize="8"); f.edge("B","E",label=" QualifiesFor",fontsize="8"); f.edge("B","F",label=" QualifiesFor",fontsize="8")

for relation in myRelations:
  f.edge(relation[0],relation[2],label=relation[1],fontsize="8");

for name, label, color in zip(names, labels,colors): 
  f.node(name, label, color=color, style = "filled")

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


