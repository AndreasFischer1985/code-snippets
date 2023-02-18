#################
# Basic Examples
#################

# Transformers
#--------------

#!/usr/bin/Rscript
require("httr")
model_id = "google/flan-t5-xl" 
payload = "Please write a step by step recipe to make bolognese pasta."
params=list("max_length"=200, "length_penalty"=2, "num_beams"=16, "early_stopping"=TRUE)
url=paste0("https://api-inference.huggingface.co/models/",model_id)
post=httr::POST(url=url, body=list("inputs"=payload, "parameters"=params), encode="json")
httr::content(post)

##!/usr/bin/env python
#import requests
#model_id = "google/flan-t5-xl" 
#payload = "Please write a step by step recipe to make bolognese pasta."
#params={"max_length":200, "length_penalty":2, "num_beams":16, "early_stopping":True}
#url = f"https://api-inference.huggingface.co/models/{model_id}"
#post = requests.post(url, json={"inputs":payload, "parameters":params})
#post.json()

##!/bin/bash
#model_id="google/flan-t5-xl" 
#payload="Please write a step by step recipe to make bolognese pasta."
#params='{"max_length":200, "length_penalty":2, "num_beams":16, "early_stopping":true}'
#url="https://api-inference.huggingface.co/models/"$model_id
#data='{"inputs":"'$payload'","parameters":'$params'}'
#post=$(curl -X POST $url -H "Content-Type: application/json" --data-raw "$data")
#echo $post


# Diffusers
#------------------

#!/usr/bin/Rscript
require("httr")
payload = "obi wan kenobi, screenshot in a typical pixar movie, disney infinity 3 star wars style, volumetric lighting, subsurface scattering, photorealistic, octane render, medium shot, studio ghibli, pixar and disney animation, sharp, rendered in unreal engine 5, anime key art by greg rutkowski and josh black, bloom, dramatic lighting"
model_id = "stabilityai/stable-diffusion-2-1"
params=list("num_inference_steps"=100)
url=paste0("https://api-inference.huggingface.co/models/",model_id)
post=httr::POST(url=url, body=list("inputs"= payload, "parameters"=params), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
 	encode="json")
img=httr::content(post)
png::writePNG(img,paste0("image_",as.numeric(Sys.time()),".png"))


#########################
# Exemplary Transformers
#########################

model_ids=c(
  "google/flan-t5-large", 
  "google/flan-t5-xl", 

  "EleutherAI/gpt-neox-20b",
  "EleutherAI/gpt-j-6B",

  "bigscience/bloom",
  "bigscience/bloom-petals",

  "bigscience/bloomz-560m",
  "bigscience/bloomz-7b1",
  "bigscience/bloomz-3b",
  "bigscience/bloomz-1b1",
  "bigscience/bloomz-1b7",

  "bigscience/T0",
  "bigscience/T0p",
  "bigscience/T0pp",
  "bigscience/T0_3B",  

  "bigscience/mt0-base",
  "bigscience/mt0-xxl",
  "bigscience/mt0-xl",

  "facebook/opt-iml-30b",
  "facebook/opt-iml-max-1.3b"
)


model_id=model_ids[1]
params=list("max_length"=100,"num_beams"=16, "early_stopping"=TRUE) #,length_penalty"=2, "min_length"=200, "return_full_text"=FALSE 
url=paste0("https://api-inference.huggingface.co/models/",model_id)
post=httr::POST(url=url, body=list("inputs"=payload, "parameters"=params), 
	#httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
	#config=httr::config(connecttimeout=3600),
	encode="json")
httr::content(post)

