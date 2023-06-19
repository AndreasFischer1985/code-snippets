#############################################################################################
# Title: How to use Free & Open Source Large Language Models locally on Debian 12 via Python
# Author: Andreas Fischer
# Date: June 19th, 2023
# last update: June 19th, 2023
#############################################################################################


# prepare Debian 12 and add GPU drivers
#---------------------------------------
usermod -aG sudo username
sudo systemctl status ssh
lspci
nano /etc/apt/sources.list # manually add bookworm main contrib non-free non-free-firmware
sudo apt update && sudo apt full upgrade -y
sudo apt install nvidia-driver firmware-misc-nonfree
systemctl reboot
nvidia-smi


# install stuff via apt
#----------------------.
sudo apt install git rsync
sudo apt install r-base r-base-dev r-cran-devtools
sudo apt install python3 python3-pip python3-venv


# prepare python env
#--------------------
python3 -m venv .venv/ai
#.venv/ai/bin/pip install torch  
#.venv/ai/bin/python3
source .venv/ai/bin/activate
echo "source .venv/ai/bin/activate" >> ~/.bash_aliases
echo "alias env='source .venv/ai/bin/activate'" >> ~/.bash_aliases


# install python packages
#-------------------------
pip install torch sentence-transformers transformers ctransformers langchain diffusers llama-cpp-python accelerate protobuf pandas numpy
#CT_CUBLAS=1 pip install ctransformers --no-binary ctransformers


# Instructor-xl test embeddings (1)
#-----------------------------------

echo "Akademische und vergleichbare Fachkräfte für Datenbanken und Netzwerke">"categories.txt" 
echo "PHP: Techniken und Grundsätze der Softwareentwicklung wie Analyse, Algorithmen, Programmierung, Testen und Kompilieren von Programmierparadigmen in PHP.">>"categories.txt" 
echo "Datenbankentwickler und -administratoren">>"categories.txt" 
echo "Design und Verwaltung von Datenbanken und Netzwerken">>"categories.txt"
echo "JavaScript: Techniken und Grundsätze der Softwareentwicklung wie Analyse, Algorithmen, Programmierung, Testen und Kompilieren von Programmierparadigmen in JavaScript.">>"categories.txt" 

echo '
from datetime import datetime
import numpy as np
from InstructorEmbedding import INSTRUCTOR
file="categories.txt"
file = open(file, "r")
lines=file.readlines()
model = INSTRUCTOR("hkunlp/instructor-large") #xl
model._target_device # device(type="cuda")
instruction = "Represent the document for retrieval: "
sentences=[instruction+sentence for sentence in lines]
then = datetime.datetime.now()
embeddings = model.encode(sentences)
now = datetime.datetime.now()
print(now-then)
print(embeddings)
np.save("embeddings_categories",embeddings)
'|python

# Instructor-xl test embeddings (2)
#-----------------------------------
echo '
import numpy as np
import pandas as pd
file="categories.txt"
file = open(file, "r")
lines=file.readlines()
from InstructorEmbedding import INSTRUCTOR
embeddings=np.load("embeddings_categories.npy")

model = INSTRUCTOR("hkunlp/instructor-large") #xl
model._target_device # device(type="cuda")
string="Fachinformatiker:in, Daten und Prozessanalyse - Teilqualifizierung 5 - Datenbank; Datenbankgrundlagen; Datenbankmanagement mit My SQL; Objektorientiertes PHP; Weiterführende Programmiertechniken mit Java Script"

strings=[string]
strings.extend(string.split("; "))
instruction = "Represent the document for retrieval: "
sentences=[instruction+sentence for sentence in strings]
embeddings2=model.encode(sentences)

from sentence_transformers import util
#cosine=util.pytorch_cos_sim(embeddings1[0],embeddings2[1]).numpy()[0][0]
cosines=[[util.pytorch_cos_sim(e1,e2).numpy()[0][0] for e1 in embeddings] for e2 in embeddings2]

ids=[np.argsort(sim)[::-1].tolist() for sim in cosines] 
bestFits=[lines[id[0]] for id in ids]
bestSims=[np.sort(sim)[::-1].tolist()[0] for sim in cosines] 

df = pd.DataFrame(data={"text":strings,"best match":bestFits, "similarity":bestSims})
df.to_csv("table.csv")
'|python
 

# Flan-T5 - test Transformers
#------------------------------
echo '
import torch
from datetime import datetime
from transformers import pipeline
cuda = int(torch.cuda.is_available())-1
print(cuda)
model = "google/flan-t5-large"
prompt = "What is the meaning of my life?"
bot = pipeline(model=model,device=cuda) # use GPU (0) if available, CPU (-1) otherwise
#bot.save_pretrained("google_flan-t5-large")
then = datetime.now()
response = bot(prompt)
now = datetime.now()
print(now-then)
print("Prompt:\n"+prompt+"\n\nResponse:\n"+response[0]["generated_text"]+"\n\nduration:"+str(now-then)) 
# to be a good person
'|python


# WizardLM - test ggml-weights in llama.cpp
#------------------------------------------
wget https://huggingface.co/TheBloke/wizardLM-7B-GGML/resolve/main/wizardLM-7B.ggmlv3.q4_0.bin -P ~/ggml/models
echo '
from datetime import datetime
from llama_cpp import Llama
model="~/ggml/models/wizardLM-7B.ggmlv3.q4_0.bin"
llamallm = Llama(model_path=model,n_ctx=2048)
then = datetime.now()
response = llamallm("What is the meaning of life?", max_tokens=100, echo=True)
now = datetime.now()
print(now-then) 
print(response)
'|python


# MPT-Storywriter - test ggml-weights in ctransformers
#------------------------------------------------------
wget https://huggingface.co/TheBloke/MPT-7B-Storywriter-GGML/resolve/main/mpt-7b-storywriter.ggmlv3.q4_0.bin -P ~/ggml/models
echo '
from datetime import datetime
from ctransformers import AutoModelForCausalLM
#model="~/ggml/models/wizardLM-7B.ggmlv3.q4_0.bin" #model_type="llama"
model="~/ggml/models/mpt-7b-storywriter.ggmlv3.q4_0.bin"
llm = AutoModelForCausalLM.from_pretrained(model, model_type="mpt")
then = datetime.now()
response = llm("What is the meaning of life?")
now = datetime.now()
print(now-then)
print(response) 
'|python


# StableDiffusion - test Diffusers
#---------------------------------
echo '
import torch
if(if torch.cuda.is_available()==False):
  
  from datetime import datetime
  from diffusers import StableDiffusionPipeline
  model="stabilityai/stable-diffusion-2-1" #"prompthero/openjourney-v4"
  pipe = StableDiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-2-1")
  #pipe.save_pretrained("stabilityai_stable-diffusion-2-1")
  #pipe.to("cuda") 
  prompt = "a photograph of an astronaut riding a horse"
  then = datetime.datetime.now()
  image = pipe(prompt).images[0]
  now = datetime.now()
  print(now-then) 
  image.save(f"astronaut_rides_horse.png")
  
else:
  
  import torch
  from datetime import datetime
  from diffusers import StableDiffusionPipeline
  pipe = StableDiffusionPipeline.from_pretrained("CompVis/stable-diffusion-v1-4", revision="fp16", torch_dtype=torch.float16)
  #pipe.save_pretrained("stabilityai_stable-diffusion-2-1_f16")
  pipe.to("cuda") 
  prompt = "a photograph of an astronaut riding a horse"
  then = datetime.now()
  image = pipe(prompt).images[0]
  now = datetime.now()
  print(now-then)
  image.save(f"astronaut_rides_horse_sd_f16.png") 

'|python


# Hermes-OpenLlama
#------------------ 

echo '
pip install protobuf==3.20.1 --ignore-installed
from transformers import AutoTokenizer, AutoModelForCausalLM
tokenizer = AutoTokenizer.from_pretrained("conceptofmind/Hermes-Open-Llama-7b-8k")
model = AutoModelForCausalLM.from_pretrained("conceptofmind/Hermes-Open-Llama-7b-8k")
model("What ist the meaning of life?")
'|python

