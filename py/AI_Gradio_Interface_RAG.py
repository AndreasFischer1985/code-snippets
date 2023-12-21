#########################################################################################
# Title:  Gradio Interface to LLM-chatbot with RAG-funcionality and ChromaDB on premises 
# Author: Andreas Fischer
# Date:   October 15th, 2023
# Last update: December 21th, 2023
##########################################################################################


# Get model 
#-----------

import os
import requests

dbPath="/home/af/Schreibtisch/gradio/Chroma/db" 
if(os.path.exists(dbPath)==False): 
  dbPath="/home/user/app/db"

print(dbPath)

#modelPath="/home/af/gguf/models/SauerkrautLM-7b-HerO-q8_0.gguf"
modelPath="/home/af/gguf/models/mixtral-8x7b-instruct-v0.1.Q4_0.gguf"
if(os.path.exists(modelPath)==False):
  #url="https://huggingface.co/TheBloke/WizardLM-13B-V1.2-GGUF/resolve/main/wizardlm-13b-v1.2.Q4_0.gguf"
  #url="https://huggingface.co/TheBloke/Mixtral-8x7B-Instruct-v0.1-GGUF/resolve/main/mixtral-8x7b-instruct-v0.1.Q4_0.gguf?download=true"
  url="https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_0.gguf?download=true"
  response = requests.get(url)
  with open("./model.gguf", mode="wb") as file:
    file.write(response.content)
  print("Model downloaded")  
  modelPath="./model.gguf"

print(modelPath)


# Llama-cpp-Server
#------------------

import subprocess
command = ["python3", "-m", "llama_cpp.server", "--model", modelPath, "--host", "0.0.0.0", "--port", "2600"]
subprocess.Popen(command)
print("Server ready!")


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

print("Database ready!")
print(collection.count()) 


# Gradio-GUI
#------------

import gradio as gr
import requests
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
  body={"prompt":"[INST]"+system+"\n"+message+"[/INST]","max_tokens":500, "echo":"False","stream":"True"} #e.g. Mixtral-Instruct
  response=""
  buffer=""
  print("URL: "+url)
  print(str(body))
  print("User: "+message+"\nAI: ")
  for text in requests.post(url, json=body, stream=True):  #-H 'accept: application/json' -H 'Content-Type: application/json'
    if buffer is None: buffer=""
    buffer=str("".join(buffer))
    #print("*** Raw String: "+str(text)+"\n***\n")
    text=text.decode('utf-8')
    if((text.startswith(": ping -")==False) & (len(text.strip("\n\r"))>0)): buffer=buffer+str(text)
    #print("\n*** Buffer: "+str(buffer)+"\n***\n") 
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
      except Exception as e:
        print("Exception:"+str(e))
        pass
    yield response 

gr.ChatInterface(response).queue().launch(share=True) #False, server_name="0.0.0.0", server_port=7864)
print("Interface up and running!")
