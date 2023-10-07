#############################################################################
# Title:  Gradio Interface to AI hosted on Huggingface-Space
# Author: Andreas Fischer
# Date:   October 7th, 2023
# Last update: October 7th, 2023
#############################################################################

import gradio as gr
import requests
import random
import json
def response(message, history):
  url="https://afischer1985-wizardlm-13b-v1-2-q4-0-gguf.hf.space/v1/completions"
  body={"prompt":"###Frage: "+message+" ###Antwort:","max_tokens":1000,"stop":"###","stream":True} #128
  response=""
  buffer=""
  print("User: "+message+"\nAI: ")
  for text in requests.post(url, json=body, stream=True):  
    #print("*** Raw String: "+str(text)+"\n***\n")
    text=text.decode('utf-8')
    if(text.startswith(": ping -")==False):buffer=str(buffer)+str(text)
    #if(text.startswith(": ping -")): print("\n*** PING!\n***\n")
    #print("\n*** Buffer: "+str(buffer)+"\n***\n") 
    buffer=buffer.split('"finish_reason"')
    if(len(buffer)==1):
      buffer="".join(buffer)
      pass
    if(len(buffer)==2):
      part=buffer[0]+'"finish_reason": null}]}'  
      if(part.startswith("data: ")):part=part.replace("data: ", "")
      try: 
        part = str(json.loads(part)["choices"][0]["text"])
        print(part, end="", flush=True)
        response=response+part
        buffer="" # reset buffer
      except:
        pass
    yield response 

gr.ChatInterface(response).queue().launch(share=True)
