#############################################################################################
# Title: How to use Free & Open Source Large Language Models locally on Debian 12 via Python
# Author: Andreas Fischer
# Date: June 19th, 2023
# last update: December 23rd, 2023
#############################################################################################


# prepare Debian 12 and add GPU drivers
#---------------------------------------
usermod -aG sudo username
sudo systemctl status ssh
lspci
nano /etc/apt/sources.list # manually add bookworm main contrib non-free non-free-firmware
sudo apt update && sudo apt full upgrade -y
sudo apt install nvidia-driver firmware-misc-nonfree
sudo apt -y install nvidia-cuda-toolkit nvidia-cuda-dev 
systemctl reboot
nvidia-smi


# install stuff via apt
#----------------------.

sudo apt install git rsync ffmpeg
sudo apt install r-base r-base-dev r-cran-devtools
sudo apt install python3 python3-pip python3-venv
mkdir ggml
mkdir gguf


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

pip install torch sentence-transformers transformers ctransformers gradio langchain diffusers xformers llama-cpp-python accelerate protobuf pandas numpy
pip install llama-cpp-python[server] ctransformers[cuda] bitsandbytes 

#https://github.com/abetlen/llama-cpp-python/issues/306
#sudo apt install libclblast-dev
#CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 pip install llama-cpp-python --force-reinstall --upgrade --no-cache-dir -v


# Gradio-app based on gguf-model via ctransformers
#-------------------------------------------------

wget https://huggingface.co/NikolayKozloff/Marx-3B-V2-GGUF/resolve/main/Marx-3B-V2-Q4_1-GGUF.gguf -P ~/gguf/models
echo '
import torch
model="~/gguf/models/Marx-3B-V2-Q4_1-GGUF.gguf"
if(torch.cuda.is_available()==False):
  import time
  import gradio as gr
  from datetime import datetime
  from ctransformers import AutoModelForCausalLM
  llm = AutoModelForCausalLM.from_pretrained(model, model_type="llama") #,gpu_layers=40)
  then = datetime.now()
  def slow_echo(message, history):
    response=""
    for text in llm(message,stream=True):
      response=response+text
      print(text, end="", flush=True)
      yield response

  gr.ChatInterface(slow_echo).queue().launch(share=True)

else:

  import time
  import gradio as gr
  from datetime import datetime
  from ctransformers import AutoModelForCausalLM
  import torch
  import gc
  with torch.no_grad():
    torch.cuda.empty_cache()

  gc.collect()
  llm = AutoModelForCausalLM.from_pretrained(model, model_type="llama",gpu_layers=40)
  then = datetime.now()
  def slow_echo(message, history):
    response=""
    for text in llm(message,stream=True):
      response=response+text
      print(text, end="", flush=True)
      yield response

  gr.ChatInterface(slow_echo).queue().launch(share=True)
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

#response = llm("What is the meaning of life?")
response=""
for text in llm("Wie lautet die Definition von komplexem Problemlösen?",stream=True):
  response=response+text
  print(text, end="", flush=True)

now = datetime.now()
print(now-then)
print(response) 
'|python

# WizardLM-1.0-uncensored-llama2-13b - test gguf-weights in llama.cpp
#---------------------------------------------------------------------

wget https://huggingface.co/TheBloke/WizardLM-1.0-Uncensored-Llama2-13B-GGUF/resolve/main/wizardlm-1.0-uncensored-llama2-13b.Q4_0.gguf -P ~/gguf/models
echo '

from datetime import datetime
from llama_cpp import Llama
model="/home/af/ggml/models/wizardlm-1.0-uncensored-llama2-13b.Q4_0.gguf"
llamallm = Llama(model_path=model,n_ctx=4096)
then = datetime.now()
template="""### Instruction:
{prompt}

### Response:
"""
response = llamallm(template.format(prompt="Was ist die Definition von komplexem Problemlösen?"), max_tokens=100, echo=False)
now = datetime.now()
print(now-then) 
print(response) 
'|python


# OpenLlama - start OpenLlama-server
#-----------------------------------

wget https://huggingface.co/SlyEcho/open_llama_7b_v2_gguf/resolve/main/open-llama-7b-v2-q4_0.gguf -P ~/gguf/models
pip install llama-cpp-python[server]
export MODEL="~/ggml/models/open-llama-7b-v2-q4_0.gguf" HOST=0.0.0.0 PORT=2600
python3 -m llama_cpp.server

  # curl http://localhost:2600/v1/completions -H "Content-Type: application/json" -d '{"prompt": "Im Folgenden findest du eine Instruktion, die eine Aufgabe bescheibt. Schreibe eine Antwort, um die Aufgabe zu lösen.\n\n### Instruktion:\nWas ist die Definition von komlpexem Problemlösen?\n\n### Antwort:","max_tokens":500, "echo":"False"}'


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

 
# Roberta - test transformers for embeddings
#-------------------------------------------

echo '
import torch
import numpy as np
from datetime import datetime
from transformers import pipeline
cuda = int(torch.cuda.is_available())-1
print(cuda)
model = "T-Systems-onsite/cross-en-de-roberta-sentence-transformer"
text = "What is the meaning of my life?"
bot = pipeline(model=model,device=cuda) # use GPU (0) if available, CPU (-1) otherwise
#bot.save_pretrained("T-Systems-onsite_cross-en-de-roberta-sentence-transformer")
then = datetime.now()
embedding = bot(text)
now = datetime.now()
print(now-then)
print("Text:\n"+text+"\n\nEmbedding:\n"+str(embedding)+"\n\nduration:"+str(now-then)) 
embedding=np.mean(embedding,axis=1)[0]
# embeddings = bot(texts)
# embeddings=[np.mean(x,axis=1)[0] for x in embeddings]
'|python


# Flan-T5 - test transformers
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


# StableDiffusion - test Diffusers
#---------------------------------

echo '
import torch
if(if torch.cuda.is_available()==False):
  
  from datetime import datetime
  from diffusers import DiffusionPipeline
  model="stabilityai/stable-diffusion-2-1" # "stabilityai/sdxl-turbo", "prompthero/openjourney-v4"
  pipe = DiffusionPipeline.from_pretrained(model)
  #pipe.save_pretrained("stabilityai_stable-diffusion-2-1")
  #pipe.to("cuda") 
  prompt = "a photograph of an astronaut riding a horse"
  then = datetime.now()
  image = pipe(prompt).images[0]
  now = datetime.now()
  print(now-then) 
  image.save(f"astronaut_rides_horse.png")
  
else:
  
  import torch
  from datetime import datetime
  from diffusers import DiffusionPipeline
  model="stabilityai/stable-diffusion-2-1" # "stabilityai/sdxl-turbo", "prompthero/openjourney-v4"
  pipe = DiffusionPipeline.from_pretrained(model, torch_dtype=torch.float16)
  #pipe.save_pretrained("stabilityai_stable-diffusion-2-1_f16")
  pipe.to("cuda") 
  #pipe.enable_xformers_memory_efficient_attention()
  #pipe.enable_attention_slicing()
  prompt = "a photograph of an astronaut riding a horse"
  then = datetime.now()
  image = pipe(prompt).images[0]
  now = datetime.now()
  print(now-then)
  image.save(f"astronaut_rides_horse_sd_f16.png") 

'|python


# StableDiffusion + Dreambooth
#------------------------------

pip install -U autotrain-advanced
autotrain setup --update-torch
autotrain dreambooth --help
autotrain dreambooth \
  --model /home/af/stable-diffusion-2-1_float16/ \
  --project-name /home/af/customSD/ \
  --image-path /home/af/Bilder/AFischer1985/ \
  --prompt "AFischer1985" \
  --resolution 512 \
  --batch-size 1 \
  --num-steps 1000 \
  --fp16 \
  --gradient-accumulation 4 \
  --lr 1e-4

echo '  
    
  from diffusers import DiffusionPipeline, StableDiffusionXLImg2ImgPipeline
  import torch

  model = "/home/af/stable-diffusion-2-1_float16/" #"stabilityai/stable-diffusion-xl-base-1.0"
  pipe = DiffusionPipeline.from_pretrained(
    model,
    torch_dtype=torch.float16,
  )
  pipe.to("cuda")
  pipe.load_lora_weights("/home/af/customSD/", weight_name="pytorch_lora_weights.safetensors")
    
  #refiner = StableDiffusionXLImg2ImgPipeline.from_pretrained(
  #  "stabilityai/stable-diffusion-xl-refiner-1.0",
  #  torch_dtype=torch.float16,
  #)
  #refiner.to("cuda")
    
  prompt = "a close front shot of an AFischer1985 image standing at train station.Vintage-style travel photography of a train station in Europe, with passengers and old luggage. Ensure that his face is clear and expressive. ultra, 4k, HD"  
  prompt = "generate an image of a confident and professional-looking AFischer1985 standing in an office setting. Ensure that his face is clear and expressive, exuding a sense of competence and determination. ultra fine details."
  negative_prompt=""

  for seed in range(100):
    generator = torch.Generator("cuda").manual_seed(seed)
    image = pipe(prompt=prompt,negative_prompt=negative_prompt,guidance_scale=15, generator=generator, num_inference_steps=100)
    image = image.images[0]
    image.save(f"/home/af/customSD/images/{seed}.png")
    #image = refiner(prompt=prompt, generator=generator, image=image)
    #image = image.images[0]
    #image.save(f"images_refined/{seed}.png")

'|python


# Würstchen v2
#--------------

echo '
import torch
if(if torch.cuda.is_available()==False):

  import torch
  from diffusers import AutoPipelineForText2Image
  from diffusers.pipelines.wuerstchen import DEFAULT_STAGE_C_TIMESTEPS
  import gc
  pipe = AutoPipelineForText2Image.from_pretrained("warp-ai/wuerstchen") 
  #pipe.save_pretrained("warp-ai_wuerstchen")
  prompt = "Anthropomorphic cat dressed as a fire fighter"
  images = pipe(
    prompt, 
    width=1024,
    height=1536,
    prior_timesteps=DEFAULT_STAGE_C_TIMESTEPS,
    prior_guidance_scale=4.0,
    num_images_per_prompt=2,
  ).images
  for i in range(1): 
    images[i].save(f"wuerstchen-v2-pic"+str(i)+".png")

else:
  
  import torch
  import gc
  from datetime import datetime
  from diffusers import AutoPipelineForText2Image
  from diffusers.pipelines.wuerstchen import DEFAULT_STAGE_C_TIMESTEPS
  torch.cuda.empty_cache()
  gc.collect()
  pipe = AutoPipelineForText2Image.from_pretrained("warp-ai/wuerstchen") #, torch_dtype=torch.float16)
  #pipe.save_pretrained("warp-ai_wuerstchen")
  pipe.to("cuda") 
  prompt = "Anthropomorphic cat dressed as a fire fighter"
  then = datetime.now()
  images = pipe(
    prompt, 
    width=1024,
    height=1536,
    prior_timesteps=DEFAULT_STAGE_C_TIMESTEPS,
    prior_guidance_scale=4.0,
    num_images_per_prompt=2,
  ).images
  now = datetime.now()
  print(now-then)
  for i in range(1): 
    images[i].save(f"wuerstchen-v2-cuda-pic"+str(i)+".png")

'|python


# SDXL - test Diffusers
#-----------------------
echo '
from diffusers import StableDiffusionXLPipeline
import torch
import gc
pipe = StableDiffusionXLPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, variant="fp16", # use_safetensors=True
)
#pipe.save_pretrained("stabilityai_stable-diffusion-xl-base-1.0")
torch.cuda.empty_cache()
gc.collect()
pipe.to("cuda")
prompt = "Astronaut in a jungle, cold color palette, muted colors, detailed, 8k"
image = pipe(prompt=prompt).images[0]
image.save(f"astronaut_in_a_jungle.png")

# Use refiner:
from diffusers import DiffusionPipeline
import torch
base = DiffusionPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, variant="fp16", use_safetensors=True
)
base.to("cuda")
refiner = DiffusionPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-refiner-1.0",
    text_encoder_2=base.text_encoder_2,
    vae=base.vae,
    torch_dtype=torch.float16,
    use_safetensors=True,
    variant="fp16",
)
refiner.to("cuda")
n_steps = 40
high_noise_frac = 0.8
prompt = "Astronaut in a jungle, cold color palette, muted colors, detailed, 8k"
image = base(
    prompt=prompt,
    num_inference_steps=n_steps,
    denoising_end=high_noise_frac,
    output_type="latent",
).images
image = refiner(
    prompt=prompt,
    num_inference_steps=n_steps,
    denoising_start=high_noise_frac,
    image=image,
).images[0]
image.save(f"astronaut_in_a_jungle2.png")
'|python


# SDXL-turbo
#------------
echo '
from diffusers import StableDiffusionXLPipeline
pipe = StableDiffusionXLPipeline.from_pretrained("stabilityai/sdxl-turbo") #, torch_dtype=torch.float16, variant="fp16")
#pipe.save_pretrained("stabilityai_sdxl-turbo")
#pipe.to("cuda")
prompt = "Astronaut in a jungle, cold color palette, muted colors, detailed, 8k"
image = pipe(prompt=prompt, num_inference_steps=1, guidance_scale=0.0).images[0]
image.save(f"astronaut_in_a_jungle_turbo.png")

from diffusers import StableDiffusionXLImg2ImgPipeline
from diffusers.utils import load_image
pipe = StableDiffusionXLImg2ImgPipeline.from_pretrained("stabilityai/sdxl-turbo") #"/home/af/stabilityai_sdxl-turbo"
init_image = load_image("https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/diffusers/cat.png").resize((512, 512))
prompt = "cat wizard, gandalf, lord of the rings, detailed, fantasy, cute, adorable, Pixar, Disney, 8k"
strength=0.4 # make sure num_inference_steps * strength is larger or equal to 1
image = pipe(prompt, image=init_image, num_inference_steps=round(1/strength+0.5)*1, strength=strength, guidance_scale=0.0).images[0]
image.save(f"cat_wizard_turbo.png")
'|python


# Whisper - test audio-transcription
#-----------------------------------
echo '
import torch
from transformers import AutoModelForSpeechSeq2Seq, AutoProcessor, pipeline
#from datasets import load_dataset
from datetime import datetime

device = "cuda:0" if torch.cuda.is_available() else "cpu"
torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32

model_id = "openai/whisper-large-v3"

model = AutoModelForSpeechSeq2Seq.from_pretrained(
    model_id, torch_dtype=torch_dtype, low_cpu_mem_usage=True, use_safetensors=True
)
model.to(device)

processor = AutoProcessor.from_pretrained(model_id)

pipe = pipeline(
    "automatic-speech-recognition",
    model=model,
    tokenizer=processor.tokenizer,
    feature_extractor=processor.feature_extractor,
    max_new_tokens=128,
    chunk_length_s=30,
    batch_size=8, #16
    return_timestamps=True,
    torch_dtype=torch_dtype,
    device=device,
)

#dataset = load_dataset("distil-whisper/librispeech_long", "clean", split="validation")
#sample = dataset[0]["audio"]
then = datetime.now()
result = pipe("/home/af/Musik/Interviews/Interview.mp3", generate_kwargs={"language": "german"})
now = datetime.now()
print(now-then)
print(result["text"])

result["text"]
result["chunks"]

with open("/home/af/Musik/Interviews/transkript.txt", mode="w", encoding="utf-8") as file:
    # Write the string to the file
    file.write(result["text"])
    
import csv
keys = result["chunks"][0].keys()
with open("/home/af/Musik/Interviews/transkript.csv", "w", newline="", encoding="utf-8") as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(result["chunks"])
'|python

# Bark - test audio-generation
#------------------------------

echo '
from transformers import AutoProcessor, AutoModel, BarkModel
processor = AutoProcessor.from_pretrained("suno/bark")
#model = AutoModel.from_pretrained("suno/bark")
model = BarkModel.from_pretrained("suno/bark", torch_dtype=torch.float16).to("cuda")
# model.save_pretrained("/home/af/suno_bark")
inputs = processor(
    text=["Hallo Welt."],
    return_tensors="pt",
    voice_preset="v2/de_speaker_8"
)
inputs = inputs.to("cuda")
speech_values = model.generate(**inputs, do_sample=True) #tensor([[ 1.2337e-03,  6.6125e-04,  1.0219e-03,  ..., -5.1628e-05, -1.1722e-04, -7.7545e-05]])
import torchaudio
audio_tensor = speech_values.to("cpu") 
audio_tensor = audio_tensor .to(torch.float32)
torchaudio.save("output.wav", audio_tensor, sample_rate=model.generation_config.sample_rate)
'|python


# xTTS - test voice-cloning
#---------------------------
python3 -m pip install TTS
echo '
from TTS.api import TTS
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2", gpu=True)
tts.tts_to_file(text="Es hat viel Zeit gekostet, eine Stimme zu entwickeln und nun, da ich sie habe, werde ich nicht länger schweigen.",
                file_path="output_de.wav",
                speaker_wav="/home/af/Musik/speech_sample.wav",
                language="de")
'|python
