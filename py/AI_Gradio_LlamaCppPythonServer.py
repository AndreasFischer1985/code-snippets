#########################################################################################
# Title:  Gradio Interface to LLM-chatbot with on premises 
# Author: Andreas Fischer
# Date:   October 15th, 2023
# Last update: January 21st, 2024
##########################################################################################

#https://github.com/abetlen/llama-cpp-python/issues/306
#sudo apt install libclblast-dev
#CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 pip install llama-cpp-python --force-reinstall --upgrade --no-cache-dir -v

# Get model 
#-----------

import os
import requests

##modelPath="/home/af/gguf/models/phi-2.Q4_0.gguf"
#modelPath="/home/af/gguf/models/openchat-3.5-0106.Q4_0.gguf"
modelPath="/home/af/gguf/models/SauerkrautLM-7b-HerO-q8_0.gguf"
#modelPath="/home/af/gguf/models/sauerkrautlm-una-solar-instruct.Q4_0.gguf"
#modelPath="/home/af/gguf/models/decilm-7b-uniform-gqa-q8_0.gguf"
#modelPath="/home/af/gguf/models/mixtral-8x7b-instruct-v0.1.Q4_0.gguf"
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
command = ["python3", "-m", "llama_cpp.server", "--model", modelPath, "--host", "0.0.0.0", "--port", "2600", "--n_threads", "4", "--n_gpu_layers","33"]
subprocess.Popen(command)
print("Server ready!")



# Gradio-GUI
#------------

import gradio as gr
import requests
import json
def response(message, history):
  prompt=message
  system="Du bist ein KI-basiertes Assistenzsystem."
  if("mixtral-8x7b-instruct" in modelPath): 
    prompt=f"[INST] {prompt} [/INST]"
  if("Mistral-7B-Instruct" in modelPath): 
    prompt=f"[INST] {prompt} [/INST]"
  if("openchat-3.5" in modelPath):
    prompt=f"GPT4 Correct User: {system} {prompt}<|end_of_turn|>GPT4 Correct Assistant:"
  if("SauerkrautLM-7b-HerO" in modelPath):    
    prompt=f"<|im_start|>system\n{system}<|im_end|>\n<|im_start|>user\n{prompt}<|im_end|>\n<|im_start|>assistant\n"
  if("WizardLM-13B-V1.2" in modelPath):
    prompt=f"{system} USER: {prompt} ASSISTANT: "
  if("phi-2" in modelPath):
    prompt=f"Instruct: {prompt}\nOutput:"
  print(prompt)
  #url="https://afischer1985-wizardlm-13b-v1-2-q4-0-gguf.hf.space/v1/completions"
  url="http://0.0.0.0:2600/v1/completions"  
  body={"prompt":prompt,"max_tokens":1000, "echo":"False","stream":"True"} #e.g. Mixtral-Instruct
  response=""
  buffer=""
  print("URL: "+url)
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

gr.ChatInterface(response, chatbot=gr.Chatbot(render_markdown=True),title="AI-Interface").queue().launch(share=True) #False, server_name="0.0.0.0", server_port=7864)
print("Interface up and running!")
