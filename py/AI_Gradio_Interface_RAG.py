#########################################################################################
# Title:  Gradio Interface to LLM-chatbot with RAG-funcionality and ChromaDB on premises 
# Author: Andreas Fischer
# Date:   October 15th, 2023
# Last update: December 15th, 2023
##########################################################################################


# Set paths
#-----------

dbPath="/home/af/Schreibtisch/gradio/Chroma/db" #"/home/user/app/db"
#modelPath="/home/af/gguf/models/SauerkrautLM-7b-HerO-q8_0.gguf"
modelPath="/home/af/gguf/models/mixtral-8x7b-instruct-v0.1.Q4_0.gguf"


# Chroma-DB
#-----------

import chromadb
#client = chromadb.Client()
path=dbPath
client = chromadb.PersistentClient(path=path)
print(client.heartbeat()) 
print(client.get_version())  
print(client.list_collections()) 
from chromadb.utils import embedding_functions
default_ef = embedding_functions.DefaultEmbeddingFunction()
sentence_transformer_ef = embedding_functions.SentenceTransformerEmbeddingFunction(model_name="T-Systems-onsite/cross-en-de-roberta-sentence-transformer")
#instructor_ef = embedding_functions.InstructorEmbeddingFunction(model_name="hkunlp/instructor-large", device="cuda")
print(str(client.list_collections()))

global collection
if("name=ChromaDB1" in str(client.list_collections())):
  print("ChromaDB1 found!")
  collection = client.get_collection(name="ChromaDB1", embedding_function=sentence_transformer_ef)
else:
  print("ChromaDB1 created!")
  collection = client.create_collection(
    "ChromaDB1",
    embedding_function=sentence_transformer_ef,
    metadata={"hnsw:space": "cosine"})
  
  collection.add(
    documents=["The meaning of life is to love.", "This is a sentence", "This is a sentence too"], 
    metadatas=[{"source": "notion"}, {"source": "google-docs"}, {"source": "google-docs"}], 
    ids=["doc1", "doc2", "doc3"], 
  )

print(collection.count()) 


# Gradio-GUI
#------------

import gradio as gr
import requests
import random
import json
def response(message, history):
  addon=""
  results=collection.query(
    query_texts=[message],
    n_results=2,
    #where={"source": "google-docs"}
    #where_document={"$contains":"search_string"}
  )
  results=results['documents'][0]
  print(results)
  if(len(results)>1):
    addon=" Bitte berücksichtige bei deiner Antwort ggf. folgende Auszüge aus unserer Datenbank, sofern sie für die Antwort erforderlich sind. Ingoriere unpassende Auszüge unkommentiert:\n"+"\n".join(results)+"\n\n"
  #url="https://afischer1985-wizardlm-13b-v1-2-q4-0-gguf.hf.space/v1/completions"
  url="http://localhost:2600/v1/completions"
  system="Du bist ein KI-basiertes Assistenzsystem."+addon+"\n\n"  
  #body={"prompt":system+"### Instruktion:\n"+message+"\n\n### Antwort:","max_tokens":500, "echo":"False","stream":"True"} #e.g. SauerkrautLM
  body={"prompt":"<s>[INST]"+system+"\n"+message+"[/INST]### Antwort:","max_tokens":500, "echo":"False","stream":"True"} #e.g. Mixtral-Instruct
  response=""
  buffer=""
  print("URL: "+url)
  print(str(body))
  print("User: "+message+"\nAI: ")
  for text in requests.post(url, json=body, stream=True):  #-H 'accept: application/json' -H 'Content-Type: application/json'
    print("*** Raw String: "+str(text)+"\n***\n")
    text=text.decode('utf-8')
    if(text.startswith(": ping -")==False):buffer=str(buffer)+str(text)
    print("\n*** Buffer: "+str(buffer)+"\n***\n") 
    buffer=buffer.split('"finish_reason": null}]}')
    if(len(buffer)==1):
      buffer="".join(buffer)
      pass
    if(len(buffer)==2):
      part=buffer[0]+'"finish_reason": null}]}'  
      if(part.lstrip('\n\r').startswith("data: ")): part=part.lstrip('\n\r').replace("data: ", "")
      try: 
        part = str(json.loads(part)["choices"][0]["text"])
        print(part, end="", flush=True)
        response=response+part
        buffer="" # reset buffer
      except:
        pass
    yield response 

gr.ChatInterface(response).queue().launch(share=False, server_name="0.0.0.0", server_port=7864)


# Llama-cpp-Server
#------------------

import subprocess
command = ["python3", "-m", "llama_cpp.server", "--model", modelPath, "--host", "0.0.0.0", "--port", "2600"]
subprocess.run(command)
