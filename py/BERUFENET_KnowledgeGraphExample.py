#############################################################################
# Title:  Scrape data and plot a directed knowledge graph based on BERUFENET
# Author: Andreas Fischer
# Date:   August 12th, 2023
# Last update: January 4th, 2024
#############################################################################

path="/home/af/Dokumente/Py/knowledgeGraph/"


#*******************************************************************************
# Get list of occupations on BERUFENET (id & title) and save it to a csv-file 
#********************************************************************************

import requests
import json
import csv

response0=json.loads(requests.get("https://rest.arbeitsagentur.de/infosysbub/bnet/pc/v1/berufe?page=0&suchwoerter=*",  headers={"X-API-Key":"d672172b-f3ef-4746-b659-227c39d95acf"}).content)
totalPages=response0['page']['totalPages']

responses=[json.loads(requests.get("https://rest.arbeitsagentur.de/infosysbub/bnet/pc/v1/berufe?page="+str(p)+"&suchwoerter=*",  headers={"X-API-Key":"d672172b-f3ef-4746-b659-227c39d95acf"}).content) 
  for p in range(0,totalPages)]

berufe=[]
for i in range(0,len(responses)):
  berufe=berufe+responses[i]['_embedded']['berufSucheList']

len(berufe) #3571 on Aug 12th
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
      response = ""
      while(len(response)<=100):
        print("url = "+url)
        response = requests.get(url,  headers={"X-API-Key":"d672172b-f3ef-4746-b659-227c39d95acf"}).content
      print("valid response")
      return response
    except Exception as e:
      print("Error:", e)
      time.sleep(2 ** tries) # Wait for two times longer each time we fail
      tries += 1 

details=[]
for i in ids:
  x=getDetails("https://rest.arbeitsagentur.de/infosysbub/bnet/pc/v1/berufe/"+str(i))
  print("length = "+str(len(x)))
  x=json.loads(x)
  details=details+[x]

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

from itertools import chain 
details = list(chain(*details)) #simplify structure of details
len(details) #5728

#details[0]['aufstiegsweiterbildungen']
#details[0]['infofelder'][0] #'id': 'b30-1'

l=[len(details[i]) for i in range(0,len(details))]

ids=[]
for i in range(0,len(details)):
  ids.append([details[i]['id']])

codenr=[]
for i in range(0,len(details)):
  codenr.append([details[i]['codenr']])

kldb2010=[]
for i in range(0,len(details)):
  kldb2010.append([details[i]['kldb2010']])

kurzbezeichnung=[]
for i in range(0,len(details)):
  kurzbezeichnung.append([details[i]['kurzBezeichnungNeutral']])

aufstiegsweiterbildungen=[] # CVET for occupation/work
for i in range(0,len(details)):
  aufstiegsweiterbildungen.append(details[i]['aufstiegsweiterbildungen'])

zugangsberufe=[] # prerequisite occupations for occupation/work
for i in range(0,len(details)):
  check=False
  for j in range(0,len(details[i]['infofelder'])):
    if(details[i]['infofelder'][j]['id']=='b30-1'): 
      zugangsberufe=zugangsberufe+[details[i]['infofelder'][j]['content']]
      check=True
  if(check==False): zugangsberufe=zugangsberufe+[""]

#for each entry in zugangsberufe extract IDs from formulations such as 'ba-berufepool-extsysref data-idref="14217"':
zugangsberufeIDs=[[re.sub('(data-idref=|")','',x) for x in re.findall('data-idref="[0-9]*"',z)] for z in zugangsberufe] 

zugangsstudienfächer=[] # prerequisite occupations for occupation/work
for i in range(0,len(details)):
  check=False
  for j in range(0,len(details[i]['infofelder'])):
    if(details[i]['infofelder'][j]['id']=='b30-2'): 
      zugangsstudienfächer=zugangsstudienfächer+[details[i]['infofelder'][j]['content']]
      check=True
  if(check==False): zugangsstudienfächer=zugangsstudienfächer+[""]

#for each entry in zugangsstudienfächer extract IDs from formulations such as 'ba-berufepool-extsysref data-idref="14217"':
zugangsstudienfächerIDs=[[re.sub('(data-idref=|")','',x) for x in re.findall('data-idref="[0-9]*"',z)] for z in zugangsstudienfächer]

zugangsIDs=[list(set(zugangsberufeIDs[i]+zugangsstudienfächerIDs[i])) for i in range(0,len(details))]

relations1csv=[] 
for i in range(0,len(details)):
  if (len(zugangsIDs[i])>0): relations1csv=relations1csv+[(str(z)," ZugangZu ",str(ids[i][-1])) for z in zugangsIDs[i]]

len(relations1csv)
relations1csv=list(set(relations1csv))
len(relations1csv)

#for each entry in aufstiegsweiterbildungen extract IDs such as aufstiegsweiterbildungen[0][0]['id']:
aufstiegsweiterbildungenIDs=[[x['id'] for x in a] for a in aufstiegsweiterbildungen]

relations2csv=[] 
for i in range(0,len(details)):
  if (len(aufstiegsweiterbildungenIDs[i])>0): relations2csv=relations2csv+[(str(ids[i][-1])," AufstiegsmöglichkeitZu ",str(a)) for a in aufstiegsweiterbildungenIDs[i]]

len(relations2csv)
relations2csv=list(set(relations2csv))
len(relations2csv)

relations=relations1csv+relations2csv

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

z=zip(ids,codenr,kldb2010,kurzbezeichnung) # l,aufstiegsweiterbildungen,zugangsberufe,aufstiegsweiterbildungenIDs,zugangsberufeIDs,zugangsstudienfächerIDs,zugangsIDs)
with open(path+'lookup-table.csv', 'w', newline='') as f:
  writer = csv.writer(f)
  writer.writerow(['ids','codenr','kldb2010','kurzbezeichnung']) # 'l','aufstiegsweiterbildungen','zugangsberufe','aufstiegsweiterbildungenIDs','zugangsberufeIDs','zugangsstudienfächerIDs','zugangsIDs'])    
  for r in [x for x in z]:
    writer.writerow(r)

with open(path+"ids.json", "w") as f:
  json.dump(ids, f)

with open(path+"kldb2010.json", "w") as f:
  json.dump(kldb2010, f)

with open(path+"codenr.json", "w") as f:
  json.dump(codenr, f)

with open(path+"kurzbezeichnung.json", "w") as f:
  json.dump(kurzbezeichnung, f)


#***********************
# Variant 1: Graphviz
#***********************

import graphviz
import csv
import json

relations=[]
with open(path+'relations.csv', newline='') as csvfile:
    doc = csv.reader(csvfile, delimiter=',', quotechar=' ')
    for row in doc:
        relations.append(row)

with open(path+"ids.json", "r") as f: 
   ids = json.load(f)

with open(path+"kldb2010.json", "r") as f: 
   kldb2010 = json.load(f)

with open(path+"codenr.json", "r") as f: 
   codenr = json.load(f)

with open(path+"kurzbezeichnung.json", "r") as f: 
   kurzbezeichnung = json.load(f)

# gather all relations from and to ID 15323 and add relations from (but not to) the IDs above (15322,93916,93944,15325 & 7846):
queryNodes=["15323"]
myRelations=[]
for r in relations: 
  if(r[0] in queryNodes or r[2] in queryNodes): myRelations.append(r)

len(myRelations) #26
selectiveQueryNodes=["15322","93916","93944","15325","7846"]
for r in relations: 
  if(r[0] in selectiveQueryNodes): myRelations.append(r)

len(myRelations) #199

# gather only relations from and to ID 15322:
queryNodes=["15322"] 
myRelations=[]
for r in relations: 
  if(r[0] in queryNodes or r[2] in queryNodes): myRelations.append(r)

len(myRelations) #5

f = graphviz.Digraph(filename = path+"graphviz_graph.gv")
names = list(set([r[0] for r in myRelations]+[r[2] for r in myRelations]))

labels=[]
for i in range(0,len(names)):
  for j in range(0,len(ids)):
    if(str(ids[j][0])==str(names[i])): 
      labels.append(kurzbezeichnung[j][0]+"\n"+codenr[j][0]+"\nID "+str(ids[j][0]))
      break

len(names)
len(labels)

colors = ["white" for n in names]

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


